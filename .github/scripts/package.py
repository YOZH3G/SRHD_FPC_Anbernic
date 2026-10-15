"""Package CI outputs without game assets or signing material."""

import io
import re
import shutil
import subprocess
import sys
import tarfile
import zipfile
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))
from build_support import dependency_source, require_tool, sdl_source
from targets import BuildConfig, host_cpu
from windows import discover_toolchain


def windows_runtime_files(binary: Path, readobj: Path) -> list[Path]:
    """Follow PE imports, excluding OS libraries and unused build outputs."""
    bundled = {
        name.lower(): binary.parent / name
        for name in (
            "okgf.dll",
            "SDL2.dll",
            "vorbisfile.dll",
            "libvorbis.dll",
            "ogg.dll",
            "libzlib.dll",
            "libunwind.dll",
        )
    }
    system = {
        "advapi32.dll",
        "gdi32.dll",
        "imm32.dll",
        "kernel32.dll",
        "mpr.dll",
        "msvcrt.dll",
        "ntdll.dll",
        "ole32.dll",
        "oleaut32.dll",
        "setupapi.dll",
        "shell32.dll",
        "ucrtbase.dll",
        "user32.dll",
        "version.dll",
        "winmm.dll",
    }
    pending = [binary]
    files = {}
    while pending:
        path = pending.pop()
        if path.name.lower() in files:
            continue
        if not path.is_file():
            raise FileNotFoundError(f"Windows runtime dependency is missing: {path}")
        files[path.name.lower()] = path
        imports = subprocess.check_output([str(readobj), "--coff-imports", str(path)], text=True)
        for name in re.findall(r"^  Name: (\S+\.dll)$", imports, re.MULTILINE | re.IGNORECASE):
            name = name.lower()
            if name in system or name.startswith(("api-ms-win-", "ext-ms-win-")):
                continue
            if name not in bundled:
                raise RuntimeError(f"Unreviewed Windows dependency in {path.name}: {name}")
            pending.append(bundled[name])
    return sorted(files.values())


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=ROOT, text=True).strip()


def package(target: str) -> None:
    platforms = {"linux": "Linux-x86_64", "android": "Android-arm64", "win64": "Windows-x86_64"}
    if target not in platforms:
        raise ValueError(f"Unsupported release target: {target}")
    if target == "linux" and host_cpu() != "x86_64":
        raise ValueError("Linux releases require an x86_64 build host")
    config = BuildConfig(target, release=True, root=ROOT)
    platform = platforms[target]
    commit = git("rev-parse", "HEAD")
    name = f"SpaceRangersHD-{platform}"
    destination = ROOT / "build/release"
    destination.mkdir(parents=True, exist_ok=True)
    diagnostics = ROOT / "build/diagnostics" / platform
    diagnostics.mkdir(parents=True, exist_ok=True)
    info = diagnostics / "build.txt"
    info.write_text(
        f"Commit: {commit}\n"
        f"Subject: {git('show', '-s', '--format=%s', 'HEAD')}\n"
        f"Built: {datetime.now(timezone.utc).isoformat(timespec='seconds')}\n"
        f"Platform: {platform}\nProfile: release (-O4, no LTO)\n"
        f"FPC: {git('-C', 'vendor/fpc', 'rev-parse', 'HEAD')}\n"
        f"OKGF: {git('-C', 'vendor/okgf', 'rev-parse', 'HEAD')}\n"
    )
    if target == "android":
        shutil.copy2(config.artifact, destination / f"{name}.apk")
        symbols = ROOT / "build/android-symbols"
        if not any(symbols.glob("*/*.so")):
            raise FileNotFoundError("Android release symbols are missing")
        with tarfile.open(diagnostics / f"{name}-symbols.tar.gz", "w:gz") as archive:
            archive.add(symbols, arcname="symbols")
        return

    if target == "win64":
        toolchain = discover_toolchain()
        binaries = windows_runtime_files(
            config.artifact, require_tool(str(toolchain / "bin/llvm-readobj"))
        )
    else:
        binaries = [config.artifact, config.binary_directory / "libokgf.so"]
    files = {binary.name: binary for binary in binaries}
    files.update({filename: ROOT / filename for filename in ("LICENSE", "NOTICE.md")})
    files["build.txt"] = info
    for source, filename in (
        ("licenses/spacerangershd-fpc-fixes.txt", "spacerangershd-fpc-fixes.txt"),
        ("vendor/okgf/LICENSE", "OKGF.txt"),
        ("vendor/okgf/vendor/softfloat/COPYING.txt", "SoftFloat.txt"),
        ("vendor/fpc/rtl/COPYING.FPC", "FPC.txt"),
        ("vendor/fpc/rtl/COPYING.txt", "FPC-LGPL.txt"),
        ("vendor/fpc/packages/paszlib/readme.txt", "paszlib.txt"),
        ("vendor/fpc/packages/pasjpeg/readme.txt", "pasjpeg.txt"),
    ):
        files[f"licenses/{filename}"] = ROOT / source
    if target == "win64":
        files["licenses/SDL2.txt"] = sdl_source(config.work / "native") / "LICENSE.txt"
        for dependency, filename in (
            ("zlib", "LICENSE"),
            ("jpeg", "LICENSE.md"),
            ("png", "LICENSE"),
            ("ogg", "COPYING"),
            ("vorbis", "COPYING"),
        ):
            files[f"licenses/{dependency}.txt"] = dependency_source(dependency) / filename
        files["licenses/jpeg-IJG.txt"] = dependency_source("jpeg") / "README.ijg"
        files["licenses/LLVM.txt"] = toolchain / "LICENSE.TXT"
        files["licenses/MinGW-w64.txt"] = (
            toolchain / "x86_64-w64-mingw32/share/mingw32/COPYING.MinGW-w64-runtime.txt"
        )
        with zipfile.ZipFile(
            destination / f"{name}.zip", "w", compression=zipfile.ZIP_DEFLATED
        ) as archive:
            for filename, path in files.items():
                archive.write(path, f"{name}/{filename}")
        return

    readme = (
        "Space Rangers HD — Free Pascal port\n\n"
        "Requires your own Space Rangers HD game data (not included).\n"
        "Built on Ubuntu 24.04; requires glibc 2.39+ and an x86-64-v2 CPU.\n"
        "Install runtime libraries on Ubuntu 24.04:\n"
        "sudo apt-get install libsdl2-2.0-0 libogg0 libvorbisfile3 libjpeg-turbo8 libpng16-16t64 libxvidcore4\n\n"
        "Keep Rangers and libokgf.so together, then run:\n"
        './Rangers --game-dir="/path/to/game"\n'
    )
    with tarfile.open(destination / f"{name}.tar.gz", "w:gz", dereference=True) as archive:
        for filename, path in files.items():
            archive.add(path, arcname=f"{name}/{filename}")
        content = readme.encode()
        member = tarfile.TarInfo(f"{name}/README.txt")
        member.size = len(content)
        member.mtime = info.stat().st_mtime
        archive.addfile(member, io.BytesIO(content))


if __name__ == "__main__":
    package(sys.argv[1])
