[Русская версия](README_RU.md)

# Space Rangers HD — Anbernic Linux / FPC Port

An unofficial Free Pascal port of **Space Rangers HD: A War Apart** for Anbernic
Linux handhelds, with a built-in Russian/English on-screen keyboard and a UI
adapted to 800×600. Supply game assets from your own licensed copy; downloads
contain the port only.

**[Download the latest release](https://github.com/YOZH3G/SRHD_FPC_Anbernic/releases/latest)**
· [Installation and troubleshooting](platform/linux/ANBERNIC.md)
· [Build from source](BUILDING.md)

> Status: **experimental**. Builds are verified under QEMU; physical handhelds,
> their GPUs, sound and controls have not been tested yet.

## Choose a package

Choose your installed firmware first, then check the model:

| Firmware | Models | Package | Architecture |
| --- | --- | --- | --- |
| muOS | RG35XX Plus/H/SP/2024, RG28XX, RG40XX H/V | `SpaceRangersHD-H700-muOS.zip` | ARMHF and AArch64 |
| KNULLI | the same H700 models | `SpaceRangersHD-H700-KNULLI.zip` | AArch64 |
| ArkOS | RG353V/VS/M, RG351P/M/V/MP, RG503 | `SpaceRangersHD-Rockchip-ArkOS.zip` | AArch64 |
| AmberELEC | RG351P/M/V/MP, RG552 | `SpaceRangersHD-Rockchip-AmberELEC.zip` | AArch64 |
| ROCKNIX | RG353P/PS/V/VS/M, RG552, RG503 | `SpaceRangersHD-Rockchip-ROCKNIX.zip` | AArch64 |

RG351P/M on ArkOS require a compatible community release. The original
RG35XX 2022/2023 and Android are not covered by these Linux packages.
Package checksums are in the release's `SHA256SUMS`.

## Install

1. Install current **PortMaster**. The firmware must provide **SDL2 ≥ 2.26.0**
   and **glibc ≥ 2.29**.
2. Extract the package into the Ports directory: muOS uses
   `/mnt/mmc/ROMS/Ports` or `/mnt/sdcard/ROMS/Ports`; KNULLI uses
   `/userdata/roms/ports`; ArkOS/AmberELEC/ROCKNIX usually use `/roms/ports`.
   See the [full instructions](platform/linux/ANBERNIC.md) for alternate paths.
3. Keep `Space Rangers HD.sh` beside `spacerangershd/`. Copy `INSTALL*.TXT`,
   `CFG.TXT`, `CFG/` and `DATA/` from your installed game into
   `spacerangershd/game/`; `INSTALL.TXT` must be directly inside that folder.
4. Refresh the game list and launch **Space Rangers HD** from Ports.

Settings and saves live in `spacerangershd/profile/`; the launcher log is
`spacerangershd/log.txt`. Back up `game/` and `profile/` before updating and do
not mix libraries from different port versions. SDL and display/audio drivers
come from the firmware; the package includes the other runtime libraries.

## Controls and RU/EN keyboard

| Button | Action |
| --- | --- |
| D-pad / left stick | mouse cursor |
| A / B | left / right click |
| Start / R1 | Enter |
| Select | Escape |
| X / Y | Space / Tab |
| L1 | slow cursor |
| Select + Start | quit through PortMaster |

Click a text field with **A** to open the keyboard; **L2** opens it for the
focused field. While it is open:

- **Y:** Russian/English; **R2:** lower/upper case, including ё/Ё.
- **A:** press a key; **B:** delete the character before the caret.
- On-screen Space, `<` and `>` insert a space and move the caret.
- **Start/R1** or **OK** apply; **Select** or **Cancel** discard edits.

The keyboard respects each field's length and character limits. It is on by
default in PortMaster; manual launches use `--on-screen-keyboard`.

## Resolution and renderer

The minimum internal resolution is **800×600**: set `VideoMode=800,600` in
`profile/CFG.TXT` and keep Mobile UI enabled. Menus, station, shops, equipment,
galaxy map, journal, save/load and the keyboard fit the frame; the space HUD
scales separately from the world. Lower values are replaced with 800×600.
Fullscreen scales the frame to the panel while preserving aspect ratio.

Linux defaults to the hardware-accelerated `--renderer=sdl`. If acceleration
is unavailable, the game falls back to software drawing automatically;
`--renderer=software` forces it. The selected driver and fallback reason are in
`spacerangershd/profile/########.log`.

## Performance

The SDL renderer is optimized without changing resolution or image quality:
buffer reuse, texture-state caching, batched points, direct rectangle fills,
cached space-object textures and a frame limiter that sleeps until the frame is
due. Pixel identity with the original drawing path is checked on software,
OpenGL and GLES2.

All measurements were taken under QEMU and on x86_64, not on handhelds.
[Method, results and limitations](docs/performance/README.md) (Russian).

## Screenshots and video

Captured from the real ARMHF/AArch64 builds under QEMU with licensed game assets.

| Russian keyboard, ARMHF | In space after takeoff, AArch64 |
| --- | --- |
| ![Russian keyboard on ARMHF](docs/screenshots/armhf/keyboard-ru.png) | ![Ship in space on AArch64](docs/screenshots/aarch64/space.png) |

More: [800×600 UI](docs/screenshots/adapted-800x600/README.md),
[equipment and resolution switching](docs/screenshots/centered-1024/README.md),
[planet screens](docs/screenshots/planet-layout/README.md),
[all screenshots](docs/screenshots/README.md).

[![Watch: main menu to space](docs/media/video-preview.png)](docs/media/aarch64-menu-to-space.mp4)

Real-time AArch64 recording with game audio: main menu, character setup,
galaxy generation, station, hangar, takeoff and 20 seconds in space. Recorded
under QEMU with the early keyboard release; [recording details](docs/media/README.md).

## What is verified

Every release is rebuilt from source. The final binaries for both architectures
pass the main menu, a new game, station, hangar, takeoff and 20 seconds in space
under QEMU; glibc imports no newer than 2.29 and launcher scenarios are checked
too. Release notes list the SHA256 of the verified binaries. RU/EN input and
the 800×600 screens were verified by dedicated scenarios when introduced.

Not verified: physical handhelds, their GPUs and display rotation, sound and
controls, extended play. Device reports are welcome in Issues.

## Development and attribution

This fork is based on the port author's
[reference `main`](https://github.com/pakompom/SpaceRangersHD_FPC/tree/main);
[UPSTREAM.md](platform/linux/UPSTREAM.md) records the revision and migration.
The upstream port was developed with LLMs through Codex.

- `source/`: Pascal game code; `platform/`: compatibility and SDL runtime;
  `native/`: native libraries; `tools/`: build, packaging and tests.
- `vendor/fpc/` and `vendor/okgf/`: pinned submodules —
  `git submodule update --init --recursive`.
- [Building](BUILDING.md), [development notes](DEVELOPING.md),
  [behavior changes](CHANGES.md).
- [License for custom additions](LICENSE) and [rights and attribution](NOTICE.md).

Unofficial; not affiliated with the game's developers or publisher.
