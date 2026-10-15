{$IFDEF ANDROID}
library Rangers;
{$ELSE}
program Rangers;
{$ENDIF}

{$APPTYPE GUI}
{$IMAGEBASE $00400000}
{$SETPEFLAGS $20}
{$I-}
{$IF not Defined(WASI) and not Defined(ANDROID) and not Defined(SRHD_IOS) and not Defined(SWITCH)}
  {$R Rangers.res}
{$ENDIF}

uses
{$IFDEF SWITCH}
  NxThreads,
{$ENDIF}
{$IFDEF FPC_WASM_EMSCRIPTEN}
  EmscriptenThreads,
{$ENDIF}
{$IFDEF UNIX}
  cthreads,
{$ENDIF}
{$IF Defined(WASI) or Defined(ANDROID) or Defined(SRHD_IOS) or Defined(SWITCH)}
  unicodeducet,
  fpwidestring,
{$ENDIF}
{$IF Defined(UNIX) and not Defined(ANDROID) and not Defined(SRHD_IOS)}
  cwstring,
{$ENDIF}
{$IFDEF MSWINDOWS}
  Windows,
{$ENDIF}
  GameEvents,
  Classes,
  SysUtils,
  DateUtils,
  GameWindow,
  GameSystem,
  GameDiagnostics,
  GameBuildInfo,
  GlobalsV,
  EC_Struct,
  Direct3D9,
  CrcUnit,
  GI_GAI,
  GR_Rect,
  EC_FileStream,
  GI_XviD,
  GI_Circle,
  GI_PolyLine,
  GR_gi,
  EC_CacheGAI,
  GI_SpaceImg,
  GI_SpaceCircle,
  GI_StarFieldImg,
  EC_CachePalBitmap,
  EC_CacheRotateBuf,
  EC_CachePlanetTempl,
  EC_CacheLightPal,
  EC_CacheTBitmap,
  EC_CacheBitmap,
  GI_StarFieldM,
  GI_StarField,
  EC_CacheGI,
  GI_GraphBuf,
  GI_ShrLight,
  GI_Frame,
  GI_Line,
  GI_SimpleImage,
  GI_TransImage,
  GI_GI,
  EC_CacheAlphaBitmap,
  GI_AlphaImage,
  GI_AImage,
  GI_Image,
  EC_CacheFont,
  GI_Label,
  GI_ScrollBar,
  GI_PanelScrollBar,
  GI_Grid,
  GI_RadioGroup,
  GI_CheckBox,
  GI_Planet,
  GI_PlanetButton,
  GI_StatusBar,
  GI_GraphButton,
  GI_CountBar,
  GI_Edit,
  GI_Zone,
  GI_TextButton,
  GI_SimpleButton,
  GI_Door,
  GI_MultiImage,
  GI_GAIFile,
  GI_InfiniteImage,
  GI_RotateImageGAI,
  EC_CacheHSAI,
  GI_RotateImage5,
  GI_RotateImage2,
  GI_RotateImage,
  GI_SBPath,
  GI_Window,
  GI_Panel,
  PopUp,
  GI_Cursor,
  GI_Main,
  aPacket,
  DirectXRenderException,
  MessageText,
  GR_Main,
  GI_MessageLoop,
  SE_SoundRnd,
  WStringUtils,
  LocalAchievements,
  GI_MessageBox,
  SE_Gate,
  aCalc,
  aPath,
  aGalaxyEvent,
  TextQuestInterface,
  TextFieldClass,
  EventClass,
  ValueListClass,
  CPDiapClass,
  ParViewStringClass,
  ParameterClass,
  CPVarClass,
  CalcParseClass,
  ParameterDeltaClass,
  LocationClass,
  SequenceClass,
  PathClass,
  TextQuest,
  EC_CacheBuf,
  ab_Global,
  GI_Tail,
  EC_Ether,
  GI_PSWeapon,
  GI_RadialEffect,
  GI_PSMissileHit,
  GI_PDTurretWeapon,
  GI_PSEyes,
  GI_PSWeapon16Esodafer,
  GI_PSWeapon14Vertix,
  GI_PSWeapon13IMHO,
  GI_PSWeapon12Turbogravir,
  GI_PSWeapon11Desintegrator,
  GI_PSWeapon10AVision,
  GI_PSWeapon09MResonator,
  GI_PSWeapon08ECutter,
  GI_PSWeapon07Blaster,
  GI_PSWeapon06Phaser,
  GI_PSWeapon05Treton,
  GI_PSWeapon03Lezka,
  GI_PSWeapon02FragCannon,
  GI_PSWeapon01Laser,
  aGroup,
  fChameleon,
  fTextBox,
  fCount2,
  aEObjInfo,
  fListBox,
  fPlanet,
  fPlanetNO,
  fGoodsShop2,
  fScaner,
  fGov,
  fFilm,
  aModsInfo,
  fMods,
  fMainForm,
  fJump,
  fGameLoad,
  fGameMenu,
  fCfgSettings,
  fGameEnd,
  fPlanetQuest,
  ab_W18,
  ab_W17,
  ab_W16,
  ab_W15,
  ab_W14,
  ab_W13,
  ab_W12,
  ab_W11,
  ab_W10,
  ab_W09,
  ab_W08,
  ab_W07,
  ab_W06,
  ab_W05,
  ab_W04,
  ab_W03,
  ab_W02,
  ab_W01,
  ab_W,
  abWall,
  fRuinsTalk,
  fPanelPlanet,
  fInfo,
  aPirate,
  aWarrior,
  aTransport,
  aKling,
  aTranclucator,
  fAbout,
  fIntroduction,
  fGameSettings,
  fGameSettings2,
  SE_Missile,
  aMissile,
  fRewards,
  fRating2,
  fSelectFace,
  fJournal,
  fLoadRobot,
  fLoadQuest,
  fLoadAB,
  aSaveLoad,
  BlockParException,
  ExceptionInfo,
  ab_Polygon,
  fLoad,
  fTalk,
  fHangar,
  fCustom,
  fCount1,
  aScriptFun,
  aScript,
  ab_Space,
  ab_ShipAI,
  ab_Object,
  SE_Ship2,
  ab_Hit,
  ab_Ship,
  ab_StopLine,
  ab_WorldLine,
  ab_WorldImage,
  ab_Zone,
  ab_Item,
  ab_MainForm,
  SE_GAIEffect,
  fGalaxy2,
  fPanelRuins,
  fEquipmentShop,
  CheatCode,
  fScore,
  SE_Planet,
  SE_Sputnik,
  SE_Asteroid,
  fFilmFile,
  SE_Ruins,
  aRuins,
  fShip2,
  SE_Star,
  aShip,
  ThreadCalc,
  SE_Container,
  aItem,
  aRanger,
  SE_Hole,
  aAsteroid,
  aPlanet,
  aNormalShip,
  aPlayer,
  fPanelLoad,
  fSaveManager,
  fPanelMain,
  fStarMap,
  SE_Meteorite,
  SE_Angel,
  SE_Anim,
  SE_Comet,
  SE_BGObj,
  SE_Laser,
  SE_StarsField,
  SE_Process,
  aEFilm,
  aEFilmEnd,
  SE_Space,
  SE_Weapon,
  aConst,
  Robot,
  GR_DX,
  EC_CacheSound,
  EC_Data,
  EC_Cache,
  VorbisFile,
  GR_Sound,
  EC_Thread,
  GR_Music,
  EC_Str,
  Achievements,
  fAchievements,
  Globals,
  SE_Garbage,
  EC_Mem,
  GR_GraphBufPal,
  EC_Expression,
  EC_BlockPar,
  EC_HsFile,
  EC_File,
  EC_Buf,
  GR_GraphBuf,
  aVector,
  aGalaxy,
  aMyFunction,
  EC_OKGF,
  DirectSound,
  BreakMessageGIException,
  aGalaxyStruct,
  GI_PSWeapon17Kafacitor;

type
  TWineGetHostVersion = procedure(var HostOS, HostVersion: PAnsiChar); stdcall;
  TWineGetBuildId = function: PAnsiChar; stdcall;
  TAD = class(TObject)
  public
    procedure ApplicationActivated(Sender: TObject);
    procedure ApplicationDeactivated(Sender: TObject);
  end;

var
  ApplicationEvents: TAD;
  ArgumentIndex: Integer;
{$IFDEF MSWINDOWS}
  WineModule: HMODULE;
{$ENDIF}
  WineGetVersion: Pointer;
  WineGetHostVersion: TWineGetHostVersion;
  WineNtToUnixFileName: Pointer;
  WineGetBuildId: TWineGetBuildId;
  WineHostOS: PAnsiChar;
  WineHostVersion: PAnsiChar;
  LanguageFileName: AnsiString;
  LanguageLine: AnsiString;
  StartupText: WideString;
  LanguageFile: TextFile;

procedure HandleApplicationActivated;
var
  Buffer: TSoundBuffer;
begin
  RuntimeActive := True;
  if SoundManager <> nil then
  begin
    Buffer := SoundManager.FirstBuffer;
    while Buffer <> nil do
    begin
      if Buffer.Streaming then
        Buffer.SetVolume(MusicVolume * MusicVolumeScale)
      else
        Buffer.SetVolume(SoundVolume);
      Buffer := Buffer.Next;
    end;
  end;
  if RegisteredScreens[CurrentScreenId] <> nil then
  begin
    FullFrameRedrawRequested := True;
    (TObject(RegisteredScreens[CurrentScreenId]) as TMessageLoopGI).InvalidateViewport;
  end;
  if MemorySnapshotActive then
    RestoreGameFromMemorySnapshot;
end;

procedure TAD.ApplicationActivated(Sender: TObject);
begin
  HandleApplicationActivated;
end;

procedure HandleApplicationDeactivated;
begin
{$IFNDEF ANDROID}
  if WindowedModeRequested then
    Exit;
{$ENDIF}
  RuntimeActive := False;
end;

procedure TAD.ApplicationDeactivated(Sender: TObject);
begin
  HandleApplicationDeactivated;
end;

procedure HandleMessageIdle; { Checks background work, but this build performs no idle action. Assigned to GR_Main.OnMessageIdle. Removing the empty tests changes native behavior and bytes. }
begin
  if MemorySnapshotActive then
    Exit;
  if Galaxy = nil then
    Exit;
  if (NewGameGenerationThread <> nil) and NewGameGenerationThread.IsRunning then
    Exit;
  if (GameLoadScreen <> nil) and GameLoadScreen.IsLoading then
    Exit;
  if IsTurnCalculationRunning then
    Exit;
end;

procedure HandleMessageResume; { Empty conditional callback assigned to GR_Main.OnMessageResume. }
begin
  if MemorySnapshotActive then
    Exit;
  if Galaxy = nil then
    Exit;
end;

procedure PurgeCacheDirectoryFiles; { Nonrecursive; restores the previous working directory. }
var
  FileName, OldDirectory: AnsiString;
  Search: TSearchRec;
begin
  OldDirectory := GetCurrentDir;
  SetCurrentDir(NativeGamePath(AnsiString(GetGameUserDirectory + 'Cache\')));
  // Win32's *.* also included extensionless cache files.
  if SysUtils.FindFirst('*', faAnyFile, Search) = 0 then
  begin
    repeat
      FileName := Search.Name;
      if (FileName <> '.') and (FileName <> '..') then
        SysUtils.DeleteFile(NativeGamePath(AnsiString(GetGameUserDirectory + 'Cache\' + WideString(FileName))));
    until SysUtils.FindNext(Search) <> 0;
    SysUtils.FindClose(Search);
  end;
  SetCurrentDir(NativeGamePath(OldDirectory));
end;

function CollectInstallLanguageCodes: WideString; { Comma-separated lowercase names from INSTALL_*.txt in the current directory. }
var
  FileName, LanguageCode: WideString;
  LowerCode: AnsiString;
  NameLength: Integer;
  Search: TSearchRec;
begin
  Result := '';
  // Unix FindFirst masks are case-sensitive even on a case-insensitive volume.
  // Match the original Windows mask explicitly so INSTALL_ENGLISH.TXT is found.
  if SysUtils.FindFirst('*', faAnyFile, Search) = 0 then
  begin
    repeat
      FileName := Search.Name;
      if ((Search.Attr and faDirectory) <> 0)
          or not SameText(Copy(FileName, 1, 8), 'INSTALL_')
          or not SameText(ExtractFileExt(FileName), '.txt') then
        Continue;
      NameLength := Length(FileName);
      LanguageCode := Copy(FileName, 9, NameLength - 12);
      LowerCode := AnsiLowerCase(AnsiString(LanguageCode));
      if Result = '' then
        Result := WideString(LowerCode)
      else
        Result := Result + ',' + WideString(LowerCode);
    until SysUtils.FindNext(Search) <> 0;
    SysUtils.FindClose(Search);
  end;
end;

procedure PresentGameFailure(Report: TGameExceptionReport);
var
  Summary: UnicodeString;
begin
  Summary := UnicodeString(Copy(GameExceptionSummary(Report), 1, 2500));
  if GameDiagnosticsAvailable then
    Summary := Summary + LineEnding + LineEnding + 'Details: ' + GameDiagnosticsPath
  else
    Summary := Summary + LineEnding + LineEnding + 'The diagnostic log could not be written.';
  try
    GameMessageBox(Summary, 'Space Rangers HD — error', $10);
  except
    LogCurrentGameException('diagnostics', 'Unable to display the error dialog');
  end;
end;

procedure RunGameSession;
var
  FailureReport: TGameExceptionReport;
  Attempt: Integer;
  WorkersStopped, RetryRequested: Boolean;
  RetryPrompt: UnicodeString;
begin
{$IF Defined(WASI) or Defined(ANDROID)}
  SetMultiByteConversionCodePage(CP_UTF8);
  // OS path encoding is separate from strings returned by RTL file routines.
  SetMultiByteFileSystemCodePage(CP_UTF8);
  SetMultiByteRTLFileSystemCodePage(CP_UTF8);
{$ENDIF}
  DecimalSeparator := '.';
  MainRuntimeThreadId := System.GetCurrentThreadID;
  GR_Main.CCInterface := TCCInterface.Create;
  RuntimeExitCheckCallback1 := HandleRuntimeExitCheck1;
  RuntimeExitCheckCallback2 := HandleRuntimeExitCheck2;
  DebugKeyCallback := HandleDebugKey;
  RuntimeStartupTick := GameTickCount;
  OnMessageIdle := @HandleMessageIdle;
  OnMessageResume := @HandleMessageResume;
  ApplicationEvents := TAD.Create;
  OnGameActivated := ApplicationEvents.ApplicationActivated;
  OnGameDeactivated := ApplicationEvents.ApplicationDeactivated;
  for ArgumentIndex := 1 to ParamCount do
    if LowerCase(ParamStr(ArgumentIndex)) = 'savemergedcfg' then
      DumpLoadedConfig := True;
  // The executable can live in an app bundle; resources are selected explicitly.
  for ArgumentIndex := 1 to ParamCount do
    if Copy(ParamStr(ArgumentIndex), 1, 11) = '--game-dir=' then
      SetGameDirectory(UTF8Decode(Copy(ParamStr(ArgumentIndex), 12, MaxInt)));
  Randomize;
  Attempt := 0;
  repeat
    Inc(Attempt);
    FailureReport := nil;
    LogGameMessage(gllInfo, 'startup', 'Starting attempt ' + IntToStr(Attempt));
    try
      try
        ExitCode := 0;
        PostLoadScreenId := screenMainMenu;
        if SkipModsOnReload then
          LogGameMessage(gllWarning, 'startup', 'Retrying with mods disabled');
        SelectedLanguage := '';
        AvailableLanguageCodes := '';
        RequestedLanguage := '';
        for ArgumentIndex := 1 to ParamCount do
          if Copy(ParamStr(ArgumentIndex), 1, 11) = '--language=' then
            RequestedLanguage := UTF8Decode(Copy(ParamStr(ArgumentIndex), 12, MaxInt))
          else if (ParamStr(ArgumentIndex) = '--language') and (ArgumentIndex < ParamCount) then
            RequestedLanguage := UTF8Decode(ParamStr(ArgumentIndex + 1));
        InitializeAchievementDefinitions;
        if not SkipModsOnReload then
          InitializePlatformRuntimeAndMainWindow;
        if InstallConfig.CountParamsByPath('GameDistributor') > 0 then
          LogGameMessage(gllInfo, 'startup', 'Game data distributor=' + InstallConfig.GetParamByPathOrMarker('GameDistributor'));
        SelectedLanguage := 'english';
        AvailableLanguageCodes := CollectInstallLanguageCodes;
        LanguageFileName := AnsiString(GetGameUserDirectory + 'Lang.txt');
        if FileExists(NativeGamePath(LanguageFileName)) then
        begin
          AssignFile(LanguageFile, NativeGamePath(LanguageFileName));
          Reset(LanguageFile);
          while not Eof(LanguageFile) do
          begin
            Readln(LanguageFile, LanguageLine);
            StartupText := WideString(LanguageLine);
            if CountDelimitedPartsW(StartupText, '=') > 1 then
              if ExtractDelimitedPartW(StartupText, 0, '=') = 'Lang' then
                SelectedLanguage := TrimWideString(ExtractDelimitedPartW(StartupText, 1, '='));
          end;
          CloseFile(LanguageFile);
        end;
        LoadLanguageAndPackages;
        InitializeScriptHostRuntime;
        LoadLocalAchievements;
        RunningUnderWine := False;
{$IFDEF MSWINDOWS}
        WineModule := Windows.LoadLibrary('ntdll.dll');
        if WineModule > 32 then
        begin
          WineGetVersion := GetProcAddress(WineModule, 'wine_get_version');
          @WineGetHostVersion := GetProcAddress(WineModule, 'wine_get_host_version');
          WineNtToUnixFileName := GetProcAddress(WineModule, 'wine_nt_to_unix_file_name');
          @WineGetBuildId := GetProcAddress(WineModule, 'wine_get_build_id');
          RunningUnderWine :=
              (WineGetVersion <> nil) or Assigned(WineGetHostVersion) or (WineNtToUnixFileName <> nil) or Assigned(WineGetBuildId);
          if RunningUnderWine then
          begin
            LogGameMessage(gllInfo, 'system', 'Compatibility runtime=Wine/Proton');
            if Assigned(WineGetHostVersion) then
            begin
              WineGetHostVersion(WineHostOS, WineHostVersion);
              LogGameMessage(gllInfo, 'system', 'Host=' + AnsiString(WineHostOS) + ' ' + AnsiString(WineHostVersion));
            end;
            if Assigned(WineGetBuildId) then
              LogGameMessage(gllInfo, 'system', 'Wine build=' + AnsiString(WineGetBuildId()));
          end;
          FreeLibrary(WineModule);
        end;
{$ENDIF}
        while True do
        begin
          if ReloadScriptTemplates or ReloadModsRequested then
            LoadDatConfigAndModOverrides;
          if ReloadModsRequested then
          begin
            LoadSelectedModInstallBlocks;
            if not LoadConfiguredPackages then
              raise Exception.Create('Cannot open the configured game packages');
            ReloadModsRequested := False;
          end;
          InitializeRuntimeAndSettings;
          InitializeGlobalUiRuntime;
          InitializeRobotRuntime;

          if Galaxy <> nil then
          begin
            Galaxy.RefreshAllShipDerivedState;
            Galaxy.ReapplyInterfaceOverrides;
            Galaxy.BindScriptImports;
          end;
          if BuildVersionMismatch then
            raise Exception.Create('Game data compatibility mismatch; expected version ' + GameVersionText);
          RequestedScreenId := screenLoad;
          ScreenLoadMode := 0;
          if PostLoadScreenId = screenArcadeBattle then
            PostLoadScreenId := screenMainMenu;
          if ScreenUsesCompositeLoadAssets(PostLoadScreenId) then
            ScreenLoadMode := 3;
          RunMainScreenStateLoop;
          // Stop calculation before releasing the UI and its script resources.
          if TurnCalculationThread <> nil then
          begin
            TurnCalculationThread.RequestStop;
            TurnCalculationThread.WaitForIdle(INFINITE);
          end;
          if Galaxy <> nil then
          begin
            GR_Main.CCInterface.GetProtectedStateXorSeed;
            Galaxy.RestoreProtectedState;
            Galaxy.ClearIntegrityStatus;
          end;
          FinalizeRobotRuntime;
          FinalizeGlobalUiRuntime;
          FinalizeRuntimeAndSettings;
          if ((RequestedScreenId = screenNone) and (PostLoadScreenId = screenNone)) or ExitScreenLoop then
          begin
            FreeDatConfigRoots;
            Break;
          end;
          if ReloadModsRequested then
          begin
            ResetScriptHostRuntimeState;
            ResetInstalledPackageState;
            FreeDatConfigRoots;
            ClearModInfoState;
            SkipModsOnReload := False;
          end;
        end;
        SkipModsOnReload := False;
        if Galaxy <> nil then
        begin
          if IsTurnCalculationRunning then
            WaitForTurnCalculation;
          Galaxy.Free;
          Galaxy := nil;
          if MemorySnapshotBuffer <> nil then
            MemorySnapshotBuffer.Free;
          MemorySnapshotBuffer := nil;
          MemorySnapshotActive := False;
        end;
        FreeAllRandomSounds;
        FinalizeScriptHostRuntime;
        FinalizePlatformRuntime;
        if StartupCleanupObject <> nil then
        begin
          StartupCleanupObject.Free;
          StartupCleanupObject := nil;
        end;
        PurgeCacheDirectoryFiles;
      except
        // Own the original report before cleanup can raise another exception.
        FailureReport := CaptureGameException('Game session attempt ' + IntToStr(Attempt));
        LogGameException(FailureReport, 'game');
        ExitScreenLoop := True;
        WorkersStopped := False;
        try
          StopGalaxyWorkers;
          WorkersStopped := True;
        except
          LogCurrentGameException('shutdown', 'Stopping workers after the game failure');
        end;
        // Startup can retry without mods. A partially generated or simulated
        // galaxy must never be reused by that recovery path.
        if WorkersStopped
            and (Galaxy = nil)
            and (NewGameGenerationThread = nil)
            and not (ExceptObject is EWorkerFailure)
            // Native faults may leave library state unsafe for an in-process retry.
            and not GameExceptionPreventsRecovery(ExceptObject)
            and not SuppressModRetryPrompt
            and (SelectedMods <> '')
            and not SkipModsOnReload then
        begin
          RetryRequested := False;
          try
            RetryPrompt :=
                'Failed to launch: '
                    + UnicodeString(Copy(GameExceptionSummary(FailureReport), 1, 500))
                    + LineEnding
                    + LineEnding
                    + 'Try restarting without mods?';
            if GameDiagnosticsAvailable then
              RetryPrompt := RetryPrompt + LineEnding + 'Details: ' + GameDiagnosticsPath;
            if GameMessageBox(RetryPrompt, 'Space Rangers HD', $1 or $10) = 1 then
            begin
              // Retire audio/cache/UI users before closing the packages they
              // read. This mirrors normal mod reload teardown; a cleanup
              // failure cancels recovery and preserves the original report.
              FinalizeRobotRuntime;
              FinalizeGlobalUiRuntime;
              FinalizeRuntimeAndSettings;
              FreeAllRandomSounds;
              ResetScriptHostRuntimeState;
              FreeDatConfigRoots;
              ResetInstalledPackageState;
              FreeAndNil(ModInstallConfigs);
              FreeAndNil(ModLanguageInstallConfigs);
              FreeAndNil(LanguageInstallConfig);
              ClearModInfoState;
              RetryRequested := True;
            end;
          except
            LogCurrentGameException('startup', 'Preparing a retry without mods');
          end;
          if RetryRequested then
          begin
            SkipModsOnReload := True;
            ExitScreenLoop := False;
            raise;
          end;
        end;
        SkipModsOnReload := False;
        // Do not destroy shared objects if worker shutdown itself failed.
        if WorkersStopped then
          try
            FreeAndNil(NewGameGenerationThread);
            FinalizeSaveWriter(False);
            if Galaxy <> nil then
            begin
              Galaxy.Free;
              Galaxy := nil;
            end;
            if MemorySnapshotBuffer <> nil then
              MemorySnapshotBuffer.Free;
            MemorySnapshotBuffer := nil;
            MemorySnapshotActive := False;
            FinalizeGlobalUiRuntime;
            FinalizeRuntimeAndSettings;
            FreeAllRandomSounds;
            FinalizeScriptHostRuntime;
            FinalizePlatformRuntime;
            if StartupCleanupObject <> nil then
            begin
              StartupCleanupObject.Free;
              StartupCleanupObject := nil;
            end;
          except
            // Damaged/partially initialized state may also fail destruction.
            // Keep the original failure; all galaxy workers are already idle.
            LogCurrentGameException('shutdown', 'Cleanup after the game failure');
          end;
        raise;
      end;
    except
      if FailureReport = nil then
        FailureReport := CaptureGameException('Game session attempt ' + IntToStr(Attempt));
      LogGameException(FailureReport, 'game');
      ExitCode := 1;
      if not SkipModsOnReload then
        PresentGameFailure(FailureReport);
    end;
    FreeAndNil(FailureReport);
  until not SkipModsOnReload;
end;

procedure RunGame;
var
  Report: TGameExceptionReport;
  InstanceLocked: Boolean;
begin
  InstanceLocked := False;
  ExitCode := 0;
  // The profile directory selects the instance lock and the log location.
  for ArgumentIndex := 1 to ParamCount do
    if Copy(ParamStr(ArgumentIndex), 1, 11) = '--user-dir=' then
      SetGameUserDirectory(UTF8Decode(Copy(ParamStr(ArgumentIndex), 12, MaxInt)))
    else if ParamStr(ArgumentIndex) = '--experimental-low-res' then
      GameCompactLayoutEnabled := True
    else if ParamStr(ArgumentIndex) = '--renderer=sdl' then
      GameRendererPreference := grpSDL
    else if ParamStr(ArgumentIndex) = '--renderer=software' then
      GameRendererPreference := grpSoftware
    else if ParamStr(ArgumentIndex) = '--on-screen-keyboard' then
      OnScreenKeyboardEnabled := True
    else if ParamStr(ArgumentIndex) = '--no-on-screen-keyboard' then
      OnScreenKeyboardEnabled := False;
  try
    // A second instance must not rotate or overwrite the running game's log.
    InstanceLocked := LockGameInstance;
    if not InstanceLocked then
    begin
      GameMessageBox('Space Rangers HD is already running.', 'Space Rangers HD', $10);
      ExitCode := 1;
      Exit;
    end;
    InitializeGameDiagnostics(GameUserDirectory);
    OnGameNativeExceptionDetails := @GameNativeExceptionDetails;
    LogGameMessage(
        gllInfo,
        'startup',
        'SpaceRangersHD_FPC revision=' + GameBuildRevision + ' source=' + GameBuildSourceState + ' profile=' + GameBuildProfile
    );
    LogGameMessage(gllInfo, 'startup', 'Target=' + GameBuildTarget + ' backend=' + GameBuildBackend + ' compiler=' + GameBuildCompiler);
    LogGameMessage(gllInfo, 'startup', 'FPC revision=' + GameBuildCompilerRevision + ' source=' + GameBuildCompilerSourceState);
{$IFDEF MSWINDOWS}
    LogGameMessage(gllInfo, 'startup', 'Executable image base=$' + IntToHex(PtrUInt(GetModuleHandle(nil)), SizeOf(Pointer) * 2));
{$ENDIF}
    RunGameSession;
  except
    // Covers failures before assets/configuration or a native window exists.
    Report := CaptureGameException('Application startup');
    try
      if not GameDiagnosticsAvailable then
      begin
        InitializeGameDiagnostics(UnicodeString(GetTempDir(False)) + 'rangers-fpc-startup-' + IntToStr(GetProcessID));
      end;
      LogGameException(Report, 'startup');
      ExitCode := 1;
      PresentGameFailure(Report);
    finally
      Report.Free;
    end;
  end;
  // The logger closes after SDL/graphics unit finalization.
end;

{$IFDEF ANDROID}
var
  AndroidGameStarted: Boolean = False;

function AndroidGameMain(ArgumentCount: LongInt; Arguments: PPAnsiChar): LongInt; cdecl;
begin
  // SDL calls this on its application thread after the launcher has selected
  // private resource/profile directories and loaded this library. A new game
  // session gets a fresh Android process; the original globals are not reusable.
  if AndroidGameStarted then
    Exit(1);
  AndroidGameStarted := True;
  System.argc := ArgumentCount;
  System.argv := Arguments;
  RunGame;
  // Android keeps this library loaded, then discards its private game process;
  // unit finalization is not a reliable completion boundary on that platform.
  CloseGameDiagnostics;
  Result := ExitCode;
end;

exports
  AndroidGameMain name 'sr_fpc_main';

begin
end.
{$ELSE}
begin RunGame;
end.
{$ENDIF}
