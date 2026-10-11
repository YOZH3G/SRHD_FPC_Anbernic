# Space Rangers HD — FPC Enhanced Port

A personal, opinionated Free Pascal port of **Space Rangers HD: A War Apart**,
based on the [original decompilation](https://github.com/pakompom/SpaceRangersHD_decomp).
Breaking changes can happen at any time.

This fork's `main` branch extends the author's
[`personal` branch](https://github.com/pakompom/SpaceRangersHD_FPC/tree/personal)
with Anbernic Linux support. The author's reference `main` branch is a separate
port focused on platform compatibility.

https://github.com/user-attachments/assets/724f0543-1cb1-4b46-bb47-95ab45cbdfee

This port is developed exclusively with LLMs such as GPT-6 Astra through Codex.

- [Additions and behavior changes](ADDITIONS.md)
- [Building and running](BUILDING.md)
- [Anbernic installation and RU/EN keyboard controls](platform/linux/ANBERNIC.md)
- [Download Anbernic releases](https://github.com/YOZH3G/SpaceRangersHD_FPC/releases)
- [MIT license for custom additions](LICENSE) and [attribution](NOTICE.md)

## Anbernic Linux

Experimental ARMHF and AArch64 packages target muOS, KNULLI, ArkOS, AmberELEC
and ROCKNIX. Install current PortMaster and supply assets from your own game
copy. The launcher enables the built-in Russian/English on-screen keyboard:
click an edit field with A, use Y for language and R2 for case, Start to confirm,
and Select to cancel. L2 opens the keyboard for a focused edit field.

Keyboard input, commit/cancel, name-length limits and takeoff have been checked
under QEMU with game assets. Physical handhelds remain untested; see the release
report for the exact binaries and checks.

Free Pascal is pinned as the [fpc_sr](https://github.com/pakompom/fpc_sr) submodule,
which retains upstream history and carries our compiler and runtime fixes.
Both macOS and Android builds use its LLVM backend. See the
[FPC changes](vendor/fpc/PORT.md) for the compiler fixes and Android support.

## Source

- `source/`: Pascal game code, grouped by subsystem.
- `platform/`: native compatibility, SDL, and Android runtime.
- `native/`: OKGF build integration.
- `tools/`: build, run, and formatting scripts.
- `vendor/okgf/`: pinned [OKGF](https://github.com/pakompom/okgf) submodule.
- `vendor/fpc/`: pinned [Free Pascal fork](https://github.com/pakompom/fpc_sr) submodule.
