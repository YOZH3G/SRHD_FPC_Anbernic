#include <SDL2/SDL.h>
#include <stdio.h>

/* Run without initializing video so a handheld log records available drivers
   even when the firmware's display backend cannot start. */
int main(void) {
    SDL_version version;
    SDL_GetVersion(&version);
    printf("System SDL: %u.%u.%u\n", version.major, version.minor, version.patch);
    if (SDL_VERSIONNUM(version.major, version.minor, version.patch) < SDL_VERSIONNUM(2, 0, 18)) {
        fprintf(stderr, "SDL 2.0.18 or newer is required. Update the firmware.\n");
        return 1;
    }
    printf("Video drivers:");
    for (int i = 0; i < SDL_GetNumVideoDrivers(); i++)
        printf(" %s", SDL_GetVideoDriver(i));
    printf("\nAudio drivers:");
    for (int i = 0; i < SDL_GetNumAudioDrivers(); i++)
        printf(" %s", SDL_GetAudioDriver(i));
    printf("\n");
    return 0;
}
