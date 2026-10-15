program TextureState;
{$MODE DELPHI}
{$Q-}
uses
  SysUtils,
  Types,
  GameGraphics,
  GameWindow,
  Direct3D9,
  SDL2;
const
  D3DTEXF_POINT = 1;
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
  Surface, Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Quad: array[0..3] of TVertex;
  Locked: TD3DLockedRect;
  Pixels: array[0..575] of Cardinal;
  ReferenceHash, Hash: Cardinal;
  Pixel: Cardinal;
  Rect: TSDL_Rect;
  I, J, Cycle: Integer;

procedure DrawAndCheck;
begin
  Device.SetRenderTarget(0, Screen);
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF0000FF, 1, 0);
  Device.SetTexture(0, Texture);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, 2, @Quad, SizeOf(TVertex));
  Rect.X := 8;
  Rect.Y := 8;
  Rect.W := 1;
  Rect.H := 1;
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixel, 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  // An alpha-128 red source over opaque blue must contain both channels.
  // A stale NONE blend would replace it with red and lose the blue channel.
  if ((Pixel shr 16) and 255 < 100) or (Pixel and 255 < 100) or (Pixel shr 24 < 254) then
    raise Exception.CreateFmt('Alpha blending was not restored: %.8x', [Pixel]);
  Rect.X := 0;
  Rect.Y := 0;
  Rect.W := 24;
  Rect.H := 24;
  if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixels, 24 * 4) <> 0 then
    raise Exception.Create(string(SDL_GetError));
  Hash := 2166136261;
  for J := 0 to High(Pixels) do
    Hash := (Hash xor Pixels[J]) * 16777619;
  if ReferenceHash = 0 then
    ReferenceHash := Hash
  else if Hash <> ReferenceHash then
    raise Exception.Create('Copy/present/reset changed the filtered frame');

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
  Device.CreateTexture(16, 16, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, Texture, nil);
  Texture.LockRect(0, Locked, nil, 0);
  for I := 0 to 255 do
    if I mod 16 < 8 then
      PCardinal(PByte(Locked.Bits) + (I div 16) * Locked.Pitch + (I mod 16) * 4)^ := $80FF0000
    else
      PCardinal(PByte(Locked.Bits) + (I div 16) * Locked.Pitch + (I mod 16) * 4)^ := $8000FF00;
  Texture.UnlockRect(0);
  Texture.GetSurfaceLevel(0, Surface);
  Device.GetBackBuffer(0, 0, 0, Screen);
  FillChar(Quad, SizeOf(Quad), 0);
  for I := 0 to 3 do
  begin
    Quad[I].Color := $FFFFFFFF;
    Quad[I].RHW := 1;
  end;
  Quad[0].X := -0.5;
  Quad[0].Y := -0.5;
  Quad[1].X := 23.5;
  Quad[1].Y := -0.5;
  Quad[1].U := 1;
  Quad[2].X := 23.5;
  Quad[2].Y := 23.5;
  Quad[2].U := 1;
  Quad[2].V := 1;
  Quad[3].X := -0.5;
  Quad[3].Y := 23.5;
  Quad[3].V := 1;
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  GameGraphicsTransform.PixelAligned := False;
  for Cycle := 0 to 3 do
  begin
    if Cycle > 0 then
    begin
      Inc(GameTextureGeneration);
      Inc(GameTargetGeneration);
      Device.TestCooperativeLevel;
    end;
    Device.SetRenderTarget(0, Screen);
    Device.SetSamplerState(0, 5, D3DTEXF_LINEAR);
    DrawAndCheck;
    Device.StretchRect(Surface, nil, Screen, nil, D3DTEXF_POINT);
    DrawAndCheck;
    Device.Present(nil, nil, 0, nil);
    DrawAndCheck;
    if Cycle = 2 then
    begin
      Device.Reset(Params);
      Device.GetBackBuffer(0, 0, 0, Screen);
      DrawAndCheck;
    end;
  end;
  WriteLn('PASS: copy/draw sampling, alpha blending, presentation, reset and handle recreation');
  Device.SetTexture(0, nil);
  Surface := nil;
  Screen := nil;
  Texture := nil;
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
