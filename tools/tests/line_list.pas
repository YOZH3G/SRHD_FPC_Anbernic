program LineList;
{$MODE DELPHI}
{$Q-}
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
const
  LineCount = 300;
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Lines: array[0..LineCount * 2 - 1] of TVertex;
  Separate, Listed: array[0..12287] of Cardinal;
  Rect: TSDL_Rect;
  Clip: TRect;
  Mode, I, Differing: Integer;

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
  WriteLn('RENDERER ', GameRendererName);
  Rect.X := 0;
  Rect.Y := 0;
  Rect.W := 128;
  Rect.H := 96;
  Device.GetBackBuffer(0, 0, 0, Screen);
  Device.SetRenderTarget(0, Screen);
  Clip := Types.Rect(7, 9, 111, 85);
  Device.SetScissorRect(@Clip);
  Device.SetTexture(0, nil);
  // Short overlapping translucent edges like the radiation lattice, lines
  // running past the clip rectangle, and zero-length edges, which a list
  // skips.
  for I := 0 to LineCount - 1 do
  begin
    FillChar(Lines[I * 2], SizeOf(TVertex) * 2, 0);
    Lines[I * 2].X := (I * 37) mod 140 - 6;
    Lines[I * 2].Y := (I * 23) mod 110 - 7;
    Lines[I * 2 + 1].X := Lines[I * 2].X + (I mod 7) * 3 - 9;
    Lines[I * 2 + 1].Y := Lines[I * 2].Y + (I mod 5) * 4 - 8;
    Lines[I * 2].Color := Cardinal(40 + I * 7 mod 200) shl 24 or Cardinal(I * 71 mod 256) shl 16 or Cardinal(I * 13 mod 256) shl 8 or $80;
    Lines[I * 2 + 1].Color := Lines[I * 2].Color;
    Lines[I * 2].RHW := 1;
    Lines[I * 2 + 1].RHW := 1;
  end;
  for Mode := 0 to 3 do
  begin
    GameGraphicsTransform := GameGraphicsIdentityTransform;
    case Mode of
      1:
      begin
        GameGraphicsTransform.ScaleX := 0.8;
        GameGraphicsTransform.ScaleY := 0.8;
      end;
      2:
      begin
        GameGraphicsTransform.ScaleX := 1.5;
        GameGraphicsTransform.ScaleY := 1.5;
      end;
      3: GameGraphicsTransform.ScaleY := 1.25;
    end;
    GameGraphicsTransform.OffsetX := 0.25;
    GameGraphicsTransform.OffsetY := -0.75;
    Device.Clear(0, nil, D3DCLEAR_TARGET, $40102030, 1, 0);
    for I := 0 to LineCount - 1 do
      if (Lines[I * 2].X <> Lines[I * 2 + 1].X) or (Lines[I * 2].Y <> Lines[I * 2 + 1].Y) then
        Device.DrawPrimitiveUP(D3DPT_LINESTRIP, 1, @Lines[I * 2], SizeOf(TVertex));
    Read(Separate);
    Device.Clear(0, nil, D3DCLEAR_TARGET, $40102030, 1, 0);
    Device.DrawPrimitiveUP(D3DPT_LINELIST, LineCount, @Lines, SizeOf(TVertex));
    Read(Listed);
    Differing := 0;
    for I := 0 to High(Separate) do
      if Separate[I] <> Listed[I] then
        Inc(Differing);
    WriteLn('LINES mode ', Mode, ': ', Differing, ' of ', Length(Separate), ' pixels differ');
    // Unscaled single-color edges were SDL lines; the list draws quads.
    if (Mode <> 0) and (Differing <> 0) then
      raise Exception.Create('A line list differs from the same lines drawn one by one');
  end;
  WriteLn('PASS');
  Screen := nil;
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
