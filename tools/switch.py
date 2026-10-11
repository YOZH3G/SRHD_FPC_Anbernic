"""Nintendo Switch homebrew build using FPC LLVM and devkitPro/libnx."""

import json
import os
import shlex
from pathlib import Path

from build_support import (
    BuildStamp,
    build_jobs,
    build_okgf,
    compile_native,
    content_state,
    link_native,
    require_tool,
    run_step,
)
from targets import PACKAGE_VERSION, ROOT, BuildConfig

# Select devkitA64's PIC multilib consistently for compilation and linking.
MACHINE_FLAGS = ("-fPIE", "-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft")
C_FLAGS = (
    "-O2",
    "-g",
    "-ffunction-sections",
    "-fdata-sections",
    *MACHINE_FLAGS,
    "-ftls-model=local-exec",
    "-D__SWITCH__",
)


def sdk_root() -> Path:
    root = Path(os.environ.get("DEVKITPRO", "/opt/devkitpro"))
    if not (root / "libnx/switch.specs").is_file():
        raise FileNotFoundError(
            "Install devkitPro switch-dev and Switch portlibs; set DEVKITPRO if needed."
        )
    os.environ.setdefault("DEVKITPRO", str(root))
    return root


def prepare_runtime(
    compiler: Path, toolchain: Path | None, revision: str
) -> tuple[Path, list[str]]:
    from compiler import VENDOR, WORK, llvm_options

    clang = require_tool(str(toolchain / "clang") if toolchain else "clang")
    runtime = WORK / "aarch64-switch/runtime"
    units = runtime / "units"
    units.mkdir(parents=True, exist_ok=True)
    rtl = VENDOR / "rtl"
    paths = [
        rtl / "switch",
        rtl / "inc",
        rtl / "aarch64",
        rtl / "common",
        rtl / "objpas",
        *sorted(p for p in (rtl / "objpas").iterdir() if p.is_dir()),
        rtl / "charmaps",
        VENDOR / "packages/rtl-objpas/src/inc",
    ]
    flags = [
        "-n",
        "-Tswitch",
        "-Aclang-llvm",
        "-Cg",
        "-XP",
        f"-FD{clang.parent}",
        *llvm_options(clang),
        f"-j{build_jobs()}",
        "-O2",
        "-OoNOFASTMATH",
        "-dCLASSESINLINE",
        "-dFPC_USE_SIMPLE_RANDOM",
        "-dFPC_USE_PC24_RANDOM",
        "-dFPC_USE_PC24_MATH",
    ]
    build_flags = [
        *flags,
        # Keep RTL source locations in the ELF used for host symbolization.
        "-gw3",
        "-Ur",
        f"-FU{units}",
        f"-FE{units}",
        f"-Fu{units}",
        *(f"-Fi{p}" for p in paths),
        *(f"-Fu{p}" for p in paths),
    ]
    stamp = BuildStamp(runtime / "runtime.stamp")
    sdk = sdk_root()
    gcc = sdk / "devkitA64/bin/aarch64-none-elf-gcc"
    bridges = []
    for name in ("nxlibc", "nx_start", "nxthread"):
        obj = units / f"{name}.o"
        compile_native(
            runtime,
            [
                gcc,
                *C_FLAGS,
                "-D_GNU_SOURCE",
                f"-I{sdk}/libnx/include",
                "-c",
                rtl / f"switch/{name}.c",
                "-o",
                obj,
            ],
            False,
        )
        bridges.append(obj)
    signature = json.dumps([revision, build_flags, content_state([compiler, clang, *bridges])])
    if not stamp.matches(signature, units / "classes.ppu", units / "nxthreads.ppu"):
        with stamp.recording(signature):
            # The RTL owns this directory; released PPUs must never mask source changes.
            for ppu in units.glob("*.ppu"):
                ppu.unlink()
            run_step(runtime, "system", [compiler, *build_flags, "-Us", rtl / "switch/system.pp"])
            run_step(runtime, "runtime", [compiler, *build_flags, rtl / "switch/buildrtl.pp"])
    packages = VENDOR / "packages"
    return compiler, [
        *flags,
        f"-Fu{units}",
        f"-Fu{packages}/rtl-objpas/src/inc",
        f"-Fu{packages}/fcl-base/src",
        f"-Fu{packages}/rtl-unicode/src/inc",
    ]


def build_switch(config: BuildConfig, rebuild: bool) -> Path:
    from compiler import prepare_compiler
    from pascal import build_paszlib, compile_pascal, pascal_flags

    sdk = sdk_root()
    gcc = sdk / "devkitA64/bin/aarch64-none-elf-gcc"
    config.create_directories()
    work, binary, units = config.work, config.binary_directory, config.units
    compiler, flags = prepare_compiler(config)
    paszlib = build_paszlib(work, compiler, flags, rebuild)
    native = build_okgf(
        work,
        config.release,
        "-DBUILD_SHARED_LIBS=OFF",
        f"-DCMAKE_TOOLCHAIN_FILE={sdk}/cmake/Switch.cmake",
        rebuild=rebuild,
        jobs=build_jobs(),
    )
    # NROs contain no ELF/DWARF sections for the runtime line-info reader.
    # Preserve DWARF in Rangers.elf for host-side crash symbolization instead.
    game_flags = [flag for flag in pascal_flags(config.release, paszlib) if flag != "-gl"]
    compile_pascal(
        work,
        [
            compiler,
            *flags,
            *game_flags,
            "-gw3",
            "-Cn",
            f"-FU{units}",
            f"-FE{binary}",
            ROOT / "source/Rangers.dpr",
        ],
        rebuild,
        binary / "ppas.sh",
    )
    platform = ROOT / "platform/switch"
    native_objects = []
    for source in sorted(platform.glob("*.c")):
        obj = work / (source.stem + ".o")
        compile_native(
            work,
            [
                gcc,
                *C_FLAGS,
                f"-I{sdk}/libnx/include",
                f"-I{sdk}/portlibs/switch/include/SDL2",
                "-c",
                source,
                "-o",
                obj,
            ],
            rebuild,
        )
        native_objects.append(obj)
    # Extend FPC's link recipe with native dependencies. Its search paths,
    # {$linklib} entries, machine flags and explicit -k options stay intact.
    link_command, response_path = pascal_link_command(
        binary / "ppas.sh",
        work,
        ("EGL", "glapi", "drm_nouveau", "jpeg", "png", "z", "stdc++", "pthread"),
    )
    objects = [
        (work / arg).resolve()
        for arg in link_command[1:]
        if not arg.startswith("-") and arg.endswith((".o", ".a"))
    ]
    if not objects:
        raise RuntimeError("FPC did not write its Switch object list.")
    elf = binary / "Rangers.elf"
    sdk_libraries = [
        sdk / "libnx/switch.specs",
        sdk / "libnx/switch.ld",
        *sorted((sdk / "libnx/lib").glob("*.a")),
        *sorted((sdk / "portlibs/switch/lib").glob("*.a")),
        *sorted((sdk / "devkitA64/aarch64-none-elf/lib/pic").glob("*.a")),
        # Also track archives supplied by Pascal units outside the SDK.
        *(
            archive
            for arg in link_command
            if arg.startswith("-L")
            for archive in sorted((work / arg[2:]).glob("*.a"))
        ),
    ]
    link_native(
        work,
        [
            link_command[0],
            "-g",
            *native_objects,
            f"-L{native}",
            *link_command[1:],
            f"-Wl,-Map,{binary}/Rangers.map",
        ],
        [*objects, *native_objects, native / "libokgf.a", *sdk_libraries],
        [elf],
        rebuild,
    )
    # -Cn intentionally retains its active response for incremental relinks.
    # Each compilation writes a new PID-named file; older ones are obsolete.
    for obsolete in binary.glob("link[0-9]*.res"):
        if obsolete.resolve() != response_path.resolve():
            obsolete.unlink()
    nacp = binary / "Rangers.nacp"
    stamp = BuildStamp(work / "package.stamp")
    package_signature = json.dumps(
        [
            PACKAGE_VERSION,
            content_state(
                [elf, Path(__file__), sdk / "tools/bin/elf2nro", sdk / "tools/bin/nacptool"]
            ),
        ]
    )
    if not stamp.matches(package_signature, config.artifact, nacp):
        with stamp.recording(package_signature):
            run_step(
                work,
                "nacp",
                [
                    sdk / "tools/bin/nacptool",
                    "--create",
                    "Space Rangers HD",
                    "SpaceRangersHD_FPC contributors",
                    PACKAGE_VERSION,
                    nacp,
                ],
            )
            run_step(
                work, "nro", [sdk / "tools/bin/elf2nro", elf, config.artifact, f"--nacp={nacp}"]
            )
    return config.artifact


def pascal_link_command(
    script: Path, work: Path, libraries: tuple[str, ...]
) -> tuple[list[str], Path]:
    # ppas.sh sets IFS to a quoted newline. Parse only the compiler command,
    # rather than treating each line of the surrounding shell as a command.
    for line in script.read_text().splitlines():
        if "aarch64-none-elf-gcc" not in line:
            continue
        words = shlex.split(line)
        if words and Path(words[0]).name == "env":
            # The compiler records DEVKITPRO for standalone ppas.sh use.
            # sdk_root() already supplies it to this build's subprocesses.
            words = words[2:]
        if not words or Path(words[0]).name != "aarch64-none-elf-gcc":
            continue
        for index, arg in enumerate(words[1:], 1):
            if arg.startswith("@"):
                response_path = work / arg[1:]
                response = shlex.split(response_path.read_text())
                # Keep the native libraries in FPC's rescan group, since SDL,
                # the codecs and the game may reference one another.
                end = response.index("-Wl,--end-group")
                response[end:end] = [f"-l{name}" for name in libraries]
                words[index : index + 1] = response
                return words, response_path
    raise RuntimeError("FPC did not write a Switch linker response file.")


def run_switch(
    config: BuildConfig, game_directory: Path, emulator: str | None, profile: Path | None
) -> None:
    import shutil
    import subprocess

    if not config.artifact.is_file():
        raise FileNotFoundError("Build with ./tools/build.py --target=switch first.")
    emulator = emulator or os.environ.get("SWITCH_EMULATOR") or shutil.which("Ryujinx")
    if not emulator and Path("/Applications/Ryujinx.app/Contents/MacOS/Ryujinx").is_file():
        emulator = "/Applications/Ryujinx.app/Contents/MacOS/Ryujinx"
    if not emulator:
        raise FileNotFoundError(
            "Set SWITCH_EMULATOR or pass --emulator with a Ryujinx-compatible executable."
        )
    if profile is None and os.environ.get("SWITCH_EMULATOR_ROOT"):
        profile = Path(os.environ["SWITCH_EMULATOR_ROOT"])
    if profile is None:
        raise ValueError("Pass --emulator-root with your configured development emulator profile.")
    profile = profile.expanduser().resolve()
    if not (profile / "Config.json").is_file():
        raise FileNotFoundError(
            "The emulator profile must already be configured (Config.json is missing)."
        )
    sd_game = profile / "sdcard/switch/SpaceRangersHD/game"
    sd_game.parent.mkdir(parents=True, exist_ok=True)
    if sd_game.is_symlink() and sd_game.resolve() != game_directory:
        raise ValueError(f"Emulator assets already point elsewhere: {sd_game}")
    if not sd_game.exists():
        sd_game.symlink_to(game_directory, target_is_directory=True)
    elif sd_game.resolve() != game_directory:
        raise ValueError(f"Emulator assets already exist: {sd_game}")
    subprocess.run([emulator, "--root-data-dir", str(profile), str(config.artifact)], check=True)
