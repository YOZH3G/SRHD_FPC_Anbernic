# Upstream base for the Anbernic port

This fork's `main` extends the author's enhanced `personal` branch. On
2026-10-11 it was merged through
[`8d40393`](https://github.com/pakompom/SpaceRangersHD_FPC/commit/8d40393dd64f4823924b4fbc7b32691cb6893b3c),
the current tip of that branch. Its updates include timer/rendering optimizations,
native script utilities, pointer-width fixes, mod manuals and incremental builds.

The author's newer reference `main` is a separate port with different history
and behavior. It is not a drop-in replacement for the enhanced branch. Likewise,
the Delphi decompilation is an upstream source project, not the FPC build tree.

OKGF is updated to
[`7f41bc6`](https://github.com/pakompom/okgf/commit/7f41bc64cc87a8d77afab69b5e7be91126390dd9),
also used by the author's current reference port. This includes overlapping-copy
fixes, converter bounds checks and configurable library builds.

The FPC submodule retains the enhanced branch's pin
`1cecb27cfbc11df80bad8dda5cf10bf04ea95e0d`. Linux cross builds accept an
already bootstrapped compiler and target RTL via `--fpc-source`; see `BUILDING.md`.
Release runtime checks must be repeated after changes to game code or OKGF.

Preserved local additions: ARMHF/AArch64 Linux builds, resource-path handling,
zlib and ARM C ABI fixes, PortMaster packages, RU/EN keyboard and resource-backed
regression helpers. Release assets exclude proprietary game files and saves.
