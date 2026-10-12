program OpaqueTexture;
{$MODE DELPHI}
{$Q-}
uses SysUtils, Types, GameGraphics, GameWindow, Direct3D9, SDL2;
type
  TVertex = packed record
    X, Y, Z, RHW: Single;
    Color: Cardinal;
    U, V: Single;
  end;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Texture: IDirect3DTexture9;
  Screen, TextureSurface, TargetSurface: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Quad: array[0..3] of TVertex;
  Locked: TD3DLockedRect;
  Pixels: array[0..4095] of Cardinal;
  Hash: QWord;
  Pixel: Cardinal;
  Format: Cardinal;
  Reference: array[0..7] of QWord;
  Rect: TSDL_Rect;
  Samples: array[0..6] of Double;
  Started: QWord;
  Swap: Double;
  I, J, K, Cycle, Sample, CaseIndex: Integer;
  Alpha: Byte;
  Bench: Boolean;

procedure Draw;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
  Device.SetTexture(0, Texture);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
end;

begin
  DefaultFormatSettings.DecimalSeparator := '.';
  Format := D3DFMT_R5G6B5;
  Bench := False;
  for I := 1 to ParamCount do
  begin
    if ParamStr(I) = '--rgba' then Format := D3DFMT_A8R8G8B8;
    if ParamStr(I) = '--rgbx' then Format := D3DFMT_X8R8G8B8;
    if ParamStr(I) = '--bench' then Bench := True;
  end;
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 800; Params.BackBufferHeight := 600;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True; Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  WriteLn('RENDERER ', GameRendererName);
  Device.GetBackBuffer(0, 0, 0, Screen);
  Device.CreateTexture(32, 32, 1, 0, Format, D3DPOOL_MANAGED, Texture, nil);
  Texture.LockRect(0, Locked, nil, 0);
  for J := 0 to 31 do
    for I := 0 to 31 do
      if Format = D3DFMT_R5G6B5 then
        PWord(PByte(Locked.Bits) + J * Locked.Pitch + I * 2)^ :=
            (I shl 11) or ((J * 2) shl 5) or ((I + J) mod 32)
      else
      begin
        Pixel := (I * 8 shl 16) or (J * 8 shl 8) or ((I + J) mod 32 * 8);
        // XRGB's unused alpha byte deliberately stays zero.
        if Format = D3DFMT_A8R8G8B8 then Pixel := Pixel or $FF000000;
        PCardinal(PByte(Locked.Bits) + J * Locked.Pitch + I * 4)^ := Pixel;
      end;
  Texture.UnlockRect(0);
  Texture.GetSurfaceLevel(0, TextureSurface);
  FillChar(Quad, SizeOf(Quad), 0);
  Quad[0].X := -0.5; Quad[0].Y := -0.5;
  Quad[1].X := 63.5; Quad[1].Y := -0.5; Quad[1].U := 1;
  Quad[2].X := 63.5; Quad[2].Y := 63.5; Quad[2].U := 1; Quad[2].V := 1;
  Quad[3].X := -0.5; Quad[3].Y := 63.5; Quad[3].V := 1;
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  Rect.X := 0; Rect.Y := 0; Rect.W := 64; Rect.H := 64;
  for Cycle := 0 to 2 do
  begin
    if Cycle > 0 then
    begin
      Device.SetTexture(0, nil);
      Device.Reset(Params); Device.GetBackBuffer(0, 0, 0, Screen);
    end;
    Device.SetRenderTarget(0, Screen);
    for CaseIndex := 0 to 7 do
    begin
      // Alternate opaque, faded, tinted and varying vertex alpha, with both filters.
      Device.SetSamplerState(0, 5, 1 + CaseIndex div 4);
      for I := 0 to 3 do
      begin
        case CaseIndex mod 4 of
          0: Quad[I].Color := $FFFFFFFF;
          1: Quad[I].Color := $80FFFFFF;
          2: Quad[I].Color := $FF80C040;
          3: begin
            Quad[I].Color := $FFFFFFFF;
            if I = 3 then Quad[I].Color := $80FFFFFF;
          end;
        end;
        Quad[I].RHW := 1;
      end;
      if Cycle = 1 then
        Device.StretchRect(TextureSurface, nil, Screen, nil, 1);
      Draw;
      if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888,
          @Pixels, 64 * 4) <> 0 then raise Exception.Create(string(SDL_GetError));
      Hash := 14695981039346656037;
      for I := 0 to High(Pixels) do Hash := (Hash xor Pixels[I]) * 1099511628211;
      if Cycle = 0 then Reference[CaseIndex] := Hash
      else if Hash <> Reference[CaseIndex] then raise Exception.Create('Copy/reset changed texture output');
      if Cycle = 0 then WriteLn('CASE ', CaseIndex, ' ', IntToHex(Hash, 16));
    end;
  end;
  if Format = D3DFMT_A8R8G8B8 then
  begin
    for I := 0 to 3 do Quad[I].Color := $FFFFFFFF;
    Device.SetSamplerState(0, 5, 1);
    Rect.X := 63; Rect.Y := 63; Rect.W := 1; Rect.H := 1;
    // Mutate the last texel after an opaque upload. The cached decision must
    // change in both directions, including after managed-handle recreation.
    for Cycle := 0 to 3 do
    begin
      case Cycle of
        0: Alpha := 0;
        1: Alpha := 254;
        2: Alpha := 128;
      else Alpha := 255;
      end;
      Texture.LockRect(0, Locked, nil, 0);
      PCardinal(PByte(Locked.Bits) + 31 * Locked.Pitch + 31 * 4)^ :=
          Cardinal(Alpha) shl 24 or $00FF0000;
      Texture.UnlockRect(0);
      if Cycle = 2 then
      begin
        Inc(GameTextureGeneration); Device.TestCooperativeLevel;
      end;
      Draw;
      if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888,
          @Pixel, 4) <> 0 then raise Exception.Create(string(SDL_GetError));
      if (Alpha = 0) and (Pixel <> $FF123456) then
        raise Exception.Create('Transparent last texel replaced the background');
      if (Alpha = 255) and (Pixel <> $FFFF0000) then
        raise Exception.Create('Opaque last texel did not replace the background');
      if (Alpha = 128) and ((Pixel and 255 = 0) or ((Pixel shr 16) and 255 < 100)) then
        raise Exception.Create('Changed texel lost alpha blending');
      WriteLn('MUTATION ', Alpha, ' ', IntToHex(Pixel, 8));
    end;
  end;
  // Alpha modulation must also blend into a RGB565 target's ARGB backing store.
  Device.CreateRenderTarget(64, 64, D3DFMT_R5G6B5, 0, 0, False, TargetSurface, nil);
  Device.SetRenderTarget(0, TargetSurface);
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF0000FF, 1, 0);
  for I := 0 to 3 do Quad[I].Color := $80FFFFFF;
  Device.SetTexture(0, Texture);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
  Rect.X := 8; Rect.Y := 8; Rect.W := 1; Rect.H := 1;
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888,
      @Pixel, 4) <> 0 then raise Exception.Create(string(SDL_GetError));
  if (((Pixel shr 16) and 255) = 0) or ((Pixel and 255) < 100) then
    raise Exception.Create('RGB565 render target lost alpha blending');
  Device.SetRenderTarget(0, Screen); TargetSurface := nil;
  Quad[1].X := 799.5; Quad[2].X := 799.5;
  Quad[2].Y := 599.5; Quad[3].Y := 599.5;
  for I := 0 to 3 do Quad[I].Color := $FFFFFFFF;
  Device.SetSamplerState(0, 5, 1);
  if Bench then
  begin
    for J := 1 to 10 do begin Draw; Device.Present(nil, nil, 0, nil); end;
    for Sample := 0 to High(Samples) do
    begin
      Started := SDL_GetPerformanceCounter;
      for J := 1 to 100 do begin Draw; Device.Present(nil, nil, 0, nil); end;
      Samples[Sample] := (SDL_GetPerformanceCounter - Started) * 1000.0
          / SDL_GetPerformanceFrequency / 100;
    end;
    for J := 0 to High(Samples) do
      for K := J + 1 to High(Samples) do
        if Samples[J] > Samples[K] then
        begin Swap := Samples[J]; Samples[J] := Samples[K]; Samples[K] := Swap; end;
    WriteLn('{"median_ms":', Samples[3]:0:6, ',"min_ms":', Samples[0]:0:6,
        ',"max_ms":', Samples[6]:0:6, '}');
  end;
  WriteLn('PASS: texture opacity, modulation, filtering, alpha transitions, copy, targets and reset');
  Device.SetTexture(0, nil); TextureSurface := nil; Texture := nil; Screen := nil;
  Device := nil; Graphics := nil; CloseGameWindow;
end.
