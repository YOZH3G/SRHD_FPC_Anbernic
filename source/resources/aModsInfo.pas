unit aModsInfo;

{$I GameOptions.inc}

interface

uses
  GameSystem,
  Classes,
  EC_BlockPar,
  EC_Struct,
  GI_Image;

type

  TModInfo = class;

  TModInfo = class(TObjectEx)
    Folder: WideString;
    SwitchImage: TImageGI;
    IndexText: WideString;
    Name: WideString;
    Section: WideString;
    SmallDescription: WideString;
    FullDescription: WideString;
    Author: WideString;
    DependencyNames: WideString;
    DependencyCount: Integer;
    Dependencies: array of TModInfo;
    ConflictNames: WideString;
    ConflictCount: Integer;
    Conflicts: array of TModInfo;
    Priority: Cardinal;
    UnsupportedLanguage: Boolean;
    MissingFolder: Boolean;
    MissingDependency: Boolean;
    Misplaced: Boolean;
    DuplicateName: Boolean;
    ReferencedAsConflict: Boolean;
    ReferencedAsDependency: Boolean;
    Selected: Boolean;
    constructor Create;
    destructor Destroy; override;
    function GetDisplayName: WideString;
    function GetConflict(Index: Integer; VariantIndex: Integer): TModInfo;
    function GetDependency(Index: Integer; VariantIndex: Integer): TModInfo;
  end;

var

  ModInfos: TList = nil;

  SelectedModInfos: TList = nil;

  ModIdCounts: TBlockParEC = nil;

  ModConflictIndex: TBlockParEC = nil;

  ModDependencyIndex: TBlockParEC = nil;

  ModInfosInitialized: Boolean = False;

function LoadModInfo(Folder: WideString; Info: TModInfo): Boolean;

procedure ScanModFolders(Folder: WideString; Prefix: WideString);

procedure InitializeModInfos;

procedure ClearModInfoState;

implementation

uses
  SysUtils,
  EC_Str,
  EC_Expression,
  GR_Main;

constructor TModInfo.Create;
begin
  inherited Create;
  Folder := '';
  SwitchImage := nil;
  Name := '';
  Section := '';
  SmallDescription := '';
  FullDescription := '';
  Author := '';
  DependencyNames := '';
  DependencyCount := 0;
  SetLength(Dependencies, 0);
  ConflictNames := '';
  ConflictCount := 0;
  SetLength(Conflicts, 0);
  Priority := 0;
  UnsupportedLanguage := False;
  MissingFolder := False;
  MissingDependency := False;
  Misplaced := False;
  DuplicateName := False;
  ReferencedAsConflict := False;
  ReferencedAsDependency := False;
  Selected := False;
end;

destructor TModInfo.Destroy;
begin
  SetLength(Dependencies, 0);
  SetLength(Conflicts, 0);
  inherited Destroy;
end;

function TModInfo.GetDisplayName: WideString;
begin
  if Name <> '' then
    Result := Name
  else
    Result := '[' + Folder + ']';
end;

function TModInfo.GetConflict(Index, VariantIndex: Integer): TModInfo;
var
  Info: TModInfo;
  Indices: WideString;
  Count: Integer;
begin
  Result := nil;
  if (Index < 0) or (Index >= ConflictCount) then
    Exit;
  if VariantIndex = 0 then
  begin
    Result := Conflicts[Index];
    Exit;
  end;
  Info := Conflicts[Index];
  if not Info.DuplicateName then
    Exit;
  Indices := ModConflictIndex.GetParam(Info.Name);
  Count := CountDelimitedPartsW(Indices, ',');
  if (VariantIndex < 0) or (VariantIndex >= Count) then
    Exit;
  Result := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, VariantIndex, ','))]);
end;

function TModInfo.GetDependency(Index, VariantIndex: Integer): TModInfo;
var
  Info: TModInfo;
  Indices: WideString;
  Count: Integer;
begin
  Result := nil;
  if (Index < 0) or (Index >= DependencyCount) then
    Exit;
  if VariantIndex = 0 then
  begin
    Result := Dependencies[Index];
    Exit;
  end;
  Info := Dependencies[Index];
  if not Info.DuplicateName then
    Exit;
  Indices := ModDependencyIndex.GetParam(Info.Name);
  Count := CountDelimitedPartsW(Indices, ',');
  if (VariantIndex < 0) or (VariantIndex >= Count) then
    Exit;
  Result := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, VariantIndex, ','))]);
end;

// Exact lookup of a backslash-separated folder key. If absent, Index is the
// insertion position; lookup never changes the list or reserves a nil entry.
function FindModFolder(const Folder: WideString; out Index: Integer): Boolean;
var
  Left, Right, Middle, Comparison: Integer;
begin
  Left := 0;
  Right := ModInfos.Count;
  while Left < Right do
  begin
    Middle := Left + (Right - Left) div 2;
    // Preserve the original UI order and the load order of equal-priority mods.
    Comparison := CompareScriptNames(PWideChar(Folder), PWideChar(TModInfo(ModInfos[Middle]).Folder));
    if Comparison = 0 then
    begin
      Index := Middle;
      Exit(True);
    end;
    if Comparison < 0 then
      Right := Middle
    else
      Left := Middle + 1;
  end;
  Index := Left;
  Result := False;
end;

function FindSavedModFolder(const Root: WideString; var Folder: WideString; out Index: Integer): Boolean;
var
  I: Integer;
  Info: TModInfo;
begin
  // Names saved by the manager usually already have the discovered spelling.
  if FindModFolder(Folder, Index) then
    Exit(True);
  // Resolve saved spelling exactly as resource loading does. Distinct physical
  // case-only folders must remain distinct entries on case-sensitive storage.
  Folder := ResolveGameRelativePath(Root, Folder);
  if FindModFolder(Folder, Index) then
    Exit(True);
  // Missing entries have no on-disk spelling; coalesce repeated saved aliases.
  // Existing folders use only their resolved identity, including nested mods
  // that were hidden from scanning by an enclosing mod.
  if not DirectoryExists(NativeGamePath(Root + '\' + Folder)) then
    for I := 0 to ModInfos.Count - 1 do
    begin
      Info := TModInfo(ModInfos[I]);
      if Info.MissingFolder and SameGamePathName(Info.Folder, Folder) then
      begin
        Index := I;
        Exit(True);
      end;
    end;
  Result := False;
end;

function LoadModInfo(Folder: WideString; Info: TModInfo): Boolean;
var
  MetadataPath: WideString;
  HasCommonResources, HasForeignResources, HasLanguageResources: Boolean;
  Block: TBlockParEC;
  Language, Languages: WideString;
  I, Count: Integer;

  function ModPath(const RelativePath: WideString): UnicodeString;
  begin
    Result := NativeGamePath(Folder + '\' + RelativePath);
  end;

  function HasOtherLanguageResources: Boolean;
  var
    FileName: UnicodeString;
    FindData: TUnicodeSearchRec;
  begin
    Result := False;
    if SysUtils.FindFirst(ModPath('*'), faAnyFile, FindData) = 0 then
      try
        repeat
          FileName := FindData.Name;
          if ((FindData.Attr and faDirectory) = 0)
              and (Length(FileName) > 12)
              and SameGamePathName(Copy(FileName, 1, 8), 'install_')
              and SameGamePathName(ExtractFileExt(FileName), '.txt')
              and not SameGamePathName(FileName, 'install_' + SelectedLanguage + '.txt') then
            Exit(True);
        until SysUtils.FindNext(FindData) <> 0;
      finally
        SysUtils.FindClose(FindData);
      end;
    if SysUtils.FindFirst(ModPath('CFG\*'), faAnyFile, FindData) = 0 then
      try
        repeat
          FileName := FindData.Name;
          if ((FindData.Attr and faDirectory) <> 0)
              and (FileName <> '.')
              and (FileName <> '..')
              and not SameGamePathName(FileName, Language)
              and SysUtils.FileExists(ModPath('CFG\' + FileName + '\Lang.dat')) then
            Exit(True);
        until SysUtils.FindNext(FindData) <> 0;
      finally
        SysUtils.FindClose(FindData);
      end;
  end;

begin
  HasForeignResources := False;
  HasLanguageResources := False;
  HasCommonResources := False;
  Block := nil;
  // Every lookup is rooted in this mod; discovery must never change the
  // process CWD used by resource loaders and directory enumerators.
  Folder := ExpandFileName(NativeGamePath(Folder));
  if not DirectoryExists(Folder) then
    Exit(False);
  try
    if SysUtils.FileExists(ModPath('install.txt'))
        or SysUtils.FileExists(ModPath('CFG\Main.dat'))
        or SysUtils.FileExists(ModPath('CFG\CacheData.dat')) then
      HasCommonResources := True;
    Language := LanguageInstallConfig.GetParam('Lang');
    if SysUtils.FileExists(ModPath('install_' + SelectedLanguage + '.txt'))
        or SysUtils.FileExists(ModPath('CFG\' + Language + '\Lang.dat')) then
      HasLanguageResources := True;
    if not HasCommonResources and not HasLanguageResources then
      HasForeignResources := HasOtherLanguageResources;
    Result := (HasCommonResources or HasLanguageResources) or HasForeignResources;
    MetadataPath := ModPath('ModuleInfo.txt');
    if not SysUtils.FileExists(MetadataPath) then
    begin
      if not Result then
        Exit;
      if not HasLanguageResources then
      begin
        if not HasForeignResources then
          HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end;
      Exit;
    end;
    Block := TBlockParEC.Create;
    try
      Block.LoadFromTextFileWithEncodingProbe(PWideChar(MetadataPath), False, Folder);
      if not Result then
      begin
        if Block.CountParams('NoNormalResources') <= 0 then
        begin
          Block.Free;
          Block := nil;
          Exit;
        end;
        Result := True;
      end;
      if Block.CountParams('Name') > 0 then
        Info.Name := TrimWideString(Block.GetParam('Name'));
      if Block.CountParams('Section' + Language) > 0 then
        Info.Section := TrimWideString(Block.GetParam('Section' + Language))
      else if Block.CountParams('Section') > 0 then
        Info.Section := TrimWideString(Block.GetParam('Section'));
      if Block.CountParams('SmallDescription' + Language) > 0 then
      begin
        Count := Block.CountParams('SmallDescription' + Language);
        Info.SmallDescription := Block.GetParamByPath('SmallDescription' + Language + ':0');
        for I := 1 to Count - 1 do
          Info.SmallDescription :=
              Info.SmallDescription + #13#10 + Block.GetParamByPath('SmallDescription' + Language + ':' + IntToWideString(I));
      end
      else if Block.CountParams('SmallDescription') > 0 then
      begin
        Count := Block.CountParams('SmallDescription');
        Info.SmallDescription := Block.GetParamByPath('SmallDescription:0');
        for I := 1 to Count - 1 do
          Info.SmallDescription := Info.SmallDescription + #13#10 + Block.GetParamByPath('SmallDescription:' + IntToWideString(I));
      end;
      if Block.CountParams('FullDescription' + Language) > 0 then
      begin
        Count := Block.CountParams('FullDescription' + Language);
        Info.FullDescription := Block.GetParamByPath('FullDescription' + Language + ':0');
        for I := 1 to Count - 1 do
          Info.FullDescription :=
              Info.FullDescription + #13#10 + Block.GetParamByPath('FullDescription' + Language + ':' + IntToWideString(I));
      end
      else if Block.CountParams('FullDescription') > 0 then
      begin
        Count := Block.CountParams('FullDescription');
        Info.FullDescription := Block.GetParamByPath('FullDescription:0');
        for I := 1 to Count - 1 do
          Info.FullDescription := Info.FullDescription + #13#10 + Block.GetParamByPath('FullDescription:' + IntToWideString(I));
      end;
      if Block.CountParams('Author' + Language) > 0 then
        Info.Author := TrimWideString(Block.GetParam('Author' + Language))
      else if Block.CountParams('Author') > 0 then
        Info.Author := TrimWideString(Block.GetParam('Author'));
      if Block.CountParams('Languages') > 0 then
      begin
        Info.UnsupportedLanguage := True;
        Language := WideString(LowerCase(AnsiString(Language)));
        Languages := TrimWideString(Block.GetParam('Languages'));
        Count := CountDelimitedPartsW(Languages, ',');
        if Languages <> '' then
          for I := 0 to Count - 1 do
            if WideString(LowerCase(AnsiString(TrimWideString(ExtractDelimitedPartW(Languages, I, ','))))) = Language then
            begin
              Info.UnsupportedLanguage := False;
              Break;
            end;
      end
      else if not HasLanguageResources then
      begin
        if not HasForeignResources then
          HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end;
      if Block.CountParams('Dependence') > 0 then
        Info.DependencyNames := TrimWideString(Block.GetParam('Dependence'));
      if Block.CountParams('Conflict') > 0 then
        Info.ConflictNames := TrimWideString(Block.GetParam('Conflict'));
      if Block.CountParams('Priority') > 0 then
        Info.Priority := ExtractDigitsToIntW(Block.GetParam('Priority'));
    except
      Info.Name := '';
      Info.Section := '';
      Info.SmallDescription := '';
      Info.FullDescription := '';
      Info.Author := '';
      if not HasLanguageResources then
      begin
        if not HasForeignResources then
          HasForeignResources := HasOtherLanguageResources;
        Info.UnsupportedLanguage := HasForeignResources;
      end
      else
        Info.UnsupportedLanguage := True;
      Info.DependencyNames := '';
      Info.ConflictNames := '';
      Info.Priority := 0;
    end;
  finally
    if Block <> nil then
      Block.Free;
  end;
end;

procedure ScanModFolders(Folder, Prefix: WideString);
var
  FileName: WideString;
  Path, ChildPrefix: WideString;

  Info: TModInfo;
  Index: Integer;
  FindData: TUnicodeSearchRec;
begin
  // Searching an explicit path cannot fall back to the current directory when
  // Mods is missing or unreadable. Recursive scans leave the caller's CWD alone.
  if SysUtils.FindFirst(NativeGamePath(Folder + '\*'), faAnyFile, FindData) = 0 then
  begin
    try
      repeat
        if (FindData.Attr and faDirectory) <> 0 then
        begin
          FileName := WideString(FindData.Name);
          if (FileName <> '.') and (FileName <> '..') then
          begin
            Path := Folder + '\' + FileName;
            Info := TModInfo.Create;
            try
              if LoadModInfo(Path, Info) then
              begin
                Info.Folder := Prefix + FileName;
                if not FindModFolder(Info.Folder, Index) then
                begin
                  ModInfos.Insert(Index, Info);
                  Info := nil; // ModInfos owns it after successful insertion.
                end;
              end
              else
              begin
                ChildPrefix := Prefix + FileName + '\';
                ScanModFolders(Path, ChildPrefix);
              end;
            finally
              Info.Free;
            end;
          end;
        end;
      until SysUtils.FindNext(FindData) <> 0;
    finally
      SysUtils.FindClose(FindData);
    end;
  end;
end;

procedure InitializeModInfos;
var
  Folder, Name, Names, Indices: WideString;
  I, J, Index, Count: Integer;
  Info: TModInfo;
begin
  if ModInfosInitialized then
    Exit;
  if ModInfos = nil then
    ModInfos := TList.Create;
  if SelectedModInfos = nil then
    SelectedModInfos := TList.Create;
  if ModIdCounts = nil then
    ModIdCounts := TBlockParEC.Create;
  if ModConflictIndex = nil then
    ModConflictIndex := TBlockParEC.Create;
  if ModDependencyIndex = nil then
    ModDependencyIndex := TBlockParEC.Create;
  Folder := NativeGamePath(WideString(GetCurrentDir) + '\Mods');
  ScanModFolders(Folder, '');
  if SelectedMods <> '' then
  begin
    Names := SelectedMods;
    Names := ReplaceAllWideString(Names, '/', '\');
    Count := CountDelimitedPartsW(Names, ',');
    for I := 0 to Count - 1 do
    begin
      Name := TrimWideString(ExtractDelimitedPartW(Names, I, ','));
      if Name <> '' then
      begin
        if not FindSavedModFolder(Folder, Name, Index) then
        begin
          Info := TModInfo.Create;
          try
            Info.Folder := Name;
            Info.MissingFolder := not LoadModInfo(Folder + '\' + Name, Info);
            ModInfos.Insert(Index, Info);
          except
            Info.Free;
            raise;
          end;
        end
        else
          Info := TModInfo(ModInfos[Index]);
        // Selection is independent of how the entry was found (including
        // missing folders). Repeated saved names must not duplicate the order.
        if not Info.Selected then
        begin
          Info.Selected := True;
          SelectedModInfos.Add(Info);
        end;
      end;
    end;
  end;
  // Count accepted entries once, after both discovery and selection recovery.
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.Name <> '' then
      if ModIdCounts.CountParams(Info.Name) <= 0 then
        ModIdCounts.AddParam(Info.Name, '1')
      else
        ModIdCounts.SetOrAddParam(Info.Name, '0');
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    Info.IndexText := IntToWideString(I);
    if Info.Name <> '' then
      Info.DuplicateName := ModIdCounts.GetParam(Info.Name) <> '1';
    if Info.ConflictNames <> '' then
    begin
      Count := CountDelimitedPartsW(Info.ConflictNames, ',');
      for J := 0 to Count - 1 do
      begin
        Indices := TrimWideString(ExtractDelimitedPartW(Info.ConflictNames, J, ','));
        if ModConflictIndex.CountParams(Indices) <= 0 then
          ModConflictIndex.AddParam(Indices, '');
      end;
    end;
    if Info.DependencyNames <> '' then
    begin
      Count := CountDelimitedPartsW(Info.DependencyNames, ',');
      for J := 0 to Count - 1 do
      begin
        Indices := TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, J, ','));
        if ModDependencyIndex.CountParams(Indices) <= 0 then
          ModDependencyIndex.AddParam(Indices, '');
      end;
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.Name = '' then
      Continue;
    if ModConflictIndex.CountParams(Info.Name) > 0 then
    begin
      Indices := ModConflictIndex.GetParam(Info.Name);
      if Indices = '' then
        ModConflictIndex.SetParam(Info.Name, IntToWideString(I))
      else
        ModConflictIndex.SetParam(Info.Name, Indices + ',' + IntToWideString(I));
    end;
    if ModDependencyIndex.CountParams(Info.Name) > 0 then
    begin
      Indices := ModDependencyIndex.GetParam(Info.Name);
      if Indices = '' then
        ModDependencyIndex.SetParam(Info.Name, IntToWideString(I))
      else
        ModDependencyIndex.SetParam(Info.Name, Indices + ',' + IntToWideString(I));
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.DependencyNames = '' then
      Continue;
    Info.DependencyCount := CountDelimitedPartsW(Info.DependencyNames, ',');
    SetLength(Info.Dependencies, Info.DependencyCount);
    for J := 0 to Info.DependencyCount - 1 do
    begin
      Indices := TrimWideString(ExtractDelimitedPartW(Info.DependencyNames, J, ','));
      Indices := ModDependencyIndex.GetParam(Indices);
      if Indices = '' then
      begin
        Info.MissingDependency := True;
        Info.Dependencies[J] := nil;
      end
      else
        Info.Dependencies[J] := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, 0, ','))]);
    end;
  end;
  for I := 0 to ModInfos.Count - 1 do
  begin
    Info := TModInfo(ModInfos[I]);
    if Info.ConflictNames = '' then
      Continue;
    Info.ConflictCount := CountDelimitedPartsW(Info.ConflictNames, ',');
    SetLength(Info.Conflicts, Info.ConflictCount);
    for J := 0 to Info.ConflictCount - 1 do
    begin
      Indices := TrimWideString(ExtractDelimitedPartW(Info.ConflictNames, J, ','));
      Indices := ModConflictIndex.GetParam(Indices);
      if Indices = '' then
      begin
        Info.Conflicts[J] := nil;
      end
      else
        Info.Conflicts[J] := TModInfo(ModInfos[ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, 0, ','))]);
    end;
  end;
  for I := 0 to ModConflictIndex.GetParamCount - 1 do
  begin
    Indices := ModConflictIndex.GetParamValue(I);
    Count := CountDelimitedPartsW(Indices, ',');
    for J := 0 to Count - 1 do
    begin
      Index := ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, J, ','));
      TModInfo(ModInfos[Index]).ReferencedAsConflict := True;
    end;
  end;
  for I := 0 to ModDependencyIndex.GetParamCount - 1 do
  begin
    Indices := ModDependencyIndex.GetParamValue(I);
    Count := CountDelimitedPartsW(Indices, ',');
    for J := 0 to Count - 1 do
    begin
      Index := ExtractDigitsToIntW(ExtractDelimitedPartW(Indices, J, ','));
      TModInfo(ModInfos[Index]).ReferencedAsDependency := True;
    end;
  end;
  ModInfosInitialized := True;
end;

procedure ClearModInfoState;
var
  Index: Integer;
begin
  ModInfosInitialized := False;
  if ModInfos <> nil then
  begin
    for Index := 0 to ModInfos.Count - 1 do
      TObject(ModInfos[Index]).Free;
    ModInfos.Clear;
  end;
  if SelectedModInfos <> nil then
    SelectedModInfos.Clear;
  if ModIdCounts <> nil then
    ModIdCounts.Clear;
  if ModConflictIndex <> nil then
    ModConflictIndex.Clear;
  if ModDependencyIndex <> nil then
    ModDependencyIndex.Clear;
end;

end.
