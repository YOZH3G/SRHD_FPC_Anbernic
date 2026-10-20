unit GameGPUPlanet;
{$MODE delphi}
interface
uses
  Types;

function GPUPlanetCreate(Projection: Pointer; Width, Height: Integer): Pointer;
procedure GPUPlanetDestroy(var Planet: Pointer);
function GPUPlanetLayer(
    Planet: Pointer;
    Layer: Integer;
    Pixels: Pointer;
    Width, Height, Pitch, BytesPerPixel: Integer;
    Palette: Pointer;
    PaletteCount, Variant: Integer
): Boolean;
function GPUPlanetLight(Planet, Light: Pointer): Boolean;
function GPUPlanetLightSource(Planet, Light, Rotation: Pointer): Boolean;
procedure GPUPlanetSetLightAngle(Planet: Pointer; Angle: Integer);
function GPUPlanetReady(Planet: Pointer): Boolean;

function GPUAtmosphereCreate(Image: Pointer; Width, Height, Pitch: Integer): Pointer;
procedure GPUAtmosphereDestroy(var Atmosphere: Pointer);
function GPUAtmosphereMask(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer;
    Angle: Integer
): Boolean;
function GPUAtmosphereReady(Atmosphere: Pointer): Boolean;
function GPUAtmosphereSource(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer
): Boolean;
procedure GPUAtmosphereAngle(Atmosphere: Pointer; Angle: Integer);


implementation
{$IFDEF ANDROID}

function rangers_gpu_planet_create(
    Projection: Pointer;
    Width, Height: Integer
): Pointer; cdecl; external 'okgf';
procedure rangers_gpu_planet_destroy(Planet: Pointer); cdecl; external 'okgf';
function rangers_gpu_planet_layer(
    Planet: Pointer;
    Layer: Integer;
    Pixels: Pointer;
    Width, Height, Pitch, BytesPerPixel: Integer;
    Palette: Pointer;
    PaletteCount, Variant: Integer
): Integer; cdecl; external 'okgf';
function rangers_gpu_planet_light(Planet, Light: Pointer): Integer; cdecl; external 'okgf';
function rangers_gpu_planet_light_source(
    Planet,
    Light,
    Rotation: Pointer
): Integer; cdecl; external 'okgf';
procedure rangers_gpu_planet_light_angle(
    Planet: Pointer;
    Angle: Integer
); cdecl; external 'okgf';
function rangers_gpu_planet_ready(Planet: Pointer): Integer; cdecl; external 'okgf';
function rangers_gpu_planet_draw(
    Planet: Pointer;
    Layer, MapOffset, Linear: Integer;
    Vertices: Pointer;
    Count: Integer
): Integer; cdecl; external 'okgf';
function rangers_gpu_atmosphere_create(
    Image: Pointer;
    Width, Height, Pitch: Integer
): Pointer; cdecl; external 'okgf';
procedure rangers_gpu_atmosphere_destroy(Atmosphere: Pointer); cdecl; external 'okgf';
function rangers_gpu_atmosphere_mask(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer;
    Angle: Integer
): Integer; cdecl; external 'okgf';
function rangers_gpu_atmosphere_ready(Atmosphere: Pointer): Integer; cdecl; external 'okgf';
function rangers_gpu_atmosphere_source(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer
): Integer; cdecl; external 'okgf';
procedure rangers_gpu_atmosphere_angle(
    Atmosphere: Pointer;
    Angle: Integer
); cdecl; external 'okgf';
function rangers_gpu_atmosphere_draw(
    Atmosphere: Pointer;
    Color: Cardinal;
    Linear: Integer;
    Vertices: Pointer;
    Count: Integer
): Integer; cdecl; external 'okgf';
{$ENDIF}

function GPUPlanetCreate(Projection: Pointer; Width, Height: Integer): Pointer;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_planet_create(Projection, Width, Height);
{$ELSE}
  Result := nil;
{$ENDIF}
end;

procedure GPUPlanetDestroy(var Planet: Pointer);
begin
{$IFDEF ANDROID}
  rangers_gpu_planet_destroy(Planet);
{$ENDIF}
  Planet := nil;
end;

function GPUPlanetLayer(
    Planet: Pointer;
    Layer: Integer;
    Pixels: Pointer;
    Width, Height, Pitch, BytesPerPixel: Integer;
    Palette: Pointer;
    PaletteCount, Variant: Integer
): Boolean;
begin
{$IFDEF ANDROID}
  Result :=
      rangers_gpu_planet_layer(
              Planet,
              Layer,
              Pixels,
              Width,
              Height,
              Pitch,
              BytesPerPixel,
              Palette,
              PaletteCount,
              Variant)
          <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function GPUPlanetLight(Planet, Light: Pointer): Boolean;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_planet_light(Planet, Light) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function GPUPlanetLightSource(Planet, Light, Rotation: Pointer): Boolean;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_planet_light_source(Planet, Light, Rotation) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure GPUPlanetSetLightAngle(Planet: Pointer; Angle: Integer);
begin
{$IFDEF ANDROID}
  rangers_gpu_planet_light_angle(Planet, Angle);
{$ENDIF}
end;



function GPUPlanetReady(Planet: Pointer): Boolean;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_planet_ready(Planet) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function GPUAtmosphereCreate(Image: Pointer; Width, Height, Pitch: Integer): Pointer;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_atmosphere_create(Image, Width, Height, Pitch);
{$ELSE}
  Result := nil;
{$ENDIF}
end;

procedure GPUAtmosphereDestroy(var Atmosphere: Pointer);
begin
{$IFDEF ANDROID}
  rangers_gpu_atmosphere_destroy(Atmosphere);
{$ENDIF}
  Atmosphere := nil;
end;

function GPUAtmosphereMask(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer;
    Angle: Integer
): Boolean;
begin
{$IFDEF ANDROID}
  Result :=
      rangers_gpu_atmosphere_mask(Atmosphere, Mask, Width, Height, Pitch, Rotation, Angle) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function GPUAtmosphereSource(
    Atmosphere, Mask: Pointer;
    Width, Height, Pitch: Integer;
    Rotation: Pointer
): Boolean;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_atmosphere_source(Atmosphere, Mask, Width, Height, Pitch, Rotation) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;

procedure GPUAtmosphereAngle(Atmosphere: Pointer; Angle: Integer);
begin
{$IFDEF ANDROID}
  rangers_gpu_atmosphere_angle(Atmosphere, Angle);
{$ENDIF}
end;



function GPUAtmosphereReady(Atmosphere: Pointer): Boolean;
begin
{$IFDEF ANDROID}
  Result := rangers_gpu_atmosphere_ready(Atmosphere) <> 0;
{$ELSE}
  Result := False;
{$ENDIF}
end;
end.
