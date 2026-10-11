#!/bin/bash
# Requires PortMaster's controller mapping and firmware integration.
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
gamedir="$script_dir/spacerangershd"
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
controlfolder=""
for candidate in /opt/system/Tools/PortMaster /opt/tools/PortMaster "$XDG_DATA_HOME/PortMaster" /mnt/mmc/MUOS/PortMaster "$script_dir/PortMaster" /roms/ports/PortMaster /PortMaster; do
    if [ -f "$candidate/control.txt" ]; then
        controlfolder="$candidate"
        break
    fi
done
if [ -z "$controlfolder" ]; then
    echo "Install PortMaster before starting Space Rangers HD."
    exit 1
fi
source "$controlfolder/control.txt"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls
cd "$gamedir" || exit 1
exec > >(tee "$gamedir/log.txt") 2>&1
if [ ! -f "$gamedir/game/INSTALL.TXT" ]; then
    echo "Copy the original game resources into $gamedir/game (see README.txt)."
    exit 1
fi
mkdir -p "$gamedir/profile"
export LD_LIBRARY_PATH="$gamedir/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export SDL_GAMECONTROLLERCONFIG="${sdl_controllerconfig}"
binary="Rangers.@ARCH@"
cleanup() {
    if [ -n "${controls_pid:-}" ]; then
        kill "$controls_pid" 2>/dev/null || true
    fi
    if declare -F pm_finish >/dev/null; then
        pm_finish
    fi
}
trap cleanup EXIT
$GPTOKEYB "$binary" -c "$gamedir/rangers.gptk" &
controls_pid=$!
"./$binary" --game-dir="$gamedir/game" --user-dir="$gamedir/profile" --fullscreen --renderer=sdl --on-screen-keyboard "$@"
exit $?
