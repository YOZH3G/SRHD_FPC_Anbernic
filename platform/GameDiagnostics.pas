unit GameDiagnostics;

{$MODE OBJFPC}
{$H+}

interface

uses
  SysUtils;

type
  TGameLogLevel = (gllDebug, gllInfo, gllWarning, gllError);
  TGameNativeExceptionDetails = function(E: TObject): UnicodeString;

  TGameExceptionOrigin = class;

  // Reports own their context and share the original failure. Clones can cross
  // threads without referring to an exception object whose handler has ended.
  TGameExceptionReport = class
  private
    FOrigin: TGameExceptionOrigin;
    FContext: UnicodeString;
    constructor CreateClone(Source: TGameExceptionReport);
    function GetOriginalClass: UnicodeString;
    function GetOriginalMessage: UnicodeString;
    function GetBacktrace: UnicodeString;
    function GetNativeDetails: UnicodeString;
  public
    constructor Create(const AClass, AMessage, ABacktrace, ANativeDetails, AContext: UnicodeString);
    destructor Destroy; override;
    function Clone: TGameExceptionReport;
    procedure AddContext(const Value: UnicodeString);
    property OriginalClass: UnicodeString read GetOriginalClass;
    property OriginalMessage: UnicodeString read GetOriginalMessage;
    property Backtrace: UnicodeString read GetBacktrace;
    property NativeDetails: UnicodeString read GetNativeDetails;
    property Context: UnicodeString read FContext;
  end;

  EGameDiagnosticException = class(Exception)
  private
    FReport: TGameExceptionReport;
  public
    // Stack frames are captured by the first exception handler.
    constructor Create(const AMessage: UnicodeString); overload;
    // Takes ownership of AReport.
    constructor Create(AReport: TGameExceptionReport); overload;
    destructor Destroy; override;
    property Report: TGameExceptionReport read FReport;
  end;

  TGameExceptionOrigin = class
  private
    References, Logged, ID: LongInt;
    OriginalClass, OriginalMessage, Backtrace, NativeDetails: UnicodeString;
    LoggedContexts: UnicodeString;
    Frames: array of Pointer;
    FramesCaptured, Symbolized, UnsafeFault: Boolean;
  end;

var
  OnGameNativeExceptionDetails: TGameNativeExceptionDetails;

// Idempotent during a session. False means the requested path was unavailable;
// GameDiagnosticsPath then identifies a temporary fallback, if one was opened.
function InitializeGameDiagnostics(const Directory: UnicodeString): Boolean;
procedure CloseGameDiagnostics;
function GameDiagnosticsPath: UnicodeString;
function GameDiagnosticsAvailable: Boolean;
function GameLogEnabled(Level: TGameLogLevel): Boolean;
// Call at thread entry. The first name wins; each worker gets a unique suffix.
procedure SetGameLogThreadName(const Name: ShortString);
procedure LogGameMessage(Level: TGameLogLevel; const Subsystem, Text: UnicodeString);
function CaptureGameException(const Context: UnicodeString): TGameExceptionReport;
function GameExceptionSummary(Report: TGameExceptionReport): UnicodeString;
procedure LogGameException(Report: TGameExceptionReport; const Subsystem: UnicodeString = 'exception'; Level: TGameLogLevel = gllError);
procedure LogCurrentGameException(const Subsystem, Context: UnicodeString; Level: TGameLogLevel = gllError);
// Add context and then use bare "raise" to retain class and original address.
procedure AddGameExceptionContext(E: Exception; const Context: UnicodeString);
// Graphics wrappers propagate aborts without adding failure context.
procedure AddCurrentGameExceptionContext(const Context: UnicodeString);
function GameExceptionPreventsRecovery(E: TObject): Boolean;

implementation

uses
  Classes;

const
  LogFileName = 'rangers-fpc.log';
  MaxLogFileBytes = 4 * 1024 * 1024;
  MaxLogRecordBytes = 128 * 1024;
  MaxSessionHeaderBytes = 64 * 1024;
  RecordTruncated = ' [record truncated at 128 KiB]';
  MaxStackFrames = 256;
  MaxContextCharacters = 8192;
  MaxContextLine = 1024;
  MaxContextEntries = 32;
  ContextOmitted = '[additional context omitted]';

type
  TGameLogFile = class(THandleStream)
  public
    destructor Destroy; override;
  end;

var
  LogLock: TRTLCriticalSection;
  SymbolLock: TRTLCriticalSection;
  LogReady: Boolean;
  SessionOpen, PrimaryPathOpened: Boolean;
  LogFile: TGameLogFile;
  LogPath: UnicodeString;
  MinimumLevel: TGameLogLevel = gllInfo;
  NextExceptionID: LongInt;
  LogBytesWritten: Int64;
  SessionHeader: UTF8String;
  SessionHeaderFull: Boolean;
  NextLogThreadID: LongInt;
  LogSessionID: QWord;
  SessionStartedAt, WarningRecords, ErrorRecords: QWord;

threadvar
  LogThreadLabel: string[48];
  ThreadMappingSession: QWord;

procedure SetGameLogThreadName(const Name: ShortString);
var
  I: Integer;
  SafeName: string[32];
begin
  if LogThreadLabel <> '' then
    Exit;
  SafeName := Copy(Name, 1, 32);
  for I := 1 to Length(SafeName) do
    if not (SafeName[I] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '_']) then
      SafeName[I] := '_';
  if SafeName = '' then
    SafeName := 'worker';
  if SafeName = 'main' then
    LogThreadLabel := 'main'
  else
    LogThreadLabel := SafeName + '#' + IntToStr(InterlockedIncrement(NextLogThreadID));
end;

function RecordNewContexts(const Context: UnicodeString; var Recorded: UnicodeString): UnicodeString; forward;
function OpenLog(const Path: UnicodeString; out FailureReason: UnicodeString): Boolean; forward;
function LevelName(Level: TGameLogLevel): UnicodeString; forward;

destructor TGameLogFile.Destroy;
begin
  FileClose(Handle);
  inherited Destroy;
end;

function Utf8PrefixLength(const Value: UTF8String; Limit: SizeInt): SizeInt;
begin
  Result := Length(Value);
  if Result <= Limit then
    Exit;
  Result := Limit;
  // Do not retain a leading byte whose continuation bytes were cut off.
  while (Result > 0) and ((Byte(Value[Result + 1]) and $C0) = $80) do
    Dec(Result);
end;

function UnicodePrefix(const Value: UnicodeString; Limit: SizeInt): UnicodeString;
begin
  if (Limit < Length(Value))
      and (Limit > 0)
      and (Ord(Value[Limit]) >= $D800)
      and (Ord(Value[Limit]) <= $DBFF)
      and (Ord(Value[Limit + 1]) >= $DC00)
      and (Ord(Value[Limit + 1]) <= $DFFF) then
    Dec(Limit);
  Result := Copy(Value, 1, Limit);
end;

procedure EmergencyWrite(const Text: UnicodeString);
var
  Bytes: UTF8String;
begin
  try
    Bytes := UTF8Encode(UnicodePrefix(Text, MaxLogRecordBytes));
    if (Length(Text) > MaxLogRecordBytes) or (Length(Bytes) + Length(LineEnding) > MaxLogRecordBytes) then
      Bytes := Copy(Bytes, 1, Utf8PrefixLength(Bytes, MaxLogRecordBytes - Length(RecordTruncated) - Length(LineEnding))) + RecordTruncated;
    if (Bytes = '') or (Bytes[Length(Bytes)] <> #10) then
      Bytes := Bytes + LineEnding;
    // Bypass Pascal's GUI stderr message-box writer on Windows.
    FileWrite(StdErrorHandle, Bytes[1], Length(Bytes));
  except
    // Diagnostics must never replace the failure they were meant to explain.
  end;
end;

function FormatLogRecord(Level: TGameLogLevel; const Subsystem, Text: UnicodeString; const AThread: ShortString): UTF8String;
var
  Prefix, Area: UnicodeString;
  PrefixBytes, Segment: UTF8String;
  Used, Start, Finish, Limit: SizeInt;
  Truncated: Boolean;

  function AppendBytes(const Value: UTF8String): Boolean;
  var
    Count, Capacity: SizeInt;
  begin
    Count := Utf8PrefixLength(Value, Limit - Used);
    if Used + Count > Length(FormatLogRecord) then
    begin
      Capacity := Length(FormatLogRecord) * 2;
      if Capacity < Used + Count then
        Capacity := Used + Count;
      if Capacity > MaxLogRecordBytes then
        Capacity := MaxLogRecordBytes;
      SetLength(FormatLogRecord, Capacity);
    end;
    if Count > 0 then
      Move(Value[1], FormatLogRecord[Used + 1], Count);
    Inc(Used, Count);
    Result := Count = Length(Value);
  end;

begin
  Area := UnicodeStringReplace(UnicodePrefix(Subsystem, 128), #10, ' ', [rfReplaceAll]);
  Area := UnicodeStringReplace(Area, #13, ' ', [rfReplaceAll]);
  Prefix :=
      UnicodeString(FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz', Now))
          + ' ['
          + LevelName(Level)
          + '] ['
          + Area
          + '] [thread='
          + UnicodeString(AThread)
          + '] ';
  PrefixBytes := UTF8Encode(Prefix);
  SetLength(Result, 256);
  Used := 0;
  Limit := MaxLogRecordBytes - Length(RecordTruncated) - Length(LineEnding);
  AppendBytes(PrefixBytes);
  Start := 1;
  Truncated := False;
  while Start <= Length(Text) do
  begin
    Finish := Start;
    while (Finish <= Length(Text)) and (Text[Finish] <> #10) and (Text[Finish] <> #13) and (Finish - Start < MaxLogRecordBytes) do
      Inc(Finish);
    if (Finish <= Length(Text))
        and (Finish > Start)
        and (Ord(Text[Finish - 1]) >= $D800)
        and (Ord(Text[Finish - 1]) <= $DBFF)
        and (Ord(Text[Finish]) >= $DC00)
        and (Ord(Text[Finish]) <= $DFFF) then
      Dec(Finish);
    Segment := UTF8Encode(Copy(Text, Start, Finish - Start));
    if not AppendBytes(Segment) then
    begin
      Truncated := True;
      Break;
    end;
    if Finish > Length(Text) then
      Break;
    if (Text[Finish] <> #10) and (Text[Finish] <> #13) then
    begin
      Truncated := True;
      Break;
    end;
    Start := Finish + 1;
    if (Text[Finish] = #13) and (Start <= Length(Text)) and (Text[Start] = #10) then
      Inc(Start);
    if not AppendBytes(LineEnding + PrefixBytes) then
    begin
      Truncated := True;
      Break;
    end;
  end;
  Limit := MaxLogRecordBytes;
  if Truncated then
    AppendBytes(RecordTruncated);
  AppendBytes(LineEnding);
  SetLength(Result, Used);
end;

procedure CacheSessionRecord(Level: TGameLogLevel; const Subsystem, Text: UnicodeString; const Bytes: UTF8String);
const
  HeaderTruncated = ' [retained startup context truncated at 64 KiB]';
var
  Available: SizeInt;
begin
  if SessionHeaderFull or (Level <> gllInfo) then
    Exit;
  if not ((Subsystem = 'startup')
      or (Subsystem = 'mods')
      or (Subsystem = 'config')
      or (Subsystem = 'video')
      or (Subsystem = 'renderer')
      or ((Subsystem = 'session') and (Pos('Session started;', Text) = 1))) then
    Exit;
  Available := MaxSessionHeaderBytes - Length(SessionHeader);
  if Length(Bytes) <= Available then
    SessionHeader := SessionHeader + Bytes
  else
  begin
    if Available >= Length(HeaderTruncated) + Length(LineEnding) then
      SessionHeader :=
          SessionHeader
              + Copy(Bytes, 1, Utf8PrefixLength(Bytes, Available - Length(HeaderTruncated) - Length(LineEnding)))
              + HeaderTruncated
              + LineEnding;
    SessionHeaderFull := True;
  end;
end;

procedure WriteBytesLocked(const Bytes: UTF8String);
begin
  if Bytes = '' then
    Exit;
  LogFile.WriteBuffer(Bytes[1], Length(Bytes));
  Inc(LogBytesWritten, Length(Bytes));
end;

function LevelName(Level: TGameLogLevel): UnicodeString;
begin
  case Level of
    gllDebug: Result := 'DEBUG';
    gllInfo: Result := 'INFO';
    gllWarning: Result := 'WARN';
    gllError: Result := 'ERROR';
  end;
end;

procedure WriteRecordLocked(Level: TGameLogLevel; const Subsystem, Text: UnicodeString; Lifecycle: Boolean = False);
var
  FailureReason: UnicodeString;
  Bytes: UTF8String;
begin
  if (Level < MinimumLevel) and not Lifecycle then
    Exit;
  if Level = gllWarning then
    Inc(WarningRecords)
  else if Level = gllError then
    Inc(ErrorRecords);
  if LogThreadLabel = '' then
    SetGameLogThreadName('worker');
  if (MinimumLevel = gllDebug) and (ThreadMappingSession <> LogSessionID) then
  begin
    ThreadMappingSession := LogSessionID;
    WriteRecordLocked(gllDebug, 'thread', 'Native thread ID=' + IntToStr(QWord(GetCurrentThreadID)));
  end;
  Bytes := FormatLogRecord(Level, Subsystem, Text, LogThreadLabel);
  if LogFile <> nil then
  begin
    try
      if LogBytesWritten + Length(Bytes) > MaxLogFileBytes then
      begin
        FreeAndNil(LogFile);
        if not OpenLog(LogPath, FailureReason) then
        begin
          EmergencyWrite('Game diagnostics rollover failed: ' + LogPath + ' (' + FailureReason + '); continuing on stderr');
          EmergencyWrite(UTF8Decode(Bytes));
          Exit;
        end;
        WriteBytesLocked(FormatLogRecord(gllInfo, 'session', 'Log continued (4 MiB limit)', LogThreadLabel));
        WriteBytesLocked(SessionHeader);
      end;
      WriteBytesLocked(Bytes);
      CacheSessionRecord(Level, Subsystem, Text, Bytes);
      if Level = gllError then
        FileFlush(LogFile.Handle);
      Exit;
    except
      on E: Exception do
      begin
        FreeAndNil(LogFile);
        EmergencyWrite(
            'Game diagnostics file write failed: ' + LogPath + ' (' + UnicodeString(E.ClassName) + ': ' + UnicodeString(E.Message) + ')'
        );
      end;
    else
      begin
        FreeAndNil(LogFile);
        EmergencyWrite('Game diagnostics file write failed: ' + LogPath);
      end;
    end;
  end;
  EmergencyWrite(UTF8Decode(Bytes));
end;

procedure RotateLog(const Path: UnicodeString);
var
  I: Integer;
  OldPath, NewPath: UnicodeString;
begin
  for I := 3 downto 1 do
  begin
    if I = 1 then
      OldPath := Path
    else
      OldPath := Path + '.' + UnicodeString(IntToStr(I - 1));
    NewPath := Path + '.' + UnicodeString(IntToStr(I));
    if FileExists(OldPath) then
    begin
      if FileExists(NewPath) and not DeleteFile(NewPath) then
        raise EInOutError.Create('Cannot rotate previous game diagnostics: ' + SysErrorMessage(GetLastOSError));
      if not RenameFile(OldPath, NewPath) then
        raise EInOutError.Create('Cannot retain previous game diagnostics: ' + SysErrorMessage(GetLastOSError));
    end;
  end;
end;

function OpenLog(const Path: UnicodeString; out FailureReason: UnicodeString): Boolean;
var
  Handle: THandle;
  ErrorCode: Integer;
begin
  Result := False;
  FailureReason := '';
  Handle := THandle(-1);
  try
    if not ForceDirectories(ExtractFileDir(Path)) then
    begin
      ErrorCode := GetLastOSError;
      if FileExists(ExtractFileDir(Path)) then
        raise EInOutError.Create('Log directory path is an existing file');
      if ErrorCode <> 0 then
        raise EOSError.Create('Cannot create log directory: ' + SysErrorMessage(ErrorCode));
      raise EInOutError.Create('Cannot create log directory');
    end;
    RotateLog(Path);
    // Use the Unicode overload: TFileStream's String-only constructor would
    // convert names through the Windows ANSI code page on some RTL versions.
    Handle := FileCreate(Path, fmShareDenyWrite, &600);
    if Handle = THandle(-1) then
      raise EOSError.Create('Cannot create log file: ' + SysErrorMessage(GetLastOSError));
    LogFile := TGameLogFile.Create(Handle);
    Handle := THandle(-1);
    LogPath := Path;
    LogBytesWritten := 0;
    Result := True;
  except
    on E: Exception do
      FailureReason := E.ClassName + ': ' + E.Message;
  else
    FailureReason := 'Unknown failure opening log file';
  end;
  if not Result then
  begin
    if Handle <> THandle(-1) then
      FileClose(Handle);
    FreeAndNil(LogFile);
  end;
end;

function PreviousSessionIncomplete(const Path: UnicodeString): Boolean;
const
  BoundaryBytes = 4096;
  SessionPrefix = ' [INFO] [session] [thread=';
  StartMessage = 'Session started; timestamps use local time; platform=';
var
  Handle: THandle;
  Size: Int64;
  Head, Tail, Message: AnsiString;
  Lines: TStringList;
  I, Count: Integer;
  Started: Boolean;

  function SessionMessage(const Line: AnsiString): AnsiString;
  var
    Start, Finish, Index: SizeInt;
  begin
    Result := '';
    // Only actual session records count, never a marker quoted in error text.
    if Pos(SessionPrefix, Line) <> 24 then
      Exit;
    Start := 24 + Length(SessionPrefix);
    Finish := Pos('] ', Line, Start);
    if (Finish <= Start) or (Finish - Start > 48) then
      Exit;
    for Index := Start to Finish - 1 do
      if not (Line[Index] in ['a'..'z', 'A'..'Z', '0'..'9', '-', '_', '#']) then
        Exit;
    Result := Copy(Line, Finish + 2, MaxInt);
  end;

begin
  Result := False;
  Handle := FileOpen(Path, fmOpenRead or fmShareDenyNone);
  if Handle = THandle(-1) then
    Exit;
  Lines := nil;
  try
    try
      Size := FileSeek(Handle, Int64(0), fsFromEnd);
      if Size <= 0 then
        Exit;
      Count := BoundaryBytes;
      if Size < Count then
        Count := Size;
      SetLength(Head, Count);
      if (FileSeek(Handle, Int64(0), fsFromBeginning) < 0) or (FileRead(Handle, Head[1], Count) <> Count) then
        Exit;
      Lines := TStringList.Create;
      Lines.Text := Head;
      Started := False;
      for I := 0 to Lines.Count - 1 do
        if Pos(StartMessage, SessionMessage(Lines[I])) = 1 then
          Started := True;
      // Older severity-filtered logs and unrelated/empty files are unknown.
      if not Started then
        Exit;
      SetLength(Tail, Count);
      if (FileSeek(Handle, Size - Count, fsFromBeginning) < 0) or (FileRead(Handle, Tail[1], Count) <> Count) then
        Exit;
      Lines.Text := Tail;
      I := Lines.Count - 1;
      while (I >= 0) and (Lines[I] = '') do
        Dec(I);
      Message := '';
      if I >= 0 then
        Message := SessionMessage(Lines[I]);
      Result := (Message <> 'Session ended') and (Pos('Session ended;', Message) <> 1);
    except
      // An unreadable log has unknown shutdown status.
      Result := False;
    end;
  finally
    Lines.Free;
    FileClose(Handle);
  end;
end;

function InitializeGameDiagnostics(const Directory: UnicodeString): Boolean;
var
  RequestedPath, FallbackPath: UnicodeString;
  Setting, PrimaryFailure, FallbackFailure: UnicodeString;
  PreviousIncomplete: Boolean;
begin
  Result := False;
  if not LogReady then
    Exit;
  try
    EnterCriticalSection(LogLock);
    try
      if SessionOpen then
        Exit(PrimaryPathOpened);
      SetGameLogThreadName('main');
      Inc(LogSessionID);
      SessionOpen := True;
      SessionStartedAt := GetTickCount64;
      WarningRecords := 0;
      ErrorRecords := 0;
      SessionHeader := '';
      SessionHeaderFull := False;
      Setting := LowerCase(GetEnvironmentVariable('SR_LOG_LEVEL'));
      MinimumLevel := gllInfo;
      if Setting = 'debug' then
        MinimumLevel := gllDebug
      else if (Setting = 'warning') or (Setting = 'warn') then
        MinimumLevel := gllWarning
      else if Setting = 'error' then
        MinimumLevel := gllError;
      RequestedPath := IncludeTrailingPathDelimiter(Directory) + LogFileName;
{$IF Defined(ANDROID) or Defined(SRHD_IOS)}
      // Mobile OSes normally reclaim suspended apps without shutdown callbacks.
      // A missing end marker cannot distinguish that lifecycle from a failure.
      PreviousIncomplete := False;
{$ELSE}
      PreviousIncomplete := PreviousSessionIncomplete(RequestedPath);
{$ENDIF}
      PrimaryPathOpened := OpenLog(RequestedPath, PrimaryFailure);
      Result := PrimaryPathOpened;
      if not Result then
      begin
        FallbackPath :=
            IncludeTrailingPathDelimiter(UnicodeString(GetTempDir(False)))
                + 'rangers-fpc-'
                + UnicodeString(IntToStr(GetProcessID))
                + '.log';
        if OpenLog(FallbackPath, FallbackFailure) then
          WriteRecordLocked(
              gllWarning,
              'diagnostics',
              'Requested log could not be opened: ' + RequestedPath + ' (' + PrimaryFailure + ')' + '; using ' + FallbackPath
          )
        else
          EmergencyWrite(
              'Cannot open game diagnostics; stderr fallback. Requested: '
                  + RequestedPath
                  + ' ('
                  + UnicodeString(PrimaryFailure)
                  + '); fallback: '
                  + FallbackPath
                  + ' ('
                  + UnicodeString(FallbackFailure)
                  + ')'
          );
      end;
      WriteRecordLocked(
          gllInfo,
          'session',
          'Session started; timestamps use local time; '
              + 'platform='
              + {$I %FPCTARGETOS%} +'; cpu='
              + {$I %FPCTARGETCPU%} +'; pointer-bits='
              + IntToStr(SizeOf(Pointer) * 8),
          True
      );
      if PrimaryPathOpened and PreviousIncomplete then
        WriteRecordLocked(
            gllWarning,
            'session',
            'Previous session has no shutdown marker (interrupted, force-quit, or crashed); '
                + 'its last records are in rangers-fpc.log.1'
{$IF Defined(DARWIN) and not Defined(SRHD_IOS)}
                + '; macOS crash reports may be in ~/Library/Logs/DiagnosticReports'
{$ENDIF}
        );
    finally
      LeaveCriticalSection(LogLock);
    end;
  except
    EmergencyWrite('Unable to initialize game diagnostics');
  end;
end;

procedure CloseGameDiagnostics;
begin
  if not LogReady then
    Exit;
  try
    EnterCriticalSection(LogLock);
    try
      if not SessionOpen then
        Exit;
      WriteRecordLocked(
          gllInfo,
          'session',
          'Session ended; exit code='
              + IntToStr(ExitCode)
              + '; elapsed='
              + UIntToStr((GetTickCount64 - SessionStartedAt) div 1000)
              + 's; warning records='
              + UIntToStr(WarningRecords)
              + '; error records='
              + UIntToStr(ErrorRecords),
          True
      );
      if LogFile <> nil then
        FileFlush(LogFile.Handle);
      FreeAndNil(LogFile);
      SessionOpen := False;
    finally
      LeaveCriticalSection(LogLock);
    end;
  except
    EmergencyWrite('Unable to close game diagnostics');
  end;
end;

function GameDiagnosticsPath: UnicodeString;
begin
  Result := '';
  if not LogReady then
    Exit;
  EnterCriticalSection(LogLock);
  try
    Result := LogPath;
  finally
    LeaveCriticalSection(LogLock);
  end;
end;

function GameLogEnabled(Level: TGameLogLevel): Boolean;
begin
  Result := LogReady and (Level >= MinimumLevel);
end;

function GameDiagnosticsAvailable: Boolean;
begin
  Result := False;
  if not LogReady then
    Exit;
  EnterCriticalSection(LogLock);
  try
    Result := LogFile <> nil;
  finally
    LeaveCriticalSection(LogLock);
  end;
end;

procedure LogGameMessage(Level: TGameLogLevel; const Subsystem, Text: UnicodeString);
begin
  if not GameLogEnabled(Level) then
    Exit;
  try
    EnterCriticalSection(LogLock);
    try
      WriteRecordLocked(Level, Subsystem, Text);
    finally
      LeaveCriticalSection(LogLock);
    end;
  except
    EmergencyWrite('Game diagnostics: ' + UnicodeString(Text));
  end;
end;

constructor TGameExceptionReport.Create(const AClass, AMessage, ABacktrace, ANativeDetails, AContext: UnicodeString);
begin
  inherited Create;
  FOrigin := TGameExceptionOrigin.Create;
  FOrigin.References := 1;
  FOrigin.ID := InterlockedIncrement(NextExceptionID);
  FOrigin.OriginalClass := AClass;
  FOrigin.OriginalMessage := AMessage;
  FOrigin.Backtrace := ABacktrace;
  FOrigin.NativeDetails := ANativeDetails;
  FOrigin.FramesCaptured := True;
  FOrigin.Symbolized := True;
  AddContext(AContext);
end;

constructor TGameExceptionReport.CreateClone(Source: TGameExceptionReport);
begin
  inherited Create;
  FOrigin := Source.FOrigin;
  InterlockedIncrement(FOrigin.References);
  FContext := Source.FContext;
end;

destructor TGameExceptionReport.Destroy;
begin
  if (FOrigin <> nil) and (InterlockedDecrement(FOrigin.References) = 0) then
    FOrigin.Free;
  inherited Destroy;
end;

function TGameExceptionReport.Clone: TGameExceptionReport;
begin
  Result := TGameExceptionReport.CreateClone(Self);
end;

procedure TGameExceptionReport.AddContext(const Value: UnicodeString);
begin
  RecordNewContexts(Value, FContext);
end;

function TGameExceptionReport.GetOriginalClass: UnicodeString;
begin
  Result := FOrigin.OriginalClass;
end;

function TGameExceptionReport.GetOriginalMessage: UnicodeString;
begin
  Result := FOrigin.OriginalMessage;
end;

function TGameExceptionReport.GetNativeDetails: UnicodeString;
begin
  Result := FOrigin.NativeDetails;
end;

function SafeFrame(Address: Pointer; Formatter: TBackTraceStrFunc): UnicodeString;
begin
  Result := '$' + UnicodeString(IntToHex(PtrUInt(Address), SizeOf(Pointer) * 2));
  if Assigned(Formatter) then
    try
      Result := UnicodeString(Formatter(Address));
    except
      // The raw address remains useful when symbol lookup itself fails.
    end;
end;

function TGameExceptionReport.GetBacktrace: UnicodeString;
var
  I: Integer;
  Formatter: TBackTraceStrFunc;
begin
  EnterCriticalSection(SymbolLock);
  try
    if not FOrigin.Symbolized then
    begin
      // FPC's DwarfBackTraceStr temporarily replaces this global callback and
      // does not restore it if lookup throws. Serialize all port symbolization
      // and call one saved callback, restoring it even after a failed lookup.
      Formatter := BackTraceStrFunc;
      try
        FOrigin.Backtrace := '';
        for I := 0 to High(FOrigin.Frames) do
        begin
          if I > 0 then
            FOrigin.Backtrace := FOrigin.Backtrace + LineEnding;
          FOrigin.Backtrace := FOrigin.Backtrace + SafeFrame(FOrigin.Frames[I], Formatter);
        end;
        FOrigin.Symbolized := True;
      finally
        BackTraceStrFunc := Formatter;
      end;
    end;
    Result := FOrigin.Backtrace;
  finally
    LeaveCriticalSection(SymbolLock);
  end;
end;

procedure CaptureFrames(Origin: TGameExceptionOrigin);
var
  Frame, Count, First: Integer;
begin
  if Origin.FramesCaptured then
    Exit;
  Count := ExceptFrameCount;
  if Count > MaxStackFrames - 1 then
    Count := MaxStackFrames - 1;
  First := Ord(ExceptAddr <> nil);
  SetLength(Origin.Frames, Count + First);
  if First <> 0 then
    Origin.Frames[0] := ExceptAddr;
  for Frame := 0 to Count - 1 do
    Origin.Frames[Frame + First] := ExceptFrames[Frame];
  Origin.FramesCaptured := True;
  Origin.Symbolized := False;
end;

function CaptureGameException(const Context: UnicodeString): TGameExceptionReport;
var
  E: TObject;
  AClass, AMessage, Native: UnicodeString;
begin
  E := ExceptObject;
  if (E is EGameDiagnosticException) and (EGameDiagnosticException(E).Report <> nil) then
  begin
    Result := EGameDiagnosticException(E).Report.Clone;
    CaptureFrames(Result.FOrigin);
    Result.AddContext(Context);
    Exit;
  end;
  AClass := 'UnknownException';
  AMessage := 'No active exception';
  if E <> nil then
  begin
    AClass := E.ClassName;
    if E is Exception then
      AMessage := Exception(E).Message
    else
      AMessage := 'Raised object is not a SysUtils.Exception';
  end;
  Native := '';
  if (E is EExternal) and Assigned(OnGameNativeExceptionDetails) then
    try
      Native := OnGameNativeExceptionDetails(E);
    except
      Native := 'Native exception details unavailable';
    end;
  Result := TGameExceptionReport.Create(AClass, AMessage, '', Native, Context);
  Result.FOrigin.UnsafeFault := GameExceptionPreventsRecovery(E);
  Result.FOrigin.FramesCaptured := False;
  CaptureFrames(Result.FOrigin);
end;

function GameExceptionSummary(Report: TGameExceptionReport): UnicodeString;
begin
  Result := '';
  if Report = nil then
    Exit;
  Result := Report.OriginalClass + ': ' + Report.OriginalMessage;
  if Report.Context <> '' then
    Result := Result + LineEnding + 'Context: ' + Report.Context;
  if Report.NativeDetails <> '' then
    Result := Result + LineEnding + Report.NativeDetails;
end;

function FormatGameException(Report: TGameExceptionReport): UnicodeString;
begin
  Result := GameExceptionSummary(Report);
  if (Report <> nil) and (Report.Backtrace <> '') then
    Result := Result + LineEnding + 'Original backtrace:' + LineEnding + Report.Backtrace;
end;

function RecordNewContexts(const Context: UnicodeString; var Recorded: UnicodeString): UnicodeString;
var
  Lines, Line: UnicodeString;
  Start, Finish, Entries, I: SizeInt;
begin
  Result := '';
  if (Context = '') or (Pos(ContextOmitted, Recorded) > 0) then
    Exit;
  Lines := UnicodeStringReplace(Copy(Context, 1, MaxContextCharacters * 2), #13#10, #10, [rfReplaceAll]);
  Lines := UnicodeStringReplace(Lines, #13, #10, [rfReplaceAll]) + #10;
  Entries := Ord(Recorded <> '');
  for I := 1 to Length(Recorded) do
    if Recorded[I] = #10 then
      Inc(Entries);
  Start := 1;
  repeat
    Finish := Pos(#10, Lines, Start);
    if Finish = 0 then
      Break;
    Line := Copy(Lines, Start, Finish - Start);
    if Length(Line) > MaxContextLine then
      Line := Copy(Line, 1, MaxContextLine - 12) + ' [truncated]';
    if (Line <> '') and (Pos(#10 + Line + #10, #10 + Recorded + #10) = 0) then
    begin
      if (Entries >= MaxContextEntries) or (Length(Recorded) + Length(Line) + Length(ContextOmitted) + 2 > MaxContextCharacters) then
      begin
        Recorded := Recorded + #10 + ContextOmitted;
        if Result <> '' then
          Result := Result + LineEnding;
        Result := Result + ContextOmitted;
        Exit;
      end;
      if Recorded <> '' then
        Recorded := Recorded + #10;
      Recorded := Recorded + Line;
      if Result <> '' then
        Result := Result + LineEnding;
      Result := Result + Line;
      Inc(Entries);
    end;
    Start := Finish + 1;
  until Start > Length(Lines);
end;

procedure LogGameException(Report: TGameExceptionReport; const Subsystem: UnicodeString; Level: TGameLogLevel);
var
  Required: LongInt;
  NewContexts, Identity, FullReport: UnicodeString;
  NeedFullReport: Boolean;
begin
  if (Report = nil) or not GameLogEnabled(Level) then
    Exit;
  try
    Required := Ord(Level) + 1;
    EnterCriticalSection(LogLock);
    try
      NeedFullReport := Report.FOrigin.Logged < Required;
    finally
      LeaveCriticalSection(LogLock);
    end;
    // Symbol lookup can be slow, and its RTL callback uses global state.
    // Complete it outside the file lock, under the separate symbol lock.
    if NeedFullReport then
      FullReport := FormatGameException(Report);
    EnterCriticalSection(LogLock);
    try
      // Shared across clones. Keep later context even after the origin was
      // recorded, without duplicating its message and original backtrace.
      NewContexts := RecordNewContexts(Report.Context, Report.FOrigin.LoggedContexts);
      Identity := 'Failure #' + IntToStr(Report.FOrigin.ID);
      if Report.FOrigin.Logged < Required then
      begin
        WriteRecordLocked(Level, Subsystem, Identity + ': ' + FullReport);
        Report.FOrigin.Logged := Required;
      end
      else if NewContexts <> '' then
        WriteRecordLocked(Level, Subsystem, Identity + ' additional context: ' + NewContexts);
    finally
      LeaveCriticalSection(LogLock);
    end;
  except
    EmergencyWrite('Exception diagnostics could not be fully recorded');
  end;
end;

procedure LogCurrentGameException(const Subsystem, Context: UnicodeString; Level: TGameLogLevel);
var
  Report: TGameExceptionReport;
begin
  if not GameLogEnabled(Level) then
    Exit;
  try
    Report := CaptureGameException(Context);
    try
      LogGameException(Report, Subsystem, Level);
    finally
      Report.Free;
    end;
  except
    EmergencyWrite('Exception diagnostics could not be captured: ' + UnicodeString(Context));
  end;
end;

function ExceptionMessageText(const Value: UnicodeString): AnsiString;
begin
  // Exception.Message is an RTL AnsiString. Retain the UTF-8 codepage tag rather
  // than converting Unicode through the machine's potentially narrow ACP.
  Result := RawByteString(UTF8Encode(Value));
end;

constructor EGameDiagnosticException.Create(const AMessage: UnicodeString);
begin
  inherited Create(ExceptionMessageText(AMessage));
  FReport := TGameExceptionReport.Create(UnicodeString(ClassName), AMessage, '', '', '');
  FReport.FOrigin.FramesCaptured := False;
end;

constructor EGameDiagnosticException.Create(AReport: TGameExceptionReport);
begin
  FReport := AReport;
  inherited Create(ExceptionMessageText(GameExceptionSummary(AReport)));
end;

destructor EGameDiagnosticException.Destroy;
begin
  FReport.Free;
  inherited Destroy;
end;

procedure AddGameExceptionContext(E: Exception; const Context: UnicodeString);
var
  Original, ContextText: UnicodeString;
  ContextStart: SizeInt;
begin
  if (E = nil) or (Context = '') then
    Exit;
  try
    if (E is EGameDiagnosticException) and (EGameDiagnosticException(E).Report <> nil) then
    begin
      EGameDiagnosticException(E).Report.AddContext(Context);
      E.Message := ExceptionMessageText(GameExceptionSummary(EGameDiagnosticException(E).Report));
    end
    else
    begin
      Original := UnicodeString(E.Message);
      ContextStart := Pos(LineEnding + 'Context: ', Original);
      ContextText := '';
      if ContextStart > 0 then
      begin
        ContextText := Copy(Original, ContextStart + Length(LineEnding + 'Context: '), MaxInt);
        Original := Copy(Original, 1, ContextStart - 1);
      end;
      RecordNewContexts(Context, ContextText);
      E.Message := ExceptionMessageText(Original + LineEnding + 'Context: ' + ContextText);
    end;
  except
    // Keep the original object, class, message and exception address usable.
  end;
end;

procedure AddCurrentGameExceptionContext(const Context: UnicodeString);
begin
  if (ExceptObject is Exception) and not (ExceptObject is EAbort) then
    AddGameExceptionContext(Exception(ExceptObject), Context);
end;

function GameExceptionPreventsRecovery(E: TObject): Boolean;
var
  Original: UnicodeString;
begin
  Result := (E is EAccessViolation) or (E is EStackOverflow) or (E is EPrivilege) or (E is EExternalException);
  if (E is EGameDiagnosticException) and (EGameDiagnosticException(E).Report <> nil) then
  begin
    Original := EGameDiagnosticException(E).Report.OriginalClass;
    Result :=
        EGameDiagnosticException(E).Report.FOrigin.UnsafeFault
            or (Original = 'EAccessViolation')
            or (Original = 'EStackOverflow')
            or (Original = 'EPrivilege')
            or (Original = 'EExternalException');
  end;
end;

initialization
  InitCriticalSection(LogLock);
  InitCriticalSection(SymbolLock);
  LogReady := True;

finalization
  CloseGameDiagnostics;
  LogReady := False;
  DoneCriticalSection(SymbolLock);
  DoneCriticalSection(LogLock);

end.
