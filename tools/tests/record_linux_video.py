#!/usr/bin/env python3
"""Record real AArch64 SDL frames and audio under QEMU, preserving elapsed time."""

import argparse
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--game-dir", type=Path, required=True)
    parser.add_argument("--sdk-root", type=Path, required=True)
    parser.add_argument("--qemu", type=Path, required=True)
    parser.add_argument("--preload", type=Path, required=True)
    parser.add_argument("--profile", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    profile = args.profile.resolve()
    profile.mkdir(parents=True, exist_ok=False)
    output = args.output.resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    work = ROOT / ".local/anbernic/arm64"
    sdk = args.sdk_root.resolve() / "arm64/root"
    audio = profile / "audio.s16le"
    variables = {
        "LD_LIBRARY_PATH": f"{work}/lib:{sdk}/usr/lib:{sdk}/usr/lib/aarch64-linux-gnu:{sdk}/lib/aarch64-linux-gnu",
        "LD_PRELOAD": str(args.preload.resolve()),
        "SDL_VIDEODRIVER": "dummy",
        "SDL_AUDIODRIVER": "dummy",
        "SR_TEST_LOG": str(profile / "Rangers.log"),
        "SR_VIDEO_AUDIO": str(audio),
    }
    command = [str(args.qemu.resolve()), "-L", str(sdk)]
    for name, value in variables.items():
        command.extend(["-E", f"{name}={value}"])
    command.extend(
        [
            str(work / "Rangers"),
            f"--game-dir={args.game_dir.resolve()}",
            f"--user-dir={profile}",
            "--fullscreen",
            "--renderer=software",
            "--transitions=fast",
            "--no-thumbnail-cache",
            "--on-screen-keyboard",
        ]
    )
    frames = {"latest": None, "error": None, "count": 0}
    ready = threading.Event()
    console = (profile / "console.log").open("wb")
    game = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=console)

    def read_exact(size):
        result = bytearray()
        while len(result) < size:
            data = game.stdout.read(size - len(result))
            if not data:
                if result:
                    raise RuntimeError("Incomplete captured frame")
                return None
            result.extend(data)
        return bytes(result)

    def receive():
        try:
            while header := read_exact(12):
                width, height, _tick = struct.unpack("<III", header)
                if (width, height) != (1024, 768):
                    raise RuntimeError(f"Unexpected frame size: {width}x{height}")
                frame = read_exact(width * height * 3)
                if frame is None:
                    raise RuntimeError("Missing frame pixels")
                frames["latest"] = frame
                frames["count"] += 1
                ready.set()
        except Exception as error:
            frames["error"] = error
            ready.set()

    reader = threading.Thread(target=receive, daemon=True)
    reader.start()
    encoder = None
    start = time.monotonic()
    written = 0
    try:
        while not ready.wait(0.25):
            if game.poll() is not None or time.monotonic() - start > 120:
                raise RuntimeError("Game did not produce a menu frame")
        if frames["error"]:
            raise frames["error"]
        silent = profile / "video-silent.mp4"
        encoder_log = (profile / "encoder.log").open("wb")
        encoder = subprocess.Popen(
            [
                "ffmpeg",
                "-y",
                "-loglevel",
                "error",
                "-f",
                "rawvideo",
                "-pixel_format",
                "rgb24",
                "-video_size",
                "1024x768",
                "-framerate",
                "10",
                "-i",
                "pipe:0",
                "-c:v",
                "libx264",
                "-preset",
                "veryfast",
                "-crf",
                "25",
                "-threads",
                "2",
                "-pix_fmt",
                "yuv420p",
                "-movflags",
                "+faststart",
                str(silent),
            ],
            stdin=subprocess.PIPE,
            stderr=encoder_log,
        )
        start = time.monotonic()
        while game.poll() is None or reader.is_alive():
            if frames["error"]:
                raise frames["error"]
            elapsed = time.monotonic() - start
            if elapsed > 900:
                raise RuntimeError("Game recording timed out")
            if written / 10 <= elapsed:
                encoder.stdin.write(frames["latest"])
                written += 1
            else:
                time.sleep(min(0.05, written / 10 - elapsed))
        encoder.stdin.close()
        if encoder.wait() != 0 or game.wait() != 0:
            raise RuntimeError("Game or video encoder failed")
        encoder_log.close()
        log = (profile / "Rangers.log").read_text()
        for stage in ("MainForm", "GameSettings", "Introduction", "RuinsTalk", "Hangar", "StarMap"):
            assert f"Rangers: run {stage}" in log, stage
        assert "Exception:" not in log and "Rangers: shutdown complete" in log
        if audio.is_file() and audio.stat().st_size:
            subprocess.run(
                [
                    "ffmpeg",
                    "-y",
                    "-loglevel",
                    "error",
                    "-i",
                    str(silent),
                    "-f",
                    "s16le",
                    "-ar",
                    "44100",
                    "-ac",
                    "2",
                    "-i",
                    str(audio),
                    "-c:v",
                    "copy",
                    "-c:a",
                    "aac",
                    "-b:a",
                    "128k",
                    "-af",
                    "apad",
                    "-t",
                    str(written / 10),
                    "-movflags",
                    "+faststart",
                    str(output),
                ],
                check=True,
            )
        else:
            silent.replace(output)
        report = {
            "platform": "Linux AArch64 / QEMU; SDK SDL dummy video/audio",
            "binary_sha256": hashlib.sha256((work / "Rangers").read_bytes()).hexdigest(),
            "frames": written,
            "fps": 10,
            "seconds": written / 10,
            "captured_frames": frames["count"],
            "audio": audio.is_file() and audio.stat().st_size > 0,
            "stages": [
                "menu",
                "character setup",
                "galaxy generation",
                "station",
                "hangar",
                "space",
            ],
            "cuts": False,
            "physical_hardware_tested": False,
        }
        output.with_suffix(".json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report), flush=True)
    finally:
        if game.poll() is None:
            game.kill()
        game.wait()
        if encoder and encoder.poll() is None:
            encoder.kill()
            encoder.wait()
        console.close()


if __name__ == "__main__":
    main()
