#!/usr/bin/env python3
"""Run the Linux desktop build of the game."""

import argparse
import os
from pathlib import Path

from targets import ROOT, BuildConfig, add_build_arguments


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    add_build_arguments(parser)
    parser.add_argument(
        "--game-dir",
        type=Path,
        help="Game asset directory; defaults to game/.",
    )
    args, game_options = parser.parse_known_args()
    try:
        config = BuildConfig(args.target, args.release, args.lto)
    except ValueError as error:
        parser.error(str(error))
    game_directory = (args.game_dir or ROOT / "game").expanduser().resolve()
    if not game_directory.is_dir():
        parser.error(f"Game asset directory does not exist: {game_directory}")
    try:
        binary = config.binary_directory / "Rangers"
    except RuntimeError as error:
        parser.error(str(error))
    if not binary.is_file():
        parser.error(
            "Run ./tools/build.py first, with matching --target, --release and --lto options."
        )
    command = [str(binary), f"--game-dir={game_directory}", *game_options]
    try:
        os.execv(binary, command)
    except OSError as error:
        parser.exit(1, f"Cannot start the game: {error}\n")


if __name__ == "__main__":
    main()
