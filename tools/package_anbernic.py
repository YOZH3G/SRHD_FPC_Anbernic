#!/usr/bin/env python3
"""Package the listed Anbernic Linux targets using their firmware SDL."""

import argparse
import hashlib
from pathlib import Path

from package_h700 import MODELS, package


# Each model's Stock OS Mod image was checked: Ubuntu 22.04, glibc 2.35, SDL 2.28.5.
STOCK_MODELS = [
    "RG28XX",
    "RG34XX",
    "RG34XX SP",
    "RG35XX Plus",
    "RG35XX 2024",
    "RG35XX H",
    "RG35XX SP",
    "RG35XX Pro",
    "RG40XX H",
    "RG40XX V",
    "RG CubeXX",
    "RG SP",
]


TARGETS = [
    ("muOS", "H700", MODELS, "/mnt/mmc/ROMS/Ports"),
    ("KNULLI", "H700", MODELS, "/userdata/roms/ports"),
    # Anbernic's own 64-bit firmware and Stock OS Mod, started from the Apps menu.
    ("StockOS", "H700", STOCK_MODELS, "Roms/APPS"),
    (
        "ArkOS",
        "Rockchip",
        ["RG353V", "RG353VS", "RG353M", "RG351P", "RG351M", "RG351V", "RG351MP", "RG503"],
        "/roms/ports",
    ),
    ("AmberELEC", "Rockchip", ["RG351P", "RG351M", "RG351V", "RG351MP", "RG552"], "/roms/ports"),
    (
        "ROCKNIX",
        "Rockchip",
        ["RG353P", "RG353PS", "RG353V", "RG353VS", "RG353M", "RG552", "RG503"],
        "/roms/ports",
    ),
]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    archives = []
    for firmware, family, models, directory in TARGETS:
        archive = package(firmware, args.sdk_root.resolve(), args.output, models, family, directory)
        archives.append(archive)
        print(f"Packaged: {archive} ({archive.stat().st_size} bytes)", flush=True)
    (args.output / "SHA256SUMS").write_text(
        "".join(
            hashlib.sha256(path.read_bytes()).hexdigest() + "  " + path.name + "\n"
            for path in archives
        )
    )


if __name__ == "__main__":
    main()
