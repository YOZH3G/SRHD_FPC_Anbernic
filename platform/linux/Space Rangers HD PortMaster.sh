#!/bin/bash
# Use firmware SDL to preserve display, rotation, Wayland and audio support.
script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
# Log from the first line: until the game directory is found, write next to
# this script, since the menu discards the output.
start_log="$script_dir/spacerangershd-start.log"
: 2>/dev/null >"$start_log" || start_log="${TMPDIR:-/tmp}/spacerangershd-start.log"
exec 3>&1 4>&2 >"$start_log" 2>&1
XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
controlfolder=""
for candidate in "${PORTMASTER_DIR:-}" /mnt/mmc/MUOS/PortMaster /opt/muos/PortMaster "$XDG_DATA_HOME/PortMaster" /userdata/system/.local/share/PortMaster /opt/system/Tools/PortMaster /opt/tools/PortMaster /roms/tools/PortMaster /roms2/tools/PortMaster /roms/ports/PortMaster /roms2/ports/PortMaster /storage/roms/ports/PortMaster /PortMaster "$script_dir/PortMaster"; do
    if [ -n "$candidate" ] && [ -f "$candidate/control.txt" ]; then
        controlfolder="$candidate"
        break
    fi
done
if [ -z "$controlfolder" ]; then
    echo "Install or update PortMaster before starting Space Rangers HD."
    exit 1
fi
source "$controlfolder/control.txt"
[ -f "$controlfolder/mod_${CFW_NAME}.txt" ] && source "$controlfolder/mod_${CFW_NAME}.txt"
get_controls
# The port folder sits next to this script, or where PortMaster's installer
# puts it: ports/ under the firmware's directory (/mnt/mmc/ports on muOS).
gamedir=""
for candidate in "$script_dir/spacerangershd" ${directory:+"/$directory/ports/spacerangershd"}; do
    if [ -f "$candidate/rangers.gptk" ]; then
        gamedir="$candidate"
        break
    fi
done
if [ -z "$gamedir" ]; then
    echo "Folder spacerangershd not found next to $script_dir/${BASH_SOURCE[0]##*/}${directory:+ or in /$directory/ports}. Copy the whole archive (see README.txt)."
    exit 1
fi
cd "$gamedir" || exit 1
exec 1>&3 2>&4 3>&- 4>&-
exec > >(tee "$gamedir/log.txt") 2>&1
cat "$start_log"
rm -f "$start_log"
echo "Port folder: $gamedir"

# A 64-bit kernel can host a 32-bit userland; prefer the userland word size.
case "$(getconf LONG_BIT 2>/dev/null)" in
    32) arch=armhf ;;
    64) arch=aarch64 ;;
    *)
        case "${DEVICE_ARCH:-$(uname -m)}" in
            armhf|armv7*|armv8l) arch=armhf ;;
            aarch64|arm64) arch=aarch64 ;;
            *) echo "Unsupported architecture."; exit 1 ;;
        esac
        ;;
esac
binary="Rangers.$arch"
if [ ! -x "$binary" ]; then
    echo "This package does not contain an executable for $arch. See README.txt."
    exit 1
fi
export LD_LIBRARY_PATH="$gamedir/lib/$arch${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
if [ "$arch" = armhf ]; then
    export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib32:/lib32"
fi
if [ -n "${sdl_controllerconfig:-}" ]; then
    export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
fi
echo "Firmware: ${CFW_NAME:-unknown}; executable: $binary; SDL: firmware"
"./check-platform.$arch" || exit $?
if [ ! -f "$gamedir/game/INSTALL.TXT" ]; then
    echo "Copy the original game resources into $gamedir/game (see README.txt)."
    exit 1
fi
if [ -z "${GPTOKEYB:-}" ]; then
    echo "PortMaster's gptokeyb is missing. Update PortMaster."
    exit 1
fi
mkdir -p "$gamedir/profile"
cleanup() {
    if [ -n "${controls_pid:-}" ]; then
        kill "$controls_pid" 2>/dev/null || true
        wait "$controls_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT
[ "${CFW_NAME:-}" = muOS ] && export SDL_AUDIODRIVER="${SDL_AUDIODRIVER:-alsa}"
if declare -F pm_platform_helper >/dev/null; then
    pm_platform_helper "$binary"
fi
$GPTOKEYB "$binary" -c "$gamedir/rangers.gptk" &
controls_pid=$!
"./$binary" --game-dir="$gamedir/game" --user-dir="$gamedir/profile" --fullscreen --renderer=sdl --on-screen-keyboard "$@"
exit $?
