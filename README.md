[Русская версия](README_RU.md)

# Space Rangers HD — Anbernic Linux / FPC Port

An unofficial Free Pascal port of **Space Rangers HD: A War Apart** with
experimental Anbernic Linux packages and a built-in Russian/English keyboard.
Supply game assets from your own licensed copy; downloads contain the port only.

[Download builds](https://github.com/YOZH3G/SRHD_FPC_Anbernic/releases/tag/anbernic-ui-2026.10.11)
· [Installation and troubleshooting](platform/linux/ANBERNIC.md)
· [Build from source](BUILDING.md)

## Choose a package

Choose your installed firmware first, then check the model:

- **muOS:** RG35XX Plus/H/SP/2024, RG28XX, RG40XX H/V — H700 package with ARMHF and AArch64.
- **KNULLI:** the same H700 models — AArch64.
- **ArkOS:** RG353V/VS/M, RG351P/M/V/MP, RG503 — AArch64. RG351P/M require a compatible community release.
- **AmberELEC:** RG351P/M/V/MP and RG552 — AArch64.
- **ROCKNIX:** RG353P/PS/V/VS/M, RG552 and RG503 — AArch64.

These are target models, not a list of hardware-tested devices. The original
RG35XX 2022/2023 and Android are not covered by these Linux packages.

## Install

1. Install current **PortMaster**. The firmware must provide **SDL2 ≥ 2.26.0**
   and **glibc ≥ 2.29**.
2. Extract your package into the firmware's Ports directory: muOS uses
   `/mnt/mmc/ROMS/Ports` or `/mnt/sdcard/ROMS/Ports`; KNULLI uses
   `/userdata/roms/ports`; ArkOS/AmberELEC/ROCKNIX usually use `/roms/ports`.
   See the [full instructions](platform/linux/ANBERNIC.md) for alternate paths.
3. Keep `Space Rangers HD.sh` beside `spacerangershd/`. Copy `INSTALL*.TXT`,
   `CFG.TXT`, `CFG/` and `DATA/` from your installed game into
   `spacerangershd/game/`; `INSTALL.TXT` must be directly inside that folder.
4. Refresh the game list and launch **Space Rangers HD** from Ports.

Settings and saves live in `spacerangershd/profile/`; the launcher log is
`spacerangershd/log.txt`. Back up `game/` and `profile/` before updating.
Firmware SDL and display/audio drivers remain in use; the packages include the
other runtime libraries. Avoid mixing libraries from different port versions.

## Controls and RU/EN keyboard

The D-pad or left stick moves the mouse; **A/B** are left/right click.
**Start/R1** sends Enter, **Select** sends Escape, **L1** slows the cursor,
**X** sends Space and **Y** sends Tab. Sticks are optional.

Click a text field with **A** to open the keyboard; **L2** opens it for a focused
field. While it is open:

- **Y:** Russian/English; **R2:** lower/upper case, including ё/Ё.
- **A:** click a key; **B:** delete the character before the caret.
- Use the on-screen Space and `<` / `>` buttons to insert spaces or move the caret.
- **Start/R1** or **OK:** apply; **Select** or **Cancel:** discard edits.

The keyboard respects each field's length and character restrictions. It is
on by default in PortMaster; manual launches use `--on-screen-keyboard`.

## Renderer and screen resolution

Linux attempts `--renderer=sdl` by default. If accelerated renderer or initial
render-target creation fails, it falls back to software automatically. Use
`--renderer=software` to force software. The selected SDL backend and fallback
reason are in `spacerangershd/profile/########.log`.

The physical panel and game layout resolution differ: fullscreen scales the
logical frame to the panel while preserving aspect ratio. A 640×480 panel does
not by itself make the game render its layout at 640×480.

The current Anbernic source supports a minimum internal resolution of **800×600**.
Set `VideoMode=800,600` in `profile/CFG.TXT`; no experimental flag is needed.
Lower requested resolutions are replaced with 800×600. The menu and character
creation fit inside the frame, while the space HUD scales separately from the
world. Automatic resolution selection retains its previous behavior. These
changes are included in release `anbernic-ui-2026.10.11`. Keep Mobile UI enabled for the adapted layout. Settings, station dialogs, shops,
ship equipment, galaxy map, journal, save/load and the RU/EN keyboard now fit
the same frame. See the [800×600 screenshots and checks](docs/screenshots/adapted-800x600/README.md).
[In-game resolution switching](docs/screenshots/resolution-switch/README.md)
checks restoration of the layout when changing between 800×600 and 1024×768.
Equipment in space is centered above the HUD at both resolutions; see the
[updated captures](docs/screenshots/centered-1024/README.md).
[Planetary screens](docs/screenshots/planet-layout/README.md) now fill the 800×600
frame, with the governor fitted to the right of the dialogue.

## Screenshots

The screenshots and video below belong to the earlier
[enhanced-branch keyboard release](https://github.com/YOZH3G/SRHD_FPC_Anbernic/releases/tag/anbernic-keyboard-2026.10.11).

Captured from the actual ARMHF/AArch64 builds under QEMU using licensed game
assets. These images do not demonstrate a physical handheld or firmware driver.

Russian keyboard, ARMHF:

![Russian keyboard on ARMHF](docs/screenshots/armhf/keyboard-ru.png)

English keyboard, AArch64:

![English keyboard on AArch64](docs/screenshots/aarch64/keyboard-en.png)

In space after takeoff, AArch64:

![Ship in space on AArch64](docs/screenshots/aarch64/space.png)

[More screenshots and their test context](docs/screenshots/README.md).

## Video: main menu to space

[![Watch: main menu to space](docs/media/video-preview.png)](docs/media/aarch64-menu-to-space.mp4)

[Watch or download the AArch64 recording](docs/media/aarch64-menu-to-space.mp4).
It shows the main menu, character setup, galaxy generation, station, hangar and
first takeoff, including 20 seconds in space. The recording preserves elapsed
time and the game's audio; it has no cuts or speed changes.

This is the Linux AArch64 executable used by the ArkOS package, running under
QEMU with SDK SDL. It is not an ArkOS firmware session or a physical RG353V test.
[Recording details](docs/media/README.md) include the binary hash and method.

## What has been verified

Both architectures pass resource-backed checks for RU/EN entry, case, caret
editing, the name-length limit, confirmation and cancellation. After updating
upstream, both also completed a new galaxy's 300 preliminary turns, entered the
station and hangar, took off, and loaded a new autosave for another takeoff.
The release includes the validation report and SHA256 checksums.

Physical devices, their display rotation, sound/controller behavior and extended
campaign play remain untested. This is an **experimental release**.

## Development and attribution

This fork is based on the author's current
[reference `main`](https://github.com/pakompom/SpaceRangersHD_FPC/tree/main),
with the Anbernic packaging and RU/EN keyboard adapted to its SDL platform layer.
[Upstream tracking details](platform/linux/UPSTREAM.md) record the revision and migration.
The upstream port was developed with LLMs through Codex.

- [Behavior changes](CHANGES.md) and [build instructions](BUILDING.md).
- `source/`: Pascal game code; `platform/`: compatibility and SDL runtime.
- `native/`: native integration; `tools/`: build, packaging and test helpers.
- `vendor/okgf/` and `vendor/fpc/`: pinned submodules; initialize them with
  `git submodule update --init --recursive`.
- [License for custom additions](LICENSE) and [rights and attribution](NOTICE.md).

Unofficial; not affiliated with the game's developers or publisher.
