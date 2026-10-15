#!/usr/bin/env python3
"""Check release ZIPs before publishing.

Every package must contain the same game binary per architecture, record a clean
build of one commit, import glibc symbols no newer than 2.29 and contain neither
SDL2 nor files from the licensed game.
"""

import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

MAX_GLIBC = (2, 29)
OBJDUMP = {183: "aarch64-linux-gnu-objdump", 40: "arm-linux-gnueabihf-objdump"}
FORBIDDEN = re.compile(r"(^|/)(libSDL2[^/]*|[^/]*\.pkg|[^/]*\.sav|INSTALL[^/]*\.TXT)$", re.IGNORECASE)


def elf_machine(path: Path) -> int | None:
    header = path.read_bytes()[:20]
    if header[:4] != b"\x7fELF":
        return None
    return int.from_bytes(header[18:20], "little")


def glibc_versions(path: Path, machine: int) -> set[tuple[int, ...]]:
    output = subprocess.run([OBJDUMP[machine], "-T", str(path)], capture_output=True, text=True, check=True).stdout
    return {tuple(map(int, version.split("."))) for version in re.findall(r"GLIBC_([0-9.]+)", output)}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("packages", type=Path, help="Directory with the ZIPs and SHA256SUMS.")
    parser.add_argument("--commit", help="Expected base_commit in every build-info.json.")
    parser.add_argument("--count", type=int, default=7, help="Expected number of ZIPs.")
    args = parser.parse_args()
    errors = []
    archives = sorted(args.packages.glob("*.zip"))
    if len(archives) != args.count:
        errors.append(f"expected {args.count} ZIPs, found {len(archives)}")
    sums = dict(
        reversed(line.split(maxsplit=1))
        for line in (args.packages / "SHA256SUMS").read_text().splitlines()
        if line.strip()
    )
    binaries: dict[str, set[str]] = {}
    commits = set()
    newest = (0,)
    with tempfile.TemporaryDirectory() as directory:
        for archive in archives:
            if sums.get(archive.name) != hashlib.sha256(archive.read_bytes()).hexdigest():
                errors.append(f"{archive.name}: SHA256SUMS mismatch")
            target = Path(directory) / archive.stem
            with zipfile.ZipFile(archive) as zipped:
                if zipped.testzip() is not None:
                    errors.append(f"{archive.name}: corrupt archive")
                for name in zipped.namelist():
                    if FORBIDDEN.search(name):
                        errors.append(f"{archive.name}: must not contain {name}")
                zipped.extractall(target)
            for info in target.rglob("build-info.json"):
                data = json.loads(info.read_text())
                commits.add(data["base_commit"])
                if data["local_changes"]:
                    errors.append(f"{archive.name}: built from a modified tree")
            for path in target.rglob("*"):
                if not path.is_file() or path.is_symlink():
                    continue
                machine = elf_machine(path)
                if machine is None:
                    continue
                if path.name.startswith("Rangers."):
                    binaries.setdefault(path.name, set()).add(hashlib.sha256(path.read_bytes()).hexdigest())
                versions = glibc_versions(path, machine)
                if versions and max(versions) > MAX_GLIBC:
                    errors.append(f"{archive.name}: {path.relative_to(target)} needs GLIBC_{'.'.join(map(str, max(versions)))}")
                newest = max(newest, *versions)
    if len(commits) != 1 or (args.commit and commits != {args.commit}):
        errors.append(f"build commits: {sorted(commits)}")
    for name, hashes in binaries.items():
        if len(hashes) != 1:
            errors.append(f"{name} differs between packages")
    if errors:
        sys.exit("\n".join(errors))
    report = {name: hashes.pop() for name, hashes in sorted(binaries.items())}
    print(
        json.dumps(
            {"archives": len(archives), "commit": commits.pop(), "max_glibc": ".".join(map(str, newest)), "binaries": report},
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
