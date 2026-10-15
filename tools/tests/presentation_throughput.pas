program PresentationThroughput;
{$MODE DELPHI}
uses
  SysUtils,
  Types,
  GameGraphics,
  GameWindow,
  Direct3D9,
  SDL2;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Params: TD3DPresentParameters;
  Samples: array[0..6] of Double;
  Started: QWord;
  J, K, Sample: Integer;
  Swap: Double;

procedure DrawFrame;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
  Device.Present(nil, nil, 0, nil);
end;

begin
  DefaultFormatSettings.DecimalSeparator := '.';
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 800;
  Params.BackBufferHeight := 600;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True;
  Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  for J := 1 to 10 do
    DrawFrame;
  for Sample := 0 to High(Samples) do
  begin
    Started := SDL_GetPerformanceCounter;
    for J := 1 to 100 do
      DrawFrame;
    Samples[Sample] := (SDL_GetPerformanceCounter - Started) * 1000.0 / SDL_GetPerformanceFrequency / 100;
  end;
  for J := 0 to High(Samples) do
    for K := J + 1 to High(Samples) do
      if Samples[J] > Samples[K] then
      begin
        Swap := Samples[J];
        Samples[J] := Samples[K];
        Samples[K] := Swap;
      end;
  WriteLn(
      '{"median_ms":',
      Samples[3]:
          0:
          6,
          ',"min_ms":',
          Samples[0]:
          0:
          6,
          ',"max_ms":',
          Samples[6]:
          0:
          6,
          ',"frames_per_sample":100,"samples":7}'
  );
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
