#!/bin/sh
# TrimUI Smart Pro, Smart Pro S, Brick and Brick Pro: stock firmware and
# CrossMix-OS, started from Apps/SpaceRangersHD without PortMaster. Most of these
# firmwares run apps with BusyBox sh, so this script is POSIX sh.
script_dir=$(cd "$(dirname "$0")" && pwd) || exit 1
gamedir="$script_dir/spacerangershd"
cd "$gamedir" || exit 1
# MainUI discards app output.
exec >"$gamedir/log.txt" 2>&1

if [ "$(getconf LONG_BIT 2>/dev/null)" != 64 ]; then
    echo "This package requires a 64-bit TrimUI firmware."
    exit 1
fi
binary="Rangers.aarch64"
# Smart Pro, Brick and Brick Pro keep SDL 2.30 in /usr/trimui/lib, the Smart
# Pro S keeps SDL 2.32 in /usr/lib. CrossMix puts its own libraries, among them
# a GLVND libEGL, ahead of them; leave those out so SDL gets the firmware's GPU
# libraries.
system_dir="${TRIMUI_SYSTEM_LIBRARY_DIR:-/usr/lib}"
sdl_dir="${TRIMUI_SDL_LIBRARY_DIR:-/usr/trimui/lib}"
if [ ! -e "$sdl_dir/libSDL2-2.0.so.0" ]; then
    sdl_dir="$system_dir"
fi
export LD_LIBRARY_PATH="$gamedir/lib/aarch64:$sdl_dir:$system_dir:/lib"
if [ -e "$system_dir/libEGL.so.1" ] && [ -e "$system_dir/libGLESv2.so.2" ]; then
    export SDL_VIDEO_EGL_DRIVER="${SDL_VIDEO_EGL_DRIVER:-$system_dir/libEGL.so.1}"
    export SDL_VIDEO_GL_DRIVER="${SDL_VIDEO_GL_DRIVER:-$system_dir/libGLESv2.so.2}"
fi
# trimui_inputd presents the built-in pad as an Xbox 360 controller, which SDL
# maps by itself; a mapping inherited from CrossMix's PortMaster is not needed.
unset SDL_GAMECONTROLLERCONFIG
echo "Firmware: TrimUI; executable: $binary; SDL: $sdl_dir"
echo "EGL: ${SDL_VIDEO_EGL_DRIVER:-default}; GLES: ${SDL_VIDEO_GL_DRIVER:-default}"
./check-platform.aarch64 || exit $?
if [ ! -f "$gamedir/game/INSTALL.TXT" ]; then
    echo "Copy the original game resources into $gamedir/game (see README.txt)."
    exit 1
fi
mkdir -p "$gamedir/profile"

controls_pid=""
cleanup() {
    if [ -n "$controls_pid" ]; then
        kill "$controls_pid" 2>/dev/null || true
        wait "$controls_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT
trap 'exit 143' TERM INT
./gptokeyb.aarch64 -1 "$binary" -c "$gamedir/rangers.gptk" &
controls_pid=$!
# Let udev announce gptokeyb's virtual keyboard and mouse before SDL starts.
sleep "${TRIMUI_CONTROLS_DELAY:-1}"
"./$binary" --game-dir="$gamedir/game" --user-dir="$gamedir/profile" --fullscreen --renderer=sdl --on-screen-keyboard "$@"
exit $?
