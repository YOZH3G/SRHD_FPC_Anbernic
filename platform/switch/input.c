#include <switch.h>
#include <SDL.h>
#include <math.h>

static PadState pad;
static bool initialized, quitting;
static uint32_t previous_tick;
static uint64_t held;
static uint64_t blocked_buttons;
static bool keyboard_owned_input;
static uint8_t keyboard[SDL_NUM_SCANCODES];
static double cursor_x, cursor_y, scroll;
static bool touch_position;
void sr_switch_touch_position(int x, int y) {
    cursor_x = x;
    cursor_y = y;
    touch_position = true;
}
int sr_switch_handheld(void) { return appletGetOperationMode() == AppletOperationMode_Handheld; }
static const struct {
    uint64_t button;
    SDL_Scancode scan;
} keys[] = {
    {HidNpadButton_Plus, SDL_SCANCODE_ESCAPE},  {HidNpadButton_Minus, SDL_SCANCODE_TAB},
    {HidNpadButton_X, SDL_SCANCODE_RETURN},     {HidNpadButton_Y, SDL_SCANCODE_SPACE},
    {HidNpadButton_L, SDL_SCANCODE_LCTRL},      {HidNpadButton_R, SDL_SCANCODE_LSHIFT},
    {HidNpadButton_Left, SDL_SCANCODE_LEFT},    {HidNpadButton_Up, SDL_SCANCODE_UP},
    {HidNpadButton_Right, SDL_SCANCODE_RIGHT},  {HidNpadButton_Down, SDL_SCANCODE_DOWN},
    {HidNpadButton_ZR, SDL_SCANCODE_BACKSPACE},
};
static const uint64_t mouse_buttons[] = {HidNpadButton_A, HidNpadButton_B};
static struct {
    uint32_t tick;
    int x, y;
    uint8_t count;
} clicks[2];

uint32_t sr_switch_mouse_buttons(void) {
    return ((held & HidNpadButton_A) ? SDL_BUTTON_LMASK : 0) |
           ((held & HidNpadButton_B) ? SDL_BUTTON_RMASK : 0);
}
const uint8_t *sr_switch_keyboard_state(void) { return keyboard; }

static uint32_t click_hint(const char *name, uint32_t fallback) {
    const char *value = SDL_GetHint(name);
    return value ? (uint32_t)SDL_atoi(value) : fallback;
}

/* Keep event transitions and polled state together: SDL_PushEvent does not
 * update SDL's own keyboard or mouse state. */
static void update_buttons(SDL_Window *window, uint64_t next, uint32_t now, int x, int y) {
    uint64_t changed = held ^ next;
    held = next;
    for (unsigned i = 0; i < SDL_arraysize(keys); ++i)
        keyboard[keys[i].scan] = (held & keys[i].button) != 0;
    for (unsigned i = 0; i < SDL_arraysize(mouse_buttons); ++i) {
        if (!(changed & mouse_buttons[i]))
            continue;
        bool pressed = (held & mouse_buttons[i]) != 0;
        if (pressed) {
            uint32_t time = click_hint(SDL_HINT_MOUSE_DOUBLE_CLICK_TIME, 500);
            uint32_t radius = click_hint(SDL_HINT_MOUSE_DOUBLE_CLICK_RADIUS, 32);
            if (clicks[i].count && now - clicks[i].tick <= time &&
                (uint32_t)abs(x - clicks[i].x) <= radius &&
                (uint32_t)abs(y - clicks[i].y) <= radius) {
                if (clicks[i].count < UINT8_MAX)
                    ++clicks[i].count;
            } else {
                clicks[i].count = 1;
            }
            clicks[i].tick = now;
            clicks[i].x = x;
            clicks[i].y = y;
        }
        SDL_Event event = {0};
        event.type = pressed ? SDL_MOUSEBUTTONDOWN : SDL_MOUSEBUTTONUP;
        event.button.windowID = SDL_GetWindowID(window);
        event.button.button = i ? SDL_BUTTON_RIGHT : SDL_BUTTON_LEFT;
        event.button.state = pressed ? SDL_PRESSED : SDL_RELEASED;
        event.button.clicks = clicks[i].count;
        event.button.x = x;
        event.button.y = y;
        SDL_PushEvent(&event);
    }
    for (unsigned i = 0; i < SDL_arraysize(keys); ++i) {
        if (!(changed & keys[i].button))
            continue;
        SDL_Event event = {0};
        bool pressed = keyboard[keys[i].scan] != 0;
        event.type = pressed ? SDL_KEYDOWN : SDL_KEYUP;
        event.key.windowID = SDL_GetWindowID(window);
        event.key.state = pressed ? SDL_PRESSED : SDL_RELEASED;
        event.key.keysym.scancode = keys[i].scan;
        event.key.keysym.sym = SDL_GetKeyFromScancode(keys[i].scan);
        event.key.keysym.mod = (keyboard[SDL_SCANCODE_LCTRL] ? KMOD_LCTRL : 0) |
                               (keyboard[SDL_SCANCODE_LSHIFT] ? KMOD_LSHIFT : 0);
        SDL_PushEvent(&event);
    }
}

static void release_buttons(SDL_Window *window, uint32_t now) {
    update_buttons(window, 0, now, lround(cursor_x), lround(cursor_y));
    SDL_zero(clicks);
    scroll = 0;
}

static double axis(int value) {
    double scaled = value / 32767.0;
    if (fabs(scaled) < 0.18)
        return 0;
    return copysign((fabs(scaled) - 0.18) / 0.82, scaled);
}
void sr_switch_poll_input(SDL_Window *window) {
    if (!window)
        return;
    uint32_t now = SDL_GetTicks();
    if (initialized && now - previous_tick < 8)
        return;
    if (!initialized) {
        padConfigureInput(1, HidNpadStyleSet_NpadStandard);
        padInitializeDefault(&pad);
        int x, y;
        SDL_GetMouseState(&x, &y);
        cursor_x = x;
        cursor_y = y;
        initialized = true;
        previous_tick = now;
    }
    double elapsed = (now - previous_tick) / 1000.0;
    if (elapsed > 0.05)
        elapsed = 0.05;
    previous_tick = now;
    if (!appletMainLoop() && !quitting) {
        SDL_Event event = {.type = SDL_QUIT};
        SDL_PushEvent(&event);
        quitting = true;
    }
    padUpdate(&pad);
    uint64_t buttons = padGetButtons(&pad);
    uint64_t down = padGetButtonsDown(&pad);
    if (down & HidNpadButton_StickR) {
        SDL_Event cancel = {.type = SDL_USEREVENT};
        cancel.user.code = 0x53524354; /* Cancel the game's pending pointer gesture. */
        SDL_PushEvent(&cancel);
        if (SDL_IsTextInputActive())
            SDL_StopTextInput();
        else {
            // The applet may block or consume all subsequent releases. Clear
            // every game-owned key/button before handing it control.
            release_buttons(window, now);
            keyboard_owned_input = true;
            SDL_StartTextInput();
            return;
        }
    }
    if (SDL_IsTextInputActive()) {
        release_buttons(window, now);
        keyboard_owned_input = true;
        return;
    }
    if (keyboard_owned_input) {
        // A/B can still be held after accepting/dismissing the applet. None of
        // its buttons belong to the game until released and pressed again.
        blocked_buttons |= buttons;
        keyboard_owned_input = false;
    }
    blocked_buttons &= buttons;
    buttons &= ~blocked_buttons;
    down &= ~blocked_buttons;
    HidAnalogStickState left = padGetStickPos(&pad, 0);
    double dx = axis(left.x), dy = -axis(left.y);
    int width, height, x, y;
    SDL_GetWindowSize(window, &width, &height);
    SDL_GetMouseState(&x, &y);
    if (dx || dy) {
        double speed = (buttons & HidNpadButton_ZL) ? 180 : 850;
        cursor_x = fmin(fmax(cursor_x + dx * speed * elapsed, 0), width - 1);
        cursor_y = fmin(fmax(cursor_y + dy * speed * elapsed, 0), height - 1);
        x = lround(cursor_x);
        y = lround(cursor_y);
        SDL_WarpMouseInWindow(window, x, y);
        touch_position = false;
    } else if (!touch_position) {
        cursor_x = x;
        cursor_y = y;
    }
    if (touch_position) {
        x = lround(cursor_x);
        y = lround(cursor_y);
        if (down & (HidNpadButton_A | HidNpadButton_B)) {
            SDL_WarpMouseInWindow(window, x, y);
            touch_position = false;
        }
    }
    update_buttons(window, buttons, now, x, y);
    scroll += axis(padGetStickPos(&pad, 1).y) * elapsed * 8;
    if (fabs(scroll) >= 1) {
        int amount = (int)scroll;
        scroll -= amount;
        SDL_Event event = {0};
        event.type = SDL_MOUSEWHEEL;
        event.wheel.windowID = SDL_GetWindowID(window);
        event.wheel.y = amount;
        event.wheel.preciseY = amount;
        event.wheel.mouseX = x;
        event.wheel.mouseY = y;
        SDL_PushEvent(&event);
    }
}
