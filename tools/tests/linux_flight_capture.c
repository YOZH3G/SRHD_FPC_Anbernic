#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static int state, frames;
static char logbuf[65536];
static Uint32 last_key, space_start;
static void press(SDL_Keycode key) {
 SDL_Event e; memset(&e,0,sizeof(e)); e.type=SDL_KEYDOWN;
 e.key.keysym.sym=key; e.key.keysym.scancode=SDL_GetScancodeFromKey(key); e.key.state=SDL_PRESSED; SDL_PushEvent(&e);
 e.type=SDL_KEYUP; e.key.state=SDL_RELEASED; SDL_PushEvent(&e);
}
static void capture(SDL_Renderer *r,const char *name) {
 int w,h; SDL_GetRendererOutputSize(r,&w,&h);
 SDL_Surface *s=SDL_CreateRGBSurfaceWithFormat(0,w,h,32,SDL_PIXELFORMAT_ARGB8888);
 if(s && SDL_RenderReadPixels(r,NULL,s->format->format,s->pixels,s->pitch)==0) {
  char path[2048]; snprintf(path,sizeof(path),"%s/%s.bmp",getenv("SR_TEST_DIR"),name);
  if(SDL_SaveBMP(s,path)==0) fprintf(stderr,"CAPTURE_OK %s %dx%d\n",path,w,h);
 }
 SDL_FreeSurface(s);
}
void SDL_RenderPresent(SDL_Renderer *r) {
 static void (*real_present)(SDL_Renderer *); if(!real_present)real_present=dlsym(RTLD_NEXT,"SDL_RenderPresent");
 FILE *f=fopen(getenv("SR_TEST_LOG"),"r");
 if(f){size_t n=fread(logbuf,1,sizeof(logbuf)-1,f);logbuf[n]=0;fclose(f);}
 if(state==0 && strstr(logbuf,"Rangers: run MainForm") && ++frames>10){capture(r,"menu");press(getenv("SR_TEST_LOAD")?SDLK_l:SDLK_RETURN);state=1;frames=0;}
 else if(state==1 && getenv("SR_TEST_LOAD") && strstr(logbuf,"Rangers: run SaveManager") && ++frames>30){capture(r,"load");press(SDLK_RETURN);state=3;frames=0;}
 else if(state==1 && strstr(logbuf,"Rangers: run GameSettings") && ++frames>10){
  capture(r,"character");
  if(getenv("SR_TEST_PREVIEW_ONLY")) {
   SDL_Event e;memset(&e,0,sizeof(e));e.type=SDL_QUIT;SDL_PushEvent(&e);state=7;
  } else {press(SDLK_RETURN);state=2;}
  frames=0;
 }
 else if(state==2 && strstr(logbuf,"Rangers: run Introduction") && ++frames>10){capture(r,"generation");state=3;frames=0;}
 else if(state==3 && strstr(logbuf,"Rangers: run Hangar") && ++frames>30){capture(r,"hangar");state=5;frames=0;}
 else if(state==3 && (strstr(logbuf,"Rangers: run RuinsTalk") || strstr(logbuf,"Rangers: run Planet")) && ++frames>30){capture(r,"station");state=4;frames=0;}
 else if(state==4 && strstr(logbuf,"Rangers: run Hangar") && ++frames>30){capture(r,"hangar");state=5;frames=0;}
 else if(state==5 && strstr(logbuf,"Rangers: run StarMap") && (space_start || (space_start=SDL_GetTicks())) && SDL_GetTicks()-space_start>20000){capture(r,"space");state=6; SDL_Event e;memset(&e,0,sizeof(e));e.type=SDL_QUIT;SDL_PushEvent(&e);}
 real_present(r);
}
Uint32 SDL_GetWindowFlags(SDL_Window *w) {
 static Uint32 (*real_flags)(SDL_Window *);if(!real_flags)real_flags=dlsym(RTLD_NEXT,"SDL_GetWindowFlags");
 return real_flags(w)|SDL_WINDOW_INPUT_FOCUS;
}
int SDL_PollEvent(SDL_Event *e) {
 static int (*real_poll)(SDL_Event *);if(!real_poll)real_poll=dlsym(RTLD_NEXT,"SDL_PollEvent");
 if(state>=3 && state<=5 && SDL_GetTicks()-last_key>1000){last_key=SDL_GetTicks();press(state==3?SDLK_RETURN:state==4?SDLK_h:strstr(logbuf,"Rangers: run StarMap")?SDLK_c:SDLK_f);}
 return real_poll(e);
}

Uint32 SDL_GetMouseState(int *x, int *y) {
    // Dummy video has no physical mouse. Keep the simulated pointer away from
    // the window edges so the map's normal edge-scroll does not move the camera.
    if(x) *x=512;
    if(y) *y=384;
    return 0;
}

/* Dummy video does not generate activation events. Match a focused real window. */
SDL_Window *SDL_CreateWindow(const char *title, int x, int y, int w, int h, Uint32 flags) {
    static SDL_Window *(*create_window)(const char *, int, int, int, int, Uint32);
    if (!create_window) create_window = dlsym(RTLD_NEXT, "SDL_CreateWindow");
    SDL_Window *window = create_window(title, x, y, w, h, flags);
    if (window) {
        SDL_Event event = {0};
        event.type = SDL_WINDOWEVENT;
        event.window.windowID = SDL_GetWindowID(window);
        event.window.event = SDL_WINDOWEVENT_FOCUS_GAINED;
        SDL_PushEvent(&event);
    }
    return window;
}
