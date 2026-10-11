#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>
#include "okgf.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

extern int sr_window_open(int w, int h);
extern void sr_window_close(void);
extern int sr_present(const void *pixels, int pitch);
extern uint64_t sr_present_count(void);
extern int sr_audio_open(void);
extern void sr_audio_close(void);

#define CHECK(condition)                                                                           \
    do {                                                                                           \
        if (!(condition)) {                                                                        \
            fprintf(stderr, "Failed: %s (%s)\n", #condition, SDL_GetError());                      \
            return 1;                                                                              \
        }                                                                                          \
    } while (0)

int main(void) {
    uint8_t rgb[] = {255, 0, 0, 0, 255, 0, 0, 0, 255};
    uint16_t packed[3] = {0};
    OKGF_ConvertRGBto565(rgb, packed, 6, 3, 1);
    CHECK(packed[0] == 0xf800 && packed[1] == 0x07e0 && packed[2] == 0x001f);
    okgf_set_math_precision(OKGF_MATH_GAME);
    CHECK(okgf_get_math_precision() == OKGF_MATH_GAME);
    SDL_version version;
    SDL_GetVersion(&version);
    CHECK(version.major == 2 && version.minor == 26 && version.patch == 2);
    CHECK(Mix_Linked_Version()->major == 2 && Mix_Linked_Version()->minor == 8);
    CHECK(sr_window_open(1024, 768));
    uint16_t *pixels = calloc(1024 * 768, sizeof(*pixels));
    CHECK(pixels != NULL);
    OKGR_Fill_WORD(pixels, 2048, 1024, 768, 0x07e0);
    CHECK(pixels[0] == 0x07e0 && pixels[1024 * 768 - 1] == 0x07e0);
    CHECK(sr_present(pixels, 2048));
    CHECK(sr_present_count() == 1);
    CHECK(sr_audio_open());
    int codecs = MIX_INIT_MP3 | MIX_INIT_OGG;
    CHECK((Mix_Init(codecs) & codecs) == codecs);
    sr_audio_close();
    sr_window_close();
    free(pixels);
    SDL_Quit();
    puts("PASS: RGB565, precision, SDL software frame, dummy audio, MP3 and OGG");
    return 0;
}
