#!/usr/bin/env python3
"""Run the resource-backed keyboard/campaign checks in a fresh QEMU profile."""

import argparse
import hashlib
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--arch", choices=["armhf", "aarch64"], required=True)
    parser.add_argument(
        "--scenario", choices=["keyboard", "flight", "load"], required=True
    )
    parser.add_argument("--sdk-root", type=Path, required=True)
    parser.add_argument("--qemu", type=Path, required=True)
    parser.add_argument("--game-dir", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--preload", type=Path, required=True)
    parser.add_argument(
        "--video-driver", choices=["dummy", "offscreen"], default="dummy"
    )
    args = parser.parse_args()
    profile = args.profile.resolve()
    if args.scenario != "load":
        profile.mkdir(parents=True, exist_ok=False)
        (profile / "CFG.TXT").write_text(
            "VideoMode=1024,768\nWindow=False\nVSync=False\nMobileUI=2\nSkipIntro=True\nSound=True\nMusic=True\n"
        )
    else:
        assert (profile / "Save").is_dir(), (
            "Load scenario requires an existing campaign profile"
        )
    sdk_arch, triple = (
        ("armhf", "arm-linux-gnueabihf")
        if args.arch == "armhf"
        else ("arm64", "aarch64-linux-gnu")
    )
    sdk = args.sdk_root.resolve() / sdk_arch / "root"
    work = ROOT / ".local/anbernic" / sdk_arch
    game_log = profile / "########.log"
    variables = {
        "LD_LIBRARY_PATH": f"{work}/lib:{sdk}/usr/lib:{sdk}/usr/lib/{triple}:{sdk}/lib/{triple}",
        "LD_PRELOAD": str(args.preload.resolve()),
        "SDL_VIDEODRIVER": args.video_driver,
        "SDL_AUDIODRIVER": "dummy",
        "SR_TEST_LOG": str(game_log),
        "SR_TEST_DIR": str(profile),
    }
    if args.video_driver == "offscreen":
        variables.update(
            {
                "EGL_PLATFORM": "surfaceless",
                "LIBGL_ALWAYS_SOFTWARE": "1",
                "GALLIUM_DRIVER": "softpipe",
                "LIBGL_DRIVERS_PATH": str(sdk / f"usr/lib/{triple}/dri"),
            }
        )
    if args.scenario == "load":
        variables["SR_TEST_LOAD"] = "1"
    command = [str(args.qemu.resolve()), "-L", str(sdk)]
    for key, value in variables.items():
        command.extend(["-E", f"{key}={value}"])
    command.extend(
        [
            str(work / "Rangers"),
            f"--game-dir={args.game_dir.resolve()}",
            f"--user-dir={profile}",
            "--windowed" if args.video_driver == "offscreen" else "--fullscreen",
            "--renderer=sdl",
            "--on-screen-keyboard",
        ]
    )
    start = time.monotonic()
    with (profile / f"{args.scenario}-console.log").open("wb") as console:
        result = subprocess.run(
            command, stdout=console, stderr=subprocess.STDOUT, timeout=900
        )
    (profile / f"{args.scenario}-process.json").write_text(
        json.dumps(
            {
                "exit": result.returncode,
                "seconds": round(time.monotonic() - start, 1),
                "binary_sha256": hashlib.sha256(
                    (work / "Rangers").read_bytes()
                ).hexdigest(),
            }
        )
        + "\n"
    )
    assert result.returncode == 0, f"Game exited {result.returncode}; see {profile}"
    log = game_log.read_text(errors="replace")
    fallback = "SDL acceleration unavailable; using software:" in log
    renderer = next(
        line.split("=", 1)[1]
        for line in log.splitlines()
        if line.startswith("SDL renderer=")
    )
    if args.video_driver == "dummy":
        assert fallback and renderer == "software", "No automatic software fallback"
    else:
        assert not fallback and renderer.startswith("opengl"), "No SDL OpenGL renderer"
    if args.scenario == "keyboard":
        assert (profile / "newgame.txt").read_text(encoding="utf-8").splitlines()[
            0
        ] == "Name=Рейнджер Max"
        for name in [
            "keyboard-ru",
            "keyboard-en",
            "keyboard-limit",
            "committed",
            "cancelled",
        ]:
            assert (profile / f"{name}.bmp").is_file(), name
    else:
        assert (profile / "space.bmp").is_file(), "No space frame"
        assert "Rangers: run StarMap" in log
    report = {
        "arch": args.arch,
        "scenario": args.scenario,
        "exit": result.returncode,
        "seconds": round(time.monotonic() - start, 1),
        "renderer": renderer,
        "automatic_fallback": fallback,
        "video_driver": args.video_driver,
        "mesa_software_rasterizer": args.video_driver == "offscreen",
        "physical_hardware_tested": False,
        "binary_sha256": hashlib.sha256((work / "Rangers").read_bytes()).hexdigest(),
    }
    (profile / f"{args.scenario}-result.json").write_text(
        json.dumps(report, indent=2) + "\n"
    )
    print(json.dumps(report), flush=True)


if __name__ == "__main__":
    main()
