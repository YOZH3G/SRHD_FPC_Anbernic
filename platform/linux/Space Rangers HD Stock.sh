#!/bin/bash
# Anbernic H700 stock firmware and Stock OS Mod, 64-bit: started from Roms/APPS
# without PortMaster. The menu may run apps through dash; switch to bash first.
if [ -z "${BASH_VERSION:-}" ]; then
    exec /bin/bash "$0" "$@"
fi
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
gamedir="$script_dir/spacerangershd"
cd "$gamedir" || exit 1
# The stock menu discards app output.
exec >"$gamedir/log.txt" 2>&1

if [ "$(getconf LONG_BIT 2>/dev/null)" != 64 ]; then
    echo "This package requires the 64-bit Anbernic stock firmware."
    exit 1
fi
binary="Rangers.aarch64"
# The menu exports /usr/lib first, which holds SDL 2.0.12. The firmware's
# SDL 2.28 with the Mali video driver is in the multiarch directory.
export LD_LIBRARY_PATH="$gamedir/lib/aarch64:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# The multiarch directory also holds Mesa's libEGL and libGLESv2, which cannot
# drive the Mali GPU; SDL would load them and fail to open its window. Point SDL
# at the Mali libraries in /usr/lib, as the firmware's own apps use them.
gpu_dir="${ANBERNIC_GPU_LIBRARY_DIR:-/usr/lib}"
if [ -e "$gpu_dir/libmali.so.0" ]; then
    export SDL_VIDEO_EGL_DRIVER="${SDL_VIDEO_EGL_DRIVER:-$gpu_dir/libEGL.so.1}"
    export SDL_VIDEO_GL_DRIVER="${SDL_VIDEO_GL_DRIVER:-$gpu_dir/libGLESv2.so.2}"
fi
echo "Firmware: Anbernic stock; executable: $binary; SDL: firmware"
echo "EGL: ${SDL_VIDEO_EGL_DRIVER:-default}; GLES: ${SDL_VIDEO_GL_DRIVER:-default}"
./check-platform.aarch64 || exit $?
if [ ! -f "$gamedir/game/INSTALL.TXT" ]; then
    echo "Copy the original game resources into $gamedir/game (see README.txt)."
    exit 1
fi
mkdir -p "$gamedir/profile"

# Built-in pad "ANBERNIC-keys". Button numbers differ between models (L2/R2 are
# 9/10 on the RG28XX and 10/11 on the RG34XX SP), so read the firmware's own
# RetroArch autoconfig. Select is Back, so Select+Start closes the game.
pad_config="${ANBERNIC_PAD_CONFIG:-/mnt/vendor/deep/retro/autoconfig/udev/ANBERNIC-keys.cfg}"
pad_value() {
    local value=""
    [ -f "$pad_config" ] && value=$(sed -n "s/^input_$1 *= *\"\(.*\)\"/\1/p" "$pad_config" | head -n 1)
    echo "${value:-$2}"
}
pad_button() {
    local value
    value=$(pad_value "$2_btn" "$3")
    case "$value" in
        h0up) echo "$1:h0.1," ;;
        h0right) echo "$1:h0.2," ;;
        h0down) echo "$1:h0.4," ;;
        h0left) echo "$1:h0.8," ;;
        ''|*[!0-9]*) ;;
        *) echo "$1:b$value," ;;
    esac
}
pad_axis() {
    local value
    value=$(pad_value "$2_plus_axis" "")
    value=${value#+}
    case "$value" in
        ''|*[!0-9]*) ;;
        *) echo "$1:a$value," ;;
    esac
}
mapping="19000000010000000100000000010000,ANBERNIC-keys,"
mapping+="$(pad_button a a 0)$(pad_button b b 1)$(pad_button x x 3)$(pad_button y y 2)"
mapping+="$(pad_button back select 6)$(pad_button start start 7)"
mapping+="$(pad_button leftshoulder l 4)$(pad_button rightshoulder r 5)"
mapping+="$(pad_button lefttrigger l2 9)$(pad_button righttrigger r2 10)"
mapping+="$(pad_button leftstick l3 '')$(pad_button rightstick r3 '')"
mapping+="$(pad_button dpup up h0up)$(pad_button dpdown down h0down)"
mapping+="$(pad_button dpleft left h0left)$(pad_button dpright right h0right)"
mapping+="$(pad_axis leftx l_x)$(pad_axis lefty l_y)$(pad_axis rightx r_x)$(pad_axis righty r_y)"
export SDL_GAMECONTROLLERCONFIG="${mapping}platform:Linux,"
echo "Controls: $SDL_GAMECONTROLLERCONFIG"
cleanup() {
    if [ -n "${controls_pid:-}" ]; then
        kill "$controls_pid" 2>/dev/null || true
        wait "$controls_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT
# The firmware's PortMaster gptokeyb is too old for D-pad mouse movement.
./gptokeyb.aarch64 -1 "$binary" -c "$gamedir/rangers.gptk" &
controls_pid=$!
"./$binary" --game-dir="$gamedir/game" --user-dir="$gamedir/profile" --fullscreen --renderer=sdl --on-screen-keyboard "$@"
exit $?
