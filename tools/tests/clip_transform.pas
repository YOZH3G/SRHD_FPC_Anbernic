program ClipTransform;
{$MODE DELPHI}
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
  Screen, Target: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Quad: array[0..3] of TVertex;
  Pixels: array[0..4095] of Cardinal;
  Clip, Expected: TRect;
  Cycle, Mapping, RepeatDraw, I, X, Y: Integer;
  Color: Cardinal;

procedure CheckFrame;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF0000FF, 1, 0);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
  if SDL_RenderReadPixels(GameSDLRenderer, nil, SDL_PIXELFORMAT_ARGB8888,
      @Pixels, 64 * 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  for Y := 0 to 63 do
    for X := 0 to 63 do
    begin
      Color := $FF0000FF;
      if (X >= Expected.Left) and (X < Expected.Right)
          and (Y >= Expected.Top) and (Y < Expected.Bottom) then
        Color := $FFFF0000;
      if Pixels[Y * 64 + X] <> Color then
        raise Exception.CreateFmt('Clip mismatch: cycle %d, mapping %d, pixel %d,%d',
            [Cycle, Mapping, X, Y]);
    end;
end;

begin
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 64;
  Params.BackBufferHeight := 64;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True;
  Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  Device.CreateRenderTarget(64, 64, D3DFMT_A8R8G8B8, 0, 0, False, Target, nil);
  FillChar(Quad, SizeOf(Quad), 0);
  for I := 0 to 3 do
  begin
    Quad[I].RHW := 1;
    Quad[I].Color := $FFFF0000;
  end;
  Quad[0].X := -0.5; Quad[0].Y := -0.5;
  Quad[1].X := 127.5; Quad[1].Y := -0.5;
  Quad[2].X := 127.5; Quad[2].Y := 127.5;
  Quad[3].X := -0.5; Quad[3].Y := 127.5;
  for Cycle := 0 to 2 do
  begin
    if Cycle = 1 then Device.Reset(Params);
    if Cycle = 2 then
    begin
      Inc(GameTextureGeneration);
      Inc(GameTargetGeneration);
      Device.TestCooperativeLevel;
    end;
    Device.GetBackBuffer(0, 0, 0, Screen);
    Device.SetRenderTarget(0, Screen);
    GameGraphicsTransform := GameGraphicsIdentityTransform;
    Clip := Types.Rect(10, 10, 30, 30);
    Device.SetScissorRect(@Clip);
    // Change the mapping without setting the logical scissor again. This is
    // the camera-zoom path; a cache keyed only by the scissor is insufficient.
    for Mapping := 0 to 3 do
    begin
      GameGraphicsTransform := GameGraphicsIdentityTransform;
      case Mapping of
        0: Expected := Types.Rect(10, 10, 30, 30);
        1:
        begin
          GameGraphicsTransform.ScaleX := 0.5;
          GameGraphicsTransform.ScaleY := 0.5;
          Expected := Types.Rect(5, 5, 15, 15);
        end;
        2:
        begin
          GameGraphicsTransform.ScaleX := 0.5;
          GameGraphicsTransform.ScaleY := 0.5;
          GameGraphicsTransform.OffsetX := 6.25;
          GameGraphicsTransform.OffsetY := 6.25;
          Expected := Types.Rect(11, 11, 21, 21);
        end;
        3:
        begin
          GameGraphicsTransform.ScaleX := 2;
          GameGraphicsTransform.ScaleY := 2;
          GameGraphicsTransform.OffsetX := -5;
          GameGraphicsTransform.OffsetY := -5;
          Expected := Types.Rect(15, 15, 55, 55);
        end;
      end;
      for RepeatDraw := 0 to 2 do CheckFrame;
      // Intermediate surfaces use their own mapping, even while a screen
      // transform is active. Returning must restore the screen calculation.
      Device.SetRenderTarget(0, Target);
      Expected := Types.Rect(10, 10, 30, 30);
      CheckFrame;
      Device.SetRenderTarget(0, Screen);
      if Mapping = 0 then Expected := Types.Rect(10, 10, 30, 30)
      else if Mapping = 1 then Expected := Types.Rect(5, 5, 15, 15)
      else if Mapping = 2 then Expected := Types.Rect(11, 11, 21, 21)
      else Expected := Types.Rect(15, 15, 55, 55);
      CheckFrame;
    end;
    GameGraphicsTransform := GameGraphicsIdentityTransform;
    Clip := Types.Rect(2, 3, 7, 9);
    Device.SetScissorRect(@Clip);
    Expected := Clip;
    CheckFrame;
  end;
  WriteLn('PASS: scissor changes, camera mapping, target switches, reset and recreation');
  Target := nil; Screen := nil; Device := nil; Graphics := nil;
  CloseGameWindow;
end.
