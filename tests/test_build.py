"""Build invalidation checks using temporary sources and a simulated compiler.

Run with: python3 -m unittest discover -s tests
No installed compiler, game assets, or build cache is used.
"""

import os
import sys
import tempfile
import unittest
from contextlib import ExitStack
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
import build_support as native
import compiler
import pascal
from targets import BuildConfig

EXE_SUFFIX = ".exe" if os.name == "nt" else ""


def make_tool(path, contents="simulated tool"):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(contents)
    path.chmod(0o755)
    return path


class BuildFixture(unittest.TestCase):
    temporary_prefix = "srhd build "

    def setUp(self):
        temporary = tempfile.TemporaryDirectory(prefix=self.temporary_prefix)
        self.addCleanup(temporary.cleanup)
        self.contexts = ExitStack()
        self.addCleanup(self.contexts.close)
        self.root = Path(temporary.name)
        self.work = self.root / "work"
        self.work.mkdir()
        self.sources = self.root / "sources"
        self.sources.mkdir()
        self.source = self.sources / "main.pas"
        self.source.write_text("program main; begin end.")
        self.unit = self.work / "main.ppu"
        self.artifact = self.work / "Rangers"
        self.compiler = make_tool(self.root / ("fpc" + EXE_SUFFIX))
        self.clang = make_tool(self.root / ("clang" + EXE_SUFFIX))
        self.contexts.enter_context(patch.dict(os.environ, {"PATH": str(self.root)}))

    @staticmethod
    def edit(path, *, offset_ns=0):
        """Change content while controlling the timestamp seen by FPC."""
        before = path.stat()
        contents = path.read_text()
        path.write_text(("b" if contents[0] == "a" else "a") + contents[1:])
        os.utime(path, ns=(before.st_atime_ns, before.st_mtime_ns + offset_ns))


class PascalBuildTests(BuildFixture):
    def setUp(self):
        super().setUp()
        self.command = [self.compiler, f"-Fu{self.sources}", f"-FU{self.work}", self.source]
        self.dependencies = ()
        self.calls = []
        self.units_present = []

        def compile_step(work, name, command):
            self.calls.append(command)
            self.units_present.append(self.unit.exists())
            self.unit.write_text("compiled unit")
            self.artifact.write_text("compiled program")

        self.runner = self.contexts.enter_context(
            patch.object(pascal, "run_step", side_effect=compile_step)
        )

    def build(self, rebuild=False):
        return pascal.compile_pascal(
            self.work, self.command, rebuild, self.artifact, self.dependencies
        )

    def assert_full_rebuild(self):
        self.assertTrue(self.build())
        self.assertIn("-B", self.calls[-1])
        self.assertFalse(self.build(), "the rebuilt outputs must be cached")

    def test_first_build_then_unchanged(self):
        self.assert_full_rebuild()
        self.assertEqual(len(self.calls), 1)

    def test_ordinary_edit_uses_fpc_incremental_compilation(self):
        self.build()
        self.edit(self.source, offset_ns=2_000_000_000)
        self.assertTrue(self.build())
        self.assertNotIn("-B", self.calls[-1])
        self.assertFalse(self.build())

    def test_preserved_mtime_edit_forces_rebuild(self):
        self.build()
        self.edit(self.source)
        self.assert_full_rebuild()

    def test_two_edits_in_same_second_force_rebuild(self):
        second = self.source.stat().st_mtime_ns // 1_000_000_000 * 1_000_000_000
        os.utime(self.source, ns=(second, second + 100))
        self.build()
        self.edit(self.source, offset_ns=100)
        self.assert_full_rebuild()

    def test_added_and_removed_input_force_rebuild(self):
        self.build()
        include = self.sources / "options.inc"
        include.write_text("{$define EXAMPLE}")
        self.assert_full_rebuild()
        include.unlink()
        self.assert_full_rebuild()

    def test_missing_and_replaced_unit_force_rebuild(self):
        self.build()
        self.unit.unlink()
        self.assert_full_rebuild()
        self.edit(self.unit)
        self.assert_full_rebuild()

    def test_missing_binary_is_recreated(self):
        self.build()
        self.artifact.unlink()
        self.assertTrue(self.build())
        self.assertTrue(self.artifact.is_file())

    def test_changed_link_dependency_does_not_recompile_all_units(self):
        library = self.root / "libokgf.a"
        library.write_text("native library")
        self.dependencies = (library,)
        self.build()
        self.edit(library)
        self.assertTrue(self.build())
        self.assertNotIn("-B", self.calls[-1])

    def test_flag_change_forces_rebuild(self):
        self.build()
        self.command.insert(1, "-O4")
        self.assert_full_rebuild()

    def test_relevant_environment_change_forces_rebuild(self):
        self.build()
        with patch.dict(os.environ, {"SDKROOT": "/different/sdk"}):
            self.assert_full_rebuild()

    def test_compiler_replaced_with_older_mtime_forces_rebuild(self):
        self.build()
        self.edit(self.compiler, offset_ns=-10_000_000_000)
        self.assert_full_rebuild()

    def test_clang_replacement_including_wrapped_backend_forces_rebuild(self):
        backend = make_tool(self.root / ("clang-23" + EXE_SUFFIX))
        library = make_tool(self.root / "libclang-cpp.dll")
        self.build()
        for executable in (self.clang, backend, library):
            with self.subTest(executable=executable.name):
                self.edit(executable)
                self.assert_full_rebuild()

    def test_explicit_rebuild_forces_rebuild(self):
        self.build()
        self.assertTrue(self.build(rebuild=True))
        self.assertIn("-B", self.calls[-1])

    def test_released_package_discards_units_after_input_change(self):
        self.command.insert(1, "-Ur")
        self.build()
        self.edit(self.source, offset_ns=2_000_000_000)
        self.assert_full_rebuild()
        self.assertFalse(self.units_present[-1])

    def test_failed_build_invalidates_previous_success(self):
        self.build()
        self.command.insert(1, "-O4")
        with (
            patch.object(pascal, "run_step", side_effect=RuntimeError("compile failed")),
            self.assertRaisesRegex(RuntimeError, "compile failed"),
        ):
            self.build()
        self.command.remove("-O4")
        self.assert_full_rebuild()


class NativeBuildTests(BuildFixture):
    def test_bootstrap_revision_tracks_tool_replacement(self):
        command = [self.compiler, "compiler_cycle"]
        before = compiler.recipe_revision("source revision", command, (self.compiler,))
        self.edit(self.compiler, offset_ns=-10_000_000_000)
        after = compiler.recipe_revision("source revision", command, (self.compiler,))
        self.assertNotEqual(before, after)

    def test_bootstrap_revision_survives_restored_tool_metadata(self):
        command = [self.compiler, "compiler_cycle"]
        before = compiler.recipe_revision("source revision", command, (self.compiler,))
        original = self.compiler.read_bytes()
        self.compiler.write_bytes(original)
        stat = self.compiler.stat()
        os.utime(self.compiler, ns=(stat.st_atime_ns, stat.st_mtime_ns + 10_000_000_000))
        self.assertEqual(
            compiler.recipe_revision("source revision", command, (self.compiler,)), before
        )
        self.edit(self.compiler)
        self.assertNotEqual(
            compiler.recipe_revision("source revision", command, (self.compiler,)), before
        )


class CMakeBuildTests(BuildFixture):
    """Exercise cache decisions and filesystem effects; CMake itself is simulated."""

    def setUp(self):
        super().setUp()
        self.directory = self.work / "native"
        self.directory.mkdir()
        self.cache = self.directory / "CMakeCache.txt"
        self.generated = self.directory / "CMakeFiles"
        self.download = self.directory / "_deps/source.txt"
        self.download.parent.mkdir()
        self.download.write_text("downloaded source")
        self.recipe = self.root / "native/CMakeLists.txt"
        self.recipe.parent.mkdir()
        self.recipe.write_text("add_library(example example.c)")
        self.cache_present = []
        self.contexts.enter_context(patch.object(native, "ROOT", self.root))
        self.runner = self.contexts.enter_context(
            patch.object(native, "run_step", side_effect=self.configure_step)
        )

    def configure_step(self, work, name, command):
        self.cache_present.append((self.cache.exists(), self.generated.exists()))
        # Emulate only the cache entries the caller requested, not CMake's reset logic.
        entries = [str(arg)[2:].split("=", 1) for arg in command if str(arg).startswith("-D")]
        self.cache.write_text("".join(
            f"{key.split(':')[0]}:FILEPATH={value}\n" for key, value in entries
        ))
        self.generated.mkdir(exist_ok=True)

    def configure(self, *options):
        return native.configure_native(
            self.work, self.directory,
            [self.clang, "configure", *(options or (f"-DCMAKE_C_COMPILER={self.clang}",))],
        )

    def test_compiler_content_change_requires_clean_build(self):
        backend = make_tool(self.root / ("clang-23" + EXE_SUFFIX))
        library = make_tool(self.root / "libLLVM-23.dll")
        self.assertFalse(self.configure())
        self.assertFalse(self.configure())
        self.assertEqual(self.runner.call_count, 1)
        for executable in (self.clang, backend, library):
            with self.subTest(executable=executable.name):
                before = self.runner.call_count
                self.edit(executable, offset_ns=-10_000_000_000)
                self.assertTrue(self.configure())
                self.assertEqual(self.runner.call_count, before + 1)

    @unittest.skipIf(os.name == "nt", "Creating symbolic links needs Windows privileges")
    def test_compiler_symlink_retarget_requires_clean_build(self):
        driver = self.root / "cc"
        driver.symlink_to(self.clang)
        option = f"-DCMAKE_C_COMPILER={driver}"
        self.configure(option)
        replacement = make_tool(self.root / "replacement", "new compiler")
        driver.unlink()
        driver.symlink_to(replacement)
        self.assertTrue(self.configure(option))

    def test_toolchain_path_change_clears_metadata_but_preserves_downloads(self):
        replacement = make_tool(self.root / "replacement")
        for variable in (
            "CMAKE_C_COMPILER", "CMAKE_CXX_COMPILER", "CMAKE_RC_COMPILER", "CMAKE_TOOLCHAIN_FILE"
        ):
            with self.subTest(variable=variable):
                self.configure(f"-D{variable}={self.compiler}")
                # Typed and untyped -D options must select the same cache variable.
                self.assertTrue(self.configure(f"-D{variable}:FILEPATH={replacement}"))
                self.assertEqual(self.cache_present[-1], (False, False))
                self.assertEqual(self.download.read_text(), "downloaded source")
                before = self.runner.call_count
                self.assertFalse(self.configure(f"-D{variable}:FILEPATH={replacement}"))
                self.assertEqual(self.runner.call_count, before)

    def test_toolchain_file_edit_with_preserved_mtime_requires_clean_build(self):
        toolchain = self.root / "toolchain.cmake"
        toolchain.write_text("set(CMAKE_SYSTEM_NAME Windows)")
        option = f"-DCMAKE_TOOLCHAIN_FILE={toolchain}"
        self.configure(option)
        self.edit(toolchain)
        self.assertTrue(self.configure(option))
        self.assertEqual(self.cache_present[-1], (False, False))
        self.assertEqual(self.runner.call_count, 2)

    def test_windows_path_spelling_does_not_discard_cache(self):
        # These Windows paths are already absolute; do not prepend a POSIX cwd.
        with patch.object(native, "tool_identity_files", side_effect=lambda path: (path,)):
            self.configure("-DCMAKE_C_COMPILER=C:/SDK/bin/clang.exe")
            self.assertFalse(self.configure(r"-DCMAKE_C_COMPILER=c:\sdk\bin\clang.exe"))
        self.assertEqual(self.cache_present[-1], (True, True))

    def test_content_cache_survives_restore_and_tracks_recipe_edits(self):
        self.configure()
        for path in (self.clang, self.recipe):
            path.write_bytes(path.read_bytes())
            stat = path.stat()
            os.utime(path, ns=(stat.st_atime_ns, stat.st_mtime_ns + 10_000_000_000))
        self.assertFalse(self.configure())
        self.assertEqual(self.runner.call_count, 1)
        self.edit(self.recipe)
        self.assertFalse(self.configure(), "recipe edits reconfigure without discarding objects")
        self.assertEqual(self.runner.call_count, 2)

    def test_interrupted_configure_retries_from_clean_metadata(self):
        self.configure()
        self.edit(self.recipe)

        def interrupted(*args):
            self.cache.write_text("partial cache")
            raise RuntimeError("configure failed")

        with (
            patch.object(native, "run_step", side_effect=interrupted),
            self.assertRaisesRegex(RuntimeError, "configure failed"),
        ):
            self.configure()
        self.assertTrue(self.configure())
        self.assertEqual(self.cache_present[-1], (False, False))
        self.assertEqual(self.download.read_text(), "downloaded source")
        before = self.runner.call_count
        self.assertFalse(self.configure())
        self.assertEqual(self.runner.call_count, before)


class StampTests(BuildFixture):
    def test_failed_post_build_signature_does_not_cache_success(self):
        stamp = native.BuildStamp(self.work / "build.stamp")
        with stamp.recording("previous"):
            self.artifact.write_text("previous output")

        def signature():
            raise ValueError("invalid depfile")

        with self.assertRaisesRegex(ValueError, "invalid depfile"), stamp.recording(signature):
            self.artifact.write_text("new output")
        self.assertFalse(native.BuildStamp(stamp.path).matches("previous", self.artifact))


class ConfigurationTests(unittest.TestCase):
    def test_existing_output_layout_for_all_profiles(self):
        root = Path("/project")
        with patch("targets.host_cpu", return_value="aarch64"):
            for release in (False, True):
                for lto in (False, True):
                    with self.subTest(release=release, lto=lto):
                        config = BuildConfig("linux", release, lto, root)
                        profile = ("release" if release else "debug") + ("-lto" if lto else "")
                        self.assertEqual(config.work, root / ".local/linux-aarch64" / profile)
                        self.assertEqual(config.binary_directory, config.work / "bin")
                        self.assertEqual(config.artifact, config.binary_directory / "Rangers")

    def test_unknown_target_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Unsupported target"):
            BuildConfig("unknown")


if __name__ == "__main__":
    unittest.main()
