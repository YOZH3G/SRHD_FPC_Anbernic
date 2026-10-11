program RenderThroughput;
{$MODE DELPHI}
{$Q-}
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
  Vertices: array[0..127] of TVertex;
  Pixels: array of Cardinal;
  I: Integer;

function SDL_GetPerformanceCounter: QWord; cdecl; external SDL2Library;

procedure DrawScene(Kind: Integer);
var
  X, Y, N, J, Count: Integer;
  Angle: Double;
  Primitive: Cardinal;
begin
  Device.Clear(0, nil, D3DCLEAR_TARGET, $FF123456, 1, 0);
  GameGraphicsTransform := GameGraphicsIdentityTransform;
  if Kind = 0 then
  begin
    GameGraphicsTransform.ScaleX := 800/1024;
    GameGraphicsTransform.ScaleY := 800/1024;
    GameGraphicsTransform.PixelAligned := True;
  end
  else GameGraphicsTransform.PixelAligned := False;
  Device.SetTexture(0, Texture);
  for N := 0 to 2047 do
  begin
    X := 10 + (N mod 100)*9; Y := 10 + ((N div 100) mod 70)*9;
    if Kind < 2 then
    begin
      Vertices[0].X:=X-0.5; Vertices[0].Y:=Y-0.5;
      Vertices[1].X:=X+7.5; Vertices[1].Y:=Y-0.5;
      Vertices[2].X:=X+7.5; Vertices[2].Y:=Y+7.5;
      Vertices[3].X:=X-0.5; Vertices[3].Y:=Y+7.5;
      if Kind=1 then begin
        Vertices[1].Y:=Y+1.25; Vertices[2].X:=X+5.25;
      end;
      Vertices[0].U:=0; Vertices[0].V:=0;
      Vertices[1].U:=1; Vertices[1].V:=0;
      Vertices[2].U:=1; Vertices[2].V:=1;
      Vertices[3].U:=0; Vertices[3].V:=1;
      Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN,2,@Vertices,SizeOf(TVertex));
    end
    else begin
      // Grow/reuse buffers, alternate indexed fans and non-indexed lists,
      // then exercise untextured points, line strips and wireframe geometry.
      Count := 3 + N mod 125;
      for J:=0 to Count-1 do begin
        Angle:=J*2*Pi/Count;
        Vertices[J].X:=X+4+Cos(Angle)*4;
        Vertices[J].Y:=Y+4+Sin(Angle)*4;
        Vertices[J].U:=(Cos(Angle)+1)/2;
        Vertices[J].V:=(Sin(Angle)+1)/2;
      end;
      if N mod 5=0 then begin
        Primitive:=D3DPT_TRIANGLELIST; Count:=Count div 3;
      end else begin Primitive:=D3DPT_TRIANGLEFAN; Count:=Count-2; end;
      if N mod 29=0 then Device.SetRenderState(8,D3DFILL_WIREFRAME);
      Device.DrawPrimitiveUP(Primitive,Count,@Vertices,SizeOf(TVertex));
      Device.SetRenderState(8,D3DFILL_SOLID);
      if N mod 31=0 then begin
        Device.SetTexture(0,nil);
        Device.DrawPrimitiveUP(D3DPT_LINESTRIP,3,@Vertices,SizeOf(TVertex));
        Device.DrawPrimitiveUP(D3DPT_POINTLIST,4,@Vertices,SizeOf(TVertex));
        Device.SetTexture(0,Texture);
      end;
      if N mod 37=0 then Device.SetSamplerState(0,5,1+((N div 37) mod 2));
    end;
  end;
  if SDL_RenderFlush(GameSDLRenderer)<>0 then raise Exception.Create(string(SDL_GetError));
end;

function Fingerprint: Cardinal;
var
  J: Integer;
begin
  SetLength(Pixels,1024*768);
  if SDL_RenderReadPixels(GameSDLRenderer,nil,SDL_PIXELFORMAT_ARGB8888,@Pixels[0],1024*4)<>0 then
    raise Exception.Create(string(SDL_GetError));
  Result:=2166136261;
  for J:=0 to High(Pixels) do Result:=(Result xor Pixels[J])*16777619;
end;

procedure Measure(Kind: Integer; const Name: string);
var
  Sample,J,K: Integer;
  Started,Elapsed,Times,Swap: Double;
  Samples: array[0..6] of Double;
  Hash: Cardinal;
begin
  for J:=1 to 2 do DrawScene(Kind);
  for Sample:=0 to High(Samples) do begin
    Started:=SDL_GetPerformanceCounter;
    for J:=1 to 4 do DrawScene(Kind);
    Elapsed:=(SDL_GetPerformanceCounter-Started)*1000/SDL_GetPerformanceFrequency;
    Samples[Sample]:=Elapsed/4;
  end;
  Hash:=Fingerprint;
  for J:=0 to High(Samples) do
    for K:=J+1 to High(Samples) do
      if Samples[J]>Samples[K] then begin Swap:=Samples[J];Samples[J]:=Samples[K];Samples[K]:=Swap;end;
  Times:=Samples[3];
  WriteLn('{"case":"',Name,'","median_ms":',Times:0:3,',"min_ms":',Samples[0]:0:3,
      ',"max_ms":',Samples[6]:0:3,',"draws_per_scene":2048,"hash":"',IntToHex(Hash,8),'"}');
end;

begin
  DefaultFormatSettings.DecimalSeparator:='.';
  FillChar(Params,SizeOf(Params),0);
  Params.BackBufferWidth:=1024;Params.BackBufferHeight:=768;
  Params.BackBufferFormat:=D3DFMT_A8R8G8B8;
  Params.Windowed:=True;Params.PresentationInterval:=D3DPRESENT_INTERVAL_IMMEDIATE;
  Graphics:=CreateGameGraphics;Graphics.CreateDevice(0,D3DDEVTYPE_HAL,0,0,Params,Device);
  Device.CreateTexture(8,8,1,0,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,Texture,nil);
  Texture.LockRect(0,Locked,nil,0);
  for I:=0 to 63 do PCardinal(PByte(Locked.Bits)+(I div 8)*Locked.Pitch+(I mod 8)*4)^ := $C0804020+Cardinal(I)*$00010201;
  Texture.UnlockRect(0);
  FillChar(Vertices,SizeOf(Vertices),0);
  for I:=0 to High(Vertices) do begin Vertices[I].RHW:=1;Vertices[I].Color:=$D0FFFFFF;end;
  Measure(0,'ui-800');Measure(1,'sprites-1024');Measure(2,'mixed-primitives');
  Device.Reset(Params);Measure(0,'ui-after-reset');
  Texture:=nil;Device:=nil;Graphics:=nil;CloseGameWindow;
end.
