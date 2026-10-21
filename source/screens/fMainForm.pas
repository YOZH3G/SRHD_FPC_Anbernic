unit fMainForm;

{$I GameOptions.inc}

interface

uses
  EC_BlockPar,
  GI_MessageLoop,
  Types,
  fPanelLoad;

type

  TfMainForm = class;

  TfMainForm = class(TMessageLoopGI)
  private
    procedure FitMobileMenu;
{$IFDEF SRHD_ANBERNIC}
    procedure AddControlsButton;
    procedure ControlsClicked(Sender: TObjectGI);
{$ENDIF}
  public
    BackgroundTimer: PCallbackTimerGI;
    BackgroundScrollOffset: Integer;
    LastMenuShipAnimation: Integer;
    LastGaalShipAnimation: Integer;
    MenuTextState: WideString;
    GapE4: array[0..7] of Byte;
    PopupState: Integer;
    LoadPanel: TfPanelLoad;
    procedure OnOpen; override;
    procedure OnClose; override;
    procedure SelectMusic; override;
    procedure InitializeLayout; override;
    procedure ExecuteUiCode(Block: TBlockParEC; Key: Cardinal); override;
    constructor Create;
    destructor Destroy; override;
    procedure QuitClicked(Sender: TObjectGI);
    procedure NewGameClicked(Sender: TObjectGI);
    procedure AchievementsClicked(Sender: TObjectGI);
    procedure LoadGameClicked(Sender: TObjectGI);
    procedure SettingsClicked(Sender: TObjectGI);
    procedure ScoresClicked(Sender: TObjectGI);
    procedure AboutClicked(Sender: TObjectGI);
    procedure MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
    procedure MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
    procedure MenuShipAnimationFinished(Sender: TObjectGI);
    procedure GaalShipAnimationFinished(Sender: TObjectGI);
    procedure ScrollBackground(Timer: PCallbackTimerGI; UserData: PtrInt);
    procedure ClosePopup;
    procedure RobotBattleClicked(Sender: TObjectGI);
    procedure TextQuestClicked(Sender: TObjectGI);
    procedure ArcadeBattleClicked(Sender: TObjectGI);
    procedure ModsClicked(Sender: TObjectGI);
  end;

implementation

uses
  GameDiagnostics,
  aGalaxy,
  aSaveLoad,
  Classes,
  GameInput,
  GameWindow,
  Math,
  SysUtils,
  GR_Main,
  Globals,
  GlobalsV,
  GI_GraphButton,
  GI_GAI,
  GI_MessageBox,
  GI_Label,
  GI_Image,
  GI_Main,
  EC_Str,
  aMyFunction,
  aScript,
  aConst,
  fShip2,
  fSaveManager,
  fMods,
  Robot;

constructor TfMainForm.Create;
begin
  inherited Create;
  LoadPanel := TfPanelLoad.Create;
end;

destructor TfMainForm.Destroy;
begin
  if LoadPanel <> nil then
  begin
    LoadPanel.Free;
    LoadPanel := nil;
  end;
  inherited Destroy;
end;

procedure TfMainForm.FitMobileMenu;
const
{$IFDEF SRHD_ANBERNIC}
  ButtonNames: array[0..8] of WideString = ('New', 'Load', 'Settings', 'Controls', 'Score', 'Achievements', 'About', 'Exit', 'Circle');
{$ELSE}
  ButtonNames: array[0..7] of WideString = ('New', 'Load', 'Settings', 'Score', 'Achievements', 'About', 'Exit', 'Circle');
{$ENDIF}
var
  ButtonBounds, HeaderBounds: TRect;
  Control: TObjectGI;
  CenterX, HeaderScale, ButtonScale, MenuTop, MenuBottom, MenuLeft: Single;
  Index: Integer;

  procedure PlaceControls(const Names: array of WideString; Scale, SourceCenterX, SourceTop, TargetTop: Single);
  var
    Name: WideString;
    Item: TObjectGI;
    Offset: TPoint;
  begin
    Offset := Classes.Point(Round(CenterX / Scale - SourceCenterX), Round(TargetTop / Scale - SourceTop));
    for Name in Names do
    begin
      Item := GetByName(Name);
      Item.DisplayScale := Scale;
      Item.SetPosition(Classes.Point(Item.LocalPosition.X + Offset.X, Item.LocalPosition.Y + Offset.Y));
    end;
  end;

begin
  if not GameMobileUiEnabled or not HardwareRenderingEnabled then
    Exit;
  RootUiObject.UpdateAbsolutePosition;
  RootUiObject.UpdateSubtreeHitBounds;
  ButtonBounds := GetByName(ButtonNames[0]).HitTestBounds;
  // The circle follows the entries but its decorative padding must not
  // determine how much room their touch targets can use.
  for Index := 1 to High(ButtonNames) - 1 do
    Types.UnionRect(ButtonBounds, ButtonBounds, GetByName(ButtonNames[Index]).HitTestBounds);
  if (ButtonBounds.Right <= ButtonBounds.Left) or (ButtonBounds.Bottom <= ButtonBounds.Top) then
    Exit;
  Control := GetByName('Caption');
  CenterX := (Control.HitTestBounds.Left + Control.HitTestBounds.Right) / 2;
  Types.UnionRect(HeaderBounds, Control.HitTestBounds, GetByName('SubName').HitTestBounds);
  // Keep the compact menu's title, subtitle and entries on one center line.
  // A slightly shorter header leaves room for larger entries on phone screens.
  HeaderScale := Min(1, GameScreenHeight / 900);
  MenuTop := 24 + (HeaderBounds.Bottom - HeaderBounds.Top) * HeaderScale;
  MenuBottom := GetByName('LogoElemental').HitTestBounds.Top - 8;
  ButtonScale := GetGameMobileUiScale;
  ButtonScale := Min(ButtonScale, 2 * Min(CenterX - 12, GameScreenWidth - 12 - CenterX) / (ButtonBounds.Right - ButtonBounds.Left));
  MenuLeft := CenterX - (ButtonBounds.Right - ButtonBounds.Left) * ButtonScale / 2;
  // On narrower displays, the bottom shortcuts also extend below the column.
  if MenuLeft < GetByName('LMods').HitTestBounds.Right + 8 then
    MenuBottom := Min(MenuBottom, GetByName('LoadRobot').HitTestBounds.Top - 8);
  ButtonScale := Min(ButtonScale, (MenuBottom - MenuTop) / (ButtonBounds.Bottom - ButtonBounds.Top));
  if ButtonScale <= 0 then
    Exit;
  PlaceControls(['Caption', 'CaptionBlur', 'SubName'], HeaderScale, CenterX, HeaderBounds.Top, 12);
  MenuTop := MenuTop + (MenuBottom - MenuTop - (ButtonBounds.Bottom - ButtonBounds.Top) * ButtonScale) / 2;
  PlaceControls(ButtonNames, ButtonScale, (ButtonBounds.Left + ButtonBounds.Right) / 2, ButtonBounds.Top, MenuTop);
end;

{$IFDEF SRHD_ANBERNIC}
function ControlsText(const English, Russian: WideString): WideString;
begin
  if LowerCaseWideString(SelectedLanguage) = 'russian' then
    Result := Russian
  else
    Result := English;
end;

procedure TfMainForm.AddControlsButton;
const
  // The original seven entries keep their span; Controls follows Settings.
  Entries: array[0..7] of WideString = ('New', 'Load', 'Settings', 'Controls', 'Score', 'Achievements', 'About', 'Exit');
var
  Template: TGraphButtonGI;
  Button: TGraphButtonGI;
  Top, Span, Index: Integer;
begin
  Template := GetByName('About') as TGraphButtonGI;
  Button := TGraphButtonGI.Create(Template.Parent);
  Button.SetName('Controls');
  Button.SetDepth(Template.Depth);
  Button.SetSize(Template.ClientSize);
  Button.HitKind := gbhRect;
  Button.UpOnlyDown := True;
  Button.EnterSound := Template.EnterSound;
  Button.LeaveSound := Template.LeaveSound;
  Button.ClickSound := Template.ClickSound;
  // The other entries are artwork. Letter this one with the largest font,
  // outlined, in their colors: light grey, yellow under the cursor.
  Button.SetCaptionFontName(HugeFontName);
  Button.SetCaption(ControlsText('CONTROLS', 'УПРАВЛЕНИЕ'));
  Button.CaptionLabel.SetTextBorderWidth(1);
  Button.CaptionLabel.SetTextBorderColor(CurrentPixelFormat.PackRgbBytes(30, 20, 10));
  Button.CaptionColors[0] := CurrentPixelFormat.PackRgbBytes(222, 222, 222);
  Button.CaptionColors[1] := CurrentPixelFormat.PackRgbBytes(255, 200, 40);
  Button.CaptionColors[2] := Button.CaptionColors[1];
  Button.CaptionColors[3] := Button.CaptionColors[1];
  Button.UpdateStateVisuals(False);
  Top := GetByName('New').LocalPosition.Y;
  Span := GetByName('Exit').LocalPosition.Y - Top;
  for Index := 0 to High(Entries) do
    with GetByName(Entries[Index]) do
      SetPosition(Classes.Point(Template.LocalPosition.X, Top + Span * Index div High(Entries)));
end;

procedure TfMainForm.ControlsClicked(Sender: TObjectGI);
var
  Text: WideString;

  procedure Heading(const English, Russian: WideString);
  begin
    // A space keeps the empty line before the heading.
    if Text <> '' then
      Text := Text + ' ' + #13#10;
    Text := Text + '<color=140,40,0>' + ControlsText(English, Russian) + EndColorTag + #13#10;
  end;

  procedure Line(const Keys, English, Russian: WideString);
  begin
    Text := Text + TextHighlightColorTag + Keys + EndColorTag + ' - ' + ControlsText(English, Russian) + #13#10;
  end;

begin
  Text := '';
  Heading('GAMEPAD', 'ГЕЙМПАД');
  Line('D-pad / ' + ControlsText('left stick', 'левый стик'), 'cursor', 'курсор');
  Line('A / B', 'left / right mouse button', 'левая / правая кнопка мыши');
  Line('X', 'Space: next turn', 'пробел: следующий ход');
  Line('Y', 'Tab', 'Tab');
  Line('Start', 'Enter', 'Enter');
  Line('Select', 'Escape: menu, back', 'Escape: меню, назад');
  Line(
      'L1 / R1',
      'previous / next panel window: ship, map, quests, planet sections',
      'предыдущее / следующее окно панели: корабль, карта, задания, разделы планеты'
  );
  Line(
      'L2',
      'on-screen keyboard in a text field; quick load 3 (F6) in space',
      'экранная клавиатура в текстовом поле; в космосе - быстрая загрузка 3 (F6)'
  );
  Line('R2', 'Shift', 'Shift');
  Line('Select + Start', 'quit the game', 'выход из игры');
  if GetEnvironmentVariable('SRHD_APP_VOLUME') = '1' then
    Line(ControlsText('Volume buttons', 'Кнопки громкости'), 'game volume', 'громкость игры');
  Heading('ARCADE COMBAT', 'АРКАДНЫЙ БОЙ');
  Line(
      'D-pad / ' + ControlsText('left stick', 'левый стик'),
      'fly where pressed',
      'лететь в направлении нажатия'
  );
  Line(
      ControlsText('Right stick', 'Правый стик'),
      'forward, back and turn, as the arrow keys',
      'вперёд, назад и поворот, как стрелки'
  );
  Line(
      'R1 + D-pad / ' + ControlsText('stick', 'стик'),
      'keep course: up/down thrust, left/right turn',
      'без смены курса: вверх/вниз - тяга, влево/вправо - поворот'
  );
  Line('A', 'primary weapons', 'основное оружие');
  Line('B / X / R2', 'secondary weapons', 'дополнительное оружие');
  Line('L2', 'next primary weapon', 'следующее основное оружие');
  Line('Y', 'autopilot', 'автопилот');
  Line('Start', 'pause; the cursor works while paused', 'пауза; на паузе работает курсор');
  Line('Select', 'leave the battle', 'выход из боя');
  ShowMessageBoxGI(Self, Text, mbgOK or mbgLeftAlign);
end;
{$ENDIF}

procedure TfMainForm.InitializeLayout;
var
  OffsetX, OffsetY, LogoShift: Integer;
  LayoutExtraWidth, LayoutExtraHeight: Integer;
  WideLayout: Boolean;
  Extension: WideString;
  CaptionControl: TObjectGI;
begin
  inherited InitializeLayout;
{$IFDEF SRHD_ANBERNIC}
  AddControlsButton;
{$ENDIF}
  LayoutExtraWidth := ExtraScreenWidth;
  LayoutExtraHeight := ExtraScreenHeight;
  if GameCompactLayoutEnabled and HardwareRenderingEnabled and (GameScreenWidth < 1024) then
  begin
    LayoutExtraWidth := 0;
    LayoutExtraHeight := 0;
  end;
  LoadPanel.InitializeLayout(Self);
  LogGameMessage(gllDebug, 'ui', 'Initializing layout fMainForm');
  WideLayout := (GameScreenWidth >= 1600) and not GameMobileUiEnabled;
  with GetByName('LVersion') as TLabelGI do
  begin
    if Cardinal(GameScreenWidth) >= 1280 then
    begin
      SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight));
      SetText(ReplaceAllWideString(LocalizedText('FormMain.Version'), '<Value>', GameVersionText));
      LogoShift := 0;
    end
    else
    begin
      SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight - 7));
      SetText(ReplaceAllWideString(LocalizedText('FormMain.Version2'), '<Value>', GameVersionText));
      LogoShift := 16;
    end;
  end;
  with GetByName('LogoElemental') do
    SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight - LogoShift));
  with GetByName('Logo1C') do
    SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight - LogoShift));
  with GetByName('LogoKatauri') do
    SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight - LogoShift));
  with GetByName('LogoSNK') do
    SetPosition(Classes.Point(LocalPosition.X + LayoutExtraWidth, LocalPosition.Y + LayoutExtraHeight - LogoShift));
  if ((ExtraScreenWidth <> 0) or (ExtraScreenHeight <> 0))
      and not (GameCompactLayoutEnabled and HardwareRenderingEnabled and (GameScreenWidth < 1024)) then
  begin
    ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
    OffsetX := 0;
    OffsetY := 0;
    if WideLayout then
    begin
      OffsetX := -250;
      if (Cardinal(GameScreenHeight) >= 900) and (Cardinal(GameScreenHeight) < 1040) then
        OffsetY := (1040 - GameScreenHeight) shr 1;
    end;
    with GetByName('MainPanel') do
    begin
      SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      with FindByNameRecursive('AnimMain') do
      begin
        if ExtraScreenHeight < 0 then
        begin
          SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
          SetSize(Classes.Point(GameScreenWidth, ClientSize.Y));
        end
        else
          SetSize(Classes.Point(GameScreenWidth, GameScreenHeight));
      end;
      with FindByNameRecursive('MicroText') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('Circle') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('New') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Score') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Achievements') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Load') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Settings') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
{$IFDEF SRHD_ANBERNIC}
      with FindByNameRecursive('Controls') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
{$ENDIF}
      with FindByNameRecursive('About') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('Exit') do
        SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + OffsetX, LocalPosition.Y + ExtraScreenHeight div 2 + OffsetY));
      with FindByNameRecursive('AnimAddonShip') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadRobot') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadQuest') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadAB') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('Mods') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadRobotCnt') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadQuestCnt') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LoadABCnt') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('ModsCnt') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LRobot') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LQuest') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LAB') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      with FindByNameRecursive('LMods') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
      if ExtraScreenWidth > 0 then
      begin
        CaptionControl := FindByNameRecursive('Caption');
        if CaptionControl is TgaiGI then
        begin
          with CaptionControl as TgaiGI do
          begin
            if WideLayout and (Cardinal(GameScreenHeight) >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, 57));
              SetImagePath('Bm.FormMain3.CaptionLarge');
            end
            else
              SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end
        else
        begin
          with CaptionControl as TImageGI do
          begin
            if WideLayout and (Cardinal(GameScreenHeight) >= 900) then
            begin
              SetSize(Classes.Point(843, 218));
              SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2, 57));
              Extension :=
                  ExtractFileExtNoDotW(
                      Trim(
                          LowerCase(
                              AnsiString(
                                  CacheDataRoot
                                      .FindEntry('Bm')
                                      .ChildData
                                      .FindEntry('FormMain3')
                                      .ChildData
                                      .FindEntry('CaptionLarge')
                                      .SharedFileRef
                                      .FileRef
                                      .FileName
                              )
                          )
                      )
                  );
              if Extension = 'gai' then
                SetImagePath('GAI,Bm.FormMain3.CaptionLarge')
              else
                SetImagePath('GI,Bm.FormMain3.CaptionLarge');
            end
            else
              SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
          end;
        end;
        with FindByNameRecursive('CaptionBlur') as TImageGI do
        begin
          if WideLayout and (Cardinal(GameScreenHeight) >= 900) then
            SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2 - 7, -29))
          else
            SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
        end;
        with FindByNameRecursive('SubName') as TImageGI do
        begin
          if WideLayout and (Cardinal(GameScreenHeight) >= 900) then
          begin
            SetImagePath('GI,Bm.FormMain3.SubLarge');
            SetSize(Classes.Point(932, 76));
            SetPosition(Classes.Point((GameScreenWidth - ClientSize.X) div 2 - 54, 320));
          end
          else
            SetPosition(Classes.Point(LocalPosition.X + ExtraScreenWidth div 2 + 50, LocalPosition.Y));
        end;
      end;
      with FindByNameRecursive('Planet') do
        SetPosition(Classes.Point(LocalPosition.X, LocalPosition.Y + ExtraScreenHeight));
    end;
  end;
  if GameCompactLayoutEnabled and HardwareRenderingEnabled and (GameScreenWidth < 1024) then
  begin
    ViewportRect := Classes.Rect(0, 0, GameScreenWidth, GameScreenHeight);
    GetByName('MainPanel').DisplayScale := Min(GameScreenWidth / 1024, GameScreenHeight / 768);
  end
  else
    FitMobileMenu;
  with GetByName('LoadRobot') as TGraphButtonGI do
  begin
    SetActive(CheckRobotRuntimeAvailable);
    UpCallback := RobotBattleClicked;
  end;
  with GetByName('LoadQuest') as TGraphButtonGI do
    UpCallback := TextQuestClicked;
  with GetByName('LoadAB') as TGraphButtonGI do
    UpCallback := ArcadeBattleClicked;
  with GetByName('Mods') as TGraphButtonGI do
    UpCallback := ModsClicked;
end;

procedure TfMainForm.OnOpen;
var
  I: Integer;
begin
  SuppressModRetryPrompt := True;
  LoadPanel.OnOpen;
  LastMenuShipAnimation := -1;
  LastGaalShipAnimation := -1;
  MenuTextState := '';
  if MemorySnapshotBuffer <> nil then
    MemorySnapshotBuffer.Free;
  MemorySnapshotBuffer := nil;
  MemorySnapshotActive := False;
  if (Galaxy <> nil) and not Galaxy.Destroying then
    Galaxy.Free;
  Galaxy := nil;
  // Retained native wait follows clearing the global, even on the standalone path.
  while (Galaxy <> nil) and Galaxy.Destroying do
    SysUtils.Sleep(1);
  I := 0;
  while FindControlByPath('TempGAI' + IntToStr(I)) <> nil do
  begin
    (GetByName('TempGAI' + IntToStr(I)) as TgaiGI).RestartPlayback;
    Inc(I);
  end;
  GetByName('MainPanel').MouseMoveCallback := MainPanelMouseMove;
  (GetByName('Exit') as TGraphButtonGI).UpCallback := QuitClicked;
  (GetByName('New') as TGraphButtonGI).UpCallback := NewGameClicked;
  (GetByName('Load') as TGraphButtonGI).UpCallback := LoadGameClicked;
  (GetByName('Settings') as TGraphButtonGI).UpCallback := SettingsClicked;
{$IFDEF SRHD_ANBERNIC}
  (GetByName('Controls') as TGraphButtonGI).UpCallback := ControlsClicked;
{$ENDIF}
  (GetByName('Achievements') as TGraphButtonGI).UpCallback := AchievementsClicked;
  with GetByName('Score') as TGraphButtonGI do
    UpCallback := ScoresClicked;
  (GetByName('About') as TGraphButtonGI).UpCallback := AboutClicked;
  SelectMusic;
  GetByName('MainPanel').KeyDownCallback := MainPanelKeyDown;
  BackgroundScrollOffset := 0;
  if BackgroundTimer <> nil then
  begin
    CancelCallbackTimer(BackgroundTimer);
    BackgroundTimer := nil;
  end;
  if AnimMainFon then
    BackgroundTimer := ScheduleCallbackTimer(40, 40, ScrollBackground);
  ScrollBackground(nil, 0);
  if GetByName('Logo1C') is TgaiGI then
    with GetByName('Logo1C') as TgaiGI do
    begin
      SequenceIndex := 0;
      UpdateAutoGeometry;
      StopAutoPlayback;
      PrimeImageCaches;
    end;
  if GetByName('LogoElemental') is TgaiGI then
    with GetByName('LogoElemental') as TgaiGI do
    begin
      SequenceIndex := 0;
      UpdateAutoGeometry;
      StopAutoPlayback;
      PrimeImageCaches;
    end;
  with GetByName('AnimAddonShip') as TgaiGI do
  begin
    FirstFrameOnly := not AnimMenuShip;
    if GameCompactLayoutEnabled and HardwareRenderingEnabled and (GameScreenWidth < 1024) then
      SetPosition(Classes.Point(0, 60))
    else
      SetPosition(Classes.Point(0, ExtraScreenHeight div 2 + 60));
    SetDepth(29);
    if AnimMenuShip then
    begin
      SetFirstFrameImagePath('Bm.FormMain3.2Ship1');
      SetImagePath('Bm.FormMain3.2ShipA1');
      PrimeImageCaches;
      SetFirstFrameImagePath('Bm.FormMain3.2Ship2');
      SetImagePath('Bm.FormMain3.2ShipA2');
      PrimeImageCaches;
      SetFirstFrameImagePath('Bm.FormMain3.2Ship3');
      SetImagePath('Bm.FormMain3.2ShipA3');
      PrimeImageCaches;
      CycleCompleteCallback := MenuShipAnimationFinished;
      MenuShipAnimationFinished(FindByNameRecursive('AnimAddonShip'));
    end
    else
    begin
      SetFirstFrameImagePath('Bm.FormMain3.2Ship1');
      PrimeImageCaches;
    end;
    SetActive(True);
  end;
  if (Cardinal(GameScreenWidth) >= 1600) and not GameMobileUiEnabled then
  begin
    if FindControlByPath('AnimGaalShip') <> nil then
      with GetByName('AnimGaalShip') as TgaiGI do
      begin
        FirstFrameOnly := not AnimMenuShip;
        SetPosition(Classes.Point(GameScreenWidth - 661, (GameScreenHeight - 642) shr 1 + 70));
        SetDepth(29);
        if AnimMenuShip then
        begin
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip01');
          SetImagePath('Bm.FormMain3.AnimGaalShip01A');
          PrimeImageCaches;
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip02');
          SetImagePath('Bm.FormMain3.AnimGaalShip02A');
          PrimeImageCaches;
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip03');
          SetImagePath('Bm.FormMain3.AnimGaalShip03A');
          PrimeImageCaches;
          CycleCompleteCallback := GaalShipAnimationFinished;
          GaalShipAnimationFinished(FindByNameRecursive('AnimGaalShip'));
        end
        else
        begin
          SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip01');
          PrimeImageCaches;
        end;
        SetActive(True);
      end;
  end
  else if FindControlByPath('AnimGaalShip') <> nil then
    GetByName('AnimGaalShip').SetActive(False);
  with GetByName('LoadRobotCnt') as TLabelGI do
    SetText(LoadRobotScreen.GetCompletionSummary);
  with GetByName('LoadQuestCnt') as TLabelGI do
    SetText(LoadQuestScreen.GetCompletionSummary);
  with GetByName('LoadABCnt') as TLabelGI do
    SetText(LoadArcadeScreen.GetCatalogSummary);
  with GetByName('ModsCnt') as TLabelGI do
  begin
    if SkipModsOnReload then
      SetText(RedColorTag + IntToWideString(CountDelimitedPartsW(SelectedMods, ',')) + EndColorTag)
    else
      SetText(IntToWideString(CountDelimitedPartsW(SelectedMods, ',')));
  end;
  if ShowWineWarning then
  begin
    ShowWineWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.WeRunOnWine'), mbgCancel or mbgUnused04);
  end;
  if ShowXonarWarning then
  begin
    ShowXonarWarning := False;
    ShowMessageBoxGI(Self, LocalizedColorText('Warning.XonarDetected'), mbgCancel or mbgUnused04);
  end;
end;

procedure TfMainForm.OnClose;
begin
  LoadPanel.OnClose;
end;

procedure TfMainForm.QuitClicked(Sender: TObjectGI);
begin
  if ShowMessageBoxGI(Self, LanguageDataConfig.GetParamByPathOrMarker('FormMain.MsgExit'), mbgOK or mbgCancel or mbgQuestion)
      = mbgResultOK then
  begin
    RequestedScreenId := screenNone;
    RequestClose(1);
  end;
end;

procedure TfMainForm.NewGameClicked(Sender: TObjectGI);
begin
  ShipScreen.SelectedHoldKind := phkEmpty;
  ShipScreen.SelectedHoldItem := nil;
  RequestedScreenId := screenNewGame;
  RequestClose(1);
end;

procedure TfMainForm.AchievementsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  AchievementsReturnScreenId := FormToId(Self);
  RequestedScreenId := screenAchievements;
  RequestClose(1);
end;

procedure TfMainForm.LoadGameClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  SaveManagerReturnScreenId := FormToId(Self);
  SaveManagerMode := smmLoad;
  RequestedScreenId := screenSaveManager;
  RequestClose(1);
end;

procedure TfMainForm.SettingsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  SettingsReturnScreenId := FormToId(Self);
  RequestedScreenId := screenSettings;
  RequestClose(1);
end;

procedure TfMainForm.ScoresClicked(Sender: TObjectGI);
begin
  RequestedScreenId := screenScores;
  RequestClose(1);
end;

procedure TfMainForm.AboutClicked(Sender: TObjectGI);
begin
  AboutScreen.ReturnToScores := False;
  RequestedScreenId := screenAbout;
  RequestClose(1);
end;

procedure TfMainForm.MainPanelKeyDown(Sender: TObjectGI; Key: Cardinal);
begin
  if IsVirtualKeyDown(VK_CONTROL) or IsVirtualKeyDown(VK_SHIFT) or IsVirtualKeyDown(VK_MENU) then
    Exit;
  if Key = Ord('Q') then
  begin
    TGraphButtonGI(GetByName('LoadQuest')).ExecuteOnPressCode;
    TextQuestClicked(nil);
  end
  else if (Key = Ord('R')) and IsInstallFeatureEnabled('Robot') and CheckRobotRuntimeAvailable and (FindControlByPath('PanelRL') = nil) then
  begin
    TGraphButtonGI(GetByName('LoadRobot')).ExecuteOnPressCode;
    RobotBattleClicked(nil);
  end
  else if (Key = Ord('A')) or (Key = Ord('F')) then
  begin
    TGraphButtonGI(GetByName('LoadAB')).ExecuteOnPressCode;
    ArcadeBattleClicked(nil);
  end
  else if Key = Ord('M') then
    ModsClicked(nil)
  else if (Key = VK_F3) or (Key = Ord('L')) then
  begin
    TGraphButtonGI(GetByName('Load')).ExecuteOnPressCode;
    SaveManagerReturnScreenId := FormToId(Self);
    SaveManagerMode := smmLoad;
    RequestedScreenId := screenSaveManager;
    RequestClose(1);
  end
  else if Key = VK_ESCAPE then
  begin
    if FindControlByPath('PanelAB') <> nil then
      ClosePopup
    else
      QuitClicked(nil);
  end
  else if (Key = Ord('N')) or (Key = VK_RETURN) then
  begin
    TGraphButtonGI(GetByName('New')).ExecuteOnPressCode;
    NewGameClicked(nil);
  end
  else if Key = Ord('C') then
  begin
    TGraphButtonGI(GetByName('Settings')).ExecuteOnPressCode;
    SettingsClicked(nil);
  end;
end;

procedure TfMainForm.MainPanelMouseMove(Sender: TObjectGI; KeyState: Cardinal; Point: TPoint);
begin
  RefreshTimerTick;
end;

procedure TfMainForm.MenuShipAnimationFinished(Sender: TObjectGI);
var
  Index: Integer;
begin
  Index := 1;
  repeat
    case RandomIntRange(0, 99) of
      0..49: Index := 1;
      50..69: Index := 2;
      70..99: Index := 3;
    end;
  until (Index = 1) or (Index <> LastMenuShipAnimation);
  LastMenuShipAnimation := Index;
  with GetByName('AnimAddonShip') as TgaiGI do
  begin
    SetFirstFrameImagePath('Bm.FormMain3.' + GiResourceSuffix + 'Ship' + IntToStr(Index));
    SetImagePath('Bm.FormMain3.' + GiResourceSuffix + 'ShipA' + IntToStr(Index));
    SequenceIndex := 0;
    UpdateAutoGeometry;
    RestartPlayback;
  end;
end;

procedure TfMainForm.GaalShipAnimationFinished(Sender: TObjectGI);
var
  Index: Integer;
begin
  Index := 1;
  repeat
    case RandomIntRange(0, 99) of
      0..49: Index := 1;
      50..69: Index := 2;
      70..99: Index := 3;
    end;
  until (Index = 1) or (Index <> LastGaalShipAnimation);
  LastGaalShipAnimation := Index;
  with GetByName('AnimGaalShip') as TgaiGI do
  begin
    SetFirstFrameImagePath('Bm.FormMain3.AnimGaalShip0' + IntToStr(Index));
    SetImagePath('Bm.FormMain3.AnimGaalShip0' + IntToStr(Index) + 'A');
    SequenceIndex := 0;
    UpdateAutoGeometry;
    RestartPlayback;
  end;
end;

procedure TfMainForm.ScrollBackground(Timer: PCallbackTimerGI; UserData: PtrInt);
var
  Offset: Integer;
begin
  Inc(BackgroundScrollOffset);
  with GetByName('ImageFon1') do
  begin
    Offset := BackgroundScrollOffset mod ClientSize.X;
    SetPosition(Classes.Point(0 - Offset, 0));
  end;
  with GetByName('ImageFon2') do
    SetPosition(Classes.Point(ClientSize.X - Offset, 0));
end;

procedure TfMainForm.ClosePopup;
var
  Control: TObjectGI;
begin
  PopupState := 0;
  if FindControlByPath('PanelAB') <> nil then
  begin
    Control := FindControlByPath('PanelAB');
    Control.Invalidate;
    Control.Free;
  end;
end;

procedure TfMainForm.RobotBattleClicked(Sender: TObjectGI);
begin
  if not CheckRobotRuntimeAvailable then
    Exit;
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadRobot;
  RequestClose(1);
end;

procedure TfMainForm.TextQuestClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadQuest;
  RequestClose(1);
end;

procedure TfMainForm.ArcadeBattleClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  CaptureScreenBackground(True, 0);
  SetCursorActive(True);
  RequestedScreenId := screenLoadArcade;
  RequestClose(1);
end;

procedure TfMainForm.ModsClicked(Sender: TObjectGI);
begin
  SetCursorActive(False);
  Present;
  SetCursorActive(True);
  ShowModsManager(Self);
  if ReloadModsRequested then
  begin
    RequestedScreenId := screenNone;
    PostLoadScreenId := screenMainMenu;
    RequestClose(1);
  end;
end;

procedure TfMainForm.SelectMusic;
begin
  MusicManager.PlayCategory('Base');
end;

procedure TfMainForm.ExecuteUiCode(Block: TBlockParEC; Key: Cardinal);
begin
  ExecuteGameplayUiCode(Block, Key);
end;

end.
