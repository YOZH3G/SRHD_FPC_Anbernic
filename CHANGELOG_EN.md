# Changelog

Versions of the Anbernic and TrimUI port. New features raise the second
number of the version, fixes the third. Each version is published as a
[GitHub release](https://github.com/YOZH3G/SRHD_FPC_Anbernic/releases), and the
game shows its changes once after starting. [Русский](CHANGELOG.md)

## 0.9.0

- Long text is readable on small screens: dialogues, descriptions, the
  introduction and the ship window take a larger font below 1024x768. The
  introduction scrolls to the end of its text.
- 640x480 screens choose 800x600 by default instead of 1024x768; TrimUI
  1280x720 runs at the screen's own resolution.
- TrimUI: larger text and mobile UI for the dense screens; the Brick defaults
  to 800x600.
- Anbernic stock firmware: the volume buttons change the game's volume, the
  power button puts the handheld to sleep.
- L1 is the slow cursor again while held. R1 steps forward through the panel
  windows.
- Arcade combat: R1 with left or right on the D-pad turns the ship on the move
  instead of in place.
- The arcade battle menu fits the screen at 800x600 and below.
- Port versions are numbered, and after an update the game shows this window
  with the changes.

## 0.8.1 — 2026-10-22

- Station leaders no longer move up at 800x600 and below.
- New screenshots in the README.

## 0.8.0 — 2026-10-22

- A Controls entry in the main menu shows every button, arcade combat included.
- L1 and R1 step through the windows of the bottom-right panel: ship, map,
  quests, and on a planet its sections.
- Arcade combat: with R1 held the D-pad and stick work the thrust and turn like
  the arrow keys; the ship no longer spins from stick drift.
- The new game, introduction and settings screens fit 800x600 correctly.
- Scroll bars in the mobile settings and dialogues can be dragged.
- Anbernic stock firmware: a first attempt at game volume on the volume
  buttons.
- Less CPU load in space and on the star system map.
- The AArch64 build is optimized at link time (LTO).

## 0.7.4 — 2026-10-19

- Smoother save dialog, government screen and large battles with radiation
  weapons.
- Leaving a game for the main menu no longer freezes for seconds.

## 0.7.3 — 2026-10-18

- Fixed the FPS drop in the hangar after buying repairs or fuel: animation
  frames are decoded on a worker thread.
- The log records slow frames and frame statistics for every screen.

## 0.7.2 — 2026-10-18

- Arcade combat textures are prepared before the battle: no FPS drop in its
  first seconds.
- A save with a Russian name on a file system without Cyrillic no longer
  overwrites another save with the same Latin name.
- Fixed rare artifacts when a large image is shown for the first time.

## 0.7.1 — 2026-10-16

- The resource and texture caches fit the handheld's memory and give it back
  when memory runs low.
- The log splits frame time into work and presentation, arcade combat included.

## 0.7.0 — 2026-10-15

- A gamepad layout for arcade combat: the D-pad and stick fly the ship,
  A fires primary weapons, B secondary, Y toggles the autopilot, L2 selects
  the next primary weapon, Start pauses; the cursor works again while paused.
- Saves with Russian names work on file systems without Cyrillic: the name is
  written in Latin letters.
- The caches fit the amount of memory; faster equipment bonus calculation.

## 0.6.1 — 2026-10-15

- The game's cursor is drawn on video drivers without a system cursor.
- The PortMaster and TrimUI launchers log from the very start.
- The packages are built and checked in GitHub Actions.

## 0.6.0 — 2026-10-15

- The port is updated to the current original repository: fixes for mining,
  trajectories, the shop and scripts, and galaxy generation with mods.
- The built-in Utility Functions Pack and AutoSearch mods work without Windows
  libraries.
- A new log, `spacerangershd/profile/rangers-fpc.log`.

## 0.5.0 — 2026-10-15

- TrimUI Smart Pro, Smart Pro S, Brick and Brick Pro with stock firmware or
  CrossMix-OS: `SpaceRangersHD-TrimUI.zip`.

## 0.4.2 — 2026-10-14

- Anbernic stock firmware: the game no longer closes right after starting and
  no longer fails in the main menu over the cursor.

## 0.4.1 — 2026-10-14

- Anbernic stock firmware: buttons are read from the firmware's settings; all
  11 H700 models are supported.

## 0.4.0 — 2026-10-14

- Anbernic stock firmware and Stock OS Mod without PortMaster:
  `SpaceRangersHD-H700-StockOS.zip`.
- RG34XX SP support.

## 0.3.5 — 2026-10-14

- Less idle waiting under the FPS cap; empty frames are no longer decoded again.

## 0.3.4 — 2026-10-12

- Faster drawing in space: batched points, less rectangle geometry and fewer
  needless blends.

## 0.3.3 — 2026-10-12

- Steadier frame rate in space; a 60 FPS cap instead of 50 when the screen's
  refresh rate is unknown.

## 0.3.2 — 2026-10-11

- Faster drawing: texture state is cached between draw calls.

## 0.3.1 — 2026-10-11

- Faster drawing: geometry buffers are reused.

## 0.3.0 — 2026-10-11

- The interface fits 800x600, now the minimum internal resolution.
- Fixed planet backgrounds, the leader's position and the planet information
  panel.

## 0.2.0 — 2026-10-11

- The port moved to the original repository's main branch.
- Hardware drawing through SDL by default, with an automatic software fallback.

## 0.1.0 — 2026-10-11

- The first Anbernic build: muOS, KNULLI, ArkOS, AmberELEC, ROCKNIX.
- A Russian/English on-screen keyboard for gamepad input.
