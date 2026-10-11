#!/usr/bin/env python3
"""Mirror a local fpc_sr checkout into vendor/fpc without changing its Git metadata."""

import argparse
import hashlib
import json
import os
import shutil
import subprocess
from pathlib import Path

from targets import ROOT

SOURCE_PATHS = ("compiler", "rtl", "packages", "Makefile", "Makefile.fpc", "PORT.md")


def file_identity(data: bytes | None, executable: bool = False) -> dict | None:
    if data is None:
        return None
    return {"hash": hashlib.sha256(data).hexdigest(), "executable": executable}


def sync_fpc(source: Path) -> None:
    source = source.expanduser().resolve()
    vendor = ROOT / "vendor/fpc"
    if source == vendor.resolve():
        return
    if not (source / "compiler/pp.pas").is_file():
        raise FileNotFoundError(f"Not an FPC source checkout: {source}")
    state_path = ROOT / ".local/fpc-sync.json"
    state = json.loads(state_path.read_text()) if state_path.exists() else {}
    git = ["git", "-C", str(source)]
    base = subprocess.check_output(
        ["git", "-C", str(vendor), "rev-parse", "HEAD"], text=True
    ).strip()
    # Compare against the pinned base, including uncommitted edits. This avoids
    # reading the entire FPC tree on every ordinary game build.
    names = subprocess.check_output(
        [
            *git,
            "diff",
            "--name-only",
            "--no-renames",
            "-z",
            base,
            "--",
            *SOURCE_PATHS,
        ]
    ).split(b"\0")
    names += subprocess.check_output(
        [
            *git,
            "ls-files",
            "-z",
            "--others",
            "--exclude-standard",
            "--",
            *SOURCE_PATHS,
        ]
    ).split(b"\0")
    names += subprocess.check_output(
        [
            "git",
            "-C",
            str(vendor),
            "diff",
            "--name-only",
            "--no-renames",
            "-z",
            "HEAD",
            "--",
            *SOURCE_PATHS,
        ]
    ).split(b"\0")
    names = set(filter(None, map(os.fsdecode, names)))
    # Include files created by a prior sync and then removed at the source.
    names.update(name for name in state if not (source / name).exists())
    changes = []
    next_state = {}
    for name in sorted(names):
        relative = Path(name)
        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(f"Invalid source path: {name}")
        src, dst = source / relative, vendor / relative
        desired = src.read_bytes() if src.is_file() else None
        current = dst.read_bytes() if dst.is_file() else None
        wanted = file_identity(
            desired, bool(src.stat().st_mode & 0o111) if desired is not None else False
        )
        present = file_identity(
            current, bool(dst.stat().st_mode & 0o111) if current is not None else False
        )
        next_state[name] = wanted
        if wanted == present:
            continue
        if name in state:
            expected = state[name]
        else:
            baseline = subprocess.run(
                ["git", "-C", str(vendor), "show", f"HEAD:{name}"],
                capture_output=True,
                check=False,
            )
            entry = subprocess.check_output(
                ["git", "-C", str(vendor), "ls-tree", "HEAD", "--", name]
            )
            expected = file_identity(
                baseline.stdout if baseline.returncode == 0 else None,
                entry.startswith(b"100755 "),
            )
        if present != expected:
            raise RuntimeError(f"Local vendor edit conflicts with FPC source sync: {name}")
        changes.append((src, dst, desired))
    # Check all conflicts before changing any files.
    for src, dst, data in changes:
        if data is None:
            dst.unlink(missing_ok=True)
        else:
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(data)
            shutil.copymode(src, dst)
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(next_state, sort_keys=True))
    if changes:
        print(f"Synced {len(changes)} FPC source files into vendor/fpc.", flush=True)


def build_source_files(vendor: Path) -> set[str]:
    """Inventory checkout sources, or files in a source archive without Git."""
    git = ["git", "-C", str(vendor)]
    try:
        root = subprocess.check_output(
            [*git, "rev-parse", "--show-toplevel"], stderr=subprocess.DEVNULL
        )
    except (OSError, subprocess.CalledProcessError):
        root = b""
    if root and Path(os.fsdecode(root).strip()).resolve() == vendor.resolve():
        paths = subprocess.check_output(
            [
                *git,
                "ls-files",
                "-z",
                "--cached",
                "--others",
                "--exclude-standard",
                "--",
                *SOURCE_PATHS,
            ]
        ).split(b"\0")
        return {os.fsdecode(name) for name in paths if name}
    # Archives can be nested inside the game's Git worktree. Do not mistake
    # the enclosing repository for the FPC checkout or omit its ignored files.
    return {
        str(path.relative_to(vendor))
        for name in SOURCE_PATHS
        for path in ([vendor / name] if (vendor / name).is_file() else (vendor / name).rglob("*"))
        if path.is_file()
    }


def record_build_source(vendor: Path, destination: Path) -> None:
    """Seed the source inventory after copying a fresh bootstrap tree."""
    (destination / ".source-sync.json").write_text(json.dumps(sorted(build_source_files(vendor))))


def sync_build_source(vendor: Path, destination: Path) -> None:
    """Refresh compiler source without replacing generated objects or PPUs."""
    names = build_source_files(vendor)
    manifest = destination / ".source-sync.json"
    previous = set(json.loads(manifest.read_text())) if manifest.is_file() else set()
    for name in previous - names:
        (destination / name).unlink(missing_ok=True)
    for name in sorted(names):
        src, dst = vendor / name, destination / name
        if not src.is_file():
            dst.unlink(missing_ok=True)
        elif (
            not dst.is_file()
            or src.read_bytes() != dst.read_bytes()
            or (src.stat().st_mode & 0o111) != (dst.stat().st_mode & 0o111)
        ):
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, dst)
    manifest.write_text(json.dumps(sorted(names)))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, nargs="?", default=ROOT.parent / "fpc_sr")
    sync_fpc(parser.parse_args().source)
