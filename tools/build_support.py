"""Command execution and incremental native builds shared by the build recipes."""

import hashlib
import json
import os
import re
import shutil
import subprocess
import time
from collections.abc import Callable, Iterable, Iterator
from contextlib import contextmanager
from functools import lru_cache
from pathlib import Path, PureWindowsPath

from targets import ROOT

def require_tool(name: str) -> Path:
    path = shutil.which(name)
    if path is None:
        raise FileNotFoundError(f"Required tool not found: {name}")
    # Clang and LLVM-MinGW select their mode/target from the invoked name.
    # Resolving a prefixed driver symlink would silently select another target.
    return Path(path).absolute()


def tool_identity_files(path: Path) -> tuple[Path, ...]:
    """Include Clang backends and LLVM-MinGW's shared compiler libraries."""
    path = path.absolute()
    if not re.fullmatch(r"(?:.+-)?clang(?:\+\+)?(?:-[0-9]+)?(?:\.exe)?", path.name.lower()):
        return (path,)
    backends = tuple(
        candidate
        for candidate in sorted(path.parent.glob("*"))
        if re.fullmatch(
            r"clang-[0-9]+(?:\.exe)?|libclang-cpp\.dll|libllvm-[0-9]+\.dll",
            candidate.name.lower(),
        ) and candidate.is_file()
    )
    return (path, *backends)


def build_jobs() -> int:
    """Bound parallel compiler work to keep memory use predictable."""
    return min(6, os.cpu_count() or 1)


def output(*command: str) -> str:
    # Callers parse stdout as paths, versions, or JSON. Keep diagnostics separate.
    return subprocess.check_output(command, text=True).strip()


def run_step(work: Path, name: str, command: list[str | Path]) -> None:
    """Keep each build step's output beside its generated files."""
    log = work / f"{name}.log"
    print(f"Building {name}…", flush=True)
    started = time.monotonic()
    with log.open("w") as stream:
        try:
            subprocess.run(
                [str(arg) for arg in command],
                cwd=work,
                stdout=stream,
                stderr=subprocess.STDOUT,
                check=True,
            )
        except subprocess.CalledProcessError as error:
            print("\n".join(log.read_text(errors="replace").splitlines()[-30:]))
            raise RuntimeError(f"{name} failed; see {log}") from error
    print(f"Built {name} in {time.monotonic() - started:.1f}s.", flush=True)


def command_signature(command: list[str | Path]) -> str:
    """Track arguments, executable replacement, and build-affecting environment."""
    compiler = require_tool(str(command[0]))
    environment = {
        key: os.environ.get(key)
        for key in (
            "CC",
            "CXX",
            "CFLAGS",
            "CXXFLAGS",
            "CPPFLAGS",
            "LDFLAGS",
            "CPATH",
            "C_INCLUDE_PATH",
            "CPLUS_INCLUDE_PATH",
            "LIBRARY_PATH",
            "SDKROOT",
            "MACOSX_DEPLOYMENT_TARGET",
            "EMCC_CFLAGS",
            "EMMAKEN_CFLAGS",
            "EM_CONFIG",
        )
    }
    return json.dumps(
        [
            list(map(str, command)),
            content_state(tool_identity_files(compiler)),
            environment,
        ]
    )


def _file_digest(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


@lru_cache(maxsize=128)
def _content_digest(path: Path, _metadata: tuple[int, ...]) -> str:
    # Metadata only avoids rehashing unchanged files within this process. It is
    # not part of the persistent identity: restoring an archive changes ctime.
    return _file_digest(path)


def content_state(paths: Iterable[str | Path]) -> list:
    """Inventory contents for build tools and recipes restored across runners."""
    result = []
    for path in sorted(set(map(Path, paths))):
        try:
            # Windows ctime is creation time, not a reliable change counter.
            if os.name == "nt":
                digest = _file_digest(path)
            else:
                stat = path.stat()
                metadata = (stat.st_ino, stat.st_size, stat.st_mtime_ns, stat.st_ctime_ns)
                digest = _content_digest(path, metadata)
            result.append([str(path), digest])
        except FileNotFoundError:
            result.append([str(path), None])
    return result


def file_state(paths: Iterable[str | Path]) -> list:
    """Inventory [path, size, mtime_ns, change_identity], or [path, None].

    Use contents on Windows and ctime on POSIX to catch replacements and edits
    that preserve mtime.
    """
    result = []
    for path in sorted(set(map(Path, paths))):
        try:
            stat = path.stat()
            changed = _file_digest(path) if os.name == "nt" else stat.st_ctime_ns
            result.append([str(path), stat.st_size, stat.st_mtime_ns, changed])
        except FileNotFoundError:
            result.append([str(path), None])
    return result


class BuildStamp:
    """Record success only after a step and its final signature both complete.

    Signatures are opaque strings so existing cache formats remain usable.
    A failed step leaves an empty stamp, even if old output files still exist.
    """

    def __init__(self, path: Path):
        self.path = path
        self.previous = path.read_text() if path.is_file() else ""

    def matches(self, signature: str, *outputs: Path) -> bool:
        return (
            bool(signature)
            and self.previous == signature
            and all(path.is_file() for path in outputs)
        )

    @contextmanager
    def recording(self, signature: str | Callable[[], str]) -> Iterator[None]:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text("")
        self.previous = ""
        yield
        # Depfiles and generated units are available only after the command.
        current = signature() if callable(signature) else signature
        self.path.write_text(current)
        self.previous = current


def _cmake_tool_options(options: Iterable[str]) -> dict[str, str]:
    """Read tool paths from CMake cache entries or typed/untyped -D options."""
    tools = {}
    for option in options:
        name, separator, value = option.removeprefix("-D").partition("=")
        name = name.split(":", 1)[0]
        if separator and name in (
            "CMAKE_C_COMPILER",
            "CMAKE_CXX_COMPILER",
            "CMAKE_RC_COMPILER",
            "CMAKE_TOOLCHAIN_FILE",
        ):
            tools[name] = value
    return tools


def _cmake_tool_paths(directory: Path) -> dict[str, str]:
    """Include NDK compiler paths recorded only in generated language files."""
    cache = directory / "CMakeCache.txt"
    tools = _cmake_tool_options(cache.read_text().splitlines()) if cache.is_file() else {}
    for language in ("C", "CXX", "RC"):
        name = f"CMAKE_{language}_COMPILER"
        for config in directory.glob(f"CMakeFiles/*/CMake{language}Compiler.cmake"):
            match = re.search(rf'^set\({name} "([^"]+)"\)', config.read_text(), re.MULTILINE)
            if match:
                tools.setdefault(name, match[1])
    return tools


def _tool_path_key(path: str) -> Path | PureWindowsPath:
    # Windows caches use forward slashes and may change drive-letter case.
    # Do not resolve symlinks: a prefixed Clang driver selects its target.
    windows = PureWindowsPath(path)
    return windows if windows.drive else Path(path).absolute()


def _tool_states(signature: str) -> dict:
    return {_tool_path_key(entry[0]): entry[1:] for entry in json.loads(signature)[2]}


def configure_native(work: Path, directory: Path, command: list[str | Path]) -> bool:
    """Reset CMake on changed tool paths or toolchain-file contents.

    Compiler binary changes only require cleaning objects. Return whether the
    caller needs to clean its existing native objects in either case.
    """
    stamp = BuildStamp(directory / "configure-command.json")
    cache = directory / "CMakeCache.txt"
    cached_tools = _cmake_tool_paths(directory)
    requested_tools = _cmake_tool_options(map(str, command))
    paths_changed = any(
        name in cached_tools and _tool_path_key(cached_tools[name]) != _tool_path_key(value)
        for name, value in requested_tools.items()
    )
    # Check immutable command/recipe inputs once. Only generated tool metadata
    # must be reread after configuring; avoid hashing CMake twice on Windows.
    recipe = [
        command_signature(command),
        content_state([ROOT / "native/CMakeLists.txt", *ROOT.glob("native/*.patch")]),
    ]

    def signature(tools: dict[str, str] | None = None) -> str:
        if tools is None:
            tools = _cmake_tool_paths(directory)
        # Keep the invoked path as the identity key. Reading follows symlinks,
        # so retargeting a driver changes its content identity without losing its name.
        return json.dumps(
            [
                *recipe,
                content_state(
                    identity
                    for path in tools.values()
                    if path
                    for identity in tool_identity_files(Path(path))
                ),
            ]
        )

    current = signature(cached_tools)
    if not stamp.matches(current, cache):
        try:
            old_tools = _tool_states(stamp.previous)
        except (ValueError, IndexError, KeyError, TypeError):
            old_tools = None
        # Toolchain files can change compiler selection without changing their
        # own path. Use the already captured contents to decide whether to reset.
        toolchain_changed = False
        if old_tools and (toolchain := cached_tools.get("CMAKE_TOOLCHAIN_FILE")):
            path = _tool_path_key(toolchain)
            current_tools = _tool_states(current)
            toolchain_changed = path in old_tools and old_tools[path] != current_tools.get(path)
        # Without a successful prior signature, existing CMake files can be
        # leftovers from a failed configuration and must be discarded.
        unknown_tools = old_tools is None and (cache.is_file() or stamp.path.is_file())
        fresh = paths_changed or toolchain_changed or unknown_tools
        with stamp.recording(signature):
            if fresh:
                # CMake's automatic compiler-change reset can lose other -D
                # options. Start fresh and apply the full recipe in one pass.
                # Preserve downloaded sources and other dependency caches.
                cache.unlink(missing_ok=True)
                generated = directory / "CMakeFiles"
                if generated.is_dir():
                    shutil.rmtree(generated)
            run_step(work, "configure", command)
        # Paths require a fresh configure; changed tool contents additionally
        # require cleaning objects that Make/Ninja may otherwise leave untouched.
        return fresh or (old_tools is not None and old_tools != _tool_states(stamp.previous))
    return False


def copy_if_changed(source: Path, destination: Path) -> bool:
    if destination.is_file() and source.read_bytes() == destination.read_bytes():
        return False
    shutil.copy2(source, destination)
    return True


def build_okgf(
    work: Path,
    release: bool,
    *options: str,
    rebuild: bool = False,
) -> Path:
    directory = work / "native"
    configuration = "Release" if release else "RelWithDebInfo"
    # Platform options may supply their own release flags.
    release_flags = (
        []
        if any(option.startswith("-DCMAKE_C_FLAGS_RELEASE=") for option in options)
        else ["-DCMAKE_C_FLAGS_RELEASE=-O2 -DNDEBUG"]
    )
    compiler_changed = configure_native(work, directory, [
        "cmake", "-S", ROOT / "native", "-B", directory, f"-DCMAKE_BUILD_TYPE={configuration}",
        *release_flags,
        *options,
    ])  # fmt: skip
    run_step(
        work,
        "okgf",
        [
            "cmake",
            "--build",
            directory,
            "--parallel",
            *(["--clean-first"] if rebuild or compiler_changed else []),
        ],
    )
    return directory
