unit GI_ScrollBar;

{$I GameOptions.inc}

interface

uses
  EC_BlockPar,
  GI_Frame,
  GI_Image,
  GI_Label,
  GI_MessageLoop,
  GI_Panel,
  Types;

const
  // Every nonzero calculation mode accounts for PageSize.
  scmValue = 0;

  srNoHit = 0;
  srDecreaseArrow = 1;
  srIncreaseArrow = 2;
  srPageBefore = 3;
  srPageAfter = 4;
  srThumb = 5;

  sbImageNormal = 0;
  sbImageActive = 1;
  sbImageDown = 2;

type
  TScrollBarRegion = type Cardinal;
  TScrollBarOrientation = (soHorizontal = 1, soVertical);

  TScrollBarGI = class;

  TScrollBarGI = class(TPanelGI)
  private
    Indicator: TFrameGI;
    IndicatorThickness: Integer;
  public
    Minimum: Integer;
    Maximum: Integer;
    Position: Integer;
    LargeChange: Integer;
    SmallChange: Integer;
    PageSize: Integer;
    Orientation: TScrollBarOrientation;
    CalculationMode: Integer;
    UpImages: array[0..2] of TImageGI;
    BeforeThumbBarImages: array[0..2] of TImageGI;
    ThumbTopImages: array[0..2] of TImageGI;
    ThumbCenterImages: array[0..2] of TImageGI;
    ThumbBottomImages: array[0..2] of TImageGI;
    AfterThumbBarImages: array[0..2] of TImageGI;
    DownImages: array[0..2] of TImageGI;
    RepeatTimer: PCallbackTimerGI;
    PressedRegion: TScrollBarRegion;
    HoveredRegion: TScrollBarRegion;
    DragStartPosition: Integer;
    MinimumLabel: TLabelGI;
    MaximumLabel: TLabelGI;
    PositionLabel: TLabelGI;
    PositionChangedCallback: TObjectNotifyEventGI;
    procedure Clear; override;
    procedure SetSize(Size: TPoint); override;
    procedure SetConfigPath(const Path: WideString); override;
    procedure SetActive(Enabled: Boolean); override;
    procedure LoadFromConfigPath(const Path: WideString); override;
    procedure ProcessMouseMove(KeyState: Cardinal; Point: TPoint); override;
    procedure OnMouseEnter; override;
    procedure OnMouseLeave; override;
    procedure CancelPointerInput; override;
    procedure ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint); override;
    procedure ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint); override;
    procedure ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint); override;
    procedure LoadFromBlock(Block: TBlockParEC); override;
    constructor Create(Owner: TObjectGI);
    destructor Destroy; override;
    procedure SetUpPosition(Point: TPoint);
    procedure SetBeforeThumbBarPosition(Point: TPoint);
    procedure SetThumbTopPosition(Point: TPoint);
    procedure SetThumbCenterPosition(Point: TPoint);
    procedure SetThumbBottomPosition(Point: TPoint);
    procedure SetAfterThumbBarPosition(Point: TPoint);
    procedure SetDownPosition(Point: TPoint);
    procedure SetBeforeThumbBarSize(Size: TPoint);
    procedure SetThumbCenterSize(Size: TPoint);
    procedure SetAfterThumbBarSize(Size: TPoint);
    function GetHitRegion(Point: TPoint): TScrollBarRegion;
    procedure SetRange(MinValue: Integer; MaxValue: Integer);
    procedure SetPositionInternal(NewPosition: Integer);
    procedure SetPosition(NewPosition: Integer);
    procedure SetSmallChange(Value: Integer);
    procedure SetLargeChange(Value: Integer);
    procedure SetPageSize(Value: Integer);
    procedure SetOrientation(Value: TScrollBarOrientation);
    procedure SetKindCalcMode(Value: Integer);
    procedure UpdateLayout;
    procedure UpdateSizeForOrientation;
    procedure SetIndicatorThickness(Value: Integer);
    procedure StartAutoRepeat(DelayMs: Integer; RepeatMs: Integer);
    procedure StopAutoRepeat;
    procedure AutoRepeat(Timer: PCallbackTimerGI; UserData: PtrInt);
    procedure LoadScrollBarProperties(Block: TBlockParEC);
  end;

implementation

uses
  Classes,
  Math,
  GI_Main,
  GR_Main,
  SysUtils;

constructor TScrollBarGI.Create(Owner: TObjectGI);
begin
  inherited Create(Owner);
  TouchInteraction := tiDrag;
  RepeatTimer := nil;
  UpImages[sbImageNormal] := TImageGI.Create(Self);
  UpImages[sbImageNormal].SetDepth(1);
  UpImages[sbImageActive] := TImageGI.Create(Self);
  UpImages[sbImageActive].SetDepth(1);
  UpImages[sbImageDown] := TImageGI.Create(Self);
  UpImages[sbImageDown].SetDepth(1);
  BeforeThumbBarImages[sbImageNormal] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageNormal].SetDepth(1);
  BeforeThumbBarImages[sbImageActive] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageActive].SetDepth(1);
  BeforeThumbBarImages[sbImageDown] := TImageGI.Create(Self);
  BeforeThumbBarImages[sbImageDown].SetDepth(1);
  ThumbTopImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbTopImages[sbImageNormal].SetDepth(0);
  ThumbTopImages[sbImageActive] := TImageGI.Create(Self);
  ThumbTopImages[sbImageActive].SetDepth(0);
  ThumbTopImages[sbImageDown] := TImageGI.Create(Self);
  ThumbTopImages[sbImageDown].SetDepth(0);
  ThumbCenterImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageNormal].SetDepth(0);
  ThumbCenterImages[sbImageActive] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageActive].SetDepth(0);
  ThumbCenterImages[sbImageDown] := TImageGI.Create(Self);
  ThumbCenterImages[sbImageDown].SetDepth(0);
  ThumbBottomImages[sbImageNormal] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageNormal].SetDepth(0);
  ThumbBottomImages[sbImageActive] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageActive].SetDepth(0);
  ThumbBottomImages[sbImageDown] := TImageGI.Create(Self);
  ThumbBottomImages[sbImageDown].SetDepth(0);
  AfterThumbBarImages[sbImageNormal] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageNormal].SetDepth(1);
  AfterThumbBarImages[sbImageActive] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageActive].SetDepth(1);
  AfterThumbBarImages[sbImageDown] := TImageGI.Create(Self);
  AfterThumbBarImages[sbImageDown].SetDepth(1);
  DownImages[sbImageNormal] := TImageGI.Create(Self);
  DownImages[sbImageNormal].SetDepth(1);
  DownImages[sbImageActive] := TImageGI.Create(Self);
  DownImages[sbImageActive].SetDepth(1);
  DownImages[sbImageDown] := TImageGI.Create(Self);
  DownImages[sbImageDown].SetDepth(1);
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := soVertical;
  CalculationMode := scmValue;
end;

destructor TScrollBarGI.Destroy;
begin
  UpImages[sbImageNormal].Free;
  UpImages[sbImageActive].Free;
  UpImages[sbImageDown].Free;
  BeforeThumbBarImages[sbImageNormal].Free;
  BeforeThumbBarImages[sbImageActive].Free;
  BeforeThumbBarImages[sbImageDown].Free;
  ThumbTopImages[sbImageNormal].Free;
  ThumbTopImages[sbImageActive].Free;
  ThumbTopImages[sbImageDown].Free;
  ThumbCenterImages[sbImageNormal].Free;
  ThumbCenterImages[sbImageActive].Free;
  ThumbCenterImages[sbImageDown].Free;
  ThumbBottomImages[sbImageNormal].Free;
  ThumbBottomImages[sbImageActive].Free;
  ThumbBottomImages[sbImageDown].Free;
  AfterThumbBarImages[sbImageNormal].Free;
  AfterThumbBarImages[sbImageActive].Free;
  AfterThumbBarImages[sbImageDown].Free;
  DownImages[sbImageNormal].Free;
  DownImages[sbImageActive].Free;
  DownImages[sbImageDown].Free;
  inherited Destroy;
end;

procedure TScrollBarGI.Clear;
begin
  FreeAndNil(Indicator);
  IndicatorThickness := 0;
  Minimum := 0;
  Maximum := 99;
  Position := 0;
  LargeChange := 1;
  SmallChange := 1;
  PageSize := 1;
  Orientation := soVertical;
  CalculationMode := scmValue;
  PressedRegion := srNoHit;
  HoveredRegion := srNoHit;
  StopAutoRepeat;
  PositionChangedCallback := nil;
end;

procedure TScrollBarGI.SetUpPosition(Point: TPoint);
begin
  UpImages[sbImageNormal].SetPosition(Point);
  UpImages[sbImageActive].SetPosition(Point);
  UpImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetBeforeThumbBarPosition(Point: TPoint);
begin
  BeforeThumbBarImages[sbImageNormal].SetPosition(Point);
  BeforeThumbBarImages[sbImageActive].SetPosition(Point);
  BeforeThumbBarImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetThumbTopPosition(Point: TPoint);
begin
  ThumbTopImages[sbImageNormal].SetPosition(Point);
  ThumbTopImages[sbImageActive].SetPosition(Point);
  ThumbTopImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetThumbCenterPosition(Point: TPoint);
begin
  ThumbCenterImages[sbImageNormal].SetPosition(Point);
  ThumbCenterImages[sbImageActive].SetPosition(Point);
  ThumbCenterImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetThumbBottomPosition(Point: TPoint);
begin
  ThumbBottomImages[sbImageNormal].SetPosition(Point);
  ThumbBottomImages[sbImageActive].SetPosition(Point);
  ThumbBottomImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetAfterThumbBarPosition(Point: TPoint);
begin
  AfterThumbBarImages[sbImageNormal].SetPosition(Point);
  AfterThumbBarImages[sbImageActive].SetPosition(Point);
  AfterThumbBarImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetDownPosition(Point: TPoint);
begin
  DownImages[sbImageNormal].SetPosition(Point);
  DownImages[sbImageActive].SetPosition(Point);
  DownImages[sbImageDown].SetPosition(Point);
end;

procedure TScrollBarGI.SetBeforeThumbBarSize(Size: TPoint);
begin
  BeforeThumbBarImages[sbImageNormal].SetSize(Size);
  BeforeThumbBarImages[sbImageActive].SetSize(Size);
  BeforeThumbBarImages[sbImageDown].SetSize(Size);
end;

procedure TScrollBarGI.SetThumbCenterSize(Size: TPoint);
begin
  ThumbCenterImages[sbImageNormal].SetSize(Size);
  ThumbCenterImages[sbImageActive].SetSize(Size);
  ThumbCenterImages[sbImageDown].SetSize(Size);
end;

procedure TScrollBarGI.SetAfterThumbBarSize(Size: TPoint);
begin
  AfterThumbBarImages[sbImageNormal].SetSize(Size);
  AfterThumbBarImages[sbImageActive].SetSize(Size);
  AfterThumbBarImages[sbImageDown].SetSize(Size);
end;

function TScrollBarGI.GetHitRegion(Point: TPoint): TScrollBarRegion;
var
  UpEnd, ThumbStart, ThumbEnd, DownStart: Integer;
begin
  if Indicator <> nil then
    Exit(srNoHit);
  if Orientation = soHorizontal then
  begin
    UpEnd := UpImages[sbImageNormal].ClientSize.X;
    ThumbStart := ThumbTopImages[sbImageNormal].LocalPosition.X;
    ThumbEnd := ThumbBottomImages[sbImageNormal].LocalPosition.X + ThumbBottomImages[sbImageNormal].ClientSize.X;
    DownStart := ClientSize.X - DownImages[sbImageNormal].ClientSize.X;
    if Point.X < 0 then
      Result := srNoHit
    else if Point.X <= UpEnd then
      Result := srDecreaseArrow
    else if Point.X <= ThumbStart then
      Result := srPageBefore
    else if Point.X <= ThumbEnd then
      Result := srThumb
    else if Point.X <= DownStart then
      Result := srPageAfter
    else if Point.X <= ClientSize.X then
      Result := srIncreaseArrow
    else
      Result := srNoHit;
  end
  else
  begin
    UpEnd := UpImages[sbImageNormal].ClientSize.Y;
    ThumbStart := ThumbTopImages[sbImageNormal].LocalPosition.Y;
    ThumbEnd := ThumbBottomImages[sbImageNormal].LocalPosition.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y;
    DownStart := ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y;
    if Point.Y < 0 then
      Result := srNoHit
    else if Point.Y <= UpEnd then
      Result := srDecreaseArrow
    else if Point.Y <= ThumbStart then
      Result := srPageBefore
    else if Point.Y <= ThumbEnd then
      Result := srThumb
    else if Point.Y <= DownStart then
      Result := srPageAfter
    else if Point.Y <= ClientSize.Y then
      Result := srIncreaseArrow
    else
      Result := srNoHit;
  end;
end;

procedure TScrollBarGI.SetRange(MinValue, MaxValue: Integer);
begin
  if MinimumLabel <> nil then
    MinimumLabel.SetText(IntToStr(MinValue));
  if MaximumLabel <> nil then
    MaximumLabel.SetText(IntToStr(MaxValue));
  if (Maximum <> MaxValue) or (Minimum <> MinValue) then
  begin
    if MinValue > MaxValue then
      MinValue := MaxValue;
    Minimum := MinValue;
    Maximum := MaxValue;
    if Position < Minimum then
      SetPositionInternal(Minimum);
    if Position > Maximum then
      SetPositionInternal(Maximum);
    if Maximum - Minimum + 1 < PageSize then
      SetPosition(Minimum);
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetPositionInternal(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then
    PositionLabel.SetText(IntToStr(NewPosition));
  if Position <> NewPosition then
  begin
    Position := NewPosition;
    if Position < Minimum then
      Position := Minimum;
    if CalculationMode = scmValue then
    begin
      if Position > Maximum then
        Position := Maximum;
    end
    else
    begin
      if Maximum - PageSize + 1 < Position then
        Position := Maximum - PageSize + 1;
      if Position < Minimum then
        Position := Minimum;
    end;
    if PositionLabel <> nil then
      PositionLabel.SetText(IntToStr(Position));
    if OldPosition <> Position then
      if Active = True then
      begin
        UpdateLayout;
        Invalidate;
      end;
  end;
end;

procedure TScrollBarGI.SetPosition(NewPosition: Integer);
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  if PositionLabel <> nil then
    PositionLabel.SetText(IntToStr(NewPosition));
  if Position <> NewPosition then
  begin
    Position := NewPosition;
    if Position < Minimum then
      Position := Minimum;
    if CalculationMode = scmValue then
    begin
      if Position > Maximum then
        Position := Maximum;
    end
    else
    begin
      if Maximum - PageSize + 1 < Position then
        Position := Maximum - PageSize + 1;
      if Position < Minimum then
        Position := Minimum;
    end;
    if PositionLabel <> nil then
      PositionLabel.SetText(IntToStr(Position));
    if OldPosition <> Position then
      if Active = True then
      begin
        UpdateLayout;
        Invalidate;
        if Assigned(PositionChangedCallback) then
          PositionChangedCallback(Self);
      end;
  end;
end;

procedure TScrollBarGI.SetSmallChange(Value: Integer);
begin
  if SmallChange <> Value then
  begin
    SmallChange := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetLargeChange(Value: Integer);
begin
  if SmallChange <> Value then
  begin
    LargeChange := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetPageSize(Value: Integer);
begin
  if PageSize <> Value then
  begin
    PageSize := Value;
    if PageSize > Maximum - Minimum + 1 then
      PageSize := Maximum - Minimum + 1;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetOrientation(Value: TScrollBarOrientation);
begin
  if Orientation <> Value then
  begin
    Orientation := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetKindCalcMode(Value: Integer);
begin
  if CalculationMode <> Value then
  begin
    CalculationMode := Value;
    if Active = True then
    begin
      UpdateLayout;
      Invalidate;
    end;
  end;
end;

procedure TScrollBarGI.SetConfigPath(const Path: WideString);
begin
  inherited SetConfigPath(Path);
  if Indicator <> nil then
    UpdateSizeForOrientation;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TScrollBarGI.SetSize(Size: TPoint);
begin
  inherited SetSize(Size);
  if Active = True then
    UpdateLayout;
end;

procedure TScrollBarGI.SetActive(Enabled: Boolean);
begin
  inherited SetActive(Enabled);
  if Enabled = True then
    UpdateLayout;
end;

procedure TScrollBarGI.UpdateLayout;
var
  X, Y, TrackLength, BeforeLength, ThumbLength, AfterLength, MinimumThumbLength: Integer;
begin
  if Indicator <> nil then
  begin
    if Orientation = soHorizontal then
      TrackLength := ClientSize.X
    else
      TrackLength := ClientSize.Y;
    Indicator.SetActive((TrackLength > 0) and (Maximum - Minimum + 1 > PageSize));
    if Indicator.Active then
    begin
      ThumbLength := Min(TrackLength, Max(12, Round(Double(PageSize) / (Maximum - Minimum + 1) * TrackLength)));
      if CalculationMode = scmValue then
        AfterLength := Maximum - Minimum
      else
        AfterLength := Maximum - Minimum + 1 - PageSize;
      BeforeLength := Round(Double(EnsureRange(Position - Minimum, 0, AfterLength)) / Max(1, AfterLength) * (TrackLength - ThumbLength));
      if Orientation = soHorizontal then
      begin
        Indicator.SetPosition(Classes.Point(BeforeLength, 0));
        Indicator.SetSize(Classes.Point(ThumbLength, IndicatorThickness));
      end
      else
      begin
        Indicator.SetPosition(Classes.Point(0, BeforeLength));
        Indicator.SetSize(Classes.Point(IndicatorThickness, ThumbLength));
      end;
    end;
    Exit;
  end;
  if Active then
  begin
    if (Orientation = soHorizontal) then
    begin
      Y := (ClientSize.Y div 2);
      if ((((UpImages[sbImageNormal].ClientSize.X + DownImages[sbImageNormal].ClientSize.X) + ThumbTopImages[sbImageNormal].ClientSize.X)
              + ThumbBottomImages[sbImageNormal].ClientSize.X)
          >= ClientSize.X) then
      begin
        X := 0;
        SetUpPosition(Classes.Point(X, (Y - (UpImages[sbImageNormal].ClientSize.Y div 2))));
        Inc(X, UpImages[sbImageNormal].ClientSize.X);
        SetThumbTopPosition(Classes.Point(X, (Y - (ThumbTopImages[sbImageNormal].ClientSize.Y div 2))));
        SetBeforeThumbBarPosition(Classes.Point(X, (Y - (BeforeThumbBarImages[sbImageNormal].ClientSize.Y div 2))));
        SetBeforeThumbBarSize(
            Classes.Point(BeforeThumbBarImages[sbImageNormal].ClientSize.X, BeforeThumbBarImages[sbImageNormal].ClientSize.Y)
        );
        Inc(X, ThumbTopImages[sbImageNormal].ClientSize.X);
        ThumbCenterImages[sbImageNormal].SetActive(False);
        ThumbCenterImages[sbImageActive].SetActive(False);
        ThumbCenterImages[sbImageDown].SetActive(False);
        SetThumbBottomPosition(Classes.Point(X, (Y - (ThumbBottomImages[sbImageNormal].ClientSize.Y div 2))));
        SetAfterThumbBarPosition(Classes.Point(X, (Y - (AfterThumbBarImages[sbImageNormal].ClientSize.Y div 2))));
        SetAfterThumbBarSize(
            Classes.Point(AfterThumbBarImages[sbImageNormal].ClientSize.X, AfterThumbBarImages[sbImageNormal].ClientSize.Y)
        );
        Inc(X, ThumbBottomImages[sbImageNormal].ClientSize.X);
        SetDownPosition(Classes.Point(X, (Y - (DownImages[sbImageNormal].ClientSize.Y div 2))));
      end
      else
      begin
        TrackLength := ((ClientSize.X - UpImages[sbImageNormal].ClientSize.X) - DownImages[sbImageNormal].ClientSize.X);
        if ((Maximum - Minimum + 1) = 0) then
        begin
          ThumbLength := TrackLength;
        end
        else
        begin
          ThumbLength := Integer(Trunc(((PageSize / ((Maximum - Minimum) + 1)) * TrackLength)));
          if (ThumbLength > TrackLength) then
          begin
            ThumbLength := TrackLength;
          end;
        end;
        MinimumThumbLength := 0;
        if ((ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X) >= ThumbLength) then
        begin
          ThumbLength := (ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X);
          MinimumThumbLength := ThumbLength;
        end;
        if CalculationMode = scmValue then
        begin
          if MinimumThumbLength = 0 then
          begin
            if Maximum - Minimum + 1 = 0 then
              BeforeLength := 0
            else
              BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          end
          else
          begin
            if Maximum - Minimum = 0 then
              BeforeLength := 0
            else
              BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength)));
          end;
        end
        else
        begin
          if Maximum - Minimum + 1 = 0 then
            BeforeLength := 0
          else
            BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          if BeforeLength + ThumbLength > TrackLength then
            BeforeLength := TrackLength - ThumbLength;
        end;
        AfterLength := ((TrackLength - BeforeLength) - ThumbLength);
        if ((ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X) >= ThumbLength) then
        begin
          ThumbCenterImages[sbImageNormal].SetActive(False);
          ThumbCenterImages[sbImageActive].SetActive(False);
          ThumbCenterImages[sbImageDown].SetActive(False);
          SetThumbCenterSize(Classes.Point(0, ThumbCenterImages[sbImageNormal].ClientSize.Y));
        end
        else
        begin
          ThumbCenterImages[sbImageNormal]
              .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb)));
          ThumbCenterImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srThumb));
          ThumbCenterImages[sbImageDown].SetActive(PressedRegion = srThumb);
          SetThumbCenterPosition(
              Classes.Point(
                  ((UpImages[sbImageNormal].ClientSize.X + ThumbTopImages[sbImageNormal].ClientSize.X) + BeforeLength),
                  (Y - (ThumbCenterImages[sbImageNormal].ClientSize.Y div 2))
              )
          );
          SetThumbCenterSize(
              Classes.Point(
                  (ThumbLength - (ThumbTopImages[sbImageNormal].ClientSize.X + ThumbBottomImages[sbImageNormal].ClientSize.X)),
                  ThumbCenterImages[sbImageNormal].ClientSize.Y
              )
          );
        end;
        SetUpPosition(Classes.Point(0, (Y - (UpImages[sbImageNormal].ClientSize.Y div 2))));
        SetDownPosition(
            Classes.Point((ClientSize.X - DownImages[sbImageNormal].ClientSize.X), (Y - (DownImages[sbImageNormal].ClientSize.Y div 2)))
        );
        SetThumbTopPosition(
            Classes.Point((UpImages[sbImageNormal].ClientSize.X + BeforeLength), (Y - (ThumbTopImages[sbImageNormal].ClientSize.Y div 2)))
        );
        SetThumbBottomPosition(
            Classes.Point(
                (((BeforeLength + ThumbLength) - ThumbBottomImages[sbImageNormal].ClientSize.X) + UpImages[sbImageNormal].ClientSize.X),
                (Y - (ThumbBottomImages[sbImageNormal].ClientSize.Y div 2))
            )
        );
        SetBeforeThumbBarPosition(
            Classes.Point(UpImages[sbImageNormal].ClientSize.X, (Y - (BeforeThumbBarImages[sbImageNormal].ClientSize.Y div 2)))
        );
        SetBeforeThumbBarSize(
            Classes.Point((ThumbTopImages[sbImageNormal].ClientSize.X + BeforeLength), BeforeThumbBarImages[sbImageNormal].ClientSize.Y)
        );
        SetAfterThumbBarPosition(
            Classes.Point(
                (((BeforeLength + ThumbLength) - ThumbBottomImages[sbImageNormal].ClientSize.X) + DownImages[sbImageNormal].ClientSize.X),
                (Y - (AfterThumbBarImages[sbImageNormal].ClientSize.Y div 2))
            )
        );
        SetAfterThumbBarSize(
            Classes.Point((ThumbBottomImages[sbImageNormal].ClientSize.X + AfterLength), AfterThumbBarImages[sbImageNormal].ClientSize.Y)
        );
      end;
    end
    else
    begin
      X := (ClientSize.X div 2);
      if ((((UpImages[sbImageNormal].ClientSize.Y + DownImages[sbImageNormal].ClientSize.Y) + ThumbTopImages[sbImageNormal].ClientSize.Y)
              + ThumbBottomImages[sbImageNormal].ClientSize.Y)
          >= ClientSize.Y) then
      begin
        Y := 0;
        SetUpPosition(Classes.Point((X - (UpImages[sbImageNormal].ClientSize.X div 2)), Y));
        Inc(Y, UpImages[sbImageNormal].ClientSize.Y);
        SetThumbTopPosition(Classes.Point((X - (ThumbTopImages[sbImageNormal].ClientSize.X div 2)), Y));
        SetBeforeThumbBarPosition(Classes.Point((X - (BeforeThumbBarImages[sbImageNormal].ClientSize.X div 2)), Y));
        SetBeforeThumbBarSize(
            Classes.Point(BeforeThumbBarImages[sbImageNormal].ClientSize.X, BeforeThumbBarImages[sbImageNormal].ClientSize.Y)
        );
        Inc(Y, ThumbTopImages[sbImageNormal].ClientSize.Y);
        ThumbCenterImages[sbImageNormal].SetActive(False);
        ThumbCenterImages[sbImageActive].SetActive(False);
        ThumbCenterImages[sbImageDown].SetActive(False);
        SetThumbBottomPosition(Classes.Point((X - (ThumbBottomImages[sbImageNormal].ClientSize.X div 2)), Y));
        SetAfterThumbBarPosition(Classes.Point((X - (AfterThumbBarImages[sbImageNormal].ClientSize.X div 2)), Y));
        SetAfterThumbBarSize(
            Classes.Point(AfterThumbBarImages[sbImageNormal].ClientSize.X, AfterThumbBarImages[sbImageNormal].ClientSize.Y)
        );
        Inc(Y, ThumbBottomImages[sbImageNormal].ClientSize.Y);
        SetDownPosition(Classes.Point((X - (DownImages[sbImageNormal].ClientSize.X div 2)), Y));
      end
      else
      begin
        TrackLength := ((ClientSize.Y - UpImages[sbImageNormal].ClientSize.Y) - DownImages[sbImageNormal].ClientSize.Y);
        if ((Maximum - Minimum + 1) = 0) then
        begin
          ThumbLength := TrackLength;
        end
        else
        begin
          ThumbLength := Integer(Trunc(((PageSize / ((Maximum - Minimum) + 1)) * TrackLength)));
          if (ThumbLength > TrackLength) then
          begin
            ThumbLength := TrackLength;
          end;
        end;
        MinimumThumbLength := 0;
        if ((ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y) >= ThumbLength) then
        begin
          ThumbLength := (ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y);
          MinimumThumbLength := ThumbLength;
        end;
        if CalculationMode = scmValue then
        begin
          if MinimumThumbLength = 0 then
          begin
            if Maximum - Minimum + 1 = 0 then
              BeforeLength := 0
            else
              BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          end
          else
          begin
            if Maximum - Minimum = 0 then
              BeforeLength := 0
            else
              BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum) * (TrackLength - MinimumThumbLength)));
          end;
        end
        else
        begin
          if Maximum - Minimum + 1 = 0 then
            BeforeLength := 0
          else
            BeforeLength := Integer(Trunc((Position - Minimum) / (Maximum - Minimum + 1) * TrackLength));
          if BeforeLength + ThumbLength > TrackLength then
            BeforeLength := TrackLength - ThumbLength;
        end;
        AfterLength := ((TrackLength - BeforeLength) - ThumbLength);
        if ((ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y) >= ThumbLength) then
        begin
          ThumbCenterImages[sbImageNormal].SetActive(False);
          ThumbCenterImages[sbImageActive].SetActive(False);
          ThumbCenterImages[sbImageDown].SetActive(False);
          SetThumbCenterSize(Classes.Point(ThumbCenterImages[sbImageNormal].ClientSize.X, 0));
        end
        else
        begin
          ThumbCenterImages[sbImageNormal]
              .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb)));
          ThumbCenterImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srThumb));
          ThumbCenterImages[sbImageDown].SetActive(PressedRegion = srThumb);
          SetThumbCenterPosition(
              Classes.Point(
                  (X - (ThumbCenterImages[sbImageNormal].ClientSize.X div 2)),
                  ((UpImages[sbImageNormal].ClientSize.Y + ThumbTopImages[sbImageNormal].ClientSize.Y) + BeforeLength)
              )
          );
          SetThumbCenterSize(
              Classes.Point(
                  ThumbCenterImages[sbImageNormal].ClientSize.X,
                  (ThumbLength - (ThumbTopImages[sbImageNormal].ClientSize.Y + ThumbBottomImages[sbImageNormal].ClientSize.Y))
              )
          );
        end;
        SetUpPosition(Classes.Point((X - (UpImages[sbImageNormal].ClientSize.X div 2)), 0));
        SetDownPosition(
            Classes.Point((X - (DownImages[sbImageNormal].ClientSize.X div 2)), (ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y))
        );
        SetThumbTopPosition(
            Classes.Point((X - (ThumbTopImages[sbImageNormal].ClientSize.X div 2)), (UpImages[sbImageNormal].ClientSize.Y + BeforeLength))
        );
        SetThumbBottomPosition(
            Classes.Point(
                (X - (ThumbBottomImages[sbImageNormal].ClientSize.X div 2)),
                (((BeforeLength + ThumbLength) - ThumbBottomImages[sbImageNormal].ClientSize.Y) + UpImages[sbImageNormal].ClientSize.Y)
            )
        );
        SetBeforeThumbBarPosition(
            Classes.Point((X - (BeforeThumbBarImages[sbImageNormal].ClientSize.X div 2)), UpImages[sbImageNormal].ClientSize.Y)
        );
        SetBeforeThumbBarSize(
            Classes.Point(BeforeThumbBarImages[sbImageNormal].ClientSize.X, (ThumbTopImages[sbImageNormal].ClientSize.Y + BeforeLength))
        );
        SetAfterThumbBarPosition(
            Classes.Point(
                (X - (AfterThumbBarImages[sbImageNormal].ClientSize.X div 2)),
                (((BeforeLength + ThumbLength) - ThumbBottomImages[sbImageNormal].ClientSize.Y) + DownImages[sbImageNormal].ClientSize.Y)
            )
        );
        SetAfterThumbBarSize(
            Classes.Point(AfterThumbBarImages[sbImageNormal].ClientSize.X, (ThumbBottomImages[sbImageNormal].ClientSize.Y + AfterLength))
        );
      end;
    end;
    UpImages[sbImageNormal]
        .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srDecreaseArrow)) or (PressedRegion = srDecreaseArrow)));
    UpImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srDecreaseArrow));
    UpImages[sbImageDown].SetActive(PressedRegion = srDecreaseArrow);
    BeforeThumbBarImages[sbImageNormal]
        .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srPageBefore)) or (PressedRegion = srPageBefore)));
    BeforeThumbBarImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srPageBefore));
    BeforeThumbBarImages[sbImageDown].SetActive(PressedRegion = srPageBefore);
    ThumbTopImages[sbImageNormal].SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb)));
    ThumbTopImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srThumb));
    ThumbTopImages[sbImageDown].SetActive(PressedRegion = srThumb);
    ThumbBottomImages[sbImageNormal]
        .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srThumb)) or (PressedRegion = srThumb)));
    ThumbBottomImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srThumb));
    ThumbBottomImages[sbImageDown].SetActive(PressedRegion = srThumb);
    AfterThumbBarImages[sbImageNormal]
        .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srPageAfter)) or (PressedRegion = srPageAfter)));
    AfterThumbBarImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srPageAfter));
    AfterThumbBarImages[sbImageDown].SetActive(PressedRegion = srPageAfter);
    DownImages[sbImageNormal]
        .SetActive(not (((PressedRegion = srNoHit) and (HoveredRegion = srIncreaseArrow)) or (PressedRegion = srIncreaseArrow)));
    DownImages[sbImageActive].SetActive((PressedRegion = srNoHit) and (HoveredRegion = srIncreaseArrow));
    DownImages[sbImageDown].SetActive(PressedRegion = srIncreaseArrow);
  end;
end;

procedure TScrollBarGI.UpdateSizeForOrientation;
begin
  if Indicator <> nil then
  begin
    if Orientation = soHorizontal then
      SetSize(Classes.Point(ClientSize.X, IndicatorThickness))
    else
      SetSize(Classes.Point(IndicatorThickness, ClientSize.Y));
  end
  else if Orientation = soHorizontal then
    SetSize(Classes.Point(ClientSize.X, UpImages[sbImageNormal].ClientSize.Y))
  else
    SetSize(Classes.Point(UpImages[sbImageNormal].ClientSize.X, ClientSize.Y));
end;

procedure TScrollBarGI.SetIndicatorThickness(Value: Integer);
var
  Child: TObjectGI;
begin
  Value := Max(0, Value);
  if IndicatorThickness = Value then
    Exit;
  CancelPointerInput;
  IndicatorThickness := Value;
  if Value = 0 then
    FreeAndNil(Indicator)
  else if Indicator = nil then
  begin
    Child := FirstChild;
    while Child <> nil do
    begin
      Child.SetActive(False);
      Child := Child.NextSibling;
    end;
    Indicator := TFrameGI.Create(Self);
    Indicator.SetFill(True);
    Indicator.SetFillColor(GetColorGI('126,148,151'));
  end;
  // Touch scrolling belongs to the content; this only shows its position.
  SetHitTestDisabled(Value > 0);
  UpdateSizeForOrientation;
  Invalidate;
end;

procedure TScrollBarGI.ProcessMouseMove(KeyState: Cardinal; Point: TPoint);
var
  LogicalPoint: TPoint;
begin
  inherited ProcessMouseMove(KeyState, Point);
  LogicalPoint := ScreenToLogicalPoint(Point);
  if PressedRegion = srThumb then
  begin
    if Orientation = soHorizontal then
    begin
      if Maximum - Minimum = 0 then
        SetPosition(Minimum)
      else if CalculationMode = scmValue then
        SetPosition(
            Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.X
                                - UpImages[sbImageNormal].ClientSize.X
                                - DownImages[sbImageNormal].ClientSize.X
                                - ThumbCenterImages[sbImageNormal].ClientSize.X
                                - ThumbTopImages[sbImageNormal].ClientSize.X
                                - ThumbBottomImages[sbImageNormal].ClientSize.X)
                            * (LogicalPoint.X - HitTestBounds.Left - UpImages[sbImageNormal].ClientSize.X)
                    ))
                + DragStartPosition
        )
      else
        SetPosition(
            Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.X - UpImages[sbImageNormal].ClientSize.X - DownImages[sbImageNormal].ClientSize.X)
                            * (LogicalPoint.X - HitTestBounds.Left - UpImages[sbImageNormal].ClientSize.X)
                    ))
                + DragStartPosition
        );
    end
    else
    begin
      if Maximum - Minimum = 0 then
        SetPosition(Minimum)
      else if CalculationMode = scmValue then
        SetPosition(
            Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.Y
                                - UpImages[sbImageNormal].ClientSize.Y
                                - DownImages[sbImageNormal].ClientSize.Y
                                - ThumbCenterImages[sbImageNormal].ClientSize.Y
                                - ThumbTopImages[sbImageNormal].ClientSize.Y
                                - ThumbBottomImages[sbImageNormal].ClientSize.Y)
                            * (LogicalPoint.Y - HitTestBounds.Top - UpImages[sbImageNormal].ClientSize.Y)
                    ))
                + DragStartPosition
        )
      else
        SetPosition(
            Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.Y - UpImages[sbImageNormal].ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y)
                            * (LogicalPoint.Y - HitTestBounds.Top - UpImages[sbImageNormal].ClientSize.Y)
                    ))
                + DragStartPosition
        );
    end;
  end;
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  UpdateLayout;
  Invalidate;
end;

procedure TScrollBarGI.OnMouseEnter;
begin
  inherited OnMouseEnter;
end;

procedure TScrollBarGI.OnMouseLeave;
begin
  inherited OnMouseLeave;
  if PressedRegion = srNoHit then
    HoveredRegion := srNoHit;
  if Active = True then
  begin
    UpdateLayout;
    Invalidate;
  end;
end;

procedure TScrollBarGI.ProcessLeftButtonDown(KeyState: Cardinal; Point: TPoint);
var
  LogicalPoint: TPoint;
begin
  inherited ProcessLeftButtonDown(KeyState, Point);
  LogicalPoint := ScreenToLogicalPoint(Point);
  if Active then
    MessageLoop.SetFocusedControl(Self);
  HoveredRegion := GetHitRegion(ToLocalPoint(Point));
  PressedRegion := HoveredRegion;
  if PressedRegion = srDecreaseArrow then
  begin
    SetPosition(Position - SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srIncreaseArrow then
  begin
    SetPosition(Position + SmallChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srPageBefore then
  begin
    SetPosition(Position - LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srPageAfter then
  begin
    SetPosition(Position + LargeChange);
    StartAutoRepeat(500, 50);
  end
  else if PressedRegion = srThumb then
  begin
    StopAutoRepeat;
    if Maximum - Minimum = 0 then
      DragStartPosition := Minimum
    else if Orientation = soHorizontal then
    begin
      if CalculationMode = scmValue then
        DragStartPosition :=
            Position
                - Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.X
                                - UpImages[sbImageNormal].ClientSize.X
                                - DownImages[sbImageNormal].ClientSize.X
                                - ThumbCenterImages[sbImageNormal].ClientSize.X
                                - ThumbTopImages[sbImageNormal].ClientSize.X
                                - ThumbBottomImages[sbImageNormal].ClientSize.X)
                            * (LogicalPoint.X - HitTestBounds.Left - UpImages[sbImageNormal].ClientSize.X)
                    ))
      else
        DragStartPosition :=
            Position
                - Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.X - UpImages[sbImageNormal].ClientSize.X - DownImages[sbImageNormal].ClientSize.X)
                            * (LogicalPoint.X - HitTestBounds.Left - UpImages[sbImageNormal].ClientSize.X)
                    ));
    end
    else
    begin
      if CalculationMode = scmValue then
        DragStartPosition :=
            Position
                - Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.Y
                                - UpImages[sbImageNormal].ClientSize.Y
                                - DownImages[sbImageNormal].ClientSize.Y
                                - ThumbCenterImages[sbImageNormal].ClientSize.Y
                                - ThumbTopImages[sbImageNormal].ClientSize.Y
                                - ThumbBottomImages[sbImageNormal].ClientSize.Y)
                            * (LogicalPoint.Y - HitTestBounds.Top - UpImages[sbImageNormal].ClientSize.Y)
                    ))
      else
        DragStartPosition :=
            Position
                - Integer(
                    Trunc(
                        (Maximum - Minimum)
                            / (ClientSize.Y - UpImages[sbImageNormal].ClientSize.Y - DownImages[sbImageNormal].ClientSize.Y)
                            * (LogicalPoint.Y - HitTestBounds.Top - UpImages[sbImageNormal].ClientSize.Y)
                    ));
    end;
  end;
  UpdateLayout;
  Invalidate;
end;

procedure TScrollBarGI.ProcessLeftButtonUp(KeyState: Cardinal; Point: TPoint);
begin
  inherited ProcessLeftButtonUp(KeyState, Point);
  PressedRegion := srNoHit;
  if not HitTestCursor then
    HoveredRegion := srNoHit;
  if MessageLoop.FocusedControl = Self then
    MessageLoop.SetFocusedControl(nil);
  UpdateLayout;
  StopAutoRepeat;
end;

procedure TScrollBarGI.CancelPointerInput;
begin
  inherited CancelPointerInput;
  StopAutoRepeat;
  if MessageLoop.FocusedControl = Self then
    MessageLoop.SetFocusedControl(nil);
  if PressedRegion <> srNoHit then
  begin
    PressedRegion := srNoHit;
    UpdateLayout;
  end;
end;

procedure TScrollBarGI.ProcessLeftButtonDoubleClick(KeyState: Cardinal; Point: TPoint);
begin

end;

procedure TScrollBarGI.StartAutoRepeat(DelayMs, RepeatMs: Integer);
begin
  StopAutoRepeat;
  RepeatTimer := MessageLoop.ScheduleCallbackTimer(DelayMs, RepeatMs, AutoRepeat);
end;

procedure TScrollBarGI.StopAutoRepeat;
begin
  if RepeatTimer <> nil then
    MessageLoop.CancelCallbackTimer(RepeatTimer);
  RepeatTimer := nil;
end;

procedure TScrollBarGI.AutoRepeat(Timer: PCallbackTimerGI; UserData: PtrInt);
begin
  if PressedRegion = srDecreaseArrow then
    SetPosition(Position - SmallChange)
  else if PressedRegion = srIncreaseArrow then
    SetPosition(Position + SmallChange)
  else if PressedRegion = srPageBefore then
    SetPosition(Position - LargeChange)
  else if PressedRegion = srPageAfter then
    SetPosition(Position + LargeChange);
end;

procedure TScrollBarGI.LoadFromConfigPath(const Path: WideString);
begin
  inherited LoadFromConfigPath(Path);
  LoadScrollBarProperties(UiStyleConfig.GetBlockByPath(Path));
end;

procedure TScrollBarGI.LoadFromBlock(Block: TBlockParEC);
begin
  inherited LoadFromBlock(Block);
  LoadScrollBarProperties(Block);
end;

procedure TScrollBarGI.LoadScrollBarProperties(Block: TBlockParEC);
begin
  if Block.CountParams('Min') > 0 then
    Minimum := StrToInt(Block.GetParam('Min'));
  if Block.CountParams('Max') > 0 then
    Maximum := StrToInt(Block.GetParam('Max'));
  if Block.CountParams('PageSize') > 0 then
    PageSize := StrToInt(Block.GetParam('PageSize'));
  if Block.CountParams('LargeChange') > 0 then
    LargeChange := StrToInt(Block.GetParam('LargeChange'));
  if Block.CountParams('SmallChange') > 0 then
    SmallChange := StrToInt(Block.GetParam('SmallChange'));
  if Block.CountParams('Position') > 0 then
    Position := StrToInt(Block.GetParam('Position'));
  if Block.CountParams('Kind') > 0 then
    if Block.GetParam('Kind') = 'x' then
      Orientation := soHorizontal
    else
      Orientation := soVertical;
  if Block.CountParams('KindCalc') > 0 then
    CalculationMode := StrToInt(Block.GetParam('KindCalc'));
  if Block.CountParams('ImageUpN') > 0 then
    UpImages[sbImageNormal].SetImagePath(Block.GetParam('ImageUpN'));
  if Block.CountParams('ImageUpA') > 0 then
    UpImages[sbImageActive].SetImagePath(Block.GetParam('ImageUpA'));
  if Block.CountParams('ImageUpD') > 0 then
    UpImages[sbImageDown].SetImagePath(Block.GetParam('ImageUpD'));
  if Block.CountParams('ImageBarN') > 0 then
    BeforeThumbBarImages[sbImageNormal].SetImagePath(Block.GetParam('ImageBarN'));
  if Block.CountParams('ImageBarA') > 0 then
    BeforeThumbBarImages[sbImageActive].SetImagePath(Block.GetParam('ImageBarA'));
  if Block.CountParams('ImageBarD') > 0 then
    BeforeThumbBarImages[sbImageDown].SetImagePath(Block.GetParam('ImageBarD'));
  if Block.CountParams('ImageTopN') > 0 then
    ThumbTopImages[sbImageNormal].SetImagePath(Block.GetParam('ImageTopN'));
  if Block.CountParams('ImageTopA') > 0 then
    ThumbTopImages[sbImageActive].SetImagePath(Block.GetParam('ImageTopA'));
  if Block.CountParams('ImageTopD') > 0 then
    ThumbTopImages[sbImageDown].SetImagePath(Block.GetParam('ImageTopD'));
  if Block.CountParams('ImageCenterN') > 0 then
    ThumbCenterImages[sbImageNormal].SetImagePath(Block.GetParam('ImageCenterN'));
  if Block.CountParams('ImageCenterA') > 0 then
    ThumbCenterImages[sbImageActive].SetImagePath(Block.GetParam('ImageCenterA'));
  if Block.CountParams('ImageCenterD') > 0 then
    ThumbCenterImages[sbImageDown].SetImagePath(Block.GetParam('ImageCenterD'));
  if Block.CountParams('ImageBottomN') > 0 then
    ThumbBottomImages[sbImageNormal].SetImagePath(Block.GetParam('ImageBottomN'));
  if Block.CountParams('ImageBottomA') > 0 then
    ThumbBottomImages[sbImageActive].SetImagePath(Block.GetParam('ImageBottomA'));
  if Block.CountParams('ImageBottomD') > 0 then
    ThumbBottomImages[sbImageDown].SetImagePath(Block.GetParam('ImageBottomD'));
  if Block.CountParams('ImageBarN') > 0 then
    AfterThumbBarImages[sbImageNormal].SetImagePath(Block.GetParam('ImageBarN'));
  if Block.CountParams('ImageBarA') > 0 then
    AfterThumbBarImages[sbImageActive].SetImagePath(Block.GetParam('ImageBarA'));
  if Block.CountParams('ImageBarD') > 0 then
    AfterThumbBarImages[sbImageDown].SetImagePath(Block.GetParam('ImageBarD'));
  if Block.CountParams('ImageDownN') > 0 then
    DownImages[sbImageNormal].SetImagePath(Block.GetParam('ImageDownN'));
  if Block.CountParams('ImageDownA') > 0 then
    DownImages[sbImageActive].SetImagePath(Block.GetParam('ImageDownA'));
  if Block.CountParams('ImageDownD') > 0 then
    DownImages[sbImageDown].SetImagePath(Block.GetParam('ImageDownD'));
  UpImages[sbImageNormal].SetSize(UpImages[sbImageNormal].GetContentSize);
  UpImages[sbImageNormal].SetImageKindX(ikxCenter);
  UpImages[sbImageNormal].SetImageKindY(ikyCenter);
  UpImages[sbImageActive].SetSize(UpImages[sbImageActive].GetContentSize);
  UpImages[sbImageActive].SetImageKindX(ikxCenter);
  UpImages[sbImageActive].SetImageKindY(ikyCenter);
  UpImages[sbImageDown].SetSize(UpImages[sbImageDown].GetContentSize);
  UpImages[sbImageDown].SetImageKindX(ikxCenter);
  UpImages[sbImageDown].SetImageKindY(ikyCenter);
  BeforeThumbBarImages[sbImageNormal].SetSize(BeforeThumbBarImages[sbImageNormal].GetContentSize);
  BeforeThumbBarImages[sbImageNormal].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[sbImageNormal].SetImageKindY(ikyTopFill);
  BeforeThumbBarImages[sbImageActive].SetSize(BeforeThumbBarImages[sbImageActive].GetContentSize);
  BeforeThumbBarImages[sbImageActive].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[sbImageActive].SetImageKindY(ikyTopFill);
  BeforeThumbBarImages[sbImageDown].SetSize(BeforeThumbBarImages[sbImageDown].GetContentSize);
  BeforeThumbBarImages[sbImageDown].SetImageKindX(ikxLeftFill);
  BeforeThumbBarImages[sbImageDown].SetImageKindY(ikyTopFill);
  ThumbTopImages[sbImageNormal].SetSize(ThumbTopImages[sbImageNormal].GetContentSize);
  ThumbTopImages[sbImageNormal].SetImageKindX(ikxCenter);
  ThumbTopImages[sbImageNormal].SetImageKindY(ikyCenter);
  ThumbTopImages[sbImageActive].SetSize(ThumbTopImages[sbImageActive].GetContentSize);
  ThumbTopImages[sbImageActive].SetImageKindX(ikxCenter);
  ThumbTopImages[sbImageActive].SetImageKindY(ikyCenter);
  ThumbTopImages[sbImageDown].SetSize(ThumbTopImages[sbImageDown].GetContentSize);
  ThumbTopImages[sbImageDown].SetImageKindX(ikxCenter);
  ThumbTopImages[sbImageDown].SetImageKindY(ikyCenter);
  ThumbCenterImages[sbImageNormal].SetSize(ThumbCenterImages[sbImageNormal].GetContentSize);
  ThumbCenterImages[sbImageNormal].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[sbImageNormal].SetImageKindY(ikyTopFill);
  ThumbCenterImages[sbImageActive].SetSize(ThumbCenterImages[sbImageActive].GetContentSize);
  ThumbCenterImages[sbImageActive].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[sbImageActive].SetImageKindY(ikyTopFill);
  ThumbCenterImages[sbImageDown].SetSize(ThumbCenterImages[sbImageDown].GetContentSize);
  ThumbCenterImages[sbImageDown].SetImageKindX(ikxLeftFill);
  ThumbCenterImages[sbImageDown].SetImageKindY(ikyTopFill);
  ThumbBottomImages[sbImageNormal].SetSize(ThumbBottomImages[sbImageNormal].GetContentSize);
  ThumbBottomImages[sbImageNormal].SetImageKindX(ikxCenter);
  ThumbBottomImages[sbImageNormal].SetImageKindY(ikyCenter);
  ThumbBottomImages[sbImageActive].SetSize(ThumbBottomImages[sbImageActive].GetContentSize);
  ThumbBottomImages[sbImageActive].SetImageKindX(ikxCenter);
  ThumbBottomImages[sbImageActive].SetImageKindY(ikyCenter);
  ThumbBottomImages[sbImageDown].SetSize(ThumbBottomImages[sbImageDown].GetContentSize);
  ThumbBottomImages[sbImageDown].SetImageKindX(ikxCenter);
  ThumbBottomImages[sbImageDown].SetImageKindY(ikyCenter);
  AfterThumbBarImages[sbImageNormal].SetSize(AfterThumbBarImages[sbImageNormal].GetContentSize);
  AfterThumbBarImages[sbImageNormal].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[sbImageNormal].SetImageKindY(ikyBottomFill);
  AfterThumbBarImages[sbImageActive].SetSize(AfterThumbBarImages[sbImageActive].GetContentSize);
  AfterThumbBarImages[sbImageActive].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[sbImageActive].SetImageKindY(ikyBottomFill);
  AfterThumbBarImages[sbImageDown].SetSize(AfterThumbBarImages[sbImageDown].GetContentSize);
  AfterThumbBarImages[sbImageDown].SetImageKindX(ikxRightFill);
  AfterThumbBarImages[sbImageDown].SetImageKindY(ikyBottomFill);
  DownImages[sbImageNormal].SetSize(DownImages[sbImageNormal].GetContentSize);
  DownImages[sbImageNormal].SetImageKindX(ikxCenter);
  DownImages[sbImageNormal].SetImageKindY(ikyCenter);
  DownImages[sbImageActive].SetSize(DownImages[sbImageActive].GetContentSize);
  DownImages[sbImageActive].SetImageKindX(ikxCenter);
  DownImages[sbImageActive].SetImageKindY(ikyCenter);
  DownImages[sbImageDown].SetSize(DownImages[sbImageDown].GetContentSize);
  DownImages[sbImageDown].SetImageKindX(ikxCenter);
  DownImages[sbImageDown].SetImageKindY(ikyCenter);
  UpdateLayout;
end;

end.
