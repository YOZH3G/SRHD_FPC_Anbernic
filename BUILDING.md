# Building

The port is built for Linux handhelds: Anbernic and TrimUI, ARMHF and AArch64.
A Linux desktop build of the same game serves development and UI checks.

## Anbernic and TrimUI packages

On Ubuntu 24.04 x86_64, `tools/anbernic_sdk.sh` creates everything the cross
build needs: Ubuntu 20.04 ARMHF/AArch64 sysroots, Clang 19 and binutils wrappers,
SDL 2.32.4 for linking, `libevdev` for gptokeyb, and FPC cross compilers bootstrapped
from the pinned `vendor/fpc`. Its header lists the host packages; debootstrap
needs root or sudo. `sysroot` and `fpc` build the two halves separately; rebuild
`fpc` whenever the `vendor/fpc` pin changes. The AArch64 game is linked with LLVM
link-time optimization against a second RTL in `fpc/arm64/lto`; ARMHF uses FPC's
native ARM backend, which has no LTO.

```sh
git submodule update --init --recursive
tools/anbernic_sdk.sh ~/anbernic-sdk
python tools/build_linux.py --arch aarch64 --sysroot ~/anbernic-sdk/arm64/root \
  --toolchain ~/anbernic-sdk/arm64/bin --fpc-source ~/anbernic-sdk/fpc/arm64 --rebuild
python tools/build_linux.py --arch armhf --sysroot ~/anbernic-sdk/armhf/root \
  --toolchain ~/anbernic-sdk/armhf/bin --fpc-source ~/anbernic-sdk/fpc/armhf --rebuild
python tools/package_anbernic.py --sdk-root ~/anbernic-sdk --output .local/dist
PATH=~/anbernic-sdk/arm64/bin:~/anbernic-sdk/armhf/bin:$PATH \
  python tools/tests/check_packages.py .local/dist --commit "$(git rev-parse HEAD)"
```

Keep the output under `.local/`: packages record whether the tree was clean.
`check_packages.py` requires identical game binaries in every ZIP, one clean
commit, glibc imports no newer than 2.29, and no SDL2 or game files.

The [Anbernic and TrimUI packages](.github/workflows/anbernic.yml) workflow runs
these steps on every push and pull request, caching the SDK by the script's hash
and the FPC pin, and uploads the ZIPs as an artifact. Run it manually from the
Actions tab with `release` set to `draft` or `publish` to release exactly those
ZIPs from `main`. It cannot run the scenarios below, which need licensed game
data; run them locally before publishing.

Outputs are `.local/anbernic/arm64/Rangers` and `armhf/Rangers`. SDL2 ≥ 2.26 is
provided by firmware; OKGF, Ogg/Vorbis and codecs are bundled. The port uses
upstream's direct Pascal SDL adapters, without the old gamenative/SDL_mixer
bridge. Launchers select SDL acceleration with automatic software fallback.
See [Anbernic installation](platform/linux/ANBERNIC.md).

Release packages use an Ubuntu 20.04 (glibc 2.31) sysroot, and every packaged
ELF must import glibc symbols no newer than 2.29. The sysroot's SDL is only for
linking and QEMU tests and is never packaged. Before publishing, run the
resource-backed QEMU scenario on both architectures and the pixel comparison
with the original drawing path:

```sh
python tools/tests/anbernic_runtime.py --arch aarch64 --scenario flight \
  --sdk-root /path/to/sdk --qemu /usr/bin/qemu-aarch64 \
  --game-dir /path/to/licensed-game --profile /path/to/new-profile \
  --preload /path/to/flight-capture.so
python tools/tests/h700_launcher.py
python tools/tests/render_reference.py   # after tools/build.py --release
```

The stock-firmware package (`SpaceRangersHD-H700-StockOS.zip`) also builds the
pinned `vendor/gptokeyb` submodule, so the AArch64 sysroot needs the Ubuntu 20.04
`libevdev-dev` headers. To check it against a real stock image, mount the
image's rootfs read-only and pass it to the runtime scenario:

```sh
python tools/tests/anbernic_runtime.py --arch aarch64 --scenario flight \
  --sdk-root /path/to/sdk --qemu /usr/bin/qemu-aarch64 \
  --game-dir /path/to/licensed-game --profile /path/to/new-profile \
  --preload /path/to/flight-capture.so \
  --firmware-root /mnt/stock-rootfs --package-dir /path/to/H700-StockOS/spacerangershd
```

The TrimUI package (`SpaceRangersHD-TrimUI.zip`) is checked the same way. Its
firmwares keep SDL elsewhere, so name the library directories inside the rootfs:
`--firmware-library-dirs usr/lib:lib` for the Smart Pro S. The Smart Pro, Brick
and Brick Pro SDL has no `dummy` video driver; run their rootfs with a test SDL
directory first in that list.

A release contains exactly the seven ZIPs and `SHA256SUMS`; game assets and
saves are never committed or published.

## Linux desktop build

Requires Python 3.10+, FPC 3.2.2, GNU Make, CMake 3.20+, Clang 14+ with
`ld.lld` and binutils, pkg-config and development libraries for SDL2 2.26+
(or SDL2-compat), libogg, libvorbis, libjpeg and libpng. `FPC_BOOTSTRAP`
overrides the installed compiler used to bootstrap the pinned FPC.

The build uses the host CPU: x86_64 or AArch64. x86_64 requires x86-64-v2
(SSE4.2 and POPCNT). AVI playback needs `libxvidcore.so.4`.

```sh
git submodule update --init --recursive
./tools/build.py
./tools/run.py --game-dir=/path/to/game
```

Resources default to `game/` when `--game-dir` is omitted. Compiler jobs are
capped at six and the host CPU count; the limit does not adapt to RAM.

- `--release`: `-O4` instead of the default `-O2`.
- `--lto`: enable LLVM link-time optimization.
- `--rebuild`: rebuild all game units and native code (build script only).

Use matching `--release` and `--lto` options for build and run. Configurations
are `debug` and `release`, with a `-lto` suffix when enabled; the output is
`.local/linux-<cpu>/<profile>/bin/` (`Rangers` and `libokgf.so`, kept
together), and compiler and runtime caches live in `.local/fpc/<cpu>-linux/`.
SDL and codecs remain system dependencies. The handheld build defines
`SRHD_ANBERNIC`; add it to a desktop build to check the handheld UI.

## Compiler development

The build uses the pinned `vendor/fpc` submodule. To sync a local compiler
checkout before building any target:

```sh
FPC_SOURCE=../fpc_sr ./tools/build.py
```

The sync preserves Git metadata and stops on conflicting vendor edits.
`python3 tools/sync_fpc.py ../fpc_sr` syncs without building. Commit compiler
changes in `fpc_sr`, then update the vendor pin when integrating them.

`FPC_COMPILER=/path/to/ppcx64` selects a prebuilt LLVM compiler; the build
still compiles its RTL. Compiler changes invalidate RTL and game caches.
`FPC_SOURCE` retains the bootstrap compiler after the first build to speed up
compiler development.
