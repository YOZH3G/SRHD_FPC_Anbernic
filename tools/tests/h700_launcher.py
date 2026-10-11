#!/usr/bin/env python3
"""Exercise H700 launcher decisions without firmware or proprietary assets."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]


class LauncherTests(unittest.TestCase):
    def run_launcher(self, bits="64", fallback="aarch64", assets=True, arches=("armhf", "aarch64")):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            port = root / "spacerangershd"
            port.mkdir()
            (port / "game").mkdir()
            if assets:
                (port / "game/INSTALL.TXT").touch()
            launch = root / "Space Rangers HD.sh"
            shutil.copy2(ROOT / "platform/linux/Space Rangers HD PortMaster.sh", launch)
            pm = root / "PortMaster"
            pm.mkdir()
            (pm / "control.txt").write_text(
                "CFW_NAME=muOS\nGPTOKEYB=/bin/true\n"
                'get_controls() { sdl_controllerconfig="test-controller"; }\n'
                'pm_platform_helper() { echo "HELPER:$1"; }\n'
            )
            fake_bin = root / "bin"
            fake_bin.mkdir()
            getconf = fake_bin / "getconf"
            getconf.write_text('#!/bin/bash\n[ -n "$TEST_BITS" ] || exit 1\necho "$TEST_BITS"\n')
            getconf.chmod(0o755)
            for arch in arches:
                (port / "lib" / arch).mkdir(parents=True)
                binary = port / f"Rangers.{arch}"
                binary.write_text(
                    '#!/bin/bash\necho "EXEC:$0"\n'
                    'echo "ARGS:$*"\necho "LIBS:$LD_LIBRARY_PATH"\n'
                    'echo "CONTROLS:$SDL_GAMECONTROLLERCONFIG"\nexit 23\n'
                )
                binary.chmod(0o755)
                probe = port / f"check-platform.{arch}"
                probe.write_text(f'#!/bin/bash\necho "PROBE:{arch}"\n')
                probe.chmod(0o755)
            env = os.environ.copy()
            env.update(
                PORTMASTER_DIR=str(pm),
                TEST_BITS=bits,
                DEVICE_ARCH=fallback,
                PATH=f"{fake_bin}:{env['PATH']}",
                SDL_GAMECONTROLLERCONFIG="old-controller",
            )
            result = subprocess.run(["bash", str(launch)], env=env, capture_output=True, text=True)
            return result

    def test_64_bit(self):
        result = self.run_launcher()
        self.assertEqual(result.returncode, 23, result.stdout + result.stderr)
        self.assertIn("EXEC:./Rangers.aarch64", result.stdout)
        self.assertIn("--fullscreen", result.stdout)
        self.assertIn("--on-screen-keyboard", result.stdout)
        self.assertIn("CONTROLS:test-controller", result.stdout)
        self.assertIn("/lib/aarch64", result.stdout)
        self.assertIn("HELPER:Rangers.aarch64", result.stdout)

    def test_32_bit_userland_overrides_64_bit_kernel(self):
        result = self.run_launcher(bits="32", fallback="aarch64")
        self.assertEqual(result.returncode, 23, result.stdout + result.stderr)
        self.assertIn("EXEC:./Rangers.armhf", result.stdout)
        self.assertIn("/usr/lib32:/lib32", result.stdout)

    def test_architecture_fallback(self):
        result = self.run_launcher(bits="", fallback="armhf")
        self.assertEqual(result.returncode, 23, result.stdout + result.stderr)
        self.assertIn("EXEC:./Rangers.armhf", result.stdout)

    def test_missing_assets(self):
        result = self.run_launcher(assets=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Copy the original game resources", result.stdout)
        self.assertNotIn("EXEC:", result.stdout)

    def test_knulli_package_rejects_32_bit_userland(self):
        result = self.run_launcher(bits="32", arches=("aarch64",))
        self.assertEqual(result.returncode, 1)
        self.assertIn("does not contain an executable for armhf", result.stdout)


if __name__ == "__main__":
    unittest.main()
