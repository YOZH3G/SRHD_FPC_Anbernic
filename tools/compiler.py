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
    output,
    require_tool,
    run_step,
    tool_identity_files,
)
from sync_fpc import record_build_source, sync_build_source, sync_fpc
from targets import ROOT, BuildConfig

VENDOR = ROOT / "vendor/fpc"
WORK = ROOT / ".local/fpc"


@dataclass(frozen=True)
class CompilerPlan:
    config: BuildConfig
    make: str
    bootstrap: str

    @property
    def system(self) -> str:
        return "linux"

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
    return list(map(str, arguments))


def compiler_plan(config: BuildConfig) -> CompilerPlan:
    """Validate the host and bootstrap before syncing sources."""
    if platform.system() != "Linux":
        raise RuntimeError("The game builds on a Linux host.")
    make = shutil.which("gmake") or shutil.which("make")
    if make is None:
        raise FileNotFoundError("Install GNU Make to build the vendored compiler.")
    bootstrap = shutil.which(os.environ.get("FPC_BOOTSTRAP", "fpc"))
    if bootstrap is None:
        raise FileNotFoundError("Install FPC 3.2.2 to bootstrap the vendored compiler.")
    return CompilerPlan(config, make, bootstrap)


def bootstrap_compiler(plan: CompilerPlan) -> tuple[Path, Path, str]:
    """Build/cache the host compiler, independently of target RTL profiles."""
    cpu = plan.config.cpu
    make, bootstrap = plan.make, plan.bootstrap
    work = plan.work
    source = work / "source"
    bootstrap_flags = (*llvm_options(), f"-j{build_jobs()}")
    compiler_name = "ppcx64" if cpu == "x86_64" else "ppca64"
    compiler = source / "compiler" / compiler_name
    compiler_command = make_command(
        make,
        "-C",
        source,
        "compiler_cycle",
        "NOWPOCYCLE=1",
        f"PP={bootstrap}",
        "OPT=-O2",
        "LLVM=1",
        "OPTNEW=" + " ".join(bootstrap_flags),
    )
    tools = (make, bootstrap, "clang")
    revision = recipe_revision(source_revision(runtime=False), compiler_command, tools)
    host_revision = recipe_revision(
        source_revision(runtime=False, compiler=False), compiler_command, tools
    )
    host_stamp = BuildStamp(work / "host-runtime.stamp")
    # Local compiler development uses a single incremental compiler build after
    # the first bootstrap. Keep a separate executable as the build compiler.
    development = bool(os.environ.get("FPC_SOURCE"))
    development_bootstrap = work / "build-compiler"
    incremental = (
        development
        and host_stamp.matches(host_revision)
        and (compiler.is_file() or development_bootstrap.is_file())
    )
    if incremental:
        if not development_bootstrap.is_file():
            shutil.copy2(compiler, development_bootstrap)
        compiler_command = make_command(
            make,
            "-C",
            source / "compiler",
            "compiler",
            "LLVM=1",
            f"FPC={development_bootstrap}",
            "OPT=-n -B -O2 " + " ".join(bootstrap_flags),
        )
    work.mkdir(parents=True, exist_ok=True)
    stamp = BuildStamp(work / "compiler.stamp")
    external_compiler = os.environ.get("FPC_COMPILER")
    if external_compiler:
        # Compiler development and regression probes share the same executable.
        # Its content participates in the RTL and game cache signatures below.
        compiler = require_tool(str(Path(external_compiler).expanduser()))
        actual = output(str(compiler), "-iTP")
        if actual != cpu:
            raise RuntimeError(f"FPC_COMPILER targets {actual}; the build requires {cpu}.")
        source = VENDOR
    elif not stamp.matches(revision, compiler):
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
            run_step(work, "compiler", compiler_command)
            if not incremental:
                # The build compiler and its host RTL must agree after a full
                # bootstrap. Shared/host RTL edits require another full cycle.
                shutil.copy2(compiler, development_bootstrap)
                with host_stamp.recording(host_revision):
                    pass

    return compiler, source, revision


def prepare_target_runtime(
    plan: CompilerPlan, compiler: Path, source: Path, revision: str
) -> list[str]:
    """Build/cache isolated RTL units and return target/package search options."""
    cpu, lto = plan.config.cpu, plan.config.lto
    system, work = plan.system, plan.work
    llvm_flags = (*llvm_options(), f"-j{build_jobs()}", "-Aclang-llvm")
    if cpu == "x86_64":
        llvm_flags += ("-CpX86-64-V2", "-CfX86-64-V2")
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
    runtime_revision = recipe_revision(revision, runtime_command, (compiler, "clang"))
    if not stamp.matches(runtime_revision, units / "classes.ppu"):
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
            # The RTL Makefiles discover FPCFPMAKE via ../compiler/ppc and
            # query it when selecting host GCC library paths.
            (runtime_source / "compiler").symlink_to(source / "compiler", target_is_directory=True)
            units.mkdir(parents=True, exist_ok=True)
            run_step(runtime, "runtime", runtime_command)

    packages = VENDOR / "packages"
    paths = [
        units,
        packages / "rtl-objpas/src/inc",
        packages / "fcl-base/src",
        packages / "pthreads/src",
        packages / "fcl-process/src",
    ]
    return [
        "-n", *llvm_flags, *(["-Clflto"] if lto else []), "-XLL",
        *(f"-Fu{path}" for path in paths),
        f"-Fi{packages}/fcl-process/src/unix",
    ]  # fmt: skip


def prepare_compiler(config: BuildConfig) -> tuple[Path, list[str]]:
    """Build the LLVM compiler and the game's Delphi-compatible runtime."""
    plan = compiler_plan(config)
    if local_source := os.environ.get("FPC_SOURCE"):
        sync_fpc(Path(local_source))
    if not (VENDOR / "compiler/pp.pas").is_file():
        raise FileNotFoundError(
            "Initialize dependencies with: git submodule update --init --recursive"
        )
    compiler, source, revision = bootstrap_compiler(plan)
    return compiler, prepare_target_runtime(plan, compiler, source, revision)
