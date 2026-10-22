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
    def run_launcher(self, bits="64", fallback="aarch64", assets=True, arches=("armhf", "aarch64"),
                     layout="beside", portmaster=True):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            scripts = root / "ROMS/Ports"
            scripts.mkdir(parents=True)
            # PortMaster's installer puts the folder in /$directory/ports, as on muOS.
            port = (scripts if layout == "beside" else root / "ports") / "spacerangershd"
            port.mkdir(parents=True)
            (port / "game").mkdir()
            if assets:
                (port / "game/INSTALL.TXT").touch()
            if layout != "missing":
                (port / "rangers.gptk").touch()
            launch = scripts / "Space Rangers HD.sh"
            shutil.copy2(ROOT / "platform/linux/Space Rangers HD PortMaster.sh", launch)
            pm = root / "PortMaster"
            pm.mkdir()
            if portmaster:
                (pm / "control.txt").write_text(
                    f"CFW_NAME=muOS\nGPTOKEYB=/bin/true\ndirectory={str(root)[1:]}\n"
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
            log = port / "log.txt"
            start_log = scripts / "spacerangershd-start.log"
            result.log = log.read_text() if log.exists() else None
            result.start_log = start_log.read_text() if start_log.exists() else None
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
        self.assertIn("Firmware: muOS", result.log)
        self.assertIsNone(result.start_log)

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

    def test_port_folder_in_portmaster_ports_directory(self):
        result = self.run_launcher(layout="ports")
        self.assertEqual(result.returncode, 23, result.stdout + result.stderr)
        self.assertIn("EXEC:./Rangers.aarch64", result.log)
        self.assertRegex(result.log, r"Port folder: /.*/ports/spacerangershd\n")
        self.assertIsNone(result.start_log)

    def test_missing_port_folder_is_logged_beside_the_script(self):
        result = self.run_launcher(layout="missing")
        self.assertEqual(result.returncode, 1)
        self.assertIsNone(result.log)
        self.assertIn("Folder spacerangershd not found", result.start_log)

    def test_missing_portmaster_is_logged_beside_the_script(self):
        result = self.run_launcher(portmaster=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Install or update PortMaster", result.start_log)

    def test_knulli_package_rejects_32_bit_userland(self):
        result = self.run_launcher(bits="32", arches=("aarch64",))
        self.assertEqual(result.returncode, 1)
        self.assertIn("does not contain an executable for armhf", result.stdout)


class StockLauncherTests(unittest.TestCase):
    """The Apps menu of Anbernic's own firmware, without PortMaster."""

    SP_PAD = (
        'input_a_btn = "0"\ninput_b_btn = "1"\ninput_y_btn = "2"\ninput_x_btn = "3"\n'
        'input_l_btn = "4"\ninput_r_btn = "5"\ninput_select_btn = "6"\ninput_start_btn = "7"\n'
        'input_l2_btn = "10"\ninput_r2_btn = "11"\ninput_l3_btn = "9"\ninput_r3_btn = "12"\n'
        'input_up_btn = "h0up"\ninput_down_btn = "h0down"\ninput_left_btn = "h0left"\n'
        'input_right_btn = "h0right"\ninput_l_x_plus_axis = "+0"\ninput_l_y_plus_axis = "+1"\n'
    )
    # RG28XX and RG34XX: no sticks, triggers on 9 and 10.
    NO_STICK_PAD = (
        'input_a_btn = "0"\ninput_b_btn = "1"\ninput_y_btn = "2"\ninput_x_btn = "3"\n'
        'input_l_btn = "4"\ninput_r_btn = "5"\ninput_select_btn = "6"\ninput_start_btn = "7"\n'
        'input_l2_btn = "9"\ninput_r2_btn = "10"\ninput_up_btn = "h0up"\n'
        'input_down_btn = "h0down"\ninput_left_btn = "h0left"\ninput_right_btn = "h0right"\n'
    )

    def run_launcher(self, bits="64", assets=True, shell="sh", pad=SP_PAD, mali=True):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            gpu = root / "gpu"
            gpu.mkdir()
            if mali:
                (gpu / "libmali.so.0").touch()
            pad_config = root / "ANBERNIC-keys.cfg"
            if pad is not None:
                pad_config.write_text(pad)
            port = root / "spacerangershd"
            (port / "game").mkdir(parents=True)
            if assets:
                (port / "game/INSTALL.TXT").touch()
            (port / "lib/aarch64").mkdir(parents=True)
            launch = root / "Space Rangers HD.sh"
            shutil.copy2(ROOT / "platform/linux/Space Rangers HD Stock.sh", launch)
            fake_bin = root / "bin"
            fake_bin.mkdir()
            scripts = {
                fake_bin / "getconf": f'#!/bin/bash\necho "{bits}"\n',
                port / "check-platform.aarch64": '#!/bin/bash\necho "PROBE:$LD_LIBRARY_PATH"\n',
                port / "gptokeyb.aarch64": '#!/bin/bash\necho "GPTOKEYB:$*"\nsleep 5\n',
                port / "Rangers.aarch64": '#!/bin/bash\nsleep 0.2\necho "EXEC:$0"\n'
                'echo "ARGS:$*"\necho "CONTROLS:$SDL_GAMECONTROLLERCONFIG"\n'
                'echo "GPU:$SDL_VIDEO_EGL_DRIVER,$SDL_VIDEO_GL_DRIVER"\nexit 23\n',
            }
            for path, text in scripts.items():
                path.write_text(text)
                path.chmod(0o755)
            env = os.environ.copy()
            # The stock menu exports SDL 2.0.12 from /usr/lib ahead of the multiarch SDL.
            env.update(
                PATH=f"{fake_bin}:{env['PATH']}",
                LD_LIBRARY_PATH="/usr/lib32:/usr/lib:/mnt/vendor/lib",
                ANBERNIC_PAD_CONFIG=str(pad_config),
                ANBERNIC_GPU_LIBRARY_DIR=str(gpu),
            )
            for name in ("BASH_VERSION", "SDL_VIDEO_EGL_DRIVER", "SDL_VIDEO_GL_DRIVER"):
                env.pop(name, None)
            result = subprocess.run(
                [shell, str(launch)], cwd="/", env=env, capture_output=True, text=True
            )
            log = (port / "log.txt").read_text() if (port / "log.txt").exists() else ""
            return result, log

    def test_menu_shell_starts_game_with_firmware_sdl_and_controls(self):
        result, log = self.run_launcher()
        self.assertEqual(result.returncode, 23, log + result.stderr)
        self.assertIn("EXEC:./Rangers.aarch64", log)
        self.assertIn("--fullscreen", log)
        self.assertIn("--on-screen-keyboard", log)
        libraries = next(line for line in log.splitlines() if line.startswith("PROBE:"))
        self.assertLess(libraries.index("/usr/lib/aarch64-linux-gnu"), libraries.index(":/usr/lib:"))
        self.assertIn("/spacerangershd/lib/aarch64:", libraries)
        self.assertIn("GPTOKEYB:-1 Rangers.aarch64 -c", log)
        controls = next(line for line in log.splitlines() if line.startswith("CONTROLS:"))
        for part in ("ANBERNIC-keys,", "a:b0,", "back:b6,", "start:b7,", "lefttrigger:b10,",
                     "righttrigger:b11,", "leftstick:b9,", "dpup:h0.1,", "dpleft:h0.8,", "leftx:a0,",
                     "lefty:a1,", "platform:Linux,"):
            self.assertIn(part, controls)

    def test_sdl_uses_mali_gpu_libraries(self):
        # Mesa's EGL in the multiarch directory comes first on the library path.
        result, log = self.run_launcher()
        self.assertEqual(result.returncode, 23, log + result.stderr)
        self.assertRegex(log, r"GPU:/.*/gpu/libEGL\.so\.1,/.*/gpu/libGLESv2\.so\.2\n")
        result, log = self.run_launcher(mali=False)
        self.assertEqual(result.returncode, 23, log + result.stderr)
        self.assertIn("GPU:,\n", log)

    def test_pad_without_sticks_uses_its_trigger_numbers(self):
        result, log = self.run_launcher(pad=self.NO_STICK_PAD)
        self.assertEqual(result.returncode, 23, log + result.stderr)
        controls = next(line for line in log.splitlines() if line.startswith("CONTROLS:"))
        self.assertIn("lefttrigger:b9,", controls)
        self.assertIn("righttrigger:b10,", controls)
        self.assertNotIn("leftstick", controls)
        self.assertNotIn("leftx", controls)

    def test_missing_autoconfig_falls_back_to_buttons_without_sticks(self):
        result, log = self.run_launcher(pad=None)
        self.assertEqual(result.returncode, 23, log + result.stderr)
        controls = next(line for line in log.splitlines() if line.startswith("CONTROLS:"))
        self.assertIn("a:b0,", controls)
        self.assertIn("lefttrigger:b9,", controls)
        self.assertIn("dpright:h0.2,", controls)

    def test_rejects_32_bit_firmware(self):
        result, log = self.run_launcher(bits="32")
        self.assertEqual(result.returncode, 1)
        self.assertIn("64-bit Anbernic stock firmware", log)
        self.assertNotIn("EXEC:", log)

    def test_missing_assets(self):
        result, log = self.run_launcher(assets=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Copy the original game resources", log)
        self.assertNotIn("GPTOKEYB:", log)


class TrimUILauncherTests(unittest.TestCase):
    """Apps/SpaceRangersHD on TrimUI stock firmware and CrossMix-OS."""

    def run_launcher(self, bits="64", assets=True, shell=("sh",), trimui_sdl=True, gpu=True, panel=None):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            system = root / "usr/lib"
            system.mkdir(parents=True)
            sdl = root / "usr/trimui/lib"
            sdl.mkdir(parents=True)
            ((sdl if trimui_sdl else system) / "libSDL2-2.0.so.0").touch()
            if gpu:
                (system / "libEGL.so.1").touch()
                (system / "libGLESv2.so.2").touch()
            if panel:
                size_file = root / "sys" / panel[0]
                size_file.parent.mkdir(parents=True)
                size_file.write_text(panel[1] + "\n")
            app = root / "Apps/SpaceRangersHD"
            port = app / "spacerangershd"
            (port / "game").mkdir(parents=True)
            if assets:
                (port / "game/INSTALL.TXT").touch()
            (port / "lib/aarch64").mkdir(parents=True)
            launch = app / "launch.sh"
            shutil.copy2(ROOT / "platform/linux/Space Rangers HD TrimUI.sh", launch)
            fake_bin = root / "bin"
            fake_bin.mkdir()
            scripts = {
                port / "check-platform.aarch64": '#!/bin/sh\necho "PROBE:$LD_LIBRARY_PATH"\n',
                port / "gptokeyb.aarch64": '#!/bin/sh\necho "GPTOKEYB:$*"\nsleep 5\n',
                port / "Rangers.aarch64": '#!/bin/sh\nsleep 0.2\necho "EXEC:$0"\n'
                'echo "ARGS:$*"\necho "CONTROLS:${SDL_GAMECONTROLLERCONFIG-unset}"\n'
                'echo "GPU:$SDL_VIDEO_EGL_DRIVER,$SDL_VIDEO_GL_DRIVER"\n'
                'echo "DENSITY:${SRHD_UI_DENSITY-unset}"\nexit 23\n',
            }
            for path, text in scripts.items():
                path.write_text(text)
                path.chmod(0o755)
            env = os.environ.copy()
            # CrossMix exports its own libraries, a GLVND libEGL among them,
            # and PortMaster's controller mapping.
            loader = root / "lib/ld-linux-aarch64.so.1"
            if bits == "64":
                loader.parent.mkdir()
                loader.touch()
            # Only the commands every TrimUI BusyBox firmware has; getconf is not one of them.
            for command in ("dirname", "kill", "mkdir", "sleep", "true"):
                (fake_bin / command).symlink_to(shutil.which(command))
            uname = fake_bin / "uname"
            uname.write_text(f'#!/bin/sh\necho {"aarch64" if bits == "64" else "armv7l"}\n')
            uname.chmod(0o755)
            env.update(
                PATH=str(fake_bin),
                TRIMUI_AARCH64_LOADER=str(loader),
                LD_LIBRARY_PATH="/mnt/SDCARD/System/lib:/usr/trimui/lib",
                SDL_GAMECONTROLLERCONFIG="crossmix-controller",
                TRIMUI_SYSTEM_LIBRARY_DIR=str(system),
                TRIMUI_SDL_LIBRARY_DIR=str(sdl),
                TRIMUI_CONTROLS_DELAY="0",
                TRIMUI_SYSFS=str(root / "sys"),
            )
            env.pop("SRHD_UI_DENSITY", None)
            for name in ("SDL_VIDEO_EGL_DRIVER", "SDL_VIDEO_GL_DRIVER"):
                env.pop(name, None)
            result = subprocess.run(
                [shutil.which(shell[0]), *shell[1:], str(launch)], cwd="/", env=env, capture_output=True, text=True
            )
            log = (port / "log.txt").read_text() if (port / "log.txt").exists() else ""
            # gptokeyb must not outlive the game, or it keeps grabbing the pad in MainUI.
            leftover = subprocess.run(
                ["pgrep", "-f", str(port / "gptokeyb.aarch64")], capture_output=True
            )
            self.assertNotEqual(leftover.returncode, 0, "gptokeyb still running")
            return result, log, str(root)

    def test_menu_shell_starts_game_with_firmware_sdl_and_controls(self):
        # Smart Pro, Brick and Brick Pro run apps with BusyBox sh.
        shells = [("sh",), ("dash",), ("busybox", "sh"), ("bash",)]
        for shell in (shell for shell in shells if shutil.which(shell[0])):
            with self.subTest(shell=shell):
                result, log, root = self.run_launcher(shell=shell)
                self.assertEqual(result.returncode, 23, log + result.stderr)
                # BusyBox sh runs its own uname applet, so only the loader is predictable here.
                self.assertRegex(log, r"^Launcher: TrimUI 2; machine: \S+; AArch64 loader: yes\n")
                self.assertIn("EXEC:./Rangers.aarch64", log)
                self.assertIn("--fullscreen", log)
                self.assertIn("--on-screen-keyboard", log)
                self.assertIn("GPTOKEYB:-1 Rangers.aarch64 -c", log)
                self.assertIn("CONTROLS:unset", log)
                libraries = next(line for line in log.splitlines() if line.startswith("PROBE:"))
                self.assertEqual(
                    libraries,
                    f"PROBE:{root}/Apps/SpaceRangersHD/spacerangershd/lib/aarch64:"
                    f"{root}/usr/trimui/lib:{root}/usr/lib:/lib",
                )
                self.assertIn(f"GPU:{root}/usr/lib/libEGL.so.1,{root}/usr/lib/libGLESv2.so.2\n", log)

    def test_smart_pro_s_sdl_in_system_directory(self):
        result, log, root = self.run_launcher(trimui_sdl=False)
        self.assertEqual(result.returncode, 23, log + result.stderr)
        self.assertIn(f"SDL: {root}/usr/lib\n", log)
        self.assertIn(f"PROBE:{root}/Apps/SpaceRangersHD/spacerangershd/lib/aarch64:{root}/usr/lib:", log)

    def test_ui_density_follows_the_panel(self):
        panels = {
            "Smart Pro": (("class/graphics/fb0/virtual_size", "1280,1440"), "1.5"),
            "Brick": (("class/graphics/fb0/virtual_size", "1024,768"), "2"),
            "Smart Pro S, DRM only": (("class/drm/card0-DSI-1/modes", "1280x720"), "1.5"),
            "unknown": (None, "unset"),
        }
        for name, (panel, density) in panels.items():
            with self.subTest(panel=name):
                result, log, _ = self.run_launcher(panel=panel)
                self.assertEqual(result.returncode, 23, log + result.stderr)
                self.assertIn(f"DENSITY:{density}\n", log)

    def test_without_gpu_libraries_sdl_chooses(self):
        result, log, _ = self.run_launcher(gpu=False)
        self.assertEqual(result.returncode, 23, log + result.stderr)
        self.assertIn("GPU:,\n", log)

    def test_rejects_32_bit_firmware(self):
        result, log, _ = self.run_launcher(bits="32")
        self.assertEqual(result.returncode, 1)
        self.assertIn("machine: armv7l; AArch64 loader: no", log)
        self.assertIn("64-bit TrimUI firmware", log)
        self.assertNotIn("EXEC:", log)

    def test_missing_assets(self):
        result, log, _ = self.run_launcher(assets=False)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Copy the original game resources", log)
        self.assertNotIn("GPTOKEYB:", log)


if __name__ == "__main__":
    unittest.main()
