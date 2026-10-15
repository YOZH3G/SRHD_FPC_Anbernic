program SolidRectangle;
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
var
  Graphics: IDirect3D9;
  Device: IDirect3DDevice9;
  Screen: IDirect3DSurface9;
  Params: TD3DPresentParameters;
  Quad: array[0..5] of TVertex;
  Pixels: array[0..12287] of Cardinal;
  Reference: array[0..2, 0..8] of QWord;
  Hash: QWord;
  Clip: TRect;
  Rect: TSDL_Rect;
  Mode, CaseIndex, Cycle, I, PrimitiveCount: Integer;

procedure PrepareCase;
begin
  FillChar(Quad, SizeOf(Quad), 0);
  for I := 0 to 5 do
  begin
    Quad[I].Color := $FF40A0E0;
    Quad[I].RHW := 1;
  end;
  Quad[0].X := 4.5;
  Quad[0].Y := 6.5;
  Quad[1].X := 99.5;
  Quad[1].Y := 6.5;
  Quad[2].X := 99.5;
  Quad[2].Y := 79.5;
  Quad[3].X := 4.5;
  Quad[3].Y := 79.5;
  Quad[4] := Quad[0];
  Quad[5].X := 117.5;
  Quad[5].Y := 91.5;
  Quad[5].Color := $00112233;
  PrimitiveCount := 2;
  Device.SetRenderState(8, 3); // D3DRS_FILLMODE, D3DFILL_SOLID
  case CaseIndex of
    1: PrimitiveCount := 4; // Closed fan used by DrawColoredRect.
    2:
      for I := 0 to 3 do
        Quad[I].Color := $8040A0E0;
    3: Quad[3].Color := $FF204060;
    4:
      for I := 0 to 5 do
        Quad[I].X := Quad[I].X + 0.25;
    5:
    begin
      Quad[2].X := 88.5;
      Quad[3].X := 13.5;
    end;
    6:
    begin
      PrimitiveCount := 4;
      Quad[4].X := 117.5;
      Quad[4].Y := 8.5; // Non-degenerate extra triangles.
    end;
    7: Device.SetRenderState(8, 2); // D3DFILL_WIREFRAME
    8:
    begin
      Quad[0].X := 99.5;
      Quad[1].X := 4.5;
      Quad[2].X := 4.5;
      Quad[3].X := 99.5; // Reversed winding/negative extent.
    end;
  end;
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
  for Cycle := 0 to 1 do
  begin
    if Cycle > 0 then
      Device.Reset(Params);
    Device.GetBackBuffer(0, 0, 0, Screen);
    Device.SetRenderTarget(0, Screen);
    Device.SetTexture(0, nil);
    for Mode := 0 to 2 do
    begin
      GameGraphicsTransform := GameGraphicsIdentityTransform;
      if Mode = 1 then
      begin
        GameGraphicsTransform.ScaleX := 0.78125;
        GameGraphicsTransform.ScaleY := 0.78125;
        GameGraphicsTransform.OffsetX := 3.25;
        GameGraphicsTransform.OffsetY := 2.5;
      end;
      if Mode = 2 then
      begin
        GameGraphicsTransform.ScaleX := 2;
        GameGraphicsTransform.ScaleY := 2;
      end;
      Clip := Types.Rect(12, 11, 103, 83);
      Device.SetScissorRect(@Clip);
      for CaseIndex := 0 to 8 do
      begin
        PrepareCase;
        // A partially transparent destination detects accidental alpha changes.
        Device.Clear(0, nil, D3DCLEAR_TARGET, $40102030, 1, 0);
        Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, PrimitiveCount, @Quad, SizeOf(TVertex));
        if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixels, 128 * 4) <> 0 then
          raise Exception.Create(string(SDL_GetError));
        Hash := 14695981039346656037;
        for I := 0 to High(Pixels) do
          Hash := (Hash xor Pixels[I]) * 1099511628211;
        if Cycle = 0 then
        begin
          Reference[Mode, CaseIndex] := Hash;
          WriteLn('RECT ', Mode, ' ', CaseIndex, ' ', IntToHex(Hash, 16));
        end
        else if Hash <> Reference[Mode, CaseIndex] then
          raise Exception.Create('Reset changed rectangle output');
      end;
    end;
  end;
  WriteLn('PASS: solid rectangle, closed fan, alpha, colors, fractional edges, skew, wireframe, winding, clips and reset');
  Screen := nil;
  Device := nil;
  Graphics := nil;
  CloseGameWindow;
end.
