/* Resource-backed 800x600 navigation check. Test process only, via LD_PRELOAD. */
#define _GNU_SOURCE
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { const char *screen, *capture; SDL_Keycode next; } Step;
static const Step steps[] = {
    {"MainForm", "menu", SDLK_c},
    {"CfgSettings", "settings", SDLK_ESCAPE},
    {"MainForm", NULL, SDLK_l},
    {"SaveManager", "load", SDLK_RETURN},
    {"Hangar", "hangar", SDLK_s},
    {"Ship", "ship-docked", SDLK_ESCAPE},
    {"Hangar", NULL, SDLK_g},
    {"RuinsTalk", "station", SDLK_e},
    {"EquipmentShop", "equipment", SDLK_t},
    {"GoodsShop", "goods", SDLK_i},
    {"Info", "station-info", SDLK_h},
    {"Hangar", NULL, SDLK_f},
    {"StarMap", "space", SDLK_s},
    {"Ship", "ship", SDLK_ESCAPE},
    {"StarMap", NULL, SDLK_m},
    {"Galaxy", "galaxy", SDLK_ESCAPE},
    {"StarMap", NULL, SDLK_F1},
    {"Journal", "journal", SDLK_ESCAPE},
    {"StarMap", NULL, SDLK_ESCAPE},
    {"GameMenu", "pause", SDLK_F2},
    {"SaveManager", "save", SDLK_ESCAPE},
    {"StarMap", "space-return", SDLK_s},
    {"Ship", "ship-reopened", SDLK_ESCAPE},
    {"StarMap", "space-final", 0},
};
static const size_t settings_step = 1;
static size_t step;
static int frames, finished;
static Uint32 changed_at, last_key, last_expose, matched_at;
static char logbuf[131072];
static int mouse_x = 400, mouse_y = 300, screen_width = 800;

static void press(SDL_Keycode key) {
    SDL_Event e = {0};
    e.type = SDL_KEYDOWN; e.key.state = SDL_PRESSED;
    e.key.keysym.sym = key; e.key.keysym.scancode = SDL_GetScancodeFromKey(key);
    SDL_PushEvent(&e);
    e.type = SDL_KEYUP; e.key.state = SDL_RELEASED; SDL_PushEvent(&e);
    last_key = SDL_GetTicks();
}
static void quit(void) {
    SDL_Event e = {0}; e.type = SDL_QUIT; SDL_PushEvent(&e); finished = 1;
}
static void click_settings_cancel(void) {
    double scale = screen_width < 1024 ? (double)screen_width/1024 : 1;
    mouse_x = screen_width >= 1024 ? 800 : (int)(330*scale);
    mouse_y = screen_width >= 1024 ? 720 : (int)(712*scale);
    SDL_Event e = {0}; e.type = SDL_MOUSEMOTION;
    e.motion.x = mouse_x; e.motion.y = mouse_y; SDL_PushEvent(&e);
    memset(&e, 0, sizeof(e)); e.type = SDL_MOUSEBUTTONDOWN;
    e.button.button = SDL_BUTTON_LEFT; e.button.state = SDL_PRESSED;
    e.button.x = mouse_x; e.button.y = mouse_y; SDL_PushEvent(&e);
    e.type = SDL_MOUSEBUTTONUP; e.button.state = SDL_RELEASED; SDL_PushEvent(&e);
    last_key = SDL_GetTicks();
}
static const char *current_screen(void) {
    const char *last = "", *p = logbuf;
    while ((p = strstr(p, "Rangers: "))) {
        p += 9;
        if (!strncmp(p, "run ", 4)) last = p + 4;
        else if (!strncmp(p, "resume ", 7)) last = p + 7;
    }
    return last;
}
static int is_screen(const char *name) {
    const char *p = current_screen(); size_t n = strlen(name);
    return !strncmp(p, name, n) && (p[n] == '\n' || p[n] == '\r' || !p[n]);
}
static void capture(SDL_Renderer *r, const char *name) {
    int w, h; SDL_GetRendererOutputSize(r, &w, &h);
    SDL_Surface *s = SDL_CreateRGBSurfaceWithFormat(0, w, h, 32, SDL_PIXELFORMAT_ARGB8888);
    if (s && SDL_RenderReadPixels(r, NULL, s->format->format, s->pixels, s->pitch) == 0) {
        char path[2048]; snprintf(path, sizeof(path), "%s/%s.bmp", getenv("SR_TEST_DIR"), name);
        if (SDL_SaveBMP(s, path) == 0) fprintf(stderr, "CAPTURE_OK %s %dx%d\n", path, w, h);
    }
    SDL_FreeSurface(s);
}
void SDL_RenderPresent(SDL_Renderer *r) {
    static void (*real_present)(SDL_Renderer *);
    if (!real_present) real_present = dlsym(RTLD_NEXT, "SDL_RenderPresent");
    FILE *f = fopen(getenv("SR_TEST_LOG"), "r");
    if (f) { size_t n = fread(logbuf, 1, sizeof(logbuf)-1, f); logbuf[n] = 0; fclose(f); }
    if (!finished && is_screen(steps[step].screen) && !matched_at)
        matched_at = SDL_GetTicks();
    /* Opening equipment slides its cargo panel out from behind the ship.
       Capture the settled window, rather than its first animation frames. */
    if (!finished && is_screen(steps[step].screen) && ++frames >= 5
            && SDL_GetTicks()-matched_at >= 1500) {
        if (steps[step].capture) capture(r, steps[step].capture);
        if (step == settings_step) click_settings_cancel();
        else if (steps[step].next) press(steps[step].next);
        else { fprintf(stderr, "NAVIGATION_OK\n"); quit(); }
        if (!finished) { ++step; frames = 0; matched_at = 0; changed_at = SDL_GetTicks(); }
    }
    if (!finished && changed_at && SDL_GetTicks()-changed_at > 120000) {
        fprintf(stderr, "NAVIGATION_TIMEOUT expected=%s current=%.40s\n",
            steps[step].screen, current_screen());
        quit();
    }
    real_present(r);
}
int SDL_PollEvent(SDL_Event *e) {
    static int (*real_poll)(SDL_Event *);
    if (!real_poll) real_poll = dlsym(RTLD_NEXT, "SDL_PollEvent");
    // Static menus draw only dirty regions. Expose them like a real window
    // being uncovered; waiting for animation frames would stall those screens.
    if (!finished && SDL_GetTicks()-last_expose > 200) {
        SDL_Event expose = {0}; expose.type = SDL_WINDOWEVENT;
        expose.window.event = SDL_WINDOWEVENT_EXPOSED; SDL_PushEvent(&expose);
        last_expose = SDL_GetTicks();
    }
    if (!finished && step && !is_screen(steps[step].screen)
        && is_screen(steps[step-1].screen) && SDL_GetTicks()-last_key > 1500)
        { if (step == settings_step + 1) click_settings_cancel(); else press(steps[step-1].next); }
    return real_poll(e);
}
Uint32 SDL_GetWindowFlags(SDL_Window *w) {
    static Uint32 (*real_flags)(SDL_Window *);
    if (!real_flags) real_flags = dlsym(RTLD_NEXT, "SDL_GetWindowFlags");
    return real_flags(w) | SDL_WINDOW_INPUT_FOCUS;
}
SDL_Window *SDL_CreateWindow(const char *title, int x, int y, int w, int h, Uint32 flags) {
    static SDL_Window *(*create)(const char *, int, int, int, int, Uint32);
    if (!create) create = dlsym(RTLD_NEXT, "SDL_CreateWindow");
    screen_width = w; mouse_x = w/2; mouse_y = h/2;
    SDL_Window *window = create(title, x, y, w, h, flags);
    if (window) {
        SDL_Event e = {0}; e.type = SDL_WINDOWEVENT;
        e.window.windowID = SDL_GetWindowID(window); e.window.event = SDL_WINDOWEVENT_FOCUS_GAINED;
        SDL_PushEvent(&e);
    }
    return window;
}
Uint32 SDL_GetMouseState(int *x, int *y) {
    if (x) *x = mouse_x; if (y) *y = mouse_y; return 0;
}
