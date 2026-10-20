#ifndef RANGERS_GPU_PLANET_H
#define RANGERS_GPU_PLANET_H
#include "backend.h"
#ifdef __cplusplus
extern "C" {
#endif
/* Imports immutable legacy assets. No OKGF object remains borrowed after return.
 * The retained recipes also recreate generation-scoped images after device loss. */
void *rangers_gpu_planet_create(const void *projection, int width, int height);
void rangers_gpu_planet_destroy(void *planet);
int rangers_gpu_planet_layer(void *planet, int layer, const void *pixels, int width, int height,
                             int pitch, int bytes_per_pixel, const void *palette, int palette_count,
                             int variant);
int rangers_gpu_planet_light(void *planet, const void *light);
/* Import the unrotated light and all scanline recipes once. Changing the angle
 * then changes uniforms only: no CPU pixel rotation or texture upload. */
int rangers_gpu_planet_light_source(void *planet, const void *light, const void *rotation);
void rangers_gpu_planet_light_angle(void *planet, int angle);
int rangers_gpu_planet_ready(void *planet);
int rangers_gpu_planet_draw(void *planet, int layer, int map_offset, int linear,
                            const rangers_gpu_vertex *vertices, int count);
/* Original grayscale pixels and scanline recipes are retained independently
 * from the selected angle; shader addressing preserves legacy edge rounding. */
void *rangers_gpu_atmosphere_create(const void *image, int width, int height, int pitch);
void rangers_gpu_atmosphere_destroy(void *atmosphere);
int rangers_gpu_atmosphere_mask(void *atmosphere, const void *mask, int width, int height,
                                int pitch, const void *rotation, int angle);
int rangers_gpu_atmosphere_source(void *atmosphere, const void *mask, int width, int height,
                                  int pitch, const void *rotation);
void rangers_gpu_atmosphere_angle(void *atmosphere, int angle);
int rangers_gpu_atmosphere_ready(void *atmosphere);
int rangers_gpu_atmosphere_draw(void *atmosphere, uint32_t color, int linear,
                                const rangers_gpu_vertex *vertices, int count);
#ifdef __cplusplus
}
#endif
#endif
