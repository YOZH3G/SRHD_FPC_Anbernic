#ifndef RANGERS_PLANET_BACKEND_H
#define RANGERS_PLANET_BACKEND_H
#include <stdint.h>
typedef uint32_t rangers_gpu_image;
typedef struct rangers_gpu_vertex { float unused; } rangers_gpu_vertex;
enum { RANGERS_GPU_R8, RANGERS_GPU_RG8, RANGERS_GPU_RGBA8, RANGERS_GPU_RGBA32F };
enum { RANGERS_GPU_PLANET = 3 };
uint32_t rangers_gpu_generation(void);
void rangers_gpu_release_outputs(void *object);
void rangers_gpu_destroy_image(rangers_gpu_image image);
rangers_gpu_image rangers_gpu_create_image(int width, int height, int format, int target);
int rangers_gpu_upload(rangers_gpu_image image, int x, int y, int width, int height,
                      const void *pixels, int pitch, int format);
void rangers_gpu_draw_material(int material, const rangers_gpu_image *images, int image_count,
                              const float *uniforms, int uniform_count,
                              const rangers_gpu_vertex *vertices, int count);
#endif
