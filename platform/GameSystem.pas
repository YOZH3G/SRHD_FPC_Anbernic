unit GameSystem;

{$MODE OBJFPC}
{$H+}

interface

type
  TGameMemoryStatus = packed record
    Length, MemoryLoad: Cardinal;
    TotalPhys, AvailPhys, TotalPageFile, AvailPageFile: QWord;
    TotalVirtual, AvailVirtual, AvailExtendedVirtual: QWord;
  end;

function CopyGameFile(const Source, Dest: UnicodeString): Boolean;
function QueryGameMemory(out Status: TGameMemoryStatus): Boolean;
function LockGameInstance: Boolean;

function GameTickCount: Cardinal;
function GameCpuClockMHz: Double;
function GameOperatingSystemDescription: UnicodeString;
function GameUserDirectory: UnicodeString;
function SameGamePathName(const Left, Right: UnicodeString): Boolean;
function NativeGamePath(const Path: UnicodeString): UnicodeString;
// Return a backslash-separated game key with on-disk spelling below an absolute,
// already-resolved native Root. This does not resolve symbolic links.
function ResolveGameRelativePath(const Root, RelativePath: UnicodeString): UnicodeString;
procedure SetGameDirectory(const Path: UnicodeString);
procedure SetGameUserDirectory(const Path: UnicodeString);
function GameNativeExceptionDetails(E: TObject): UnicodeString;

implementation

uses
  SysUtils,
  Classes,
  Math,
  SDL2
{$IFDEF UNIX}
  ,
  BaseUnix,
  Unix
{$ENDIF}
{$IFDEF DARWIN}
  ,
  SysCtl,
  UnixType
{$ENDIF}
{$IFDEF MSWINDOWS}
  ,
  Registry,
  Windows,
  WinDirs
{$ENDIF}
      ;

var
  UserDirectoryOverride: UnicodeString;
  InstanceFile: THandle = THandle(-1);

function GameNativeExceptionDetails(E: TObject): UnicodeString;
{$IFDEF MSWINDOWS}
var
  Code, Parameters: Cardinal;
  Address: Pointer;
  Information: array[0..2] of PtrUInt;
  I: Integer;
  Memory: TMemoryBasicInformation;
  ModulePath: array[0..1023] of WideChar;
  ModuleLength: Cardinal;
  Access: UnicodeString;
{$ENDIF}
begin
  Result := '';
{$IFDEF MSWINDOWS}
  // Pascal-raised EExternal objects have an empty native exception record.
  if not (E is EExternal) or (EExternal(E).ExceptionRecord = nil) then
    Exit;
  Code := EExternal(E).ExceptionRecord^.ExceptionCode;
  Address := EExternal(E).ExceptionRecord^.ExceptionAddress;
  Parameters := EExternal(E).ExceptionRecord^.NumberParameters;
  for I := 0 to 2 do
    if Cardinal(I) < Parameters then
      Information[I] := PtrUInt(EExternal(E).ExceptionRecord^.ExceptionInformation[I])
    else
      Information[I] := 0;
  if Code = 0 then
    Exit;
  Result := 'Native exception code=$' + IntToHex(Code, 8) + ' address=$' + IntToHex(PtrUInt(Address), SizeOf(Pointer) * 2);
  if (VirtualQuery(Address, Memory, SizeOf(Memory)) <> 0) and (Memory._Type = MEM_IMAGE) then
  begin
    ModuleLength := GetModuleFileNameW(HMODULE(Memory.AllocationBase), ModulePath, Length(ModulePath));
    if (ModuleLength > 0) and (ModuleLength < Cardinal(Length(ModulePath))) then
      Result :=
          Result
              + ' module='
              + ExtractFileName(UnicodeString(ModulePath))
              + '+$'
              + IntToHex(PtrUInt(Address) - PtrUInt(Memory.AllocationBase), 1);
  end;
  if ((Code = $C0000005) or (Code = $C0000006)) and (Parameters >= 2) then
  begin
    case Information[0] of
      0: Access := 'read';
      1: Access := 'write';
      8: Access := 'execute';
    else
      Access := UIntToStr(Information[0]);
    end;
    Result := Result + ' access=' + Access + ' target=$' + IntToHex(Information[1], SizeOf(Pointer) * 2);
    if (Code = $C0000006) and (Parameters >= 3) then
      Result := Result + ' io-status=$' + IntToHex(Information[2], 8);
  end;
{$ENDIF}
end;

{$IFDEF SWITCH}
procedure NativeSwitchMemoryStatus(out Capacity, Available: QWord); cdecl; external name 'sr_switch_memory_status';
{$ENDIF}

{$IFDEF FPC_WASM_EMSCRIPTEN}
procedure NativeWasmMemoryStatus(out Capacity, Available: QWord); cdecl; external name 'sr_fpc_memory_status';
{$ENDIF}

{$IFDEF MSWINDOWS}
// The FPC Windows unit does not declare the extended memory query.
function NativeGlobalMemoryStatusEx(var Status: TGameMemoryStatus): LongBool; stdcall; external 'kernel32.dll' name 'GlobalMemoryStatusEx';
{$ENDIF}

{$IFDEF DARWIN}
function mach_host_self: Cardinal; cdecl; external 'c';
function host_page_size(Host: Cardinal; out Size: PtrUInt): Integer; cdecl; external 'c';
function host_statistics64(Host: Cardinal; Flavor: Integer; Info: Pointer; var Count: Cardinal): Integer; cdecl; external 'c';
function mach_port_deallocate(Task, Name: Cardinal): Integer; cdecl; external 'c';
var
  mach_task_self_: Cardinal;
  cvar;
  external 'c';
{$ENDIF}

function CopyGameFile(const Source, Dest: UnicodeString): Boolean;
var
  Input, Output: TFileStream;
begin
  Result := False;
  try
    Input := TFileStream.Create(UTF8Encode(NativeGamePath(Source)), fmOpenRead or fmShareDenyNone);
    try
      Output := TFileStream.Create(UTF8Encode(NativeGamePath(Dest)), fmCreate);
      try
        Output.CopyFrom(Input, 0);
        Result := True;
      finally
        Output.Free;
      end;
    finally
      Input.Free;
    end;
  except
    on E: EStreamError do
      Result := False;
  end;
end;

function LockGameInstance: Boolean;
var
  Path: UnicodeString;
begin
  if InstanceFile <> THandle(-1) then
    Exit(True);
  ForceDirectories(GameUserDirectory);
  Path := GameUserDirectory + 'instance.lock';
{$IFDEF UNIX}
  InstanceFile := FpOpen(UTF8Encode(Path), O_CREAT or O_RDWR, &600);
  Result := (InstanceFile <> THandle(-1)) and (FpFlock(InstanceFile, LOCK_EX or LOCK_NB) = 0);
{$ELSE}
  if FileExists(Path) then
    InstanceFile := FileOpen(Path, fmOpenReadWrite or fmShareExclusive)
  else
    InstanceFile := FileCreate(Path, fmShareExclusive, 0);
  Result := InstanceFile <> THandle(-1);
{$ENDIF}
  if not Result and (InstanceFile <> THandle(-1)) then
  begin
    FileClose(InstanceFile);
    InstanceFile := THandle(-1);
  end;
end;

{$IFDEF LINUX}
function LoadProcFile(Lines: TStringList; const Path: string): Boolean;
begin
  // Android devices can restrict individual /proc files. Diagnostic queries
  // must retain their defaults rather than prevent the game from starting.
  Result := False;
  try
    Lines.LoadFromFile(Path);
    Result := True;
  except
    on E: EStreamError do
      ;
    on E: EInOutError do
      ;
  end;
end;
{$ENDIF}

function QueryGameMemory(out Status: TGameMemoryStatus): Boolean;
{$IFNDEF MSWINDOWS}
var
  Heap: TFPCHeapStatus;
  {$IFDEF DARWIN}
  Host, Count: Cardinal;
  Pages: PtrUInt;
  Stats: array[0..63] of Cardinal;
  {$ENDIF}
  {$IFDEF LINUX}
  Lines: TStringList;
  Line, Key, Value: string;
  Split: Integer;
  Bytes: QWord;
  {$ENDIF}
{$ENDIF}
begin
  Status := Default(TGameMemoryStatus);
  Status.Length := SizeOf(Status);
{$IF defined(FPC_WASM_EMSCRIPTEN) or defined(SWITCH)}
  Heap := GetFPCHeapStatus;
  {$IFDEF SWITCH}
  NativeSwitchMemoryStatus(Status.TotalPhys, Status.AvailPhys);
  {$ELSE}
  NativeWasmMemoryStatus(Status.TotalPhys, Status.AvailPhys);
  {$ENDIF}
  // FPC keeps free blocks inside arenas owned by malloc. Those bytes are not
  // in malloc's free list, so add the current Pascal thread's reusable space.
  // Other threads' private arenas remain reserved and are counted conservatively.
  Inc(Status.AvailPhys, Min(Status.TotalPhys - Status.AvailPhys, QWord(Heap.CurrHeapFree)));
  Status.TotalVirtual := Status.TotalPhys;
  Status.AvailVirtual := Status.AvailPhys;
  if Status.TotalPhys <> 0 then
    Status.MemoryLoad := ((Status.TotalPhys - Status.AvailPhys) * 100) div Status.TotalPhys;
  Result := Status.TotalPhys <> 0;
{$ELSEIF defined(MSWINDOWS)}
  Result := NativeGlobalMemoryStatusEx(Status);
{$ELSE}
  Status.TotalPhys := QWord(SDL_GetSystemRAM) * 1024 * 1024;
  Status.AvailPhys := Status.TotalPhys;
  {$IFDEF DARWIN}
  Host := mach_host_self;
  try
    Count := Length(Stats);
    if (host_page_size(Host, Pages) = 0) and (host_statistics64(Host, 4, @Stats, Count) = 0) then
      // Free and inactive pages are the memory the OS can make available.
      Status.AvailPhys := Min(Status.TotalPhys, (QWord(Stats[0]) + Stats[2]) * Pages);
  finally
    mach_port_deallocate(mach_task_self_, Host);
  end;
  {$ENDIF}
  {$IFDEF LINUX}
  Lines := TStringList.Create;
  try
    if LoadProcFile(Lines, '/proc/meminfo') then
      for Line in Lines do
      begin
        Split := Pos(':', Line);
        if Split = 0 then
          Continue;
        Key := Copy(Line, 1, Split - 1);
        Value := Trim(Copy(Line, Split + 1, MaxInt));
        Split := Pos(' ', Value);
        if Split > 0 then
          SetLength(Value, Split - 1);
        Bytes := StrToQWordDef(Value, 0) * 1024;
        if Key = 'MemTotal' then
          Status.TotalPhys := Bytes
        else if Key = 'MemAvailable' then
          Status.AvailPhys := Bytes
        else if Key = 'SwapTotal' then
          Status.TotalPageFile := Bytes
        else if Key = 'SwapFree' then
          Status.AvailPageFile := Bytes;
      end;
  finally
    Lines.Free;
  end;
  {$ENDIF}
  // The Unix address space includes large shared mappings unrelated to game
  // allocations. Use FPC's reserved heap for the game's allocation-pressure
  // checks, while retaining native-width address headroom.
  Heap := GetFPCHeapStatus;
  Status.TotalVirtual := QWord(High(PtrInt));
  Status.AvailVirtual := Status.TotalVirtual - Min(Status.TotalVirtual, QWord(Heap.CurrHeapSize));
  if Status.TotalPhys <> 0 then
    Status.MemoryLoad := ((Status.TotalPhys - Status.AvailPhys) * 100) div Status.TotalPhys;
  Result := Status.TotalPhys <> 0;
{$ENDIF}
end;

function GameTickCount: Cardinal;
begin
  // Game deadlines deliberately retain their original 32-bit wraparound arithmetic.
  Result := Cardinal(GetTickCount64);
end;

function SameGamePathName(const Left, Right: UnicodeString): Boolean;
begin
  // Linguistic Unicode comparison can ignore punctuation (notably with
  // Android's fpwidestring collation). File names require ordinal comparison
  // after case folding, so "*", ".", "a-b" and "ab" remain distinct.
  Result := UnicodeUpperCase(Left) = UnicodeUpperCase(Right);
end;

function NormalizeGamePathSeparators(const Path: UnicodeString): UnicodeString;
var
  Index: Integer;
begin
  Result := Path;
  for Index := 1 to Length(Result) do
    if (Result[Index] = '\') or (Result[Index] = '/') then
      Result[Index] := DirectorySeparator;
end;

function ResolveGamePathName(const Directory, Name: UnicodeString): UnicodeString;
var
  Match: UnicodeString;
  Entry: TUnicodeSearchRec;
begin
  Result := Name;
  // Leave search masks for FindFirst, including their punctuation.
  if (Pos('*', Name) > 0) or (Pos('?', Name) > 0) then
    Exit;
  Match := '';
  if SysUtils.FindFirst(Directory + '*', faAnyFile, Entry) = 0 then
    try
      repeat
        if Entry.Name = Name then
          Exit(Entry.Name);
        if SameGamePathName(Entry.Name, Name) then
          // Exact spelling wins. Otherwise choose by raw code units, independent
          // of directory listing order, so metadata and resource loading agree.
          if (Match = '') or (Entry.Name < Match) then
            Match := Entry.Name;
      until SysUtils.FindNext(Entry) <> 0;
    finally
      SysUtils.FindClose(Entry);
    end;
  if Match <> '' then
    Result := Match;
end;

{$IF defined(UNIX) or defined(WASI) or defined(SWITCH)}
function ResolveGamePathCase(const Path: UnicodeString): UnicodeString;
var
  Directory, Name: UnicodeString;
  {$IFDEF SWITCH}
  Volume: UnicodeString;
  {$ENDIF}
begin
  Result := Path;
  {$IFDEF SWITCH}
  // The SD filesystem already matches names case-insensitively. Keep the
  // fallback for other devoptab mounts (romfs, for example, is case-sensitive).
  Volume := ExtractFileDrive(Path);
  if Volume = '' then
    Volume := ExtractFileDrive(GetCurrentDir);
  if SameText(Volume, 'sdmc:') then
    Exit;
  {$ENDIF}
  if (Path = '') or (FileGetAttr(Path) <> -1) then
    Exit;
  // Existing resources stay cheap. Correct missing components from the parent
  // down, also allowing new files to use an existing mixed-case directory.
  Directory := ExtractFileDir(Path);
  Name := ExtractFileName(Path);
  if (Name = '') or (Directory = Path) then
    Exit;
  if Directory <> '' then
    Directory := IncludeTrailingPathDelimiter(ResolveGamePathCase(Directory));
  Result := Directory + Name;
  if FileGetAttr(Result) = -1 then
    Result := Directory + ResolveGamePathName(Directory, Name);
end;
{$ENDIF}

function NativeGamePath(const Path: UnicodeString): UnicodeString;
begin
  // Package entry names keep their original separators. Only OS paths pass here.
  Result := NormalizeGamePathSeparators(Path);
{$IF defined(UNIX) or defined(WASI) or defined(SWITCH)}
  Result := ResolveGamePathCase(Result);
{$ENDIF}
end;

function ResolveGameRelativePath(const Root, RelativePath: UnicodeString): UnicodeString;
var
  Directory, Tail, Name: UnicodeString;
  Separator: SizeInt;
begin
  // Expand both sides consistently: Windows expansion uppercases drive letters.
  Directory := IncludeTrailingPathDelimiter(ExpandFileName(Root));
  Tail := ExpandFileName(Directory + NormalizeGamePathSeparators(RelativePath));
  // Normalize dot components below Root. Preserve selections of Root itself or
  // paths outside it, so a nonempty saved name never becomes an empty key.
  if (Tail = Directory) or (Copy(Tail, 1, Length(Directory)) <> Directory) then
    Exit(StringReplace(RelativePath, '/', '\', [rfReplaceAll]));
  Tail := Copy(Tail, Length(Directory) + 1, MaxInt);
  Result := '';
  // Enumerate only below Root, even on case-insensitive filesystems where an OS
  // existence check would accept the saved spelling without correcting it.
  while Tail <> '' do
  begin
    Separator := Pos(DirectorySeparator, Tail);
    if Separator = 0 then
      Separator := Length(Tail) + 1;
    Name := Copy(Tail, 1, Separator - 1);
    Delete(Tail, 1, Separator);
    Name := ResolveGamePathName(Directory, Name);
    Directory := Directory + Name + DirectorySeparator;
    if Result <> '' then
      Result := Result + '\';
    Result := Result + Name;
  end;
end;

function GameUserDirectory: UnicodeString;
begin
  if UserDirectoryOverride <> '' then
    Exit(UserDirectoryOverride);
{$IFDEF SWITCH}
  Exit('sdmc:/switch/SpaceRangersHD/user/');
{$ENDIF}
{$IFDEF ANDROID}
  // Set by the SDL launcher before it loads the Pascal library. Android does
  // not provide a useful HOME, and shared/external storage is not a save path.
  Result := UTF8Decode(GetEnvironmentVariable('SR_USER_DIR'));
  if (Result = '') or (Result[1] <> '/') then
    raise EInOutError.Create('Android launcher did not provide the private user directory');
  Exit(IncludeTrailingPathDelimiter(Result));
{$ENDIF}
{$IFDEF FPC_WASM_EMSCRIPTEN}
  // OPFS is mounted here before the Pascal runtime starts.
  Exit('/user/');
{$ENDIF}
{$IFDEF DARWIN}
  Result := GetUserDir + 'Library/Application Support/SpaceRangersHD/';
{$ELSE}
  {$IFDEF MSWINDOWS}
  // FPC resolves redirected Documents folders through the Unicode shell API.
  Result := GetWindowsSpecialDirUnicode(CSIDL_PERSONAL);
  if Result = '' then
    raise EInOutError.Create('Cannot locate the Documents folder');
  Result := IncludeTrailingPathDelimiter(Result) + 'SpaceRangersHD\';
  {$ELSE}
  Result := UTF8Decode(GetEnvironmentVariable('XDG_DATA_HOME'));
  // XDG paths must be absolute; relative values must not follow the asset CWD.
  if (Result = '') or (Result[1] <> '/') then
    Result := UTF8Decode(GetUserDir) + '.local/share';
  Result := IncludeTrailingPathDelimiter(Result) + 'SpaceRangersHD/';
  {$ENDIF}
{$ENDIF}
end;

procedure SetGameUserDirectory(const Path: UnicodeString);
begin
  if Path = '' then
    raise EInOutError.Create('Empty user directory');
  UserDirectoryOverride := IncludeTrailingPathDelimiter(UTF8Decode(ExpandFileName(UTF8Encode(Path))));
  if not ForceDirectories(UTF8Encode(UserDirectoryOverride)) then
    raise EInOutError.Create('Cannot create user directory: ' + UTF8Encode(Path));
end;

procedure SetGameDirectory(const Path: UnicodeString);
begin
  if (Path = '') or not SetCurrentDir(UTF8Encode(NativeGamePath(Path))) then
    raise EInOutError.Create('Cannot open game directory: ' + UTF8Encode(Path));
end;

{$IFDEF DARWIN}
function DarwinSystemText(Name: PAnsiChar): UnicodeString;
var
  Buffer: array[0..255] of AnsiChar;
  Size: size_t;
begin
  Result := '';
  FillChar(Buffer, SizeOf(Buffer), 0);
  Size := SizeOf(Buffer);
  if (FPsysctlbyname(Name, @Buffer, @Size, nil, 0) = 0) and (Size > 0) and (Size <= SizeOf(Buffer)) then
    Result := UTF8Decode(UTF8String(PAnsiChar(@Buffer[0])));
end;
{$ENDIF}

function GameOperatingSystemDescription: UnicodeString;
{$IFDEF DARWIN}
var
  Version, Build: UnicodeString;
{$ELSEIF Defined(LINUX)}
var
  Info: utsname;
{$ENDIF}
begin
{$IFDEF DARWIN}
  {$IFDEF SRHD_IOS}
  Result := 'iOS';
  {$ELSE}
  Result := 'macOS';
  {$ENDIF}
  Version := DarwinSystemText('kern.osproductversion');
  Build := DarwinSystemText('kern.osversion');
  if Version <> '' then
    Result := Result + ' ' + Version
  else
  begin
    Version := DarwinSystemText('kern.osrelease');
    if Version <> '' then
      Result := Result + ' (product version unavailable; Darwin ' + Version + ')'
    else
      Result := Result + ' (version unavailable)';
  end;
  if Build <> '' then
    Result := Result + ' build ' + Build;
{$ELSEIF Defined(LINUX)}
  {$IFDEF ANDROID}
  Result := 'Android';
  {$ELSE}
  Result := 'Linux';
  {$ENDIF}
  if FpUname(Info) = 0 then
    Result := Result + ' (kernel ' + UTF8Decode(UTF8String(PAnsiChar(@Info.release[0]))) + ')'
  else
    Result := Result + ' (kernel version unavailable)';
{$ELSEIF Defined(MSWINDOWS)}
  // The Windows startup report already supplies product/build registry data.
  Result := 'Windows';
{$ELSEIF Defined(SWITCH)}
  Result := 'Nintendo Switch (OS version unavailable)';
{$ELSEIF Defined(FPC_WASM_EMSCRIPTEN)}
  Result := 'WebAssembly browser (host OS unavailable)';
{$ELSE}
  Result := 'Operating system details unavailable';
{$ENDIF}
end;

function GameCpuClockMHz: Double;
{$IFDEF DARWIN}
var
  Frequency: QWord;
  Size: size_t;
{$ENDIF}
{$IFDEF MSWINDOWS}
var
  Key: TRegistry;
{$ENDIF}
{$IFDEF LINUX}
var
  Lines: TStringList;
  Line: string;
  Split: Integer;
  Format: TFormatSettings;
  Value: Double;
{$ENDIF}
begin
  // Used by logging and the graphics auto-preset, not by simulation timing.
  // ARM's timer frequency is not its CPU clock. Keep the game's 1500 MHz
  // fallback when the OS does not report a processor frequency.
  Result := 1500;
{$IFDEF DARWIN}
  Size := SizeOf(Frequency);
  if (FPsysctlbyname('hw.cpufrequency', @Frequency, @Size, nil, 0) = 0) and (Size = SizeOf(Frequency)) and (Frequency > 0) then
    Result := Frequency / 1000000;
{$ENDIF}
{$IFDEF MSWINDOWS}
  Key := TRegistry.Create(KEY_READ);
  try
    Key.RootKey := HKEY_LOCAL_MACHINE;
    if Key.OpenKeyReadOnly('HARDWARE\DESCRIPTION\System\CentralProcessor\0') then
      if Key.ValueExists('~MHz') then
        Result := Key.ReadInteger('~MHz');
  finally
    Key.Free;
  end;
{$ENDIF}
{$IFDEF LINUX}
  if not FileExists('/proc/cpuinfo') then
    Exit;
  Lines := TStringList.Create;
  try
    if not LoadProcFile(Lines, '/proc/cpuinfo') then
      Exit;
    Format := DefaultFormatSettings;
    Format.DecimalSeparator := '.';
    for Line in Lines do
    begin
      Split := Pos(':', Line);
      if (Split > 0) and (Trim(Copy(Line, 1, Split - 1)) = 'cpu MHz') then
        if TryStrToFloat(Trim(Copy(Line, Split + 1, MaxInt)), Value, Format) and (Value > 0) then
          Exit(Value);
    end;
  finally
    Lines.Free;
  end;
{$ENDIF}
end;

finalization
  if InstanceFile <> THandle(-1) then
    FileClose(InstanceFile);
end.
