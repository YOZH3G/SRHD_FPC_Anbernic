program RadialRing;
{$MODE DELPHI}
{$Q-}
uses
  SysUtils,
  Types,
  Math,
  GameGraphics,
  GameWindow,
  Direct3D9,
  SDL2,
  GR_DX,
  GR_Main;
type
  TVertex = packed record
    X, Y, Z, RHW: Single;
    Color: Cardinal;
    U, V: Single;
  end;
const
  CenterX = 61;
  CenterY = 50;
  InnerRadius = 12;
  Background = $FF102030;
  OuterRadius = 44;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Texels: array[0..OuterRadius - InnerRadius] of Cardinal;
  Expected, Drawn: array[0..12287] of Cardinal;
  Rect: TSDL_Rect;
  Clip: TRect;
  X, Y, I, Lower, Channel, Difference, Worst, Count: Integer;
  Distance, Weight, Alpha: Double;
  Color: Cardinal;

function Channels(Value: Cardinal; Shift: Integer): Integer;
begin
  Result := (Value shr Shift) and $FF;
end;

procedure Read(var Pixels: array of Cardinal);
begin
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixels[0], 128 * 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
end;

begin
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 128;
  Params.BackBufferHeight := 96;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True;
  Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  ConfigureGameUi(gumMobile);
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  Direct3DDevice := Device;
  WriteLn('RENDERER ', GameRendererName);
  Rect.X := 0;
  Rect.Y := 0;
  Rect.W := 128;
  Rect.H := 96;
  Device.GetBackBuffer(0, 0, 0, Screen);
  Device.SetRenderTarget(0, Screen);
  // A ring cut by the clip rectangle and the screen edge, transparent at both
  // radii like the radiation ring, with a color ramp and a sharp alpha peak.
  for I := 0 to High(Texels) do
    Texels[I] := Cardinal(Round(255 * Max(0, 1 - Abs(I - 22) / 18))) shl 24 or Cardinal(I * 7) shl 16 or Cardinal(255 - I * 5) shl 8 or $40;
  Texels[0] := Texels[1] and $FFFFFF;
  Texels[High(Texels)] := Texels[High(Texels) - 1] and $FFFFFF;
  Clip := Types.Rect(3, 5, 120, 90);
  // The reference blends the texels interpolated at each pixel's exact
  // distance over the background, as the radiation ring's per-pixel points
  // did. Renderers place points differently, so it is computed here.
  for Y := 0 to 95 do
    for X := 0 to 127 do
    begin
      Expected[Y * 128 + X] := Background;
      Distance := Sqrt(Sqr(X - CenterX) + Sqr(Y - CenterY)) - InnerRadius;
      if (Distance < 0) or (Distance > High(Texels)) or not PtInRect(Clip, Types.Point(X, Y)) then
        Continue;
      Lower := Min(Floor(Distance), High(Texels) - 1);
      Weight := Distance - Lower;
      Alpha := (Channels(Texels[Lower], 24) * (1 - Weight) + Channels(Texels[Lower + 1], 24) * Weight) / 255;
      Color := $FF000000;
      for Channel := 0 to 2 do
        Color :=
            Color
                or Cardinal(
                        Round(
                            (Channels(Texels[Lower], Channel * 8) * (1 - Weight) + Channels(Texels[Lower + 1], Channel * 8) * Weight)
                                    * Alpha
                                + Channels(Background, Channel * 8) * (1 - Alpha)
                        ))
                    shl (Channel * 8);
      Expected[Y * 128 + X] := Color;
    end;
  Device.Clear(0, nil, D3DCLEAR_TARGET, Background, 1, 0);
  DrawRadialRing(CenterX, CenterY, InnerRadius, Texels, @Clip);
  Read(Drawn);
  Worst := 0;
  Count := 0;
  for I := 0 to High(Drawn) do
  begin
    Difference := 0;
    for Channel := 0 to 2 do
      Difference := Max(Difference, Abs(Channels(Drawn[I], Channel * 8) - Channels(Expected[I], Channel * 8)));
    Worst := Max(Worst, Difference);
    if Difference > 2 then
      Inc(Count);
  end;
  WriteLn('RING largest channel difference ', Worst, '; pixels off by more than 2: ', Count);
  // SDL's software renderer samples triangles coarsely; only GPUs are held
  // to the per-pixel result.
  if (GameRendererName <> 'software') and (Worst > 8) then
    raise Exception.Create('The ring mesh differs from per-pixel points');
  if (Drawn[2 * 128 + 61] <> Background) or (Drawn[50 * 128 + 61] <> Background) then
    raise Exception.Create('The ring mesh drew outside the clip rectangle or inside the ring');
  WriteLn('PASS');
  ReleaseRadialRingTexture;
  Direct3DDevice := nil;
  Screen := nil;
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
