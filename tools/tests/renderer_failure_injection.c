/* Test-only startup failures. Dummy video stands in for a renderer handle;
   this tests recovery paths, not hardware graphics or driver performance. */
#define _GNU_SOURCE
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>
static int probe_renderer;
SDL_Renderer *SDL_CreateRenderer(SDL_Window *window, int index, Uint32 flags) {
    static SDL_Renderer *(*create)(SDL_Window *, int, Uint32);
    if (!create) create = dlsym(RTLD_NEXT, "SDL_CreateRenderer");
    probe_renderer = (flags & SDL_RENDERER_ACCELERATED) != 0;
    if (probe_renderer)
        flags = SDL_RENDERER_SOFTWARE | SDL_RENDERER_TARGETTEXTURE;
    return create(window, index, flags);
}
SDL_Texture *SDL_CreateTexture(SDL_Renderer *renderer, Uint32 format, int access, int w, int h) {
    static SDL_Texture *(*create)(SDL_Renderer *, Uint32, int, int, int);
    if (!create) create = dlsym(RTLD_NEXT, "SDL_CreateTexture");
    if (probe_renderer && access == SDL_TEXTUREACCESS_TARGET &&
        strcmp(getenv("SR_RENDERER_TEST_FAIL"), "target") == 0) {
        SDL_SetError("Injected render-target failure");
        return NULL;
    }
    return create(renderer, format, access, w, h);
}
int SDL_RenderGeometry(SDL_Renderer *renderer, SDL_Texture *texture,
    const SDL_Vertex *vertices, int vertex_count, const int *indices, int index_count) {
    static int (*draw)(SDL_Renderer *, SDL_Texture *, const SDL_Vertex *, int, const int *, int);
    if (!draw) draw = dlsym(RTLD_NEXT, "SDL_RenderGeometry");
    if (probe_renderer && strcmp(getenv("SR_RENDERER_TEST_FAIL"), "geometry") == 0)
        return SDL_SetError("Injected geometry failure");
    return draw(renderer, texture, vertices, vertex_count, indices, index_count);
}
