# Upstream base for the Anbernic port

This fork now uses the author's reference `main`, through
[`e7a7bdc`](https://github.com/pakompom/SpaceRangersHD_FPC/commit/e7a7bdce89d75f64868c438da7464783933d6406),
fetched on 2026-10-11. Upstream source, platform adapters, native code, build
scripts, tests and dependency pins are retained. The migration merge keeps the
old enhanced/personal history reachable without using that implementation as
its source base.

Upstream pins: FPC `681c8811ac0ff8a4450ac50735ab7e74e0c740bb`,
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
