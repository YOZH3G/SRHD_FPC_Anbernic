program UiTileSeams;
{$MODE DELPHI}
uses SysUtils, Math, Types, GameGraphics, GameWindow, Direct3D9, SDL2;
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
  Params: TD3DPresentParameters;
  Locked: TD3DLockedRect;
  Quad: array[0..3] of TVertex;
  Pixels: array of Cardinal;
  X, Y, I, Gaps: Integer;

function RenderTiles(Scale: Single; Snap: Boolean): Integer;
var
  Rect: TSDL_Rect;
  Row, Column: Integer;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FFFF0000, 1, 0);
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  GameGraphicsTransform.ScaleX := Scale;
  GameGraphicsTransform.ScaleY := Scale;
  GameGraphicsTransform.PixelAligned := Snap;
  Device.SetTexture(0, Texture);
  Y := 20;
  while Y < 164 do
  begin
    for X := 760 to 1009 do
    begin
      Quad[0].X := X - 0.5; Quad[0].Y := Y - 0.5;
      Quad[1].X := X + 0.5; Quad[1].Y := Y - 0.5;
      Quad[2].X := X + 0.5; Quad[2].Y := Y + 7.5;
      Quad[3].X := X - 0.5; Quad[3].Y := Y + 7.5;
      Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
    end;
    Inc(Y, 8);
  end;
  Device.SetTexture(0, nil);
  Rect.X := Round(760 * Scale); Rect.Y := Round(20 * Scale);
  Rect.W := Round(1010 * Scale) - Rect.X;
  Rect.H := Round(164 * Scale) - Rect.Y;
  SetLength(Pixels, Rect.W * Rect.H);
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888,
      @Pixels[0], Rect.W * 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  Result := 0;
  for Row := 0 to Rect.H - 1 do
    for Column := 0 to Rect.W - 1 do
      if Pixels[Row * Rect.W + Column] <> $FF008000 then
        Inc(Result);
end;

begin
  FillChar(Params, SizeOf(Params), 0);
  Params.BackBufferWidth := 1024; Params.BackBufferHeight := 768;
  Params.BackBufferFormat := D3DFMT_A8R8G8B8;
  Params.Windowed := True;
  Params.PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  Graphics := CreateGameGraphics;
  Graphics.CreateDevice(0, D3DDEVTYPE_HAL, 0, 0, Params, Device);
  Device.CreateTexture(1, 8, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  Texture.LockRect(0, Locked, nil, 0);
  for I := 0 to 7 do
    PCardinal(PByte(Locked.Bits) + I * Locked.Pitch)^ := $FF008000;
  Texture.UnlockRect(0);
  FillChar(Quad, SizeOf(Quad), 0);
  for I := 0 to 3 do
  begin
    Quad[I].RHW := 1; Quad[I].Color := $FFFFFFFF;
  end;
  Quad[1].U := 1; Quad[2].U := 1; Quad[2].V := 1; Quad[3].V := 1;
  Gaps := RenderTiles(800 / 1024, False);
  if Gaps = 0 then raise Exception.Create('Fractional seam reproduction did not trigger');
  WriteLn('Reproduced fractional gaps: ', Gaps);
  Gaps := RenderTiles(800 / 1024, True);
  if Gaps <> 0 then raise Exception.CreateFmt('Scaled UI has %d gap pixels', [Gaps]);
  if RenderTiles(1, False) <> 0 then raise Exception.Create('Native UI has gap pixels');
  WriteLn('PASS: continuous UI tiles at 800x600 scale and native 1024x768');
  Texture := nil; Device := nil; Graphics := nil;
  CloseGameWindow;
end.
