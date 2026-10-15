program SpaceImageCache;
{$MODE DELPHI}
{$Q-}
uses
  SysUtils,
  Types,
  GameGraphics,
  GameWindow,
  Direct3D9,
  SDL2,
  EC_Mem,
  EC_OKGF,
  EC_Cache,
  EC_CacheGAI,
  GR_gi,
  GR_DX,
  GR_Main,
  GlobalsV,
  GI_MessageLoop,
  GI_StarField,
  GI_SpaceImg;
type
  TFrameEntries = array[0..2] of TGaiFrameEntry;
  TSequenceEntries = array[0..2] of TGaiSequenceFrameEntry;
var
  Graphics: IDirect3D9;
  Params: TD3DPresentParameters;
  Data: TCGaiEC;
  Control: TCGaiControlEC;
  Scene: TSpaceImgGI;
  Owner: TObjectGI;
  Loop: TMessageLoopGI;
  Field: TStarFieldGI;
  Image: PSpaceImageGI;
  Gi: array[0..255] of Byte;
  EmptyGi: TgiHeaderGR;
  Compressed: array[0..511] of Byte;
  Header: PgiHeaderGR;
  Plane: PgiPlaneGR;
  Entries: ^TFrameEntries;
  Sequence: ^TSequenceEntries;
  Pixels: array[0..4095] of Cardinal;
  Rect: TSDL_Rect;
  Clip: TRect;
  Hash, Reference: QWord;
  PackedSize, RawSize, Offset, I, Cycle, CaseIndex: Integer;
  ExpectWarmDecode: Boolean;
begin
  // A generated resource avoids depending on licensed game assets. Frame 0 is
  // raw RGB565; frame 1 has the same nonzero origin but an LZ/zlib envelope.
  FillChar(Gi, SizeOf(Gi), 0);
  Header := @Gi[0];
  Header.Magic := 'gi'#0#0;
  Header.Version := 1;
  Header.Bounds := Types.Rect(7, 11, 15, 19);
  Header.RedMask := $F800;
  Header.GreenMask := $07E0;
  Header.BlueMask := $001F;
  Header.PlaneCount := 1;
  Plane := @Gi[SizeOf(TgiHeaderGR)];
  Plane.DataOffset := SizeOf(TgiHeaderGR) + SizeOf(TgiPlaneGR);
  Plane.DataSize := 8 * 8 * 2;
  Plane.Bounds := Header.Bounds;
  RawSize := Plane.DataOffset + Plane.DataSize;
  for I := 0 to 63 do
    PWord(@Gi[Plane.DataOffset + I * 2])^ := $F800 or ((I mod 8) shl 5);
  PackedSize := OKGF_ZLib_Compress(@Compressed[0], @Gi[0], RawSize, 0);
  if PackedSize <= 8 then
    raise Exception.Create('Compression failed');
  Data := TCGaiEC.Create;
  Data.RawGaiData := AllocClearEC(2048);
  Data.Header := Data.RawGaiData;
  Data.Header.Bounds := Types.Rect(2, 3, 26, 27);
  Data.Header.FrameCount := 3;
  SetLength(Data.CachedFrameOrigins, 3);
  Entries := Pointer(PByte(Data.RawGaiData) + SizeOf(TGaiHeader));
  Offset := SizeOf(TGaiHeader) + 3 * SizeOf(TGaiFrameEntry);
  Entries^[0].DataOffset := Offset;
  Entries^[0].DataSize := RawSize;
  Move(Gi[0], (PByte(Data.RawGaiData) + Offset)^, RawSize);
  Inc(Offset, RawSize);
  Entries^[1].DataOffset := Offset;
  Entries^[1].DataSize := PackedSize;
  Move(Compressed[0], (PByte(Data.RawGaiData) + Offset)^, PackedSize);
  // Frame 2 is stored but has an empty content rectangle and no planes. Its
  // cached origin remains zero and warm draws must not decode it again.
  Inc(Offset, PackedSize);
  EmptyGi := Header^;
  EmptyGi.Bounds := Types.Rect(7, 11, 7, 11);
  EmptyGi.PlaneCount := 0;
  Entries^[2].DataOffset := Offset;
  Entries^[2].DataSize := SizeOf(EmptyGi);
  Move(EmptyGi, (PByte(Data.RawGaiData) + Offset)^, SizeOf(EmptyGi));
  Inc(Offset, SizeOf(EmptyGi));
  Data.SequenceTableData := Pointer(PByte(Data.RawGaiData) + Offset);
  Data.SequenceTableData.SequenceCount := 1;
  PInteger(PByte(Data.SequenceTableData) + 8)^ := 16;
  PInteger(PByte(Data.SequenceTableData) + 16)^ := 3;
  Sequence := Pointer(PByte(Data.SequenceTableData) + 20);
  Sequence^[0].SourceFrameIndex := 1;
  Sequence^[1].SourceFrameIndex := 0;
  Sequence^[2].SourceFrameIndex := 2;

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
  GlobalCache.ResidentByteLimit := 16 * 1024 * 1024;
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  Control := TCGaiControlEC.Create;
  Control.BoundData := Data;
  Control.RetainCount := 1;
  SetLength(SpaceImageTemplates, 1);
  SpaceImageTemplates[0].CacheControl := Control;
  Scene := TSpaceImgGI.Create(nil);
  Image := Scene.AllocateImage(1);
  Image.TemplateIndex := 0;
  Image.PixelPosition := Point(10, 10);
  Image.ImageSize := Point(24, 24);
  // AllocateImage does not clear new entries; the game sets every field it draws with.
  Image.ImageOffset := Point(0, 0);
  Rect.X := 0;
  Rect.Y := 0;
  Rect.W := 64;
  Rect.H := 64;
  ExpectWarmDecode := (ParamCount > 0) and (ParamStr(1) = '--baseline');
  WriteLn('RENDERER ', GameRendererName);
  for CaseIndex := 0 to 5 do
  begin
    Image.FrameIndex := CaseIndex mod 3;
    Clip := Types.Rect(0, 0, 64, 64);
    if CaseIndex >= 3 then
      Clip := Types.Rect(18, 20, 21, 25);
    for Cycle := 0 to 3 do
    begin
      if Cycle = 2 then
        Data.FrameSurfaceCache.Clear;
      if Cycle = 3 then
        Direct3DDevice.Reset(Params);
      Data.DecodedFrameGi.ClearData;
      Direct3DDevice.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
      Scene.Draw(Clip);
      if Control.RetainCount <> 1 then
        raise Exception.Create('Cache retain count changed');
      if Cycle = 1 then
        if Data.DecodedFrameGi.IsEmpty = ExpectWarmDecode then
          raise Exception
              .CreateFmt('Unexpected warm-cache GI decode in case %d (baseline=%s)', [CaseIndex, BoolToStr(ExpectWarmDecode, True)]);
      if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixels, 64 * 4) <> 0 then
        raise Exception.Create(string(SDL_GetError));
      Hash := 14695981039346656037;
      for I := 0 to High(Pixels) do
        Hash := (Hash xor Pixels[I]) * 1099511628211;
      if Cycle = 0 then
        Reference := Hash
      else if Hash <> Reference then
        raise Exception.Create('Cache/reset changed pixels');
      if Cycle = 0 then
        WriteLn('CASE ', CaseIndex, ' ', IntToHex(Hash, 16));
    end;
  end;
  Scene.Free;
  // Background clipping must also use the unchanged GI bounds, including
  // fully invisible frames. No empty frames were supported by this old path.
  Data.Header.FrameCount := 2;
  Loop := TMessageLoopGI.Create;
  Owner := TObjectGI.Create(nil);
  Owner.MessageLoop := Loop;
  Field := TStarFieldGI.Create(Owner);
  Field.BackgroundCache.BoundData := Data;
  Field.BackgroundCache.RetainCount := 1;
  Field.BackgroundCache.CacheKey := 'generated-test-background';
  Field.BackgroundBounds := Types.Rect(0, 0, 64, 64);
  BGImage := True;
  for CaseIndex := 6 to 8 do
  begin
    Clip := Types.Rect(0, 0, 64, 64);
    if CaseIndex = 7 then
      Clip := Types.Rect(9, 14, 12, 17);
    if CaseIndex = 8 then
      Clip := Types.Rect(50, 50, 60, 60);
    for Cycle := 0 to 3 do
    begin
      if Cycle = 2 then
        Data.FrameSurfaceCache.Clear;
      if Cycle = 3 then
        Direct3DDevice.Reset(Params);
      Data.DecodedFrameGi.ClearData;
      Direct3DDevice.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
      Field.DrawBackground(Clip);
      if (Cycle = 1) and Data.DecodedFrameGi.IsEmpty then
        raise Exception.Create('Missing warm background decode for frame bounds');
      if Field.BackgroundCache.RetainCount <> 1 then
        raise Exception.Create('Background retain count changed');
      if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixels, 64 * 4) <> 0 then
        raise Exception.Create(string(SDL_GetError));
      Hash := 14695981039346656037;
      for I := 0 to High(Pixels) do
        Hash := (Hash xor Pixels[I]) * 1099511628211;
      if Cycle = 0 then
        Reference := Hash
      else if Hash <> Reference then
        raise Exception.Create('Background cache/reset changed pixels');
      if Cycle = 0 then
        WriteLn('CASE ', CaseIndex, ' ', IntToHex(Hash, 16));
    end;
  end;
  Field.BackgroundCache.BoundData := nil;
  Owner.Free;
  Loop.Free;
  SetLength(SpaceImageTemplates, 0);
  Control.BoundData := nil;
  Control.Free;
  Data.Free;
  GlobalCache.Free;
  GlobalCache := nil;
  Direct3DDevice := nil;
  Graphics := nil;
  WriteLn('PASS: cold/warm raw and compressed GI, sequence remapping, origin, clip, empty frame, eviction and reset');
end.
