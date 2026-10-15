program RendererFallback;
{$MODE DELPHI}
uses
  SysUtils,
  GameWindow,
  SDL2;
var
  Texture: PSDL_Texture;
  Info: TSDL_RendererInfo;
  Rect: TSDL_Rect;
  Pixel: Cardinal;
begin
  if ParamStr(1) = 'software' then
    GameRendererPreference := grpSoftware;
{$IFDEF SRHD_ANBERNIC}
  if not GameWindowUsesRenderResolution then
    raise Exception.Create('Handheld resolutions must be independent of panel modes');
{$ENDIF}
  OpenGameWindow(1024, 768, True, True);
  try
    if ParamStr(1) = 'sdl' then
    begin
      if not GameRendererAccelerated then
        raise Exception.Create('Expected accelerated SDL driver');
      if GameRendererFallback <> '' then
        raise Exception.Create('Unexpected fallback');
    end
    else if GameRendererAccelerated then
      raise Exception.Create('Expected dummy software driver');
    if (ParamStr(1) <> 'sdl') and (GameRendererPreference = grpSDL) and (GameRendererFallback = '') then
      raise Exception.Create('Missing acceleration failure reason');
    if (GameRendererPreference = grpSoftware) and (GameRendererFallback <> '') then
      raise Exception.Create('Forced software attempted acceleration');
    if SDL_GetRendererInfo(GameSDLRenderer, Info) <> 0 then
      raise Exception.Create(string(SDL_GetError));
    Texture := SDL_CreateTexture(GameSDLRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_TARGET, 32, 32);
    if Texture = nil then
      raise Exception.Create(string(SDL_GetError));
    try
      if SDL_SetRenderTarget(GameSDLRenderer, Texture) <> 0 then
        raise Exception.Create(string(SDL_GetError));
      SDL_SetRenderDrawColor(GameSDLRenderer, 30, 80, 140, 255);
      SDL_RenderClear(GameSDLRenderer);
      Pixel := 0;
      Rect.X := 0;
      Rect.Y := 0;
      Rect.W := 1;
      Rect.H := 1;
      if SDL_RenderReadPixels(GameSDLRenderer, @Rect, SDL_PIXELFORMAT_ARGB8888, @Pixel, SizeOf(Pixel)) <> 0 then
        raise Exception.Create(string(SDL_GetError));
      if Pixel <> $FF1E508C then
        raise Exception.Create('Render target pixel mismatch');
      SDL_SetRenderTarget(GameSDLRenderer, nil);
      SDL_RenderCopy(GameSDLRenderer, Texture, nil, nil);
      SDL_RenderPresent(GameSDLRenderer);
    finally
      SDL_DestroyTexture(Texture);
    end;
    WriteLn('PASS: renderer=', UTF8Encode(GameRendererName), '; fallback=', UTF8Encode(GameRendererFallback));
  finally
    CloseGameWindow;
  end;
end.
