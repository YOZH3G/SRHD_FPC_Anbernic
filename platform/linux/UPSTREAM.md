# Upstream base for the Anbernic port

This fork now uses the author's reference `main`, through
[`e7a7bdc`](https://github.com/pakompom/SpaceRangersHD_FPC/commit/3943d1d10651781c8dad666e54918a909e674b24),
fetched on 2026-10-11. Upstream source, platform adapters, native code, build
scripts, tests and dependency pins are retained. The migration merge keeps the
old enhanced/personal history reachable without using that implementation as
its source base.

Upstream pins: FPC `e79995bc0986f46a4ad6eb3fcdd9bdc1db88b1f7`,
OKGF `7f41bc64cc87a8d77afab69b5e7be91126390dd9`.

Adapted local additions: ARMHF/AArch64 cross builds, PortMaster packages,
separate user profiles, RU/EN on-screen keyboard and the native ARM narrow
argument ABI fix. Case-insensitive loose asset paths and compression now use
upstream's GameSystem and OKGF implementations.

Linux defaults to `--renderer=sdl`. SDL acceleration is attempted first,
including an early render-target and geometry capability check. Failed acceleration falls
back to SDL software and the game's CPU drawing path. `--renderer=software`
forces software. Selected renderer and fallback reason are written to the
profile's `########.log`; no persistent configuration is rewritten to disable
acceleration after a temporary failure.

The older keyboard release, screenshots and video used the enhanced branch.
They remain historical artifacts, not evidence for the new main-based build.
Release assets exclude proprietary game files and saves.
