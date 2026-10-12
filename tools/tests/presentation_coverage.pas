program PresentationCoverage;
{$MODE DELPHI}
uses SysUtils, Types, GameGraphics, GameWindow, Direct3D9, SDL2;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Pixels: array of Cardinal;
  Ramp: TD3DGammaRamp;
  W, H, X, Y, I: Integer;
  Expected, Fill: Cardinal;

procedure SDL_PumpEvents; cdecl; external SDL2Library;

procedure CheckOutput(Width, Height: Integer; UseGamma: Boolean);
var
  Left, Top, Right, Bottom: Integer;
begin
  SDL_SetWindowSize(GameSDLWindow, Width, Height);
  SDL_PumpEvents;
  if SDL_SetRenderTarget(GameSDLRenderer, nil) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  if SDL_GetRendererOutputSize(GameSDLRenderer, W, H) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  if (W <> Width) or (H <> Height) then
    raise Exception.Create('Output resize failed');
  for I := 0 to 255 do
  begin
    Ramp.Red[I] := I * 257;
    Ramp.Green[I] := I * 257;
    Ramp.Blue[I] := I * 257;
    if UseGamma then Ramp.Red[I] := 0;
  end;
  Device.SetRenderTarget(0, Screen);
  Device.BeginScene;
  Device.SetGammaRamp(0, 0, Ramp);
  Fill := $FF11AA44;
  Device.Clear(0, nil, D3DCLEAR_TARGET, Fill, 1, 0);
  // Pollute the previous output: uncovered bars must become black again.
  if SDL_SetRenderTarget(GameSDLRenderer, nil) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  SDL_SetRenderDrawColor(GameSDLRenderer, 255, 0, 255, 255);
  SDL_RenderClear(GameSDLRenderer);
  Device.Present(nil, nil, 0, nil);
  if SDL_SetRenderTarget(GameSDLRenderer, nil) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  if SDL_RenderSetLogicalSize(GameSDLRenderer, 0, 0) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  SetLength(Pixels, W * H);
  if SDL_RenderReadPixels(GameSDLRenderer, nil, SDL_PIXELFORMAT_ARGB8888,
      @Pixels[0], W * 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  if W > H then
  begin
    Left := (W - H) div 2; Right := Left + H; Top := 0; Bottom := H;
  end
  else
  begin
    Left := 0; Right := W; Top := (H - W) div 2; Bottom := Top + W;
  end;
  for Y := 0 to H - 1 do
    for X := 0 to W - 1 do
    begin
      Expected := $FF000000;
      if (X >= Left) and (X < Right) and (Y >= Top) and (Y < Bottom) then
      begin
        Expected := Fill;
        if UseGamma then Expected := Fill and $FF00FFFF;
      end;
      if Pixels[Y * W + X] <> Expected then
        raise Exception.CreateFmt('Output %dx%d gamma=%s at %d,%d: %.8x <> %.8x',
            [W, H, BoolToStr(UseGamma, True), X, Y, Pixels[Y * W + X], Expected]);
    end;
  // Restore the D3D target after reading the window directly.
  Device.SetRenderTarget(0, Screen);
end;

procedure RunCases;
begin
  Device.GetBackBuffer(0, 0, 0, Screen);
  CheckOutput(64, 64, False);
  CheckOutput(128, 128, False);
  CheckOutput(128, 80, False);
  CheckOutput(80, 128, False);
  CheckOutput(64, 64, True);
  CheckOutput(128, 80, True);
  CheckOutput(80, 128, True);
  Device.Reset(Params);
  Device.GetBackBuffer(0, 0, 0, Screen);
  CheckOutput(64, 64, False);
end;

begin
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 64; Params.BackBufferHeight := 64;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True; Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumDesktop);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  RunCases;
  ConfigureGameUi(gumMobile);
  RunCases;
  WriteLn('PASS: desktop/native raster, full output, resizing, bars, gamma and reset');
  Screen := nil; Device := nil; Graphics := nil; CloseGameWindow;
end.
