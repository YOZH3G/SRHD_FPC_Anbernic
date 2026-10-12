program PointBlocks;
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
  Screen: IDirect3DSurface9;
  Texture: IDirect3DTexture9;
  Params: TD3DPresentParameters;
  Points: array[0..511] of TVertex;
  Pixels: array[0..12287] of Cardinal;
  Reference: array[0..5, 0..4] of QWord;
  Samples: array[0..6] of Double;
  Hash, Started: QWord;
  Rect: TSDL_Rect;
  Clip: TRect;
  Mode, CaseIndex, Cycle, I, J, K, Count, Sample: Integer;
  Swap: Double;

procedure Draw;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $40102030, 1, 0);
  Device.DrawPrimitiveUP(D3DPT_POINTLIST, Count, @Points, SizeOf(TVertex));
end;

begin
  DefaultFormatSettings.DecimalSeparator := '.';
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 128; Params.BackBufferHeight := 96;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True; Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  WriteLn('RENDERER ', GameRendererName);
  Device.CreateTexture(1, 1, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Rect.X := 0; Rect.Y := 0; Rect.W := 128; Rect.H := 96;
  for Cycle := 0 to 1 do
  begin
    if Cycle > 0 then Device.Reset(Params);
    Device.GetBackBuffer(0, 0, 0, Screen);
    Device.SetRenderTarget(0, Screen);
    for Mode := 0 to 5 do
    begin
      GameGraphicsTransform := GameGraphicsIdentityTransform;
      case Mode of
        1: begin GameGraphicsTransform.ScaleX := 0.78125; GameGraphicsTransform.ScaleY := 0.78125; end;
        2: begin GameGraphicsTransform.ScaleX := 1.5; GameGraphicsTransform.ScaleY := 1.5; end;
        3: begin GameGraphicsTransform.ScaleX := 2; GameGraphicsTransform.ScaleY := 2; end;
        4: GameGraphicsTransform.ScaleY := 2;
        5: begin GameGraphicsTransform.ScaleX := 0.625; GameGraphicsTransform.ScaleY := 0.625; end;
      end;
      GameGraphicsTransform.OffsetX := 0.25;
      GameGraphicsTransform.OffsetY := -0.75;
      Clip := Types.Rect(7, 9, 111, 85); Device.SetScissorRect(@Clip);
      for CaseIndex := 0 to 4 do
      begin
        case CaseIndex of
          0: Count := 8;
          1: Count := 127;
          2: Count := 512;
          3: Count := 16;
        else Count := 0;
        end;
        for I := 0 to High(Points) do
        begin
          // Repeated coordinates exercise ordering of overlapping translucent points.
          Points[I].X := ((I mod 64) * 17 mod 137) - 10 + (I mod 4) * 0.25;
          Points[I].Y := ((I mod 64) * 11 mod 107) - 10 + ((I mod 64) mod 3) * 0.25;
          Points[I].Color := Cardinal((I * 53 mod 256)) shl 24
              or Cardinal(I * 71 mod 256) shl 16
              or Cardinal(I * 97 mod 256) shl 8 or Cardinal(I * 131 mod 256);
          if CaseIndex <> 1 then Points[I].Color := Points[I].Color or $FF000000;
          Points[I].RHW := 1;
        end;
        if CaseIndex = 0 then Device.SetTexture(0, Texture)
        else Device.SetTexture(0, nil);
        Draw;
        if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888,
            @Pixels, 128 * 4) <> 0 then raise Exception.Create(string(SDL_GetError));
        Hash := 14695981039346656037;
        for I := 0 to High(Pixels) do Hash := (Hash xor Pixels[I]) * 1099511628211;
        if Cycle = 0 then
        begin Reference[Mode, CaseIndex] := Hash; WriteLn('POINT ', Mode, ' ', CaseIndex, ' ', IntToHex(Hash, 16)); end
        else if Hash <> Reference[Mode, CaseIndex] then raise Exception.Create('Reset changed point output');
      end;
    end;
  end;
  if ParamStr(1) = '--bench' then
  begin
    GameGraphicsTransform.ScaleX := 0.78125; GameGraphicsTransform.ScaleY := 0.78125;
    Count := 512;
    for I := 0 to High(Points) do Points[I].Color := Points[I].Color or $FF000000;
    for I := 0 to 9 do begin Draw; Device.Present(nil, nil, 0, nil); end;
    for Sample := 0 to High(Samples) do
    begin
      Started := SDL_GetPerformanceCounter;
      for I := 1 to 100 do begin Draw; Device.Present(nil, nil, 0, nil); end;
      Samples[Sample] := (SDL_GetPerformanceCounter - Started) * 1000.0 / SDL_GetPerformanceFrequency / 100;
    end;
    for J := 0 to High(Samples) do for K := J + 1 to High(Samples) do
      if Samples[J] > Samples[K] then begin Swap := Samples[J]; Samples[J] := Samples[K]; Samples[K] := Swap; end;
    WriteLn('{"median_ms":', Samples[3]:0:6, ',"min_ms":', Samples[0]:0:6, ',"max_ms":', Samples[6]:0:6, '}');
  end;
  WriteLn('PASS: scaled points, fractional positions, clipping, alpha, ordering, texture binding, scratch growth and reset');
  Device.SetTexture(0, nil); Texture := nil; Screen := nil; Device := nil; Graphics := nil; CloseGameWindow;
end.
