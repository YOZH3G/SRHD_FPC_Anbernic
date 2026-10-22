# Upstream base for the Anbernic port

This fork now uses the author's reference `main`, through
[`5c8bdba`](https://github.com/pakompom/SpaceRangersHD_FPC/commit/5c8bdba91f9d82351bb40229e6735327d7e1d59d),
merged on 2026-10-15 (first based on `3943d1d` from 2026-10-11). Upstream source, platform adapters, native code, build
scripts, tests and dependency pins are retained. The migration merge keeps the
old enhanced/personal history reachable without using that implementation as
its source base.

Upstream pins: FPC `05cb210db2c90ddb9a759f90d4c0d4734cd99fff`,
OKGF `7f41bc64cc87a8d77afab69b5e7be91126390dd9`.

Adapted local additions: ARMHF/AArch64 cross builds, PortMaster packages,
separate user profiles, RU/EN on-screen keyboard and the native ARM narrow
argument ABI fix. Case-insensitive loose asset paths and compression now use
upstream's GameSystem and OKGF implementations.

Linux defaults to `--renderer=sdl`. SDL acceleration is attempted first,
including an early render-target and geometry capability check. Failed acceleration falls
back to SDL software and the game's CPU drawing path. `--renderer=software`
forces software. Selected renderer and fallback reason are written to the
profile's `rangers-fpc.log` (upstream's unified session log); no persistent configuration is rewritten to disable
acceleration after a temporary failure.

The older keyboard release, screenshots and video used the enhanced branch.
They remain historical artifacts, not evidence for the new main-based build.
Release assets exclude proprietary game files and saves.

The 2026-10-15 merge brought in upstream's 140-column pasfmt layout (the fork
was reflowed with the same pasfmt 0.7.0 settings first), its unified
diagnostics log, mod and script fixes, and robot battles resolved as victories
(the Win32 robot DLL never loaded on Linux). Fork additions keep their
behavior: the SDL acceleration probe and software fallback, compact 800x600
layouts, the on-screen keyboard and `--user-dir`, which is now applied before
the instance lock and the log open.

Since 0.9.0 the fork builds only for Linux: the Android, Windows, macOS, iOS,
Switch and browser build tooling, their platform directories, the Android GPU
planet renderer and upstream's `build.yml` release workflow are removed. Their
`{$IFDEF}` branches stay in the Pascal sources to keep upstream merges simple;
when a merge touches the removed files, keep them deleted.
