#!/usr/bin/env python3
"""Run the resource-backed keyboard/campaign checks in a fresh QEMU profile."""

import argparse
import hashlib
import json
import subprocess
import struct
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--arch", choices=["armhf", "aarch64"], required=True)
    parser.add_argument(
        "--scenario",
        choices=["keyboard", "flight", "load", "preview", "navigation"],
        required=True,
    )
    parser.add_argument("--sdk-root", type=Path, required=True)
    parser.add_argument("--qemu", type=Path, required=True)
    parser.add_argument("--game-dir", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--preload", type=Path, required=True)
    parser.add_argument(
        "--resolution", choices=["1024x768", "800x600"], default="1024x768"
    )
    parser.add_argument(
        "--video-driver", choices=["dummy", "offscreen"], default="dummy"
    )
    parser.add_argument("--renderer", choices=["sdl", "software"], default="sdl")
    parser.add_argument(
        "--firmware-root",
        type=Path,
        help="Run on a firmware root filesystem and its own SDL instead of the SDK.",
    )
    parser.add_argument(
        "--package-dir",
        type=Path,
        help="Packaged spacerangershd directory to test instead of the build output.",
    )
    args = parser.parse_args()
    profile = args.profile.resolve()
    if args.scenario not in ("load", "navigation"):
        profile.mkdir(parents=True, exist_ok=False)
        (profile / "CFG.TXT").write_text(
            f"VideoMode={args.resolution.replace('x', ',')}\nWindow=False\nVSync=False\nMobileUI=2\nSkipIntro=True\nSound=True\nMusic=True\n"
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
    binary, libraries = work / "Rangers", f"{work}/lib:{sdk}/usr/lib"
    if args.package_dir:
        package = args.package_dir.resolve()
        binary = package / f"Rangers.{args.arch}"
        libraries = f"{package / 'lib' / args.arch}:{sdk}/usr/lib"
    if args.firmware_root:
        # The build output bundles SDK SDL, so test the packaged libraries.
        assert args.package_dir, "--firmware-root requires --package-dir"
        sdk = args.firmware_root.resolve()
        # Firmware SDL comes from the multiarch directory, as the launchers arrange.
        libraries = str(package / "lib" / args.arch)
    game_log = profile / "########.log"
    variables = {
        "LD_LIBRARY_PATH": f"{libraries}:{sdk}/usr/lib/{triple}:{sdk}/lib/{triple}",
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
    if args.scenario == "preview":
        variables["SR_TEST_PREVIEW_ONLY"] = "1"
    command = [str(args.qemu.resolve()), "-L", str(sdk)]
    for key, value in variables.items():
        command.extend(["-E", f"{key}={value}"])
    command.extend(
        [
            str(binary),
            f"--game-dir={args.game_dir.resolve()}",
            f"--user-dir={profile}",
            "--windowed"
            if args.video_driver == "offscreen" or args.resolution != "1024x768"
            else "--fullscreen",
            f"--renderer={args.renderer}",
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
                "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(),
            }
        )
        + "\n"
    )
    assert result.returncode == 0, f"Game exited {result.returncode}; see {profile}"
    log = game_log.read_text(errors="replace")
    if args.resolution != "1024x768":
        assert f"Display Mode={args.resolution}" in log, (
            "Game rejected the internal mode"
        )
        expected_size = tuple(int(part) for part in args.resolution.split("x"))
        for path in profile.glob("*.bmp"):
            width, height = struct.unpack_from("<ii", path.read_bytes(), 18)
            assert (width, abs(height)) == expected_size, f"Wrong capture size: {path}"
    fallback = "SDL acceleration unavailable; using software:" in log
    renderer = next(
        line.split("=", 1)[1]
        for line in log.splitlines()
        if line.startswith("SDL renderer=")
    )
    if args.video_driver == "dummy":
        assert renderer == "software", "No software SDL renderer"
        if args.renderer == "sdl":
            assert fallback, "No automatic software fallback"
        else:
            assert not fallback, "Forced software incorrectly reported a fallback"
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
    elif args.scenario == "navigation":
        assert "NAVIGATION_OK" in (profile / "navigation-console.log").read_text(), (
            "Navigation incomplete"
        )
        for name in [
            "settings",
            "load",
            "hangar",
            "station",
            "equipment",
            "goods",
            "station-info",
            "space",
            "ship",
            "galaxy",
            "journal",
            "pause",
            "save",
            "space-return",
        ]:
            assert (profile / f"{name}.bmp").is_file(), name
    elif args.scenario == "preview":
        assert (profile / "menu.bmp").is_file() and (
            profile / "character.bmp"
        ).is_file()
    else:
        assert (profile / "space.bmp").is_file(), "No space frame"
        assert "Rangers: run StarMap" in log
    report = {
        "arch": args.arch,
        "scenario": args.scenario,
        "requested_resolution": args.resolution,
        "requested_renderer": args.renderer,
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
