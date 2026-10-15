"""Build Windows binaries natively or with the LLVM-MinGW cross SDK."""

import os
import platform
import re
import shutil
import subprocess
from pathlib import Path

from build_support import (
    build_codecs,
    build_jobs,
    build_okgf,
    copy_if_changed,
    require_tool,
)
from targets import ROOT, BuildConfig, windows_triple


def discover_toolchain() -> Path:
    configured = os.environ.get("LLVM_MINGW")
    if configured:
        root = Path(configured).expanduser().resolve()
    elif executable := shutil.which("i686-w64-mingw32-clang"):
        # Preserve the target-prefixed driver name: it selects the SDK target.
        root = Path(executable).absolute().parent.parent
    else:
        raise FileNotFoundError("Set LLVM_MINGW to the LLVM-MinGW SDK directory.")
    for name in ("clang", "ld.lld", "i686-w64-mingw32-clang", "llvm-readobj"):
        require_tool(str(root / "bin" / name))
    return root


def cmake_options(config: BuildConfig, toolchain: Path, prefix: Path) -> list[str]:
    triple = windows_triple(config.cpu)

    def driver(name: str) -> str:
        return require_tool(str(toolchain / "bin" / f"{triple}-{name}")).as_posix()

    return [
        "-DCMAKE_SYSTEM_NAME=Windows",
        f"-DCMAKE_SYSTEM_PROCESSOR={config.cpu}",
        f"-DCMAKE_C_COMPILER={driver('clang')}",
        f"-DCMAKE_CXX_COMPILER={driver('clang++')}",
        f"-DCMAKE_RC_COMPILER={driver('windres')}",
        f"-DCMAKE_INSTALL_PREFIX={prefix.as_posix()}",
        f"-DCMAKE_FIND_ROOT_PATH={prefix.as_posix()};{toolchain.as_posix()}/{triple}",
        "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER",
        "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY",
        "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY",
        "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY",
        "-DCMAKE_POLICY_VERSION_MINIMUM=3.5",
        "-DBUILD_TESTING=OFF",
    ]


def prepare_native(config: BuildConfig, toolchain: Path, rebuild: bool) -> tuple[Path, Path]:
    for name in ("cmake", "ninja"):
        require_tool(name)
    config.create_directories()
    prefix = config.work / "dependencies/prefix"
    options = cmake_options(config, toolchain, prefix)
    build_codecs(config.work, options, rebuild, windows=True)
    # Native CMake may default to Visual Studio. Keep existing cross-build
    # generators so their configured build directories remain reusable.
    generator = ["-G", "Ninja"] if platform.system() == "Windows" else []
    native = build_okgf(
        config.work, config.release, *generator, *options, "-DBUILD_SHARED_LIBS=ON",
        rebuild=rebuild, jobs=build_jobs(),
    )
    libraries = [native / "okgf.dll", native / "SDL2.dll", *prefix.glob("bin/*.dll")]
    triple = windows_triple(config.cpu)
    libraries.append(toolchain / triple / "bin/libunwind.dll")
    for library in libraries:
        copy_if_changed(library, config.binary_directory / library.name)
    # FPC's Ogg/Vorbis units use unprefixed DLL names. Keep the original files
    # too because the codec DLLs import one another by their CMake names.
    for name in ("ogg", "vorbis", "vorbisfile", "vorbisenc"):
        matches = list(prefix.glob(f"bin/lib{name}.dll")) + list(prefix.glob(f"bin/lib{name}-*.dll"))
        if matches:
            copy_if_changed(matches[0], config.binary_directory / f"{name}.dll")
    return native, prefix


def build_windows(config: BuildConfig, rebuild: bool) -> Path:
    from compiler import prepare_compiler
    from pascal import build_paszlib, compile_pascal, pascal_flags

    toolchain = discover_toolchain()
    compiler, flags = prepare_compiler(config, toolchain / "bin")
    native, prefix = prepare_native(config, toolchain, rebuild)
    paszlib = build_paszlib(config.work, compiler, flags, rebuild)
    compile_pascal(config.work, [
        compiler, *flags, *pascal_flags(config.release, paszlib),
        f"-FU{config.units}", f"-FE{config.binary_directory}",
        f"-Fl{native}", f"-Fl{prefix / 'lib'}", ROOT / "source/Rangers.dpr",
    ], rebuild, config.artifact, tuple(config.binary_directory.glob("*.dll")))  # fmt: skip
    readobj = require_tool(str(toolchain / "bin/llvm-readobj"))
    verify_binary(config.artifact, config.cpu, readobj)
    for library in config.binary_directory.glob("*.dll"):
        verify_binary(library, config.cpu, readobj)
    return config.artifact


def verify_binary(binary: Path, cpu: str, readobj: Path) -> None:
    headers = subprocess.check_output([str(readobj), "--file-headers", str(binary)], text=True)
    expected = "I386" if cpu == "i386" else "AMD64"
    machine = re.search(r"Machine: IMAGE_FILE_MACHINE_(\w+)", headers)
    if machine is None or machine[1] != expected:
        raise RuntimeError(f"Windows dependency has the wrong CPU ({cpu} required): {binary}")


def run_windows(binary: Path, game: Path, options: list[str], bottle: str | None) -> None:
    if platform.system() == "Windows":
        subprocess.run([str(binary), f"--game-dir={game}", *options], check=True)
        return
    executable = os.environ.get("WINE")
    if not executable and platform.system() == "Darwin":
        crossover = Path("/Applications/CrossOver.app/Contents/SharedSupport/CrossOver/bin/wine")
        if crossover.is_file():
            executable = str(crossover)
    wine = require_tool(executable or "wine")
    command = [str(wine)]
    if bottle:
        command += ["--bottle", bottle]
    # Wine maps Unix files through Z:. Avoid interpreting --game-dir as a
    # Windows-relative path, and keep game arguments intact for caller control.
    command += [str(binary), "--game-dir=Z:" + str(game).replace("/", "\\"), *options]
    subprocess.run(command, check=True)
