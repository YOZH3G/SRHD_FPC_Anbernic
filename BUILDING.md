# Building

## Requirements

All targets require Python 3.10+ with current patch updates, FPC 3.2.2,
GNU Make, CMake 3.20+ and Clang 14+. `FPC_BOOTSTRAP` overrides the installed
compiler used to bootstrap the pinned FPC. Additional SDKs are listed below.
Android, iOS and Switch also require Ninja. Browser and iOS builds download
SDL2 and codecs automatically.

Desktop builds also need pkg-config and development libraries for SDL2 2.26+
(or SDL2-compat), libogg, libvorbis, libjpeg and libpng.

- Linux: binutils and `ld.lld` in addition to Clang.
- macOS: Xcode command-line tools and Homebrew.

Desktop builds use the host CPU: x86_64 or AArch64. x86_64 requires x86-64-v2
(SSE4.2 and POPCNT). AVI playback needs `libxvidcore.so.4` on Linux or `xvidcore`
on macOS; Android and Switch omit AVI playback.

## Build and run

```sh
git submodule update --init --recursive
./tools/build.py
./tools/run.py --game-dir=/path/to/game
```

The scripts detect the host OS; `--target=linux` or `--target=macos` selects it
explicitly. Resources default to `game/` when `--game-dir` is omitted.

Compiler jobs are capped at six and the host CPU count; the limit does not adapt to RAM.

- `--release`: `-O4` instead of the default `-O2`.
- `--lto`: enable LLVM link-time optimization (except Switch).
- `--rebuild`: rebuild all game units and native code (build script only).

Use matching `--target`, `--release` and `--lto` options for build and run.
Configurations are `debug` and `release`, with a `-lto` suffix when
enabled; compiler and runtime caches live in `.local/fpc/<cpu>-<system>/`.

| Platform | Output |
| --- | --- |
| Linux | `.local/linux-<cpu>/<profile>/bin/`: `Rangers` and `libokgf.so` |
| macOS | `.local/<profile>/Space Rangers HD.app` |
| Browser | `.local/wasm/<profile>/bin/` |
| Android | `.local/android-arm64/<profile>/Rangers.apk` |
| iOS / simulator | `.local/<target>-<cpu>/<profile>/SpaceRangersHD.app` |
| Switch | `.local/switch-aarch64/<profile>/bin/Rangers.nro` |

Linux CPU names are `x86_64` and `aarch64`. Keep the Linux executable and OKGF
library together; SDL and codecs remain system dependencies.

## Browser

Requires Emscripten and a browser supporting WebAssembly threads and exception
handling.

```sh
./tools/build.py --target=wasm --release
./tools/run.py --target=wasm --release --game-dir=/path/to/game
```

Open `http://127.0.0.1:8788/` and select **Start game**. The server streams the
original game assets and supplies the isolation headers needed for shared memory.
Saves are stored in this browser. Use `--port` to select a different server port.

## Android

Requires JDK 17+, Android SDK platform 35, build-tools 35+ and NDK r28+.
Build on macOS or x86_64 Linux for ARM64 devices running Android 8.0+.
Set `ANDROID_HOME`, `ANDROID_NDK_HOME` or `JAVA_HOME` to override tool locations.

```sh
./tools/build.py --target=android
```

Install the APK, copy your game folder to the device, and choose **Select game
folder** in the launcher. Keep `build/android-signing/` to sign updates with the
same key. Release symbols are in `build/android-symbols/<build-id>/`.

`ANDROID_VERSION_CODE` and `ANDROID_VERSION_NAME` override the defaults in
`tools/targets.py`; `ANDROID_BUILD_TOOLS_VERSION` selects a specific SDK build-tools version.

## iOS

Requires macOS and full Xcode; targets iOS 15+. Select Xcode with `xcode-select`
or `DEVELOPER_DIR` and install an iOS simulator runtime in Xcode's Components settings.

```sh
./tools/build.py --target=ios-simulator
./tools/run.py --target=ios-simulator --simulator="iPhone 15" --game-dir=/path/to/game
```

The simulator uses the host CPU; pass `--simulator-arch=x86_64` or `arm64` to both
commands to override it. Select a device by name or UDID with `--simulator`;
otherwise the single booted device is used. `xcrun simctl list devices available`
lists installed devices. Use `--game-dir` for the initial asset import; omit it
on later runs to reuse them. Reinstalling preserves assets and saves.

```sh
./tools/build.py --target=ios
```

Device builds use ARM64 and require signing with an Apple identity and
provisioning profile before installation. Copy game files to
`Documents/Game` through Files or Finder file sharing. Saves and logs are in
`Library/Application Support/SpaceRangersHD` within the app sandbox.

## Anbernic Linux cross builds

Initialize submodules and bootstrap ARMHF/AArch64 compilers and RTL from the
pinned `vendor/fpc` revision. A matching Linux sysroot and Clang/binutils wrappers
are required; `--fpc-source` points at the bootstrapped source/build tree.
The toolchain must also provide `<triplet>-fpcres` (the FPC resource compiler),
and its sysroot must contain SDL2 ≥ 2.26 plus Ogg/Vorbis development libraries.

```sh
python tools/build_linux.py --arch aarch64 \
  --sysroot /path/to/arm64/root --toolchain /path/to/arm64/bin \
  --fpc-source /path/to/fpc-aarch64/source --rebuild
python tools/build_linux.py --arch armhf \
  --sysroot /path/to/armhf/root --toolchain /path/to/armhf/bin \
  --fpc-source /path/to/fpc-arm/source --rebuild
python tools/package_anbernic.py --sdk-root /path/to/sdk --output /path/to/packages
```

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

A release contains exactly the six ZIPs and `SHA256SUMS`; game assets and
saves are never committed or published.

## Nintendo Switch (homebrew)

Requires devkitPro's ARM64/libnx SDK on macOS or Linux.
`DEVKITPRO` defaults to `/opt/devkitpro`. Install the SDK packages and build:

```sh
sudo dkp-pacman -Syu --needed switch-dev switch-cmake switch-sdl2 switch-mesa switch-libogg switch-libvorbis switch-libjpeg-turbo switch-libpng switch-zlib
./tools/build.py --target=switch
```

Put the NRO in `switch/SpaceRangersHD/` on the SD card and game assets in
`switch/SpaceRangersHD/game/`. Saves and logs go in `switch/SpaceRangersHD/user/`.
Use application mode/title takeover for enough memory. Keep the matching
`Rangers.elf` and `Rangers.map` for crash diagnostics.

For a Ryujinx-compatible emulator, the launcher links assets into an already
configured profile's virtual SD card:

```sh
./tools/run.py --target=switch --emulator-root=/path/to/development-profile --game-dir=/path/to/game
```

`--emulator` or `SWITCH_EMULATOR` selects the executable; `SWITCH_EMULATOR_ROOT`
can supply the profile path. For touchscreen emulation, use Handheld mode with
Direct Mouse Access disabled.

## Compiler development

The build uses the pinned `vendor/fpc` submodule. To sync a local compiler
checkout before building any target:

```sh
FPC_SOURCE=../fpc_sr ./tools/build.py
```

The sync preserves Git metadata and stops on conflicting vendor edits.
`python3 tools/sync_fpc.py ../fpc_sr` syncs without building. Commit compiler
changes in `fpc_sr`, then update the vendor pin when integrating them.
