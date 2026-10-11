/* Test-only SDL preload: automate a new game and stream actual rendered frames. */
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int stage;
static Uint32 stage_tick, last_key, last_capture;
static volatile int recording;
static char logbuf[65536];
static void press(SDL_Keycode key) {
    SDL_Event e = {0};
    e.type = SDL_KEYDOWN;
    e.key.keysym.sym = key;
    e.key.keysym.scancode = SDL_GetScancodeFromKey(key);
    e.key.state = SDL_PRESSED;
    SDL_PushEvent(&e);
    e.type = SDL_KEYUP;
    e.key.state = SDL_RELEASED;
    SDL_PushEvent(&e);
}
static int write_all(int fd, const void *buffer, size_t size) {
    const unsigned char *p = buffer;
    while (size) {
        ssize_t n = write(fd, p, size);
        if (n <= 0) return 0;
        p += n;
        size -= (size_t)n;
    }
    return 1;
}
static void next_stage(int value) { stage = value; stage_tick = SDL_GetTicks(); }
void SDL_RenderPresent(SDL_Renderer *renderer) {
    static void (*present)(SDL_Renderer *);
    if (!present) present = dlsym(RTLD_NEXT, "SDL_RenderPresent");
    FILE *log = fopen(getenv("SR_TEST_LOG"), "r");
    if (log) {
        size_t n = fread(logbuf, 1, sizeof(logbuf) - 1, log);
        logbuf[n] = 0;
        fclose(log);
    }
    Uint32 now = SDL_GetTicks();
    if (!stage && strstr(logbuf, "Rangers: run MainForm")) {
        recording = 1;
        next_stage(1);
    } else if (stage == 1 && now - stage_tick >= 4000) {
        press(SDLK_RETURN); next_stage(2);
    } else if (stage == 2 && strstr(logbuf, "Rangers: run GameSettings")) {
        next_stage(3);
    } else if (stage == 3 && now - stage_tick >= 4000) {
        press(SDLK_RETURN); next_stage(4);
    } else if (stage == 4 && strstr(logbuf, "Rangers: run Introduction")) {
        next_stage(5);
    } else if (stage == 5 && (strstr(logbuf, "Rangers: run RuinsTalk") || strstr(logbuf, "Rangers: run Planet"))) {
        next_stage(6);
    } else if (stage == 6 && now - stage_tick >= 4000) {
        press(SDLK_h);
    } else if ((stage == 5 || stage == 6) && strstr(logbuf, "Rangers: run Hangar")) {
        next_stage(7);
    } else if (stage == 7 && now - stage_tick >= 4000) {
        press(SDLK_f);
    }
    /* Check completed navigation before retrying the previous screen's key. */
    if (stage == 6 && strstr(logbuf, "Rangers: run Hangar")) next_stage(7);
    if (stage == 7 && strstr(logbuf, "Rangers: run StarMap")) next_stage(8);
    if (stage == 8 && now - stage_tick >= 20000) {
        SDL_Event e = {0}; e.type = SDL_QUIT; SDL_PushEvent(&e); next_stage(9);
    }
    if (recording && (!last_capture || now - last_capture >= 100)) {
        int width, height;
        SDL_GetRendererOutputSize(renderer, &width, &height);
        SDL_Surface *frame = SDL_CreateRGBSurfaceWithFormat(0, width, height, 24, SDL_PIXELFORMAT_RGB24);
        if (frame && SDL_RenderReadPixels(renderer, NULL, SDL_PIXELFORMAT_RGB24, frame->pixels, frame->pitch) == 0) {
            Uint32 header[] = {(Uint32)width, (Uint32)height, now};
            if (write_all(STDOUT_FILENO, header, sizeof(header)))
                for (int y = 0; y < height; y++)
                    if (!write_all(STDOUT_FILENO, (Uint8 *)frame->pixels + y * frame->pitch, width * 3)) break;
        }
        SDL_FreeSurface(frame);
        last_capture = now;
    }
    present(renderer);
}
Uint32 SDL_GetWindowFlags(SDL_Window *window) {
    static Uint32 (*flags)(SDL_Window *);
    if (!flags) flags = dlsym(RTLD_NEXT, "SDL_GetWindowFlags");
    return flags(window) | SDL_WINDOW_INPUT_FOCUS;
}
Uint32 SDL_GetMouseState(int *x, int *y) { if (x) *x = 512; if (y) *y = 384; return 0; }
int SDL_PollEvent(SDL_Event *event) {
    static int (*poll_event)(SDL_Event *);
    if (!poll_event) poll_event = dlsym(RTLD_NEXT, "SDL_PollEvent");
    Uint32 now = SDL_GetTicks();
    if (now - last_key >= 1000) {
        last_key = now;
        if (stage == 5) press(SDLK_RETURN);
        if (stage == 8) press(SDLK_c);
    }
    return poll_event(event);
}
/* Capture the mixer's actual stereo PCM rather than synthesizing a soundtrack. */
typedef struct { SDL_AudioCallback callback; void *userdata; } AudioBridge;
static void capture_audio(void *userdata, Uint8 *stream, int length) {
    AudioBridge *bridge = userdata;
    bridge->callback(bridge->userdata, stream, length);
    static int fd = -1;
    if (recording) {
        if (fd < 0) fd = open(getenv("SR_VIDEO_AUDIO"), O_WRONLY | O_CREAT | O_TRUNC, 0600);
        if (fd >= 0) write_all(fd, stream, (size_t)length);
    }
}
SDL_AudioDeviceID SDL_OpenAudioDevice(const char *device, int capture,
    const SDL_AudioSpec *desired, SDL_AudioSpec *obtained, int allowed_changes) {
    static SDL_AudioDeviceID (*open_audio)(const char *, int, const SDL_AudioSpec *, SDL_AudioSpec *, int);
    if (!open_audio) open_audio = dlsym(RTLD_NEXT, "SDL_OpenAudioDevice");
    if (capture || !desired || !desired->callback || desired->format != AUDIO_S16SYS ||
        desired->channels != 2 || desired->freq != 44100)
        return open_audio(device, capture, desired, obtained, allowed_changes);
    AudioBridge *bridge = malloc(sizeof(*bridge));
    if (!bridge) return open_audio(device, capture, desired, obtained, allowed_changes);
    *bridge = (AudioBridge){desired->callback, desired->userdata};
    SDL_AudioSpec spec = *desired;
    spec.callback = capture_audio;
    spec.userdata = bridge;
    return open_audio(device, capture, &spec, obtained, 0);
}
