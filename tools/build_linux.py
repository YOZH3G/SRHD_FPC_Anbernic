#!/usr/bin/env python3
"""Cross-build the Linux game using an installed ARM sysroot and vendored FPC."""

import argparse
import shutil
from pathlib import Path

from build_support import run_step
from targets import ROOT
from pascal import build_paszlib, compile_pascal, pascal_flags


def build_linux(
    arch: str, sysroot: Path, toolchain: Path, fpc_source: Path, rebuild: bool = False
) -> Path:
    arm = arch == "armhf"
    cpu = "arm" if arm else "aarch64"
    triplet = "arm-linux-gnueabihf" if arm else "aarch64-linux-gnu"
    work = ROOT / ".local/anbernic" / ("armhf" if arm else "arm64")
    libraries, units = work / "lib", work / "units"
    libraries.mkdir(parents=True, exist_ok=True)
    units.mkdir(parents=True, exist_ok=True)
    compiler = fpc_source / "compiler" / ("ppcrossarm" if arm else "ppcrossa64")
    runtime = fpc_source / "rtl/units" / f"{cpu}-linux"
    clang = toolchain / f"{triplet}-clang"
    for required in (compiler, runtime / "system.ppu", clang):
        if not required.is_file():
            raise FileNotFoundError(f"Missing toolchain prerequisite: {required}")
    native = work / "native"
    run_step(
        work,
        "configure",
        [
            "cmake",
            "-S",
            ROOT / "native",
            "-B",
            native,
            "-DCMAKE_BUILD_TYPE=Release",
            "-DCMAKE_SYSTEM_NAME=Linux",
            f"-DCMAKE_SYSTEM_PROCESSOR={cpu}",
            f"-DCMAKE_C_COMPILER={clang}",
            f"-DCMAKE_SYSROOT={sysroot}",
            f"-DCMAKE_FIND_ROOT_PATH={sysroot}",
            "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY",
            "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY",
            "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY",
        ],
    )
    run_step(work, "okgf", ["cmake", "--build", native, "--parallel", "4"])
    shutil.copy2(native / "libokgf.so", libraries / "libokgf.so")
    # SDK SDL is used only for cross linking and QEMU checks; firmware supplies SDL.
    shutil.copy2(sysroot / "usr/lib/libSDL2-2.0.so.0", libraries / "libSDL2-2.0.so.0")
    link = libraries / "libSDL2.so"
    link.unlink(missing_ok=True)
    link.symlink_to("libSDL2-2.0.so.0")
    for name, soname in [
        ("vorbisfile", "libvorbisfile.so.3"),
        ("vorbis", "libvorbis.so.0"),
        ("vorbisenc", "libvorbisenc.so.2"),
        ("ogg", "libogg.so.0"),
    ]:
        shutil.copy2(sysroot / f"usr/lib/{triplet}/{soname}", libraries / soname)
        link = libraries / f"lib{name}.so"
        link.unlink(missing_ok=True)
        link.symlink_to(soname)
    packages = ROOT / "vendor/fpc/packages"
    backend = (
        ["-CaEABIHF", "-CpARMV7A", "-CfVFPV3"] if arm else ["-Clv17.0", "-Aclang-llvm"]
    )
    compiler_flags = [
        "-n",
        "-Tlinux",
        *backend,
        "-Cg",
        f"-Fu{runtime}",
        f"-FD{toolchain}",
        f"-XP{triplet}-",
        f"-XR{sysroot}",
    ]
    paszlib = build_paszlib(work, compiler, compiler_flags, rebuild)
    flags = ["-dSRHD_ANBERNIC", *pascal_flags(True, paszlib)]
    if arm:
        flags = ["-O2" if flag == "-O4" else flag for flag in flags]
    paths = ["rtl-objpas/src/inc", "fcl-base/src", "pthreads/src", "fcl-process/src"]
    compile_pascal(
        work,
        [
            compiler,
            "-n",
            "-Tlinux",
            *backend,
            *flags,
            "-Cg",
            f"-Fu{runtime}",
            *(f"-Fu{packages / path}" for path in paths),
            f"-Fi{packages}/fcl-process/src/unix",
            f"-FD{toolchain}",
            f"-XP{triplet}-",
            f"-XR{sysroot}",
            f"-k--sysroot={sysroot}",
            f"-k-L{libraries}",
            f"-FU{units}",
            f"-FE{work}",
            f"-Fl{libraries}",
            f"-Fl{sysroot}/usr/lib/{triplet}",
            f"-Fl{sysroot}/lib/{triplet}",
            f"-Fl{sysroot}/usr/lib/gcc/{triplet}/9",
            "-k-lokgf",
            "-k-rpath",
            "-k$ORIGIN/lib",
            ROOT / "source/Rangers.dpr",
        ],
        rebuild,
        work / "Rangers",
        (libraries / "libokgf.so",),
    )
    return work / "Rangers"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--arch", choices=("armhf", "aarch64"), required=True)
    parser.add_argument("--sysroot", type=Path, required=True)
    parser.add_argument("--toolchain", type=Path, required=True)
    parser.add_argument("--fpc-source", type=Path, required=True)
    parser.add_argument(
        "--rebuild", action="store_true", help="Recompile all Pascal units."
    )
    args = parser.parse_args()
    try:
        binary = build_linux(
            args.arch,
            args.sysroot.resolve(),
            args.toolchain.resolve(),
            args.fpc_source.resolve(),
            args.rebuild,
        )
    except (OSError, RuntimeError) as error:
        parser.exit(1, f"{error}\n")
    print(f"Built: {binary}")


if __name__ == "__main__":
    main()
