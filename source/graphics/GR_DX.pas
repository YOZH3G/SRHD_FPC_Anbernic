unit GR_DX;

{$I GameOptions.inc}

interface

uses
  Direct3D9,
  Classes,
  Types;

const

  RgbWhite = $FFFFFF;

type

  TTextureGR = class;

  TScreenVertexGR = packed record
    X: Single;
    Y: Single;
    Z: Single;
    RHW: Single;
    Color: Cardinal;
    U: Single;
    V: Single;
  end;

  TScreenVerticesGR = array[0..15] of TScreenVertexGR;

  TCircleTableGR = array[0..360] of Single;

  TLineAlphaTableGR = array[0..359] of Byte;

  TTextureGR = class(TObject)
    LastUseTick: Cardinal;
    SurfaceCount: Integer;
    Surfaces: array of IDirect3DTexture9;
    ResidentBytes: Cardinal;
    // Set by resource caches that decode surfaces again after a release and
    // never lock them after filling, so their CPU pixel copies can be freed.
    Rebuildable: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure ReleaseSurfaces;
    function GetSurface(Index: Integer): IDirect3DTexture9;
    procedure SetSurface(Value: IDirect3DTexture9; Index: Integer);
  end;

var

  TextureManagerDisabled: Boolean = False;

  MaxTextureSize: TPoint;

  DrawVertices: TScreenVerticesGR;

  PendingPoints: array of TScreenVertexGR;

  TextureCaches: TList = nil;

  AvailableTextureBytes: Cardinal = 0;

  CircleCos: TCircleTableGR;

  CircleSin: TCircleTableGR;

  LineAlphaTable: TLineAlphaTableGR;

  ReservedTextureBytes: Cardinal = 0;

  // Resident texture bytes above which idle textures are released.
  ResidentTextureBudget: Cardinal = $10000000;

  TextureIdleSeconds: Integer = 120;

  LastTextureEvictionTick: Cardinal = 0;

  PendingPointCount: Integer = 0;

  PendingPointCapacity: Integer = 0;

  ResidentTextureBytes: Cardinal = 0;

function CreateTextureCache: TTextureGR;

procedure FreeTextureCache(Cache: TTextureGR);

procedure ReleaseAllTextureSurfaces;

procedure EvictTextureCaches(Force: Boolean);

function GR_CreateTexture(Width: Integer; Height: Integer; Format: Cardinal; Pool: Cardinal): IDirect3DTexture9;

function CreateTextureFromPixels(
    Width: Integer;
    Height: Integer;
    Format: Cardinal;
    Pixels: Pointer;
    PitchBytes: Integer;
    Pool: Cardinal
): IDirect3DTexture9;

procedure QueueDrawPoint(X: Integer; Y: Integer; Color: Cardinal; Alpha: Integer);

procedure FlushDrawPoints(ClipRect: PRect);

procedure DrawAlphaLine(X1: Integer; Y1: Integer; X2: Integer; Y2: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);

procedure DrawGradientLine(X1: Integer; Y1: Integer; Color1: Cardinal; X2: Integer; Y2: Integer; Color2: Cardinal; ClipRect: PRect);

procedure DrawAntialiasedLineDX(
    StartX: Integer;
    StartY: Integer;
    FinishX: Integer;
    FinishY: Integer;
    Color: Cardinal;
    Alpha: Integer;
    UnusedClipRect: PRect
);

procedure DrawAnimatedLineDX(
    StartX: Integer;
    StartY: Integer;
    FinishX: Integer;
    FinishY: Integer;
    Color: Cardinal;
    Phase: Integer;
    UnusedClipRect: PRect
);

procedure DrawColoredTriangle(
    X1: Integer;
    Y1: Integer;
    Color1: Cardinal;
    X2: Integer;
    Y2: Integer;
    Color2: Cardinal;
    X3: Integer;
    Y3: Integer;
    Color3: Cardinal;
    Filled: Boolean;
    ClipRect: PRect
);

procedure DrawColoredRect(
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
    Color: Cardinal;
    Alpha: Integer;
    Filled: Boolean;
    ClipRect: PRect
);

procedure DrawAntialiasedCircle(X: Integer; Y: Integer; Radius: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);

procedure DrawCircle(X: Integer; Y: Integer; Radius: Integer; Color: Cardinal; Alpha: Integer; Mode: Integer; ClipRect: PRect);

procedure DrawTexture(
    Texture: IDirect3DTexture9;
    X: Integer;
    Y: Integer;
    Alpha: Integer;
    Color: Cardinal;
    ClipRect: PRect;
    UsePreparedVertices: Boolean;
    MirrorHorizontal: Boolean
);

procedure DrawTextureSized(
    Texture: IDirect3DTexture9;
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
    Alpha: Integer;
    Color: Cardinal;
    ClipRect: PRect;
    UsePreparedVertices: Boolean;
    MirrorHorizontal: Boolean
);

function Color565ToArgb(Color: Cardinal): Cardinal;

function ColorWithAlpha(Color: Cardinal; Alpha: Cardinal): Cardinal;

function GetTextureByteSize(Texture: IDirect3DTexture9): Cardinal;

procedure AddResidentTextureBytes(ByteCount: Cardinal);

procedure SubtractResidentTextureBytes(ByteCount: Cardinal);

implementation

uses
  GameDiagnostics,
  GameGraphics,
  GameSystem,
  GameWindow,
  EC_Mem,
  GR_Main,
  EC_Str,
  Math;

var
  SeenTextureGeneration: LongInt = 0;
  LastBudgetEvictionTick: Cardinal = 0;
  BudgetEvictionNow: Cardinal = 0;

function CreateTextureCache: TTextureGR;
var
  Texture: TTextureGR;
begin
  if TextureCaches = nil then
    TextureCaches := TList.Create;
  Texture := TTextureGR.Create;
  TextureCaches.Add(Texture);
  Result := Texture;
end;

procedure FreeTextureCache(Cache: TTextureGR);
var
  Index: Integer;
begin
  if Cache <> nil then
  begin
    if TextureCaches <> nil then
    begin
      Index := TextureCaches.IndexOf(Cache);
      if Index >= 0 then
        TextureCaches.Delete(Index);
    end;
    Cache.Free;
  end;
end;

procedure ReleaseAllTextureSurfaces;
var
  Index: Integer;
  Texture: TTextureGR;
begin
  if TextureCaches <> nil then
  begin
    Index := 0;
    while TextureCaches.Count > Index do
    begin
      Texture := TextureCaches[Index];
      Texture.ReleaseSurfaces;
      Inc(Index);
    end;
  end;
end;

procedure ReleaseRebuildableTextureSurfaces;
var
  Index: Integer;
  Texture: TTextureGR;
begin
  if TextureCaches <> nil then
    for Index := 0 to TextureCaches.Count - 1 do
    begin
      Texture := TextureCaches[Index];
      if Texture.Rebuildable then
        Texture.ReleaseSurfaces;
    end;
end;

procedure NoteTextureEviction(Texture: TTextureGR);
begin
  if Texture.ResidentBytes = 0 then
    Exit;
  Inc(GameTextureEvictions);
  Inc(GameTextureEvictedBytes, Texture.ResidentBytes);
  Inc(GameFrameEvictions);
  Inc(GameFrameEvictedBytes, Texture.ResidentBytes);
end;

function CompareTextureAge(A, B: Pointer): Integer;
var
  AgeA, AgeB: Cardinal;
begin
  AgeA := BudgetEvictionNow - TTextureGR(A).LastUseTick;
  AgeB := BudgetEvictionNow - TTextureGR(B).LastUseTick;
  if AgeA > AgeB then
    Result := -1
  else if AgeA < AgeB then
    Result := 1
  else
    Result := 0;
end;

procedure ReleaseLeastRecentTextures(NowTick: Cardinal);
var
  Candidates: TList;
  Index: Integer;
  Texture: TTextureGR;
  Target: Cardinal;
begin
  // The idle sweep keeps every texture drawn in the last 20 seconds, so a
  // system full of ships can hold far more than the budget. Without swap that
  // ends in the kernel killing the game. Release the least recently drawn
  // textures until the budget fits again, sparing those of the last second.
  if NowTick - LastBudgetEvictionTick < 250 then
    Exit;
  LastBudgetEvictionTick := NowTick;
  BudgetEvictionNow := NowTick;
  Target := ResidentTextureBudget - ResidentTextureBudget div 8;
  Candidates := TList.Create;
  try
    for Index := 0 to TextureCaches.Count - 1 do
    begin
      Texture := TextureCaches[Index];
      if (Texture.ResidentBytes > 0) and (NowTick - Texture.LastUseTick > 1000) then
        Candidates.Add(Texture);
    end;
    Candidates.Sort(@CompareTextureAge);
    Index := 0;
    while (ResidentTextureBytes > Target) and (Index < Candidates.Count) do
    begin
      NoteTextureEviction(TTextureGR(Candidates[Index]));
      TTextureGR(Candidates[Index]).ReleaseSurfaces;
      Inc(Index);
    end;
  finally
    Candidates.Free;
  end;
end;

procedure EvictTextureCaches(Force: Boolean);
var
  i: Integer;
  Texture: TObject;
  AvailableBytes: Cardinal;
  LastUsed, NowTick: Cardinal;
begin
  if TextureCaches = nil then
    Exit;
  if Direct3DDevice = nil then
    Exit;
  NowTick := GameTickCount;
  if (NowTick - LastTextureEvictionTick < 10) and not Force then
    Exit;
  LastTextureEvictionTick := NowTick;
  AvailableBytes := Max(0, Integer(Direct3DDevice.GetAvailableTextureMem - ReservedTextureBytes));
  if (ResidentTextureBytes < ResidentTextureBudget) and (AvailableBytes > $1400000) and not Force then
    Exit;
  i := 0;
  while i < TextureCaches.Count do
  begin
    Texture := TextureCaches[i];
    if Texture is TTextureGR then
    begin
      LastUsed := TTextureGR(Texture).LastUseTick;
      if NowTick - LastUsed > Cardinal(TextureIdleSeconds * 1000) then
      begin
        NoteTextureEviction(TTextureGR(Texture));
        TTextureGR(Texture).ReleaseSurfaces;
      end;
    end;
    Inc(i);
  end;
  AvailableBytes := Max(0, Integer(Direct3DDevice.GetAvailableTextureMem - ReservedTextureBytes));
  if (AvailableBytes > 30 * 1024 * 1024.0) and (TextureIdleSeconds < 120) then
    Inc(TextureIdleSeconds, 10);
  if (ResidentTextureBytes > ResidentTextureBudget) or (AvailableBytes < $1400000) then
    if TextureIdleSeconds > 20 then
      Dec(TextureIdleSeconds, 10);
  if GameGraphicsDiscardUploadedPixels and (ResidentTextureBytes > ResidentTextureBudget) then
    ReleaseLeastRecentTextures(NowTick);
end;

function GR_CreateTexture(Width, Height: Integer; Format, Pool: Cardinal): IDirect3DTexture9;
var
  Texture: IDirect3DTexture9;
  ErrorCode: Integer;
begin
  if Direct3DDevice = nil then
  begin
    Result := nil;
    Exit;
  end;
  // SDL accepts small textures on every platform. Padding a repeated border
  // tile changes its drawn extent and makes linear filtering sample transparent
  // padding between copies, especially in scaled windows and mobile previews.
  Width := Max(Width, 1);
  Height := Max(Height, 1);
  ErrorCode := Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
  if ErrorCode = LongInt($8007000E) then
  begin
    LogGameMessage(
        gllWarning,
        'graphics',
        'Creating texture ' + IntToWideString(Width) + 'x' + IntToWideString(Height) + ' ran out of memory; evicting textures before retry'
    );
    EvictTextureCaches(True);
    ErrorCode := Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    if ErrorCode = 0 then
      LogGameMessage(
          gllInfo,
          'graphics',
          'Created texture ' + IntToWideString(Width) + 'x' + IntToWideString(Height) + ' after texture eviction'
      )
    else
    begin
      LogGameMessage(
          gllError,
          'graphics',
          'Creating texture '
              + IntToWideString(Width)
              + 'x'
              + IntToWideString(Height)
              + ' still failed after texture eviction; status='
              + IntToWideString(ErrorCode)
      );
      LogMemoryUsage;
    end;
  end;
  // A new texture's storage starts zero-filled and dirty. Clearing it again
  // writes the whole buffer twice on every cache miss, e.g. each 624x323 frame
  // of the hangar's hologram animations.
  Result := Texture;
end;

function CreateTextureFromPixels(
    Width, Height: Integer;
    Format: Cardinal;
    Pixels: Pointer;
    PitchBytes: Integer;
    Pool: Cardinal
): IDirect3DTexture9;
var
  Y: Integer;
  Staging, Texture: IDirect3DTexture9;
  Locked: TD3DLockedRect;
  BytesPerPixel: Integer;
begin
  if Direct3DDevice = nil then
  begin
    Result := nil;
    Exit;
  end;
  if Pool = D3DPOOL_DEFAULT then
  begin
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, D3DPOOL_SYSTEMMEM, Staging, nil);
    Staging.LockRect(0, Locked, nil, 0);
    BytesPerPixel := PitchBytes div Width;
    for Y := 0 to Height - 1 do
      System.Move(
          Pointer(AddPointerOffset(Pixels, PitchBytes * Y))^,
          Pointer(AddPointerOffset(Locked.Bits, Locked.Pitch * Y))^,
          Width * BytesPerPixel
      );
    Staging.UnlockRect(0);
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    Direct3DDevice.UpdateTexture(Staging, Texture);
    Staging := nil;
  end
  else
  begin
    Direct3DDevice.CreateTexture(Width, Height, 1, 0, Format, Pool, Texture, nil);
    Texture.LockRect(0, Locked, nil, 0);
    BytesPerPixel := PitchBytes div Width;
    for Y := 0 to Height - 1 do
      System.Move(
          Pointer(AddPointerOffset(Pixels, PitchBytes * Y))^,
          Pointer(AddPointerOffset(Locked.Bits, Locked.Pitch * Y))^,
          Width * BytesPerPixel
      );
    Texture.UnlockRect(0);
  end;
  Result := Texture;
end;

constructor TTextureGR.Create;
begin
  SurfaceCount := 0;
  LastUseTick := 0;
  ResidentBytes := 0;
end;

destructor TTextureGR.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TTextureGR.Clear;
var
  Index: Integer;
begin
  Index := 0;
  while Index < SurfaceCount do
  begin
    if Surfaces[Index] <> nil then
      Surfaces[Index] := nil;
    Inc(Index);
  end;
  if ResidentBytes > 0 then
    SubtractResidentTextureBytes(ResidentBytes);
  ResidentBytes := 0;
  SetLength(Surfaces, 0);
  SurfaceCount := 0;
  LastUseTick := 0;
end;

procedure TTextureGR.ReleaseSurfaces;
var
  i: Integer;
begin
  i := 0;
  while i < SurfaceCount do
  begin
    Surfaces[i] := nil;
    Inc(i);
  end;
  if ResidentBytes > 0 then
    SubtractResidentTextureBytes(ResidentBytes);
  ResidentBytes := 0;
  LastUseTick := 0;
end;

function TTextureGR.GetSurface(Index: Integer): IDirect3DTexture9;
begin
  Result := nil;
  // A device reset loses rebuildable textures whose pixels were discarded.
  // Release those caches so their owners decode the surfaces again; other
  // caches keep their pixels and upload them again by themselves, and some
  // owners (planet clouds) would not rebuild a released surface at once.
  if GameGraphicsDiscardUploadedPixels and (SeenTextureGeneration <> GameTextureGeneration) then
  begin
    SeenTextureGeneration := GameTextureGeneration;
    ReleaseRebuildableTextureSurfaces;
  end;
  if (Index < 0) or (Index >= SurfaceCount) then
    Exit;
  LastUseTick := GameTickCount;
  Result := Surfaces[Index];
end;

procedure TTextureGR.SetSurface(Value: IDirect3DTexture9; Index: Integer);
var
  i: Integer;
  ByteCount: Cardinal;
begin
  if (Index < 0) or (Index = SurfaceCount) then
  begin
    Index := SurfaceCount;
    Inc(SurfaceCount);
    SetLength(Surfaces, SurfaceCount);
  end
  else if Index > SurfaceCount then
  begin
    i := SurfaceCount;
    SurfaceCount := Index + 1;
    SetLength(Surfaces, SurfaceCount);
    while i < SurfaceCount do
    begin
      Surfaces[i] := nil;
      Inc(i);
    end;
  end;
  if Surfaces[Index] <> nil then
  begin
    ByteCount := GetTextureByteSize(Surfaces[Index]);
    if ByteCount > 0 then
    begin
      Dec(ResidentBytes, ByteCount);
      SubtractResidentTextureBytes(ByteCount);
    end;
  end;
  if Rebuildable then
    MarkGameGraphicsTextureRebuildable(Value);
  ByteCount := GetTextureByteSize(Value);
  Inc(ResidentBytes, ByteCount);
  AddResidentTextureBytes(ByteCount);
  Surfaces[Index] := nil;
  Surfaces[Index] := Value;
end;

procedure QueueDrawPoint(X, Y: Integer; Color: Cardinal; Alpha: Integer);
var
  Index: Integer;
begin
  if Alpha = 0 then
    Exit;
  if PendingPointCount >= PendingPointCapacity then
  begin
    Inc(PendingPointCapacity, 256);
    SetLength(PendingPoints, PendingPointCapacity);
  end;
  Index := PendingPointCount;
  Inc(PendingPointCount);
  PendingPoints[Index].Color := ColorWithAlpha(Color, Alpha);
  PendingPoints[Index].X := X;
  PendingPoints[Index].Y := Y;
  PendingPoints[Index].Z := 1;
  PendingPoints[Index].RHW := 1;
  PendingPoints[Index].U := 0;
  PendingPoints[Index].V := 0;
end;

procedure FlushDrawPoints(ClipRect: PRect);
var
  OldClip: TRect;
begin
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.DrawPrimitiveUP(D3DPT_POINTLIST, PendingPointCount, @PendingPoints[0], SizeOf(TScreenVertexGR));
  PendingPointCount := 0;
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

procedure DrawAlphaLine(X1, Y1, X2, Y2: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);
begin
  DrawGradientLine(X1, Y1, ColorWithAlpha(Color, Alpha), X2, Y2, ColorWithAlpha(Color, Alpha), ClipRect);
end;

procedure DrawGradientLine(X1, Y1: Integer; Color1: Cardinal; X2, Y2: Integer; Color2: Cardinal; ClipRect: PRect);
var
  OldClip: TRect;
begin
  DrawVertices[0].Color := Color1;
  DrawVertices[0].X := X1;
  DrawVertices[0].Y := Y1;
  DrawVertices[1].Color := Color2;
  DrawVertices[1].X := X2;
  DrawVertices[1].Y := Y2;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.DrawPrimitiveUP(D3DPT_LINESTRIP, 1, @DrawVertices, SizeOf(TScreenVertexGR));
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

procedure DrawAntialiasedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Alpha: Integer; UnusedClipRect: PRect);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, X1, Y1, X2, Y2: Double;

  function LineFractionDX(Value: Double): Double;
  begin
    Result := Value - Floor(Value);
  end;

begin
  X1 := StartX;
  Y1 := StartY;
  X2 := FinishX;
  Y2 := FinishY;
  DX := X2 - X1;
  DY := Y2 - Y1;
  if (DX = 0) and (DY = 0) then
    Exit;
  if Abs(DX) > Abs(DY) then
    Steep := False
  else
  begin
    Steep := True;
    Temp := X1;
    X1 := Y1;
    Y1 := Temp;
    Temp := X2;
    X2 := Y2;
    Y2 := Temp;
    Temp := DX;
    DX := DY;
    DY := Temp;
  end;
  if X1 > X2 then
  begin
    Temp := X1;
    X1 := X2;
    X2 := Temp;
    Temp := Y1;
    Y1 := Y2;
    Y2 := Temp;
    DX := X2 - X1;
    DY := Y2 - Y1;
  end;
  Slope := DY / DX;
  EndX := Floor(X1 + 0.5);
  EndY := Y1 + (EndX - X1) * Slope;
  Gap := 1 - LineFractionDX(X1 + 0.5);
  FirstX := Floor(X1 + 0.5);
  FirstY := Floor(EndY);
  Coverage1 := (1 - LineFractionDX(EndY)) * Gap;
  Coverage2 := LineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(FirstY, FirstX, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(FirstY + 1, FirstX, Color, Ceil(Alpha * Coverage2));
  end
  else
  begin
    QueueDrawPoint(FirstX, FirstY, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(FirstX, FirstY + 1, Color, Ceil(Alpha * Coverage2));
  end;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(X2 + 0.5);
  EndY := Y2 + (EndX - X2) * Slope;
  Gap := 1 - LineFractionDX(X2 - 0.5);
  LastX := Floor(X2 + 0.5);
  LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - LineFractionDX(InterY);
    Coverage2 := LineFractionDX(InterY);
    if Steep then
    begin
      QueueDrawPoint(Floor(InterY), X, Color, Ceil(Alpha * Coverage1));
      QueueDrawPoint(Floor(InterY) + 1, X, Color, Ceil(Alpha * Coverage2));
    end
    else
    begin
      QueueDrawPoint(X, Floor(InterY), Color, Ceil(Alpha * Coverage1));
      QueueDrawPoint(X, Floor(InterY) + 1, Color, Ceil(Alpha * Coverage2));
    end;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - LineFractionDX(EndY)) * Gap;
  Coverage2 := LineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(LastY, LastX, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(LastY + 1, LastX, Color, Ceil(Alpha * Coverage2));
  end
  else
  begin
    QueueDrawPoint(LastX, LastY, Color, Ceil(Alpha * Coverage1));
    QueueDrawPoint(LastX, LastY + 1, Color, Ceil(Alpha * Coverage2));
  end;
  FlushDrawPoints(nil);
end;

procedure DrawAnimatedLineDX(StartX, StartY, FinishX, FinishY: Integer; Color: Cardinal; Phase: Integer; UnusedClipRect: PRect);
var
  Slope, DX, DY, Gap, EndX, EndY, InterY, Coverage1, Coverage2: Double;
  X, FirstX, LastX, FirstY, LastY: Integer;
  Steep: Boolean;
  Temp, X1, Y1, X2, Y2: Double;

  function AnimatedLineFractionDX(Value: Double): Double;
  begin
    Result := Value - Floor(Value);
  end;

  procedure AdvanceLinePhase;
  begin
    Inc(Phase, 20);
    if Phase >= 360 then
      Dec(Phase, 360);
  end;

begin
  X1 := StartX;
  Y1 := StartY;
  X2 := FinishX;
  Y2 := FinishY;
  DX := X2 - X1;
  DY := Y2 - Y1;
  if (DX = 0) and (DY = 0) then
    Exit;
  if Abs(DX) > Abs(DY) then
    Steep := False
  else
  begin
    Steep := True;
    Temp := X1;
    X1 := Y1;
    Y1 := Temp;
    Temp := X2;
    X2 := Y2;
    Y2 := Temp;
    Temp := DX;
    DX := DY;
    DY := Temp;
  end;
  if X1 > X2 then
  begin
    Temp := X1;
    X1 := X2;
    X2 := Temp;
    Temp := Y1;
    Y1 := Y2;
    Y2 := Temp;
    DX := X2 - X1;
    DY := Y2 - Y1;
  end;
  Slope := DY / DX;
  EndX := Floor(X1 + 0.5);
  EndY := Y1 + (EndX - X1) * Slope;
  Gap := 1 - AnimatedLineFractionDX(X1 + 0.5);
  FirstX := Floor(X1 + 0.5);
  FirstY := Floor(EndY);
  Coverage1 := (1 - AnimatedLineFractionDX(EndY)) * Gap;
  Coverage2 := AnimatedLineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(FirstY, FirstX, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(FirstY + 1, FirstX, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end
  else
  begin
    QueueDrawPoint(FirstX, FirstY, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(FirstX, FirstY + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end;
  AdvanceLinePhase;
  X := FirstX + 1;
  InterY := EndY + Slope;
  EndX := Floor(X2 + 0.5);
  EndY := Y2 + (EndX - X2) * Slope;
  Gap := 1 - AnimatedLineFractionDX(X2 - 0.5);
  LastX := Floor(X2 + 0.5);
  LastY := Floor(EndY);
  while LastX - 1 >= X do
  begin
    Coverage1 := 1 - AnimatedLineFractionDX(InterY);
    Coverage2 := AnimatedLineFractionDX(InterY);
    if Steep then
    begin
      QueueDrawPoint(Floor(InterY), X, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
      QueueDrawPoint(Floor(InterY) + 1, X, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
    end
    else
    begin
      QueueDrawPoint(X, Floor(InterY), Color, Ceil(LineAlphaTable[Phase] * Coverage1));
      QueueDrawPoint(X, Floor(InterY) + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
    end;
    AdvanceLinePhase;
    InterY := InterY + Slope;
    Inc(X);
  end;
  Coverage1 := (1 - AnimatedLineFractionDX(EndY)) * Gap;
  Coverage2 := AnimatedLineFractionDX(EndY) * Gap;
  if Steep then
  begin
    QueueDrawPoint(LastY, LastX, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(LastY + 1, LastX, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end
  else
  begin
    QueueDrawPoint(LastX, LastY, Color, Ceil(LineAlphaTable[Phase] * Coverage1));
    QueueDrawPoint(LastX, LastY + 1, Color, Ceil(LineAlphaTable[Phase] * Coverage2));
  end;
  FlushDrawPoints(nil);
end;

procedure DrawColoredTriangle(
    X1, Y1: Integer;
    Color1: Cardinal;
    X2, Y2: Integer;
    Color2: Cardinal;
    X3, Y3: Integer;
    Color3: Cardinal;
    Filled: Boolean;
    ClipRect: PRect
);
var
  OldClip: TRect;
begin
  DrawVertices[0].Color := Color1;
  DrawVertices[0].X := X1;
  DrawVertices[0].Y := Y1;
  DrawVertices[1].Color := Color2;
  DrawVertices[1].X := X2;
  DrawVertices[1].Y := Y2;
  DrawVertices[2].Color := Color3;
  DrawVertices[2].X := X3;
  DrawVertices[2].Y := Y3;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  // Native $8510D3/$851102 set state 8 to 2/3: wireframe/solid fill.
  if not Filled then
    Direct3DDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_WIREFRAME);
  Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @DrawVertices, SizeOf(TScreenVertexGR));
  Direct3DDevice.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

procedure DrawColoredRect(X, Y, Width, Height: Integer; Color: Cardinal; Alpha: Integer; Filled: Boolean; ClipRect: PRect);
var
  OldClip: TRect;
begin
  DrawVertices[0].Color := ColorWithAlpha(Color, Alpha);
  DrawVertices[0].X := X - 0.5;
  DrawVertices[0].Y := Y - 0.5;
  DrawVertices[1].Color := DrawVertices[0].Color;
  DrawVertices[1].X := X + Width - 0.5;
  DrawVertices[1].Y := Y - 0.5;
  DrawVertices[2].Color := DrawVertices[0].Color;
  DrawVertices[2].X := X + Width - 0.5;
  DrawVertices[2].Y := Y + Height - 0.5;
  DrawVertices[3].Color := DrawVertices[0].Color;
  DrawVertices[3].X := X - 0.5;
  DrawVertices[3].Y := Y + Height - 0.5;
  DrawVertices[4].Color := DrawVertices[0].Color;
  DrawVertices[4].X := X - 0.5;
  DrawVertices[4].Y := Y - 0.5;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  if Filled then
    Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @DrawVertices, SizeOf(TScreenVertexGR))
  else
    Direct3DDevice.DrawPrimitiveUP(D3DPT_LINESTRIP, 4, @DrawVertices, SizeOf(TScreenVertexGR));
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

procedure DrawAntialiasedCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha: Integer; ClipRect: PRect);
var
  DX, DY, SX, SY, Quadrant: Integer;
  PreviousCoverage, Coverage: Single;
  PreviousDX: Integer;
begin
  DX := Radius;
  PreviousDX := Radius;
  DY := 0;
  PreviousCoverage := 0;
  Quadrant := 0;
  while Quadrant < 4 do
  begin
    SX := (Quadrant mod 2) * 2 - 1;
    SY := ((Quadrant div 2) mod 2) * 2 - 1;
    QueueDrawPoint(SX * DX + X, SY * DY + Y, Color, Alpha);
    QueueDrawPoint(SX * DY + X, SY * DX + Y, Color, Alpha);
    Inc(Quadrant);
  end;
  while DX > DY do
  begin
    Inc(DY);
    Coverage := Sqrt(Sqr(Radius) - Sqr(DY));
    Coverage := Ceil(Coverage) - Coverage;
    if Coverage < PreviousCoverage then
      Dec(DX);
    if DX < DY then
      Break;
    if (DX = DY) and (PreviousDX = DX) then
      Break;
    Quadrant := 0;
    while Quadrant < 4 do
    begin
      SX := (Quadrant mod 2) * 2 - 1;
      SY := ((Quadrant div 2) mod 2) * 2 - 1;
      QueueDrawPoint(SX * DX + X, SY * DY + Y, Color, Trunc((1 - Coverage) * Alpha));
      QueueDrawPoint(SX * DY + X, SY * DX + Y, Color, Trunc((1 - Coverage) * Alpha));
      if DX - 1 >= DY then
      begin
        QueueDrawPoint((DX - 1) * SX + X, SY * DY + Y, Color, Trunc(Alpha * Coverage));
        QueueDrawPoint(SX * DY + X, (DX - 1) * SY + Y, Color, Trunc(Alpha * Coverage));
      end;
      Inc(Quadrant);
    end;
    PreviousCoverage := Coverage;
    PreviousDX := DX;
  end;
  FlushDrawPoints(ClipRect);
end;

procedure DrawCircle(X, Y, Radius: Integer; Color: Cardinal; Alpha, Mode: Integer; ClipRect: PRect);
var
  Index: Integer;
  Vertices: array[0..4] of TScreenVertexGR;
  OldClip: TRect;
begin
  Index := 0;
  repeat
    Vertices[Index].Color := ColorWithAlpha(Color, Alpha);
    Vertices[Index].X := X;
    Vertices[Index].Y := Y;
    Vertices[Index].Z := 1;
    Vertices[Index].RHW := 1;
    Inc(Index);
  until Index = 5;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  if Mode = 0 then
    DrawAntialiasedCircle(X, Y, Radius, Color, Alpha, ClipRect)
  else if Mode = 1 then
  begin
    Index := 0;
    repeat
      Vertices[0].X := Radius * CircleCos[Index] + X;
      Vertices[0].Y := Radius * CircleSin[Index] + Y;
      Vertices[1].X := Radius * CircleCos[Index + 1] + X;
      Vertices[1].Y := Radius * CircleSin[Index + 1] + Y;
      Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @Vertices, SizeOf(TScreenVertexGR));
      Inc(Index);
    until Index = 360;
  end
  else if Mode = 2 then
  begin
    Index := 0;
    repeat
      Vertices[1].X := X + Trunc(Radius * CircleCos[Index + 1]);
      Vertices[1].Y := Y + Trunc(Radius * CircleSin[Index + 1]);
      Vertices[2].X := X + Trunc(Radius * CircleCos[Index]);
      Vertices[2].Y := Y + Trunc(Radius * CircleSin[Index]);
      if Index < 90 then
      begin
        Vertices[0].X := X + Radius;
        Vertices[0].Y := Y + Radius;
      end
      else if Index < 180 then
      begin
        Vertices[0].X := X - Radius;
        Vertices[0].Y := Y + Radius;
      end
      else if Index < 270 then
      begin
        Vertices[0].X := X - Radius;
        Vertices[0].Y := Y - Radius;
      end
      else
      begin
        Vertices[0].X := X + Radius;
        Vertices[0].Y := Y - Radius;
      end;
      Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLELIST, 1, @Vertices, SizeOf(TScreenVertexGR));
      Inc(Index);
    until Index = 360;
  end;
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

procedure DrawTexture(
    Texture: IDirect3DTexture9;
    X, Y, Alpha: Integer;
    Color: Cardinal;
    ClipRect: PRect;
    UsePreparedVertices, MirrorHorizontal: Boolean
);
begin
  DrawTextureSized(Texture, X, Y, 0, 0, Alpha, Color, ClipRect, UsePreparedVertices, MirrorHorizontal);
end;

procedure DrawTextureSized(
    Texture: IDirect3DTexture9;
    X, Y, Width, Height, Alpha: Integer;
    Color: Cardinal;
    ClipRect: PRect;
    UsePreparedVertices, MirrorHorizontal: Boolean
);
var
  Desc: TD3DSurfaceDesc;
  OldClip: TRect;
begin
  if Texture = nil then
    Exit;
  if not UsePreparedVertices then
  begin
    Texture.GetLevelDesc(0, Desc);
    if Width = 0 then
      Width := Desc.Width;
    if Height = 0 then
      Height := Desc.Height;
    DrawVertices[0].Color := ColorWithAlpha(Color, Alpha);
    DrawVertices[0].X := X - 0.5;
    DrawVertices[0].Y := Y - 0.5;
    DrawVertices[0].U := Integer(MirrorHorizontal);
    DrawVertices[0].V := 0;
    DrawVertices[1].Color := DrawVertices[0].Color;
    DrawVertices[1].X := X + Width - 0.5;
    DrawVertices[1].Y := Y - 0.5;
    DrawVertices[1].U := 1 - Integer(MirrorHorizontal);
    DrawVertices[1].V := 0;
    DrawVertices[2].Color := DrawVertices[0].Color;
    DrawVertices[2].X := X + Width - 0.5;
    DrawVertices[2].Y := Y + Height - 0.5;
    DrawVertices[2].U := 1 - Integer(MirrorHorizontal);
    DrawVertices[2].V := 1;
    DrawVertices[3].Color := DrawVertices[0].Color;
    DrawVertices[3].X := X - 0.5;
    DrawVertices[3].Y := Y + Height - 0.5;
    DrawVertices[3].U := Integer(MirrorHorizontal);
    DrawVertices[3].V := 1;
  end;
  if ClipRect <> nil then
  begin
    Direct3DDevice.GetScissorRect(OldClip);
    Direct3DDevice.SetScissorRect(ClipRect);
  end;
  Direct3DDevice.SetTexture(0, Texture);
  Direct3DDevice.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @DrawVertices, SizeOf(TScreenVertexGR));
  Direct3DDevice.SetTexture(0, nil);
  if ClipRect <> nil then
    Direct3DDevice.SetScissorRect(@OldClip);
end;

function Color565ToArgb(Color: Cardinal): Cardinal;
begin
  Result := ((Color shl 3) and $F8) or (((Color shr 3) and $FC) shl 8) or (((Color shr 8) and $F8) shl 16) or $FF000000;
end;

function ColorWithAlpha(Color, Alpha: Cardinal): Cardinal;
begin
  Result := (Color and $FFFFFF) or ((Alpha and $FF) shl 24);
end;

function GetTextureByteSize(Texture: IDirect3DTexture9): Cardinal;
var
  ByteCount: Cardinal;
  Desc: TD3DSurfaceDesc;
begin
  ByteCount := 0;
  if Texture <> nil then
  begin
    Texture.GetLevelDesc(0, Desc);
    if (Desc.Format = D3DFMT_A8R8G8B8) or (Desc.Format = D3DFMT_A8R8G8B8) then
      ByteCount := 4
    else if Desc.Format = D3DFMT_R8G8B8 then
      ByteCount := 3
    else if Desc.Format = D3DFMT_R5G6B5 then
      ByteCount := 2
    else if Desc.Format = D3DFMT_A8 then
      ByteCount := 1;
    ByteCount := Desc.Width * Desc.Height * ByteCount;
  end;
  Result := ByteCount;
end;

procedure AddResidentTextureBytes(ByteCount: Cardinal);
begin
  Inc(ResidentTextureBytes, ByteCount);
end;

procedure SubtractResidentTextureBytes(ByteCount: Cardinal);
begin
  if ResidentTextureBytes > ByteCount then
  begin
    Dec(ResidentTextureBytes, ByteCount);
    Exit;
  end;
  ResidentTextureBytes := 0;
end;

end.
