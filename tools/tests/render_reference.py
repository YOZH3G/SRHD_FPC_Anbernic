#!/usr/bin/env python3
"""Compare rendering test hashes against the drawing path of a reference commit.

The point, rectangle and texture tests only compare a renderer with itself
across resets. This script builds each test twice, against the current
platform/source tree and against a reference commit, runs both on the SDL
software renderer and on Mesa OpenGL/GLES2 through the offscreen driver, and
requires identical framebuffer hashes. Run tools/build.py --release first: the
native release compiler command is reused, so only the game sources differ.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RELEASE = ROOT / ".local/linux-x86_64/release"
TESTS = ["point_blocks", "solid_rectangle", "opaque_texture"]
RENDERERS = [
    ("software", "dummy", "software"),
    ("opengl", "offscreen", "opengl"),
    ("opengles2", "offscreen", "opengles2"),
]


def build(test: str, tree: Path, output: Path) -> Path:
    command = json.loads(json.loads((RELEASE / "pascal-command.json").read_text())[0])[0]
    command = [
        str(arg).replace(str(ROOT / "source"), str(tree / "source")).replace(
            str(ROOT / "platform"), str(tree / "platform")
        )
        for arg in command[:-1]
        if not str(arg).startswith(("-FU", "-FE"))
    ]
    units = output / "units"
    if output.exists():
        shutil.rmtree(output)
    units.mkdir(parents=True)
    command += [f"-FU{units}", f"-FE{output}", "-B", str(ROOT / f"tools/tests/{test}.pas")]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode:
        errors = [line for line in result.stdout.splitlines() if "Error" in line or "Fatal" in line]
        raise RuntimeError(f"{test} failed to build against {tree}:\n" + "\n".join(errors))
    return output / test


def run(binary: Path, video: str, renderer: str) -> list[str]:
    environment = {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "LD_LIBRARY_PATH": str(RELEASE / "bin"),
        "SDL_VIDEODRIVER": video,
        "SDL_AUDIODRIVER": "dummy",
        "SDL_RENDER_DRIVER": renderer,
    }
    result = subprocess.run(
        [str(binary)], cwd=binary.parent, env=environment, capture_output=True, text=True, timeout=600
    )
    lines = result.stdout.splitlines()
    if result.returncode or not any(line.startswith("PASS") for line in lines):
        raise RuntimeError(f"{binary} failed on {renderer} (exit {result.returncode}):\n{result.stdout[-2000:]}")
    if f"RENDERER {renderer}" not in lines:
        raise RuntimeError(f"{binary} did not get the {renderer} renderer")
    return [line for line in lines if not line.startswith(("RENDERER", "PASS"))]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", default="628ca3a", help="Commit with the original drawing paths.")
    parser.add_argument("--work", type=Path, default=ROOT / ".local/render-reference")
    args = parser.parse_args()
    reference = subprocess.check_output(["git", "rev-parse", args.reference], cwd=ROOT, text=True).strip()
    tree = args.work / f"tree-{reference[:12]}"
    if not tree.is_dir():
        tree.mkdir(parents=True)
        archive = subprocess.run(
            ["git", "archive", reference, "source", "platform"], cwd=ROOT, check=True, capture_output=True
        )
        subprocess.run(["tar", "-x", "-C", str(tree)], input=archive.stdout, check=True)
    failures = 0
    for test in TESTS:
        current = build(test, ROOT, args.work / "current" / test)
        original = build(test, tree, args.work / f"reference-{reference[:12]}" / test)
        for name, video, renderer in RENDERERS:
            expected, actual = run(original, video, renderer), run(current, video, renderer)
            different = [f"  {a} != {b}" for a, b in zip(expected, actual) if a != b]
            if len(expected) != len(actual):
                different.append(f"  {len(expected)} reference lines, {len(actual)} current lines")
            status = "MATCH" if not different else "DIFFER"
            print(f"{status} {test} {name}: {len(actual)} hashes", flush=True)
            if different:
                failures += 1
                print("\n".join(different[:20]), flush=True)
    if failures:
        sys.exit(f"{failures} renderer/test combinations differ from {reference[:12]}")
    print(f"PASS: point, rectangle and texture output matches {reference[:12]} on software, OpenGL and GLES2")


if __name__ == "__main__":
    main()
