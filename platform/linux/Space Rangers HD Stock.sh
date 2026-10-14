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
echo "Firmware: Anbernic stock; executable: $binary; SDL: firmware"
./check-platform.aarch64 || exit $?
if [ ! -f "$gamedir/game/INSTALL.TXT" ]; then
    echo "Copy the original game resources into $gamedir/game (see README.txt)."
    exit 1
fi
mkdir -p "$gamedir/profile"

# Built-in pad "ANBERNIC-keys"; indices match the firmware's RetroArch autoconfig.
# Select is Back, so Select+Start closes the game through gptokeyb.
export SDL_GAMECONTROLLERCONFIG="19000000010000000100000000010000,ANBERNIC-keys,a:b0,b:b1,x:b3,y:b2,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b12,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpleft:h0.8,dpdown:h0.4,dpright:h0.2,leftx:a0,lefty:a1,rightx:a2,righty:a3,lefttrigger:b10,righttrigger:b11,platform:Linux,"
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
