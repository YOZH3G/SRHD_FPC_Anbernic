program DiscardedPixels;
{$MODE DELPHI}
{$Q-}
// Rebuildable textures free their CPU pixels after upload on low-memory
// handhelds. Drawing, a refill through a new lock and copies between textures
// must still work, and a device reset must not touch freed pixels.
uses
  SysUtils,
  Types,
  GameGraphics,
  GameWindow,
  Direct3D9,
  SDL2;
type
  TVertex = packed record
    X, Y, Z, RHW: Single;
    Color: Cardinal;
    U, V: Single;
  end;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Texture, Copy: IDirect3DTexture9;
  Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Quad: array[0..3] of TVertex;
  I: Integer;

procedure Fill(Target: IDirect3DTexture9; Color: Cardinal);
var
  Locked: TD3DLockedRect;
  Y, X: Integer;
begin
  Target.LockRect(0, Locked, nil, 0);
  for Y := 0 to 15 do
    for X := 0 to 15 do
      PCardinal(PByte(Locked.Bits) + Y * Locked.Pitch + X * 4)^ := Color;
  Target.UnlockRect(0);
end;

procedure Expect(Source: IDirect3DTexture9; Color: Cardinal; const Step: string);
var
  Pixel: Cardinal;
  Rect: TSDL_Rect;
begin
  Device.SetRenderTarget(0, Screen);
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF000000, 1, 0);
  Device.SetTexture(0, Source);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
  Rect.X := 8;
  Rect.Y := 8;
  Rect.W := 1;
  Rect.H := 1;
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixel, 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  if Pixel and $FFFFFF <> Color and $FFFFFF then
    raise Exception.CreateFmt('%s: drew %.8x instead of %.8x', [Step, Pixel, Color]);
  Device.Present(nil, nil, 0, nil);
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
  Device.GetBackBuffer(0, 0, 0, Screen);
  FillChar(Quad, SizeOf(Quad), 0);
  for I := 0 to 3 do
  begin
    Quad[I].Color := $FFFFFFFF;
    Quad[I].RHW := 1;
  end;
  Quad[1].X := 24;
  Quad[1].U := 1;
  Quad[2].X := 24;
  Quad[2].Y := 24;
  Quad[2].U := 1;
  Quad[2].V := 1;
  Quad[3].Y := 24;
  Quad[3].V := 1;
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  GameGraphicsDiscardUploadedPixels := True;
  Device.CreateTexture(16, 16, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Texture, nil);
  MarkGameGraphicsTextureRebuildable(Texture);
  Fill(Texture, $FFFF0000);
  Expect(Texture, $FF0000, 'first upload');
  Expect(Texture, $FF0000, 'draw after the pixels were freed');
  Fill(Texture, $FF00FF00);
  Expect(Texture, $00FF00, 'refill after the pixels were freed');
  Device.CreateTexture(16, 16, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Copy, nil);
  Device.UpdateTexture(Texture, Copy);
  Expect(Copy, $000000, 'copy of freed pixels');
  Inc(GameTextureGeneration);
  Inc(GameTargetGeneration);
  Device.TestCooperativeLevel;
  // The lost handle comes back transparent; the texture cache rebuilds it.
  Expect(Texture, $000000, 'draw after a device reset');
  Fill(Texture, $FF0000FF);
  Expect(Texture, $0000FF, 'refill after a device reset');
  WriteLn('RENDERER ', GameRendererName);
  WriteLn('PASS: freed texture pixels draw, refill, copy and survive a reset');
  Device.SetTexture(0, nil);
  Screen := nil;
  Copy := nil;
  Texture := nil;
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
