/* Resource-backed UI smoke test. Use only in a test process via LD_PRELOAD. */
#include <SDL2/SDL.h>
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct { int kind, x, y; SDL_Keycode key; const char *text; } Action;
static Action actions[160];
static int count, current, state;
static Uint32 next_action;
static const char *pending_capture;
static char logbuf[65536];
static void add_key(SDL_Keycode key) { actions[count++] = (Action){.kind=1,.key=key}; }
static void add_click(int x, int y) { actions[count++] = (Action){.kind=2,.x=x,.y=y}; }
static void add_capture(const char *name) { actions[count++] = (Action){.kind=3,.text=name}; }
static void click_key(int row,int col) { add_click(52+16+col*74+30,388+94+row*44+19); }
static void press(SDL_Keycode key) {
    SDL_Event e; memset(&e,0,sizeof(e)); e.type=SDL_KEYDOWN;
    e.key.keysym.sym=key; e.key.keysym.scancode=SDL_GetScancodeFromKey(key);
    e.key.state=SDL_PRESSED; SDL_PushEvent(&e);
    e.type=SDL_KEYUP; e.key.state=SDL_RELEASED; SDL_PushEvent(&e);
}
static void click(int x,int y) {
    SDL_Event e; memset(&e,0,sizeof(e)); e.type=SDL_MOUSEMOTION;
    e.motion.x=x; e.motion.y=y; SDL_PushEvent(&e);
    memset(&e,0,sizeof(e)); e.type=SDL_MOUSEBUTTONDOWN;
    e.button.button=SDL_BUTTON_LEFT; e.button.state=SDL_PRESSED;
    e.button.x=x; e.button.y=y; SDL_PushEvent(&e);
    e.type=SDL_MOUSEBUTTONUP; e.button.state=SDL_RELEASED; SDL_PushEvent(&e);
}
static void expose(void) {
    SDL_Event e; memset(&e,0,sizeof(e)); e.type=SDL_WINDOWEVENT;
    e.window.event=SDL_WINDOWEVENT_EXPOSED; SDL_PushEvent(&e);
}
static void capture(SDL_Renderer *r,const char *name) {
    int w,h; SDL_GetRendererOutputSize(r,&w,&h);
    SDL_Surface *s=SDL_CreateRGBSurfaceWithFormat(0,w,h,32,SDL_PIXELFORMAT_ARGB8888);
    if(s && SDL_RenderReadPixels(r,NULL,s->format->format,s->pixels,s->pitch)==0) {
        char path[2048]; snprintf(path,sizeof(path),"%s/%s.bmp",getenv("SR_TEST_DIR"),name);
        if(SDL_SaveBMP(s,path)==0) fprintf(stderr,"CAPTURE_OK %s\n",path);
    }
    SDL_FreeSurface(s);
}
static void prepare_script(void) {
    for(int i=0;i<32;i++) add_key(SDLK_BACKSPACE);
    add_key(SDLK_LSHIFT); click_key(2,5); add_key(SDLK_LSHIFT); /* Р */
    click_key(1,4); click_key(1,0); click_key(1,5); click_key(2,8);
    click_key(2,9); click_key(1,4); click_key(2,5); /* ейнджер */
    /* Insert and delete before the final letter, then restore the caret. */
    add_click(52+16+4*111+30,388+94+4*44+19);
    click_key(0,0); add_key(SDLK_BACKSPACE);
    add_click(52+16+5*111+30,388+94+4*44+19);
    /* Exercise insertion at index zero, where the old edit loop read Text[0]. */
    add_key(SDLK_HOME); click_key(0,0); add_key(SDLK_BACKSPACE); add_key(SDLK_END);
    add_capture("keyboard-ru");
    add_click(52+16+2*111+30,388+94+4*44+19); /* Space */
    add_key(SDLK_TAB); add_key(SDLK_LSHIFT); click_key(3,6);
    add_key(SDLK_LSHIFT); click_key(2,0); click_key(3,1); /* Max */
    add_capture("keyboard-en");
    /* Name has 12 characters; the licensed field permits 13. Only '1' fits. */
    click_key(0,0); click_key(0,1); add_capture("keyboard-limit");
    add_key(SDLK_BACKSPACE);
    add_key(SDLK_RETURN); add_capture("committed");
    add_click(250,570);
    for(int i=0;i<32;i++) add_key(SDLK_BACKSPACE);
    actions[count++] = (Action){.kind=4,.text="Wrong"};
    add_capture("cancel-pending"); add_key(SDLK_ESCAPE); add_capture("cancelled");
    add_key(SDLK_RETURN);
}
void SDL_RenderPresent(SDL_Renderer *r) {
    static void (*real_present)(SDL_Renderer *);
    if(!real_present) real_present=dlsym(RTLD_NEXT,"SDL_RenderPresent");
    FILE *f=fopen(getenv("SR_TEST_LOG"),"r");
    if(f) { size_t n=fread(logbuf,1,sizeof(logbuf)-1,f); logbuf[n]=0; fclose(f); }
    if(state==0 && strstr(logbuf,"Rangers: run MainForm")) {
        capture(r,"menu"); press(SDLK_RETURN); state=1;
    } else if(state==1 && strstr(logbuf,"Rangers: run GameSettings")) {
        capture(r,"before"); click(250,570); state=2;
    } else if(state==2) {
        capture(r,"keyboard-open"); prepare_script(); state=3; next_action=SDL_GetTicks()+100;
    }
    if(pending_capture) { capture(r,pending_capture); pending_capture=NULL; }
    if(state==4 && strstr(logbuf,"Rangers: run Introduction")) {
        capture(r,"campaign"); SDL_Event e; memset(&e,0,sizeof(e)); e.type=SDL_QUIT;
        SDL_PushEvent(&e); state=5;
    }
    real_present(r);
}
Uint32 SDL_GetWindowFlags(SDL_Window *w) {
    static Uint32 (*real_flags)(SDL_Window *);
    if(!real_flags)real_flags=dlsym(RTLD_NEXT,"SDL_GetWindowFlags");
    return real_flags(w)|SDL_WINDOW_INPUT_FOCUS;
}
int SDL_PollEvent(SDL_Event *e) {
    static int (*real_poll)(SDL_Event *);
    if(!real_poll)real_poll=dlsym(RTLD_NEXT,"SDL_PollEvent");
    if(state==3 && !pending_capture && SDL_GetTicks()>=next_action) {
        next_action=SDL_GetTicks()+80;
        if(current==count) { state=4; }
        else {
            Action a=actions[current++];
            if(a.kind==1)press(a.key);
            if(a.kind==2)click(a.x,a.y);
            if(a.kind==3) { pending_capture=a.text; expose(); }
            if(a.kind==4) {
                SDL_Event event;memset(&event,0,sizeof(event));event.type=SDL_TEXTINPUT;
                snprintf(event.text.text,sizeof(event.text.text),"%s",a.text);SDL_PushEvent(&event);
            }
        }
    }
    return real_poll(e);
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
