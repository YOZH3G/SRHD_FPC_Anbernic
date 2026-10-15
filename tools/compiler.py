"""Bootstrap the pinned FPC compiler and isolated platform runtimes."""

import hashlib
import json
import os
import platform
import re
import shutil
import subprocess
from dataclasses import dataclass
from pathlib import Path

from build_support import (
    BuildStamp,
    build_jobs,
    content_state,
    copy_if_changed,
    output,
    require_tool,
    run_step,
    tool_identity_files,
)
from sync_fpc import record_build_source, sync_build_source, sync_fpc
from targets import (
    ANDROID_MIN_API,
    IOS_MIN_VERSION,
    ROOT,
    BuildConfig,
    desktop_target,
    host_cpu,
    windows_triple,
)

VENDOR = ROOT / "vendor/fpc"
WORK = ROOT / ".local/fpc"
FPC_SYSTEMS = {
    "linux": "linux",
    "macos": "darwin",
    "wasm": "wasip1threads",
    "android": "android",
    "ios": "ios",
    "ios-simulator": "iphonesim",
    "switch": "switch",
    "win32": "win32",
    "win64": "win64",
}


@dataclass(frozen=True)
class CompilerPlan:
    config: BuildConfig
    toolchain: Path | None
    host_system: str
    native_cpu: str
    make: str
    bootstrap: str
    bootstrap_sdk: str | None

    @property
    def windows_host(self) -> bool:
        return self.host_system == "Windows"

    @property
    def system(self) -> str:
        return FPC_SYSTEMS[self.config.target]

    @property
    def work(self) -> Path:
        return WORK / f"{self.config.cpu}-{self.system}"


def llvm_options(clang: str | Path = "clang") -> tuple[str, ...]:
    version = subprocess.check_output([str(clang), "--version"], text=True)
    match = re.search(r"clang version (\d+)", version)
    if match is None or int(match[1]) < 14:
        raise RuntimeError("Clang 14 or newer is required for the LLVM backend.")
    # The compiler supports LLVM 17 IR; older Clang needs its own IR dialect.
    return (f"-Clv{min(int(match[1]), 17)}.0",)


def source_revision(*, runtime: bool = True, compiler: bool = True) -> str:
    """Hash compiler inputs without rereading an unchanged vendored checkout."""
    digest = hashlib.sha256()
    # Packages are compiled from VENDOR by the game build, not compiler_cycle.
    # Compiler bootstrapping uses the host RTL. Switch-only runtime edits must
    # not rebuild it, while shared or host RTL edits still invalidate it.
    rtl_names = (
        ["rtl"]
        if runtime
        else [
            str(path.relative_to(VENDOR))
            for path in sorted((VENDOR / "rtl").iterdir())
            if path.name not in ("switch", "units")
        ]
    )
    names = [
        *(["compiler"] if compiler else []),
        *rtl_names,
        *sorted(path.name for path in VENDOR.glob("Makefile*")),
    ]
    try:
        git = ["git", "-C", str(VENDOR)]
        toplevel = subprocess.check_output(
            [*git, "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL
        )
        if Path(os.fsdecode(toplevel).strip()).resolve() != VENDOR.resolve():
            raise ValueError("The vendor directory is not a Git worktree.")
        digest.update(subprocess.check_output([*git, "ls-tree", "-z", "HEAD", "--", *names]))
        digest.update(
            subprocess.check_output(
                [
                    *git,
                    "diff",
                    "--binary",
                    "--no-ext-diff",
                    "--no-textconv",
                    "HEAD",
                    "--",
                    *names,
                ]
            )
        )
        untracked = subprocess.check_output(
            [
                *git,
                "ls-files",
                "--others",
                "--exclude-standard",
                "-z",
                "--",
                *names,
            ]
        )
        for name in sorted(filter(None, untracked.split(b"\0"))):
            digest.update(name + b"\0")
            digest.update((VENDOR / os.fsdecode(name)).read_bytes())
        return digest.hexdigest()
    except (OSError, ValueError, subprocess.CalledProcessError):
        # Source archives also work without Git metadata.
        digest = hashlib.sha256()
    inputs = [path for name in names for path in (VENDOR / name).rglob("*")]
    inputs.extend(path for name in names if (path := VENDOR / name).is_file())
    for path in sorted(inputs):
        if path.is_file() and path.suffix not in (".md", ".txt"):
            digest.update(str(path.relative_to(VENDOR)).encode())
            digest.update(path.read_bytes())
    return digest.hexdigest()


def recipe_revision(
    source: str,
    command: list[str | Path],
    tools: tuple[str | Path, ...],
    *,
    inputs: tuple[Path, ...] = (),
) -> str:
    identities = content_state(
        [
            *(path for tool in tools for path in tool_identity_files(require_tool(str(tool)))),
            *inputs,
        ]
    )
    return hashlib.sha256(
        json.dumps([source, list(map(str, command)), identities]).encode()
    ).hexdigest()


def make_command(*arguments: str | Path) -> list[str]:
    """Use forward slashes in native Windows make paths and assignments."""
    command = list(map(str, arguments))
    if platform.system() == "Windows":
        command = [arg.replace("\\", "/") for arg in command]
    return command


def windows_library_options(toolchain: Path, cpu: str) -> list[str]:
    triple = windows_triple(cpu)
    driver = require_tool(str(toolchain / f"{triple}-clang"))
    builtins = Path(output(str(driver), "-print-libgcc-file-name"))
    if not builtins.is_file():
        raise FileNotFoundError(f"LLVM-MinGW compiler runtime is missing: {builtins}")
    return [f"-Fl{toolchain.parent / triple / 'lib'}", f"-Fl{builtins.parent}"]


def compiler_plan(config: BuildConfig, toolchain: Path | None) -> CompilerPlan:
    """Validate the host and bootstrap before syncing sources or probing SDKs."""
    target = config.target
    host_system = platform.system()
    native_cpu = host_cpu()
    if target in ("ios", "ios-simulator") and host_system != "Darwin":
        raise RuntimeError("iOS compilation requires macOS with Xcode installed.")
    if (
        target not in ("win32", "win64", "wasm", "android", "ios", "ios-simulator", "switch")
        and target != desktop_target()
    ):
        raise RuntimeError("Desktop builds require a host with the target OS.")
    if host_system == "Windows" and (native_cpu != "x86_64" or target not in ("win32", "win64")):
        raise RuntimeError("Native Windows builds require an x64 host and win32 or win64 target.")
    required_sdk = {
        "wasm": "WebAssembly compilation requires Emscripten's LLVM tools.",
        "android": "Android compilation requires the NDK LLVM tools.",
        "win32": "Windows compilation requires the LLVM-MinGW tools.",
        "win64": "Windows compilation requires the LLVM-MinGW tools.",
    }.get(target)
    if required_sdk and toolchain is None:
        raise RuntimeError(required_sdk)
    make = shutil.which("gmake") or shutil.which("make") or shutil.which("mingw32-make")
    if make is None:
        raise FileNotFoundError("Install GNU Make to build the vendored compiler.")
    bootstrap = shutil.which(os.environ.get("FPC_BOOTSTRAP", "fpc"))
    if bootstrap is None:
        raise FileNotFoundError("Install FPC 3.2.2 to bootstrap the vendored compiler.")
    if host_system == "Windows":
        if any(
            character.isspace()
            for path in (WORK, bootstrap, toolchain, make)
            for character in str(path)
        ):
            raise RuntimeError(
                "Windows FPC builds require checkout and toolchain paths without spaces."
            )
        identity = tuple(output(bootstrap, option) for option in ("-iV", "-iSP", "-iSO"))
        if identity != ("3.2.2", "x86_64", "win64"):
            raise RuntimeError("Set FPC_BOOTSTRAP to native Win64 FPC 3.2.2 (ppcx64.exe).")
    bootstrap_sdk = (
        output("xcrun", "--sdk", "macosx", "--show-sdk-path") if host_system == "Darwin" else None
    )
    return CompilerPlan(config, toolchain, host_system, native_cpu, make, bootstrap, bootstrap_sdk)


def compiler_target(plan: CompilerPlan) -> tuple[str, list[str]]:
    """Select a host executable and the cycle's target overrides."""
    target, cpu = plan.config.target, plan.config.cpu
    system = plan.system
    native = "ppcx64" if cpu == "x86_64" else "ppca64"
    cross = {
        "i386": "ppcross386",
        "x86_64": "ppcrossx64",
        "aarch64": "ppcrossa64",
        "wasm32": "ppcrosswasm32",
    }[cpu]
    if plan.windows_host:
        flags = [f"CPU_TARGET={cpu}", f"OS_TARGET={system}"]
        if cpu != plan.native_cpu:
            flags.append("CROSSINSTALL=1")
        return (native if cpu == plan.native_cpu else cross) + ".exe", flags
    if target in ("win32", "win64", "wasm"):
        return cross, [f"CPU_TARGET={cpu}", "CROSSINSTALL=1", f"OS_TARGET={system}"]
    if cpu != plan.native_cpu:
        if target == "switch":
            system = "linux"
        elif target in ("ios", "ios-simulator"):
            # The compiler runs on macOS; only the runtime/game target iOS.
            system = "darwin"
        return cross, [f"CPU_TARGET={cpu}", "CROSSINSTALL=1", f"OS_TARGET={system}"]
    return native, []


def bootstrap_compiler(plan: CompilerPlan) -> tuple[Path, Path, str]:
    """Build/cache the host compiler, independently of target RTL profiles."""
    config, toolchain = plan.config, plan.toolchain
    target, cpu = config.target, config.cpu
    native_cpu, windows_host = plan.native_cpu, plan.windows_host
    make, bootstrap, bootstrap_sdk = plan.make, plan.bootstrap, plan.bootstrap_sdk
    work = plan.work
    source = work / "source"
    bootstrap_clang = toolchain / "clang" if windows_host else "clang"
    bootstrap_flags = (*llvm_options(bootstrap_clang), f"-j{build_jobs()}")
    host_unwinder = None
    if windows_host:
        # Both compiler backends run on Win64, including the i386 cross compiler.
        bootstrap_flags += (
            "-Aclang-llvm",
            "-XP",
            f"-FD{toolchain}",
            "-XLL",
            *windows_library_options(toolchain, native_cpu),
        )
        host_unwinder = toolchain.parent / windows_triple(native_cpu) / "bin/libunwind.dll"
        if not host_unwinder.is_file():
            raise FileNotFoundError(f"LLVM-MinGW host unwinder is missing: {host_unwinder}")
    compiler_name, cross_flags = compiler_target(plan)
    # ARM and Win64 hosts lack binary80 Extended for Intel constant folding.
    soft_fpu = (
        " -dFPC_SOFT_FPUX80"
        if (cpu in ("i386", "x86_64") and native_cpu == "aarch64")
        or (windows_host and cpu == "i386")
        else ""
    )
    compiler = source / "compiler" / compiler_name
    compiler_command = make_command(
        make,
        "-C",
        source,
        "compiler_cycle",
        "NOWPOCYCLE=1",
        f"PP={bootstrap}",
        "OPT=-O2" + (f" -XR{bootstrap_sdk}" if bootstrap_sdk else "") + soft_fpu,
        "LLVM=1",
        "OPTNEW=" + " ".join(bootstrap_flags) + soft_fpu,
        *cross_flags,
    )
    tools = (make, bootstrap, bootstrap_clang)
    inputs = (host_unwinder,) if host_unwinder else ()
    revision = recipe_revision(
        source_revision(runtime=False), compiler_command, tools, inputs=inputs
    )
    host_revision = recipe_revision(
        source_revision(runtime=False, compiler=False), compiler_command, tools, inputs=inputs
    )
    host_stamp = BuildStamp(work / "host-runtime.stamp")
    # Local compiler development uses a single incremental compiler build after
    # the first bootstrap. Keep a separate executable as the build compiler.
    development = bool(os.environ.get("FPC_SOURCE"))
    development_bootstrap = work / "build-compiler"
    # Cross cycles leave `ppc`, the native compiler that built ppcross<cpu>.
    # Retaining it permits a single host compilation when the target changes.
    build_compiler = compiler if native_cpu == cpu else source / "compiler/ppc"
    incremental = (
        development
        and not windows_host
        and host_stamp.matches(host_revision)
        and (build_compiler.is_file() or development_bootstrap.is_file())
    )
    if incremental:
        if not development_bootstrap.is_file():
            shutil.copy2(build_compiler, development_bootstrap)
        incremental_flags = cross_flags
        if native_cpu != cpu:
            host_os = "darwin" if plan.host_system == "Darwin" else "linux"
            incremental_flags = [
                f"CPU_TARGET={native_cpu}",
                f"OS_TARGET={host_os}",
                f"PPC_TARGET={cpu}",
                f"EXENAME={compiler_name}",
                "CROSSCYCLEBOOTSTRAP=1",
                "CROSSBINDIR=",
                "BINUTILSPREFIX=",
            ]
        compiler_command = make_command(
            make,
            "-C",
            source / "compiler",
            "compiler",
            "LLVM=1",
            f"FPC={development_bootstrap}",
            "OPT=-n -B -O2 "
            + " ".join(bootstrap_flags)
            + (f" -XR{bootstrap_sdk}" if bootstrap_sdk else "")
            + soft_fpu,
            *incremental_flags,
        )
    work.mkdir(parents=True, exist_ok=True)
    stamp = BuildStamp(work / "compiler.stamp")
    unwinder_copy = compiler.with_name("libunwind.dll") if host_unwinder else None
    external_compiler = os.environ.get("FPC_COMPILER")
    if external_compiler:
        # Compiler development and regression probes share the same executable.
        # Its content participates in the RTL and game cache signatures below.
        compiler = require_tool(str(Path(external_compiler).expanduser()))
        actual = output(str(compiler), "-iTP")
        if actual != cpu:
            raise RuntimeError(f"FPC_COMPILER targets {actual}; {target} requires {cpu}.")
        source = VENDOR
    elif not stamp.matches(revision, compiler, *([unwinder_copy] if host_unwinder else [])):
        with stamp.recording(revision):
            if incremental:
                # Preserve build outputs and unchanged mtimes for FPC's unit cache.
                sync_build_source(VENDOR, source)
                # Bootstrap cycles mark compiler PPUs as released (-Ur), which
                # also makes -B ignore them. Invalidate just compiler units.
                for ppu in (source / "compiler" / cpu / "units").rglob("*.ppu"):
                    ppu.unlink()
            else:
                if source.exists():
                    shutil.rmtree(source)
                shutil.copytree(VENDOR, source, ignore=shutil.ignore_patterns(".git"))
                # Record new source files from the very first bootstrap, so
                # deleting one before the first incremental build removes it.
                record_build_source(VENDOR, source)
            if windows_host:
                # The Win64 RTL builds fpcmemdll before creating its unit directory.
                (source / "rtl/units/x86_64-win64").mkdir(parents=True, exist_ok=True)
                # LLVM-generated compiler stages need the host unwinder when run.
                copy_if_changed(host_unwinder, unwinder_copy)
            run_step(work, "compiler", compiler_command)
            if not incremental and not windows_host:
                # The build compiler and its host RTL must agree after a full
                # bootstrap. Shared/host RTL edits require another full cycle.
                shutil.copy2(build_compiler, development_bootstrap)
                with host_stamp.recording(host_revision):
                    pass

    return compiler, source, revision


def prepare_target_runtime(
    plan: CompilerPlan, compiler: Path, source: Path, revision: str
) -> list[str]:
    """Build/cache isolated RTL units and return target/package search options."""
    config, toolchain = plan.config, plan.toolchain
    target, cpu, lto = config.target, config.cpu, config.lto
    system, work = plan.system, plan.work
    apple_mobile = target in ("ios", "ios-simulator")
    windows_host = plan.windows_host
    llvm_flags = (*llvm_options(toolchain / "clang" if toolchain else "clang"), f"-j{build_jobs()}")
    if target in ("linux", "android", "switch", "win32", "win64"):
        llvm_flags += ("-Aclang-llvm",)
    if cpu == "x86_64":
        llvm_flags += ("-CpX86-64-V2", "-CfX86-64-V2")
    windows_libraries = (
        windows_library_options(toolchain, cpu) if target in ("win32", "win64") else []
    )
    sdk = plan.bootstrap_sdk
    if apple_mobile:
        sdk_name = "iphoneos" if target == "ios" else "iphonesimulator"
        sdk = output("xcrun", "--sdk", sdk_name, "--show-sdk-path")
    runtime = work / ("runtime-lto" if lto else "runtime")
    runtime_source = runtime / "src"
    units = runtime_source / "rtl/units" / f"{cpu}-{system}"
    options = [
        "-O2",
        "-OoNOFASTMATH",
        *llvm_flags,
        "-dCLASSESINLINE",
        "-dFPC_USE_SIMPLE_RANDOM",
        "-dFPC_USE_PC24_RANDOM",
        "-dFPC_USE_PC24_MATH",
    ]
    if target == "wasm":
        options += [
            "-Aclang-llvm",
            "-XP",
            f"-FD{toolchain}",
            "-dFPC_WASM_EMSCRIPTEN",
            "-dFPC_WASM_HOST_ALLOCATOR",
            "-dFPC_WASM_EMBEDDED_RUNTIME",
            "-dFPC_WASM_SEPARATE_WASI_IMPORTS",
        ]
        target_flags = [
            "CPU_TARGET=wasm32",
            "OS_TARGET=wasip1threads",
            "BINUTILSPREFIX=",
            f"CROSSBINDIR={toolchain}",
        ]
    elif target in ("win32", "win64"):
        options += ["-XP", f"-FD{toolchain}", "-XLL", *windows_libraries]
        target_flags = [
            f"CPU_TARGET={cpu}",
            f"OS_TARGET={system}",
            "BINUTILSPREFIX=",
            f"CROSSBINDIR={toolchain}",
        ]
    elif target == "android":
        options += ["-Cg", "-XP", f"-FD{toolchain}"]
        target_flags = [
            "CPU_TARGET=aarch64",
            "OS_TARGET=android",
            "BINUTILSPREFIX=",
            f"CROSSBINDIR={toolchain}",
            "LOADERS=",
        ]
    elif target == "macos":
        options += ["-Aclang-llvm-darwin", f"-XR{sdk}"]
        target_flags = []
    elif apple_mobile:
        options += ["-Aclang-llvm-darwin", f"-T{system}", f"-XR{sdk}", f"-WP{IOS_MIN_VERSION}"]
        target_flags = [f"CPU_TARGET={cpu}", f"OS_TARGET={system}"]
    else:
        target_flags = [f"CPU_TARGET={cpu}", "OS_TARGET=linux"]
    if lto:
        options.append("-Clflto")
    stamp = BuildStamp(runtime / "runtime.stamp")
    runtime_command = make_command(
        plan.make,
        "-C",
        runtime_source / "rtl",
        "all",
        *target_flags,
        f"FPC={compiler}",
        "OPT=" + " ".join(options),
    )
    runtime_revision = recipe_revision(
        # The startup assembly below also depends on the Android API level.
        f"{revision}:{ANDROID_MIN_API}" if target == "android" else revision,
        runtime_command,
        (compiler, toolchain / "clang" if toolchain else "clang"),
    )
    runtime_outputs = [units / "classes.ppu"]
    if target == "android":
        runtime_outputs += [units / "prt0.o", units / "dllprt0.o"]
    if not stamp.matches(runtime_revision, *runtime_outputs):
        with stamp.recording(runtime_revision):
            if runtime_source.exists():
                shutil.rmtree(runtime_source)
            # Do not alter the native RTL used to bootstrap the compiler. Each
            # runtime profile starts from source and gets its own PPUs/objects.
            shutil.copytree(
                VENDOR / "rtl",
                runtime_source / "rtl",
                ignore=shutil.ignore_patterns("units"),
            )
            # Cross RTL Makefiles discover FPCFPMAKE via ../compiler/ppc;
            # Linux also queries it when selecting host GCC library paths.
            # Windows RTL all uses only the explicit FPC= and needs no symlink.
            if not windows_host:
                (runtime_source / "compiler").symlink_to(
                    source / "compiler", target_is_directory=True
                )
            units.mkdir(parents=True, exist_ok=True)
            if target == "android":
                # NDK clang replaces GNU as for these tiny startup objects.
                for name in ("prt0", "dllprt0"):
                    run_step(
                        runtime,
                        name,
                        [
                            toolchain / "clang",
                            f"--target=aarch64-linux-android{ANDROID_MIN_API}",
                            "-x",
                            "assembler",
                            "-Wa,-defsym,CPU64=1",
                            "-c",
                            source / f"rtl/android/{name}.as",
                            "-o",
                            units / f"{name}.o",
                        ],
                    )
            run_step(runtime, "runtime", runtime_command)

    packages = VENDOR / "packages"
    paths = [
        units,
        packages / "rtl-objpas/src/inc",
        packages / "fcl-base/src",
        packages / "pthreads/src",
        packages / "fcl-process/src",
        *([packages / "fcl-registry/src"] if target in ("win32", "win64") else []),
        *(
            [packages / "rtl-unicode/src/inc"]
            if target in ("wasm", "android", "ios", "ios-simulator")
            else []
        ),
    ]
    return [
        "-n", *llvm_flags, *(["-Clflto"] if lto else []),
        *(["-XLL"] if target in ("linux", "android") else []),
        *([f"-T{system}", "-XP", f"-FD{toolchain}", "-XLL", *windows_libraries] if target in ("win32", "win64") else []),
        *(["-Tandroid", "-Cg", "-XP", f"-FD{toolchain}"] if target == "android" else []),
        *([f"-T{system}", f"-XR{sdk}", f"-WP{IOS_MIN_VERSION}", "-Aclang-llvm-darwin"] if apple_mobile else []),
        *(["-Twasip1threads", "-dFPC_WASM_EMSCRIPTEN", "-Aclang-llvm", "-XP", f"-FD{toolchain}"] if target == "wasm" else []),
        *(f"-Fu{path}" for path in paths),
        f"-Fi{packages}/fcl-process/src/" + ("win" if target in ("win32", "win64") else "unix"),
    ]  # fmt: skip


def prepare_compiler(
    config: BuildConfig,
    toolchain: Path | None = None,
) -> tuple[Path, list[str]]:
    """Build the LLVM compiler and the game's Delphi-compatible runtime."""
    plan = compiler_plan(config, toolchain)
    if local_source := os.environ.get("FPC_SOURCE"):
        sync_fpc(Path(local_source))
    if not (VENDOR / "compiler/pp.pas").is_file():
        raise FileNotFoundError(
            "Initialize dependencies with: git submodule update --init --recursive"
        )
    compiler, source, revision = bootstrap_compiler(plan)
    if config.target == "switch":
        from switch import prepare_runtime

        return prepare_runtime(compiler, toolchain, source_revision())
    return compiler, prepare_target_runtime(plan, compiler, source, revision)
