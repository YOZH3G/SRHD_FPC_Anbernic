"""Shared build options and output paths for the build and run commands."""

import argparse
import platform
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# The handhelds are built by build_linux.py; this target is the desktop build
# used for development and UI checks.
TARGETS = ("linux",)


def add_build_arguments(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--target", choices=TARGETS, default="linux")
    parser.add_argument("--release", action="store_true", help="Select the optimized build.")
    parser.add_argument("--lto", action="store_true", help="Select LLVM link-time optimization.")


def host_cpu() -> str:
    """Use the host architecture for native desktop builds."""
    machine = platform.machine().lower()
    aliases = {"amd64": "x86_64", "arm64": "aarch64"}
    cpu = aliases.get(machine, machine)
    if cpu not in ("x86_64", "aarch64"):
        raise RuntimeError(f"Unsupported desktop architecture: {machine}")
    return cpu


@dataclass(frozen=True)
class BuildConfig:
    target: str
    release: bool = False
    lto: bool = False
    root: Path = ROOT

    def __post_init__(self) -> None:
        if self.target not in TARGETS:
            raise ValueError(f"Unsupported target: {self.target}")

    @property
    def cpu(self) -> str:
        return host_cpu()

    @property
    def profile(self) -> str:
        return ("release" if self.release else "debug") + ("-lto" if self.lto else "")

    @property
    def work(self) -> Path:
        return self.root / ".local" / f"linux-{self.cpu}" / self.profile

    @property
    def binary_directory(self) -> Path:
        return self.work / "bin"

    @property
    def units(self) -> Path:
        return self.work / "units"

    @property
    def artifact(self) -> Path:
        return self.binary_directory / "Rangers"

    def create_directories(self) -> None:
        for directory in (self.binary_directory, self.units):
            directory.mkdir(parents=True, exist_ok=True)
