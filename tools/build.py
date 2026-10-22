#!/usr/bin/env python3
"""Build Space Rangers HD for the Linux desktop."""

import argparse
import shlex
import subprocess
from pathlib import Path

from build_support import build_okgf, copy_if_changed, output, require_tool
from compiler import prepare_compiler
from pascal import build_paszlib, compile_pascal, pascal_flags
from targets import ROOT, BuildConfig, add_build_arguments


def build_linux(config: BuildConfig, rebuild: bool) -> Path:
    work, libraries, units = config.work, config.binary_directory, config.units
    config.create_directories()
    # Check system dependencies before the more expensive compiler bootstrap.
    require_tool("cmake")
    require_tool("pkg-config")
    require_tool("clang")
    require_tool("ld.lld")
    subprocess.run(
        ["pkg-config", "--print-errors", "--exists", "sdl2 >= 2.26", "vorbisfile", "ogg"],
        check=True,
    )
    native = build_okgf(work, config.release, rebuild=rebuild)
    copy_if_changed(native / "libokgf.so", libraries / "libokgf.so")
    compiler, compiler_flags = prepare_compiler(config)
    # FPC's LLVM exception runtime uses libgcc; -n disables system fpc.cfg.
    libgcc = Path(output("clang", "-print-libgcc-file-name"))
    if not libgcc.is_file():
        raise FileNotFoundError("Clang cannot locate libgcc; install the GCC runtime.")
    compiler_flags += [f"-Fl{libgcc.parent}"]
    paszlib = build_paszlib(work, compiler, compiler_flags, rebuild)
    # CMake finds C libraries; FPC needs the corresponding native search paths.
    library_flags = shlex.split(output("pkg-config", "--libs-only-L", "sdl2", "vorbisfile"))
    compile_pascal(work, [
        compiler, *compiler_flags, *pascal_flags(config.release, paszlib),
        f"-FU{units}", f"-FE{libraries}", f"-Fl{libraries}",
        *("-Fl" + flag[2:] for flag in library_flags),
        # LLD resolves command-line -l before FPC's script SEARCH_DIR entries.
        # FPC reparses -k options; quote the whole linker argument for spaced paths.
        f'-k"-L{libraries}"', "-k-lokgf", "-k--enable-new-dtags", "-k-rpath", "-k$ORIGIN",
        ROOT / "source/Rangers.dpr",
    ], rebuild, libraries / "Rangers", (libraries / "libokgf.so", libgcc))  # fmt: skip
    return config.artifact


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    add_build_arguments(parser)
    parser.add_argument(
        "--rebuild", action="store_true", help="Rebuild all game units and native code."
    )
    args = parser.parse_args()
    try:
        config = BuildConfig(args.target, args.release, args.lto)
    except ValueError as error:
        parser.error(str(error))
    try:
        artifact = build_linux(config, args.rebuild)
    except subprocess.CalledProcessError as error:
        parser.exit(1, error.output or str(error))
    except (OSError, RuntimeError) as error:
        parser.exit(1, f"{error}\n")
    print(f"Built: {artifact}")


if __name__ == "__main__":
    main()
