program FramePrefetch;
{$MODE DELPHI}
{$Q-}
uses
  cthreads,
  SysUtils,
  Types,
  GameGraphics,
  GameWindow,
  Direct3D9,
  EC_Mem,
  EC_OKGF,
  EC_Cache,
  EC_CacheGAI,
  EC_FramePrefetch,
  GR_gi,
  GR_DX,
  GR_Main,
  GlobalsV;
const
  FrameCount = 4;
  Side = 160;
type
  TFrameEntries = array[0..FrameCount - 1] of TGaiFrameEntry;
var
  Graphics: IDirect3D9;
  Params: TD3DPresentParameters;
  Raw: Pointer;
  Offset: Integer;

function NewGai: TCGaiEC;
begin
  // Both instances read the same frames; only the second one prefetches.
  Result := TCGaiEC.Create;
  Result.RawGaiData := Raw;
  Result.Header := Raw;
  SetLength(Result.CachedFrameOrigins, FrameCount);
end;

procedure FreeGai(Data: TCGaiEC);
begin
  Data.RawGaiData := nil;
  Data.Free;
end;

procedure AddFrame(Index: Integer; Gi: Pointer; Size: Integer);
var
  Entries: ^TFrameEntries;
begin
  Entries := Pointer(PByte(Raw) + SizeOf(TGaiHeader));
  Entries^[Index].DataOffset := Offset;
  Entries^[Index].DataSize := Size;
  Move(Gi^, (PByte(Raw) + Offset)^, Size);
  Inc(Offset, Size);
end;

function MakeGi(Width, Height: Integer; Alpha: Boolean; Seed: Cardinal; out Size: Integer): Pointer;
var
  Header: PgiHeaderGR;
  Plane: PgiPlaneGR;
  Bpp, I: Integer;
begin
  if Alpha then
    Bpp := 4
  else
    Bpp := 2;
  Size := SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR) + Width * Height * Bpp;
  Result := AllocMem(Size);
  Header := Result;
  Header.Magic := 'gi'#0#0;
  Header.Version := 1;
  Header.Bounds := Types.Rect(5, 9, 5 + Width, 9 + Height);
  Header.RedMask := $F800;
  Header.GreenMask := $07E0;
  Header.BlueMask := $001F;
  if Alpha then
    Header.AlphaMask := $FF000000;
  Header.PlaneCount := 1;
  Plane := Pointer(PByte(Result) + SizeOf(TgiHeaderGR));
  Plane.DataOffset := SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR);
  Plane.DataSize := Width * Height * Bpp;
  Plane.Bounds := Header.Bounds;
  for I := 0 to Width * Height * Bpp - 1 do
    PByte(Result)[Plane.DataOffset + I] := Byte((I * 7 + Seed) xor (I shr 5));
end;

function ReadTexture(Texture: IDirect3DTexture9): TBytes;
var
  Desc: TD3DSurfaceDesc;
  Locked: TD3DLockedRect;
begin
  Texture.GetLevelDesc(0, Desc);
  Texture.LockRect(0, Locked, nil, 0);
  SetLength(Result, Locked.Pitch * Integer(Desc.Height) + 8);
  PInteger(@Result[0])^ := Desc.Width;
  PInteger(@Result[4])^ := Desc.Height;
  Move(Locked.Bits^, Result[8], Locked.Pitch * Integer(Desc.Height));
  Texture.UnlockRect(0);
end;

procedure Check(Condition: Boolean; const Message: string);
begin
  if not Condition then
    raise Exception.Create(Message);
end;

var
  Gi, PackedGi: Pointer;
  Size, PackedSize, I: Integer;
  EmptyGi: TgiHeaderGR;
  Reference, Prefetching: TCGaiEC;
  Expected, Actual: TBytes;
  Used: QWord;
begin
  Raw := AllocMem(4 * 1024 * 1024);
  PGaiHeader(Raw).Bounds := Types.Rect(0, 0, Side, Side);
  PGaiHeader(Raw).FrameCount := FrameCount;
  Offset := SizeOf(TGaiHeader) + FrameCount * SizeOf(TGaiFrameEntry);
  // 0: raw RGB565; 1: the same in a ZL01 envelope; 2: 32-bit with alpha;
  // 3: stored but empty.
  Gi := MakeGi(150, 140, False, 1, Size);
  AddFrame(0, Gi, Size);
  PackedGi := AllocMem(Size + 64);
  PackedSize := OKGF_ZLib_Compress(PackedGi, Gi, Size, 0);
  Check(PackedSize > 8, 'compression failed');
  AddFrame(1, PackedGi, PackedSize);
  FreeMem(Gi);
  FreeMem(PackedGi);
  Gi := MakeGi(131, 157, True, 2, Size);
  AddFrame(2, Gi, Size);
  FreeMem(Gi);
  FillChar(EmptyGi, SizeOf(EmptyGi), 0);
  EmptyGi.Magic := 'gi'#0#0;
  EmptyGi.Version := 1;
  EmptyGi.Bounds := Types.Rect(7, 11, 7, 11);
  AddFrame(3, @EmptyGi, SizeOf(EmptyGi));

  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 800;
  Params.BackBufferHeight := 600;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True;
  Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Direct3DDevice);
  HardwareRenderingEnabled := True;
  TextureManagerDisabled := True;
  GlobalCache := TCacheEC.Create;
  Check(FramePrefetchAvailable, 'no worker thread on this machine');

  // Prefetched frames match frames decoded on the render thread.
  Reference := NewGai;
  Prefetching := NewGai;
  for I := 0 to FrameCount - 1 do
    Prefetching.PrefetchFrame(I);
  Sleep(500);
  Used := GamePrefetchedFramesUsed;
  for I := 0 to FrameCount - 1 do
  begin
    Check((Reference.GetOrCreateFrameSurface(I) = nil) = (I = 3), Format('reference frame %d', [I]));
    Check((Prefetching.GetOrCreateFrameSurface(I) = nil) = (I = 3), Format('prefetched frame %d', [I]));
    if I = 3 then
      Continue;
    Expected := ReadTexture(Reference.GetOrCreateFrameSurface(I));
    Actual := ReadTexture(Prefetching.GetOrCreateFrameSurface(I));
    Check(
        (Length(Expected) = Length(Actual)) and CompareMem(@Expected[0], @Actual[0], Length(Expected)),
        Format('pixels of frame %d differ', [I])
    );
    Check(
        (Reference.GetFrameOrigin(I).X = Prefetching.GetFrameOrigin(I).X)
            and (Reference.GetFrameOrigin(I).Y = Prefetching.GetFrameOrigin(I).Y),
        Format('origin of frame %d differs', [I])
    );
    WriteLn('FRAME ', I, ' ', PInteger(@Actual[0])^, 'x', PInteger(@Actual[4])^, ' OK');
  end;
  Check(GamePrefetchedFramesUsed - Used = FrameCount, Format('used %d prefetched frames', [GamePrefetchedFramesUsed - Used]));
  Check(Prefetching.EmptyFrames[3], 'empty frame not remembered');
  // Frames with surfaces are not queued again.
  Used := GamePrefetchedFramesUsed;
  Prefetching.FrameSurfaceCache.ReleaseSurfaces;
  Prefetching.GetOrCreateFrameSurface(0);
  Check(GamePrefetchedFramesUsed = Used, 'released frame came from the queue');
  FreeGai(Reference);
  FreeGai(Prefetching);

  // Freeing an owner drops its queued and decoded frames, many times over
  // while the worker is busy.
  for I := 1 to 200 do
  begin
    Prefetching := NewGai;
    Prefetching.PrefetchFrame(0);
    Prefetching.PrefetchFrame(1);
    Prefetching.PrefetchFrame(2);
    if I mod 3 = 0 then
      Sleep(1);
    FreeGai(Prefetching);
  end;
  WriteLn('CANCEL OK; dropped ', GamePrefetchedFramesDropped);

  // A small animation is not worth a worker round trip.
  PGaiHeader(Raw).Bounds := Types.Rect(0, 0, 100, 100);
  Prefetching := NewGai;
  Used := GamePrefetchedFramesUsed;
  Prefetching.PrefetchFrame(0);
  Sleep(100);
  Prefetching.GetOrCreateFrameSurface(0);
  Check(GamePrefetchedFramesUsed = Used, 'small animation was prefetched');
  FreeGai(Prefetching);

  GlobalCache.Free;
  GlobalCache := nil;
  Direct3DDevice := nil;
  Graphics := nil;
  FreeMem(Raw);
  WriteLn('PASS');
end.
