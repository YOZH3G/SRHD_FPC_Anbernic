/* Test-only: exercise the accelerated point-batch branch under ARM/QEMU SDL
 * software. This changes only the public info copy, not the SDL backend.
 * It verifies CPU geometry generation; it does not test a physical GPU. */
#define _GNU_SOURCE 1
#include <SDL2/SDL.h>
#include <dlfcn.h>

int SDL_GetRendererInfo(SDL_Renderer *renderer, SDL_RendererInfo *info)
{
    static int (*real_info)(SDL_Renderer *, SDL_RendererInfo *);
    if (!real_info) real_info = dlsym(RTLD_NEXT, "SDL_GetRendererInfo");
    int result = real_info(renderer, info);
    if (result == 0) info->flags |= SDL_RENDERER_ACCELERATED;
    return result;
}
