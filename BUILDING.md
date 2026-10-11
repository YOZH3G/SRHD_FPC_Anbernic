# Building

## macOS

The macOS ARM64 build requires Python 3, FPC 3.2.2 for bootstrapping, GNU Make,
Xcode command-line tools, CMake, pkg-config, SDL2, SDL2_mixer, libjpeg, and libpng.

The build creates the vendored FPC 3.3.1 LLVM compiler in `.local/fpc/` on first
use and rebuilds it when its source changes. `FPC_BOOTSTRAP` selects the installed
bootstrap compiler. The same generated compiler serves macOS and Android, with
a runtime compiled for each target. Pascal compiles through LLVM IR and Clang;
C code also uses Clang.

```sh
git submodule update --init --recursive
./tools/build.py
./tools/run.py --game-dir=/path/to/game
```

Place the game assets in `game/` using this layout:

```text
game/
  INSTALL.TXT
  INSTALL_ENGLISH.TXT
  INSTALL_RUSSIAN.TXT
  CFG.TXT
  CFG/        # configuration data and language subfolders
  DATA/*.pkg  # original game packages
```

Optional mods go in `game/Mods/` and are selected through the original mod manager.

`game/` is ignored by Git. With assets there, run `./tools/run.py` without arguments.
Generated output stays in `.local/`.
Use `--release` with both scripts for an optimized build.

Saves/settings default to `~/Library/Application Support/SpaceRangersHD/`.
Game options include `--user-dir=/path/to/profile`, `--language=english`,
`--renderer=sdl`, and `--transitions=original`.

To open a save in the galaxy observer:

```sh
./tools/run.py --observer-save=/path/to/save.sav --user-dir=/path/to/observer-profile
```

## Android

`./tools/build.py --target android` produces `.local/android/Rangers.apk`.
Build from macOS ARM64 with the bootstrap tools above, JDK 21, CMake, Ninja,
and the Android SDK/NDK. Set these dependency paths:

- `ANDROID_HOME`: SDK with platform/build-tools 35 or newer.
- `ANDROID_NDK_HOME`: NDK installation.
- `ANDROID_PREFIX`: Android ARM64 libraries/headers for SDL2, SDL2_mixer, libjpeg,
  and libpng; SDL2_mixer and image libraries are linked statically.
- `SDL_SOURCE`: matching SDL2 source tree, supplying its Android Java classes.

Android Pascal and C code use the NDK's LLVM tools. The vendored compiler includes
[Android LLVM support](vendor/fpc/PORT.md).

`JAVA_HOME` selects the JDK. The APK contains code; the launcher imports game
resources from a ZIP of the `game/` layout above:

```sh
ditto -c -k --keepParent game .local/game.zip
```

After applying mods or settings that need a restart, tap Play in the launcher.
`--release` enables optimized native code. Keep `.local/android/debug.keystore`
for subsequent updates signed with the same local key.

## Linux handheld builds

`tools/build_linux.py` builds an ARMHF or AArch64 Linux executable and native
libraries. It needs a Linux sysroot, matching cross-binutils/Clang wrappers,
SDL2 2.26.2, SDL2_mixer 2.8.1, JPEG, PNG, zlib, and a bootstrapped vendored FPC
source tree with its target RTL already built. Use a sysroot compatible with
the device firmware; host Debian libraries are not suitable for the handheld.
ARMHF uses the native FPC backend with ARMv7/VFPv3 hard-float and `-O2`.
AArch64 uses LLVM 17 IR through Clang 19. The vendored ARMHF LLVM backend cannot
compile its Linux RTL in this revision.

In the prepared cloud workspace, build with:

```sh
source /workspace/.cloud-setup/env.sh
python3 tools/build_linux.py --arch armhf \
  --sysroot /workspace/.cloud-setup/anbernic/armhf/root \
  --toolchain /workspace/.cloud-setup/anbernic/armhf/bin \
  --fpc-source .local/anbernic/fpc-arm/source
python3 tools/build_linux.py --arch aarch64 \
  --sysroot /workspace/.cloud-setup/anbernic/arm64/root \
  --toolchain /workspace/.cloud-setup/anbernic/arm64/bin \
  --fpc-source .local/anbernic/fpc-aarch64/source
```

Use `--rebuild` after changing compiler flags or rebuilding FPC to invalidate
compiled Pascal units. Outputs are `.local/anbernic/armhf/` and
`.local/anbernic/arm64/`; these contain `Rangers`, `lib/`, and build logs.
The build tool does not download a sysroot or bootstrap FPC.

The experimental packages target RG35XX Plus/muOS (ARMHF) and RG353V/ArkOS
(AArch64). Both bundles require glibc 2.29 or newer, PortMaster, and original
game resources. They include a firmware launcher and keyboard/mouse mappings
from `platform/linux/`. Packaging substitutes `@ARCH@` in the launcher with
`armhf` or `aarch64`. `--fullscreen` fits the logical canvas to the physical
display; profiles can be placed beside the port with `--user-dir`.

`--on-screen-keyboard` enables the built-in RU/EN keyboard when clicking an
edit field or pressing F6 with an edit field focused. PortMaster launchers enable
it by default: L2 opens it, Y changes language, R2 changes case, B deletes,
Start/R1 confirms, and Select cancels. `--no-on-screen-keyboard` disables it.
`tools/tests/linux_keyboard_capture.c` drives the actual SDL UI through a test-only
preload library. Resource-backed checks on both architectures cover mixed RU/EN
input, insertion at the start and middle, field length limits, commit and cancel.

`tools/tests/linux_smoke.c` checks the native libraries, an SDL software frame,
dummy audio, and MP3/OGG decoders. `tools/tests/ray_sphere.pas` checks ray/sphere
intersection, including aliased input/output. Both passed through QEMU for
both architectures. The packaged executables also reached the expected
missing-assets error through QEMU. Actual handheld video, audio, controls,
performance, and full gameplay require testing with game resources on hardware.

For H700 models (RG35XX H/SP/2024, RG28XX and RG40XX H/V), package with:

```sh
python3 tools/package_h700.py --sdk-root /workspace/.cloud-setup/anbernic \
  --output .local/anbernic/h700-dist
```

Use a new output directory when packaging again. This produces a muOS bundle
with both architectures and an AArch64 KNULLI bundle. The H700 launcher selects
the executable using the userland word size, with PortMaster's architecture as
a fallback. H700 packages use **firmware SDL2 >= 2.0.18**, preserving the Mali
display backend and screen rotation patches. They omit bundled SDL2 and ALSA;
the other native dependencies are included. The `check-platform` executable
prints the system SDL version and available drivers without initializing video.
KNULLI installs to `/userdata/roms/ports`; muOS installs to
`/mnt/mmc/ROMS/Ports` or `/mnt/sdcard/ROMS/Ports`. These are candidate packages
for the listed models, with hardware compatibility still to be verified.

To package all listed Anbernic Linux families for muOS, KNULLI, ArkOS,
AmberELEC and ROCKNIX:

```sh
python3 tools/package_anbernic.py --sdk-root /workspace/.cloud-setup/anbernic \
  --output .local/anbernic/releases
```

Use a new output directory for each packaging run. Rockchip packages reuse
the portable AArch64 executable; their firmware SDL handles the platform's
display backend. See [installation and model mapping](platform/linux/ANBERNIC.md)
for requirements and firmware-specific installation directories.

Resource-backed QEMU checks exposed two Linux/ARMHF issues: Windows asset
filename case must be resolved on Linux, and zlib's length arguments must use
the platform C `unsigned long` (`ctypes.culong`). Both are fixed. The
`tools/tests/zlib_roundtrip.pas` regression check passed for both targets.
Both builds rendered the main menu, new-game settings and introduction with
supplied 2.1.2500 resources. Proprietary resources are kept outside the checkout
and must never be added to release or source archives.
Both final binaries also completed new-game generation, created a character,
entered the station and hangar, took off, and rendered the space screen for
20 seconds before exiting with code 0. The complete QEMU scenarios took
248.2 seconds (ARMHF) and 211.4 seconds (AArch64); the earlier 150-second limit
was insufficient. ARMHF additionally needed zero-extended narrow C arguments
for OKGF's AAPCS calls. `tools/tests/okgf_narrow_args.pas` checks lighting alpha
boundaries, stride and guard bytes on both targets.
An access violation from an earlier AArch64 run has not reproduced in the
successful runs; its cause remains unresolved. Physical hardware and extended
campaign play remain untested.

## Formatting

Install [pasfmt](https://github.com/integrated-application-development/pasfmt),
clang-format, Ruff, cmakelang (`cmake-format`), and libxml2 (`xmllint`).
Run `./tools/format.py` to format Pascal, C, Java, Python, CMake, and XML source;
`./tools/format.py --check` checks the same files.

## Source comments

In Pascal game source, place comments beside changed statements, declarations, or routines:

```pascal
// CHANGE: ENHANCEMENT - Add search bookmark navigation.
// CHANGE: BUGFIX - Avoid floating-point underflow near path endpoints.
// CHANGE: PERFORMANCE - Reuse rendered thumbnails within a turn.
```

Use `PORTABILITY`, `LIMITATION`, or `CLEANUP` for those kinds of game-source changes.
Keep comments short and explain the reason. Use the same category at related
sites so a text search finds them together.
