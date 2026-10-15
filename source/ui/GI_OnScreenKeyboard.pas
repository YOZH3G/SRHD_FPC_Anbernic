unit GI_OnScreenKeyboard;

{$I GameOptions.inc}

interface
uses
  GI_MessageLoop,
  GI_Edit,
  GI_Label,
  Types;
type
  TKeyboardActionGI = (kaCharacter, kaLanguage, kaCase, kaSpace, kaBackspace, kaCaretLeft, kaCaretRight, kaConfirm, kaCancel);
  TKeyboardKeyGI = record
    Caption: WideString;
    Character: WideChar;
    Action: TKeyboardActionGI;
    Bounds: TRect;
    LabelControl: TLabelGI;
  end;
  TOnScreenKeyboardGI = class(TObjectGI)
  private
    Buffer: TEditGI;
    Header, Counter, Help: TLabelGI;
    Keys: array[0..55] of TKeyboardKeyGI;
    Russian, Uppercase: Boolean;
    Selected, Pressed: Integer;
    function AcceptCharacter(Sender: TObjectGI; Character: WideChar): Boolean;
    procedure RefreshKeys;
    procedure RefreshPreview;
    procedure DeletePreviousCharacter;
    function KeyAt(Point: TPoint): Integer;
    function ActivateKey(Index: Integer): Boolean;
    procedure FillBox(Bounds: TRect; Color: Cardinal; Clip: TRect);
  public
    Target: TEditGI;
    constructor CreateForEdit(Loop: TMessageLoopGI; Edit: TEditGI);
    procedure Apply;
    procedure Draw(ClipRect: TRect); override;
    function HandleMessage(Message, Key: Cardinal; Point: TPoint): Boolean;
  end;
implementation
uses
  Classes,
  Math,
  SysUtils,
  GameInput,
  GlobalsV,
  GI_Main,
  GR_Main,
  EC_Struct,
  GR_Rect,
  GR_GraphBuf,
  GR_DX;
var
  LastRussian: Boolean = True;
  LastUppercase: Boolean = False;

constructor TOnScreenKeyboardGI.CreateForEdit(Loop: TMessageLoopGI; Edit: TEditGI);
var
  Index, Width: Integer;
  function MakeLabel(X, Y, W, H: Integer): TLabelGI;
  begin
    Result := TLabelGI.Create(Self);
    Result.SetFontName(NormalFontName);
    Result.SetTextColor(CurrentPixelFormat.PackRgbBytes(218, 242, 249));
    Result.SetPosition(Classes.Point(X, Y));
    Result.SetSize(Classes.Point(W, H));
    Result.SetWordWrapEnabled(False);
  end;
begin
  inherited Create(nil);
  MessageLoop := Loop;
  Target := Edit;
  Russian := LastRussian;
  Uppercase := LastUppercase;
  Pressed := -1;
  Width := Min(920, GameScreenWidth - 32);
  SetSize(Classes.Point(Width, 356));
  SetPosition(Classes.Point((GameScreenWidth - Width) div 2, GameScreenHeight - 380));
  Header := MakeLabel(20, 12, Width - 150, 28);
  Header.SetFontName(NormalBoldFontName);
  Header.SetTextAlignX(taxLeft);
  Counter := MakeLabel(Width - 130, 12, 110, 28);
  Buffer := TEditGI.Create(Self);
  Buffer.FontCache.SetCacheKey(Edit.FontCache.CacheKey);
  Buffer.MaxLength := Edit.MaxLength;
  Buffer.AcceptCharCallback := AcceptCharacter;
  Buffer.AutoScrollText := True;
  Buffer.HasFocus := True;
  Buffer.SetText(Edit.Text);
  Buffer.SetCaretPosition(Edit.CaretPosition);
  Buffer.SetPosition(Classes.Point(24, 51));
  Buffer.SetSize(Classes.Point(Width - 48, 30));
  Buffer.SetTextColor(CurrentPixelFormat.PackRgbBytes(255, 222, 132));
  for Index := 0 to High(Keys) do
    Keys[Index].LabelControl := MakeLabel(0, 0, 1, 1);
  Help := MakeLabel(16, 321, Width - 32, 26);
  Help.SetFontName(SmallFontName);
  RefreshKeys;
  RefreshPreview;
end;

function TOnScreenKeyboardGI.AcceptCharacter(Sender: TObjectGI; Character: WideChar): Boolean;
begin
  Result := not Assigned(Target.AcceptCharCallback) or Target.AcceptCharCallback(Target, Character);
end;

procedure TOnScreenKeyboardGI.RefreshKeys;
const
  EnglishRows: array[0..3] of WideString = ('1234567890-_', 'qwertyuiop[]', 'asdfghjkl;''', 'zxcvbnm,./');
  RussianRows: array[0..3] of WideString = ('1234567890-_', 'йцукенгшщзхъ', 'фывапролджэ', 'ячсмитьбюё');
  Actions: array[0..7] of TKeyboardActionGI = (kaLanguage, kaCase, kaSpace, kaBackspace, kaCaretLeft, kaCaretRight, kaConfirm, kaCancel);
var
  Index, Row, Column, Cell: Integer;
  Ch: WideChar;
  Text: WideString;
begin
  LastRussian := Russian;
  LastUppercase := Uppercase;
  for Index := 0 to High(Keys) do
  begin
    Row := Index div 12;
    Column := Index mod 12;
    Cell := (ClientSize.X - 32) div 12;
    Keys[Index].Caption := '';
    if Index < 48 then
    begin
      Keys[Index].Action := kaCharacter;
      if Russian then
        Text := RussianRows[Row]
      else
        Text := EnglishRows[Row];
      if Column < Length(Text) then
      begin
        Ch := Text[Column + 1];
        if Uppercase then
          if (Ch >= 'a') and (Ch <= 'z') then
            Ch := WideChar(Ord(Ch) - 32)
          else if (Ch >= 'а') and (Ch <= 'я') then
            Ch := WideChar(Ord(Ch) - 32)
          else if Ch = 'ё' then
            Ch := 'Ё';
        Keys[Index].Character := Ch;
        Keys[Index].Caption := Ch;
      end;
    end
    else
    begin
      Column := Index - 48;
      Row := 4;
      Cell := (ClientSize.X - 32) div 8;
      Keys[Index].Action := Actions[Column];
      case Actions[Column] of
        kaLanguage:
          if Russian then
            Keys[Index].Caption := 'RU / EN'
          else
            Keys[Index].Caption := 'EN / RU';
        kaCase:
          if Uppercase then
            Keys[Index].Caption := 'ABC'
          else
            Keys[Index].Caption := 'abc';
        kaSpace:
          if Russian then
            Keys[Index].Caption := 'Пробел'
          else
            Keys[Index].Caption := 'Space';
        kaBackspace:
          if Russian then
            Keys[Index].Caption := 'Стереть'
          else
            Keys[Index].Caption := 'Back';
        kaCaretLeft: Keys[Index].Caption := '<';
        kaCaretRight: Keys[Index].Caption := '>';
        kaConfirm: Keys[Index].Caption := 'OK';
        kaCancel:
          if Russian then
            Keys[Index].Caption := 'Отмена'
          else
            Keys[Index].Caption := 'Cancel';
      end;
    end;
    Keys[Index].Bounds := Classes.Rect(16 + Column * Cell, 94 + Row * 44, 16 + (Column + 1) * Cell - 6, 132 + Row * 44);
    with Keys[Index].LabelControl do
    begin
      SetPosition(Classes.Point(Keys[Index].Bounds.Left, Keys[Index].Bounds.Top));
      SetSize(Classes.Point(Cell - 6, 38));
      SetText(Keys[Index].Caption);
    end;
  end;
  if Russian then
  begin
    Header.SetText('Экранная клавиатура / Русский');
    Help.SetText('A: ввод   B: стереть   Y: RU/EN   R2: регистр   Start: OK   Select: отмена');
  end
  else
  begin
    Header.SetText('On-screen keyboard / English');
    Help.SetText('A: type   B: back   Y: RU/EN   R2: case   Start: OK   Select: cancel');
  end;
  Invalidate;
end;

procedure TOnScreenKeyboardGI.RefreshPreview;
begin
  Counter.SetText(IntToStr(Length(Buffer.Text)) + ' / ' + IntToStr(Buffer.MaxLength));
  Invalidate;
end;

procedure TOnScreenKeyboardGI.Apply;
begin
  // Commit through the field's callbacks once. Cancel never changes the field
  // or its external validation state; character filters run on the original sender.
  Target.SetText(Buffer.Text);
  Target.SetCaretPosition(Buffer.CaretPosition);
  Target.DispatchNamedEvent(nceTextChanged, 0, 0);
  if Assigned(Target.ChangedCallback) then
    Target.ChangedCallback(Target);
end;

procedure TOnScreenKeyboardGI.DeletePreviousCharacter;
begin
  // The case button may still hold Shift; B always deletes just one character.
  if Buffer.CaretPosition > 0 then
  begin
    Buffer.SetCaretPosition(Buffer.CaretPosition - 1);
    Buffer.ProcessKeyDown(VK_DELETE);
  end;
end;

function TOnScreenKeyboardGI.KeyAt(Point: TPoint): Integer;
var
  Index: Integer;
begin
  Point := ToLocalPoint(Point);
  for Index := 0 to High(Keys) do
    if (Keys[Index].Caption <> '') and PtInRect(Keys[Index].Bounds, Point) then
      Exit(Index);
  Result := -1;
end;

function TOnScreenKeyboardGI.ActivateKey(Index: Integer): Boolean;
begin
  Result := False;
  if (Index < 0) or (Index > High(Keys)) or (Keys[Index].Caption = '') then
    Exit;
  case Keys[Index].Action of
    kaCharacter: Buffer.ProcessCharacter(Keys[Index].Character);
    kaLanguage:
    begin
      Russian := not Russian;
      RefreshKeys;
    end;
    kaCase:
    begin
      Uppercase := not Uppercase;
      RefreshKeys;
    end;
    kaSpace: Buffer.ProcessCharacter(' ');
    kaBackspace: DeletePreviousCharacter;
    kaCaretLeft: Buffer.ProcessKeyDown(VK_LEFT);
    kaCaretRight: Buffer.ProcessKeyDown(VK_RIGHT);
    kaConfirm, kaCancel:
    begin
      Result := True;
      MessageLoop.CloseOnScreenKeyboard(Keys[Index].Action = kaConfirm);
      Exit;
    end;
  end;
  RefreshPreview;
end;

function TOnScreenKeyboardGI.HandleMessage(Message, Key: Cardinal; Point: TPoint): Boolean;
var
  Index, Step: Integer;
begin
  Result := True;
  case Message of
    WM_MOUSEMOVE:
    begin
      Index := KeyAt(Point);
      if (Index >= 0) and (Index <> Selected) then
      begin
        Selected := Index;
        Invalidate;
      end;
    end;
    WM_LBUTTONDOWN: Pressed := KeyAt(Point);
    WM_LBUTTONUP:
    begin
      Index := Pressed;
      Pressed := -1;
      if (Index = KeyAt(Point)) and ActivateKey(Index) then
        Exit;
    end;
    WM_RBUTTONDOWN: DeletePreviousCharacter;
    WM_CHAR:
      if Key >= 32 then
        Buffer.ProcessCharacter(WideChar(Key));
    WM_KEYDOWN, WM_SYSKEYDOWN:
      case Key of
        VK_RETURN, VK_F6:
        begin
          MessageLoop.CloseOnScreenKeyboard(True);
          Exit;
        end;
        VK_ESCAPE:
        begin
          MessageLoop.CloseOnScreenKeyboard(False);
          Exit;
        end;
        VK_TAB:
        begin
          Russian := not Russian;
          RefreshKeys;
        end;
        VK_SHIFT, VK_CAPITAL:
        begin
          Uppercase := not Uppercase;
          RefreshKeys;
        end;
        VK_BACK: DeletePreviousCharacter;
        VK_DELETE, VK_HOME, VK_END: Buffer.ProcessKeyDown(Key);
        VK_INSERT:
          if ActivateKey(Selected) then
            Exit;
        VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN:
        begin
          case Key of
            VK_LEFT: Step := -1;
            VK_RIGHT: Step := 1;
            VK_UP: Step := -12;
          else
            Step := 12;
          end;
          repeat
            Selected := (Selected + Step + Length(Keys)) mod Length(Keys);
          until Keys[Selected].Caption <> '';
        end;
      end;
    WM_KEYUP, WM_SYSKEYUP, WM_LBUTTONDBLCLK, WM_RBUTTONUP, WM_RBUTTONDBLCLK, WM_MOUSEWHEEL, WM_MOUSELEAVE:;
  else
    Result := False;
  end;
  if Result then
    RefreshPreview;
end;

procedure TOnScreenKeyboardGI.FillBox(Bounds: TRect; Color: Cardinal; Clip: TRect);
var
  Intersection: TRect;
  Y: Integer;
begin
  if not IntersectRects(Intersection, Bounds, Clip) then
    Exit;
  if HardwareRenderingEnabled then
    DrawColoredRect(
        Intersection.Left,
        Intersection.Top,
        Intersection.Right - Intersection.Left,
        Intersection.Bottom - Intersection.Top,
        Color,
        255,
        True,
        @Clip
    )
  else
    for Y := Intersection.Top to Intersection.Bottom - 1 do
      ScreenRenderBuffer.DrawHorizontalLine16Clipped(
          Intersection.Left,
          Y,
          Intersection.Right - Intersection.Left,
          CurrentPixelFormat.PackRgbBytes((Color shr 16) and 255, (Color shr 8) and 255, Color and 255),
          Clip
      );
end;

procedure TOnScreenKeyboardGI.Draw(ClipRect: TRect);
var
  Index: Integer;
  Box: TRect;
  Child: TObjectGI;
begin
  FillBox(HitTestBounds, $1A829A, ClipRect);
  Box := HitTestBounds;
  InflateRect(Box, -2, -2);
  FillBox(Box, $071D2A, ClipRect);
  Box := Classes.Rect(AbsolutePosition.X + 16, AbsolutePosition.Y + 46, AbsolutePosition.X + ClientSize.X - 16, AbsolutePosition.Y + 84);
  FillBox(Box, $020B13, ClipRect);
  for Index := 0 to High(Keys) do
    if Keys[Index].Caption <> '' then
    begin
      Box := Keys[Index].Bounds;
      OffsetRect(Box, AbsolutePosition.X, AbsolutePosition.Y);
      if Index = Selected then
        FillBox(Box, $D6AE50, ClipRect)
      else
        FillBox(Box, $256378, ClipRect);
      InflateRect(Box, -2, -2);
      if Index = Selected then
        FillBox(Box, $375266, ClipRect)
      else
        FillBox(Box, $102F42, ClipRect);
    end;
  Child := FirstChild;
  while Child <> nil do
  begin
    Child.Draw(ClipRect);
    Child := Child.NextSibling;
  end;
end;
end.
