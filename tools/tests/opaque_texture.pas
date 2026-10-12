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
  Reference: array[0..7] of QWord;
  Rect: TSDL_Rect;
  Samples: array[0..6] of Double;
  Started: QWord;
  Swap: Double;
  I, J, K, Cycle, Sample, CaseIndex: Integer;

procedure Draw;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
  Device.SetTexture(0, Texture);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
end;

begin
  DefaultFormatSettings.DecimalSeparator := '.';
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 800; Params.BackBufferHeight := 600;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True; Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  WriteLn('RENDERER ', GameRendererName);
  Device.GetBackBuffer(0, 0, 0, Screen);
  Device.CreateTexture(32, 32, 1, 0, D3DFMT_R5G6B5, D3DPOOL_MANAGED, Texture, nil);
  Texture.LockRect(0, Locked, nil, 0);
  for J := 0 to 31 do
    for I := 0 to 31 do
      PWord(PByte(Locked.Bits) + J * Locked.Pitch + I * 2)^ :=
          (I shl 11) or ((J * 2) shl 5) or ((I + J) mod 32);
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
      else if Hash <> Reference[CaseIndex] then raise Exception.Create('Reset changed RGB565 output');
      if Cycle = 0 then WriteLn('CASE ', CaseIndex, ' ', IntToHex(Hash, 16));
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
  if ParamStr(1) = '--bench' then
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
  WriteLn('PASS: RGB565 opacity, modulation, filtering, alpha transitions, copy, targets and reset');
  Device.SetTexture(0, nil); TextureSurface := nil; Texture := nil; Screen := nil;
  Device := nil; Graphics := nil; CloseGameWindow;
end.
