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
import windows
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
    def test_depfile_tracks_header_changes(self):
        header = self.sources / "header with spaces.h"
        header.write_text("a declaration")
        obj = self.work / "native.o"
        command = [self.clang, "-c", self.source, "-o", obj]

        def compile_step(work, name, command):
            obj.write_text("object")
            depfile = Path(command[command.index("-MF") + 1])
            escaped = header.as_posix().replace(" ", "\\ ")
            depfile.write_text(f"native.o: {escaped}\n")

        with patch.object(native, "run_step", side_effect=compile_step) as runner:
            native.compile_native(self.work, command, False)
            native.compile_native(self.work, command, False)
            self.assertEqual(runner.call_count, 1)
            self.edit(header)
            native.compile_native(self.work, command, False)
            self.assertEqual(runner.call_count, 2)
            (self.work / "native.d").write_text("malformed dependency file")
            native.compile_native(self.work, command, False)
            self.assertEqual(runner.call_count, 3)

    def test_link_requires_all_outputs_and_tracks_inputs(self):
        wasm = self.work / "game.wasm"
        loader = self.work / "game.js"
        command = [self.clang, self.source, "-o", loader]

        def link_step(*args):
            wasm.write_text("wasm")
            loader.write_text("javascript")

        def link():
            native.link_native(self.work, command, [self.source], [loader, wasm], False)

        with patch.object(native, "run_step", side_effect=link_step) as runner:
            link()
            link()
            self.assertEqual(runner.call_count, 1)
            self.edit(self.source)
            link()
            self.assertEqual(runner.call_count, 2)
            wasm.unlink()
            link()
            self.assertEqual(runner.call_count, 3)

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
    def test_windows_target_cpu_is_independent_of_host(self):
        with patch("targets.host_cpu", return_value="aarch64"):
            for target, cpu in (("win32", "i386"), ("win64", "x86_64")):
                config = BuildConfig(target, True, True, Path("/project"))
                self.assertEqual(config.cpu, cpu)
                self.assertEqual(config.work, Path(f"/project/.local/{target}-{cpu}/release-lto"))
                self.assertEqual(config.artifact.name, "Rangers.exe")

    def test_existing_output_layout_for_all_profiles(self):
        root = Path("/project")
        directories = {
            "macos": root / ".local",
            "linux": root / ".local/linux-aarch64",
            "wasm": root / ".local/wasm",
        }
        with patch("targets.host_cpu", return_value="aarch64"):
            for target, directory in directories.items():
                for release in (False, True):
                    for lto in (False, True):
                        with self.subTest(target=target, release=release, lto=lto):
                            config = BuildConfig(target, release, lto, root)
                            profile = ("release" if release else "debug") + ("-lto" if lto else "")
                            self.assertEqual(config.work, directory / profile)
                            if target == "macos":
                                self.assertEqual(
                                    config.artifact, config.work / "Space Rangers HD.app"
                                )
                                self.assertEqual(
                                    config.binary_directory, config.artifact / "Contents/MacOS"
                                )
                            else:
                                self.assertEqual(config.binary_directory, config.work / "bin")
                                name = "index.html" if target == "wasm" else "Rangers"
                                self.assertEqual(config.artifact, config.binary_directory / name)

    def test_unknown_target_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "Unsupported target"):
            BuildConfig("unknown")


class WindowsToolchainFixture(BuildFixture):
    temporary_prefix = "srhd-build-"
    triples = (("i386", "i686-w64-mingw32"), ("x86_64", "x86_64-w64-mingw32"))

    def setUp(self):
        super().setUp()
        self.sdk = self.root / "llvm-mingw"
        self.bin = self.sdk / "bin"
        for _, triple in self.triples:
            for name in ("clang", "clang++", "windres"):
                make_tool(self.bin / (f"{triple}-{name}" + EXE_SUFFIX))
        self.sdk_clang = make_tool(self.bin / ("clang" + EXE_SUFFIX))
        self.sdk_backend = make_tool(self.bin / ("clang-23" + EXE_SUFFIX))
        self.sdk_library = make_tool(self.bin / "libclang-cpp.dll")


class WindowsBuildTests(WindowsToolchainFixture):
    @unittest.skipIf(os.name == "nt", "Creating symbolic links needs Windows privileges")
    def test_prefixed_driver_symlink_keeps_its_target_selection(self):
        for cpu, triple in self.triples:
            target = "win32" if cpu == "i386" else "win64"
            with self.subTest(target=target):
                driver = self.bin / f"{triple}-clang"
                driver.unlink()
                driver.symlink_to(self.sdk_clang)
                options = windows.cmake_options(BuildConfig(target), self.sdk, self.work)
                self.assertIn(f"-DCMAKE_C_COMPILER={driver.as_posix()}", options)


class WindowsCompilerTests(WindowsToolchainFixture):
    """Check orchestration contracts; full compiler cycles are tested on Windows separately."""

    def setUp(self):
        super().setUp()
        self.clang.unlink()  # Host and target compilers must both use the SDK.
        vendor = self.root / "vendor"
        for name in ("compiler/pp.pas", "rtl/Makefile"):
            path = vendor / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("source")
        make_tool(self.root / ("make" + EXE_SUFFIX))
        self.builtins = {}
        for cpu, triple in self.triples:
            library = self.sdk / triple / "builtins/clang_rt.builtins.a"
            library.parent.mkdir(parents=True)
            library.write_text("compiler runtime")
            self.builtins[cpu] = library
        unwind = self.sdk / "x86_64-w64-mingw32" / "bin/libunwind.dll"
        unwind.parent.mkdir()
        unwind.write_text("Win64 unwinder")
        self.identity = {"-iV": "3.2.2", "-iSP": "x86_64", "-iSO": "win64"}
        self.commands = {"compiler": [], "runtime": []}
        self.unwind_at_bootstrap = []
        enter = self.contexts.enter_context
        for name, value in (("VENDOR", vendor), ("WORK", self.work)):
            enter(patch.object(compiler, name, value))
        enter(patch.object(compiler, "host_cpu", return_value="x86_64"))
        enter(patch("compiler.platform.system", return_value="Windows"))
        enter(patch.object(compiler, "source_revision", return_value="source revision"))
        enter(patch.object(compiler, "record_build_source"))
        self.llvm = enter(patch.object(compiler, "llvm_options", return_value=("-Clv17.0",)))
        enter(patch.object(compiler, "output", side_effect=self.query))
        self.runner = enter(patch.object(compiler, "run_step", side_effect=self.build_step))
        enter(patch.dict(os.environ, {
            "FPC_BOOTSTRAP": str(self.compiler), "FPC_SOURCE": "", "FPC_COMPILER": "",
        }))

    def query(self, tool, option):
        if option == "-print-libgcc-file-name":
            cpu = "i386" if Path(tool).name.startswith("i686-") else "x86_64"
            return str(self.builtins[cpu])
        return self.identity[option]

    def build_step(self, work, name, command):
        self.commands[name].append(command)
        if name == "compiler":
            unwind = work / "source/compiler/libunwind.dll"
            self.unwind_at_bootstrap.append(unwind.read_text() if unwind.exists() else None)
            executable = "ppcross386.exe" if work.name.startswith("i386-") else "ppcx64.exe"
            make_tool(work / "source/compiler" / executable, "compiled LLVM backend")
        else:
            (work / "src/rtl/units" / work.parent.name / "classes.ppu").write_text("compiled RTL")

    def prepare(self, target="win64"):
        return compiler.prepare_compiler(BuildConfig(target, root=self.root), self.bin)

    def test_win32_uses_host_libraries_for_bootstrap_and_target_libraries_for_runtime(self):
        _, flags = self.prepare("win32")
        bootstrap = " ".join(self.commands["compiler"][0])
        runtime = " ".join(self.commands["runtime"][0])
        host = f"-Fl{self.builtins['x86_64'].parent.as_posix()}"
        target = f"-Fl{self.builtins['i386'].parent.as_posix()}"
        self.assertIn(host, bootstrap)
        self.assertNotIn(target, bootstrap)
        self.assertIn(target, runtime)
        self.assertNotIn(host, runtime)
        self.assertIn(f"-Fl{self.builtins['i386'].parent}", flags)
        self.assertEqual(self.unwind_at_bootstrap, ["Win64 unwinder"])

    def test_clang_backend_replacement_behind_wrapper_invalidates_cached_build(self):
        self.prepare()
        self.prepare()
        self.assertEqual(self.runner.call_count, 2)
        for executable in (self.sdk_backend, self.sdk_library):
            with self.subTest(executable=executable.name):
                before = {name: len(calls) for name, calls in self.commands.items()}
                self.edit(executable)
                self.prepare()
                self.assertEqual(
                    {name: len(calls) for name, calls in self.commands.items()},
                    {name: count + 1 for name, count in before.items()},
                )

    def test_missing_host_unwinder_is_restored_before_bootstrap(self):
        executable, _ = self.prepare()
        executable.with_name("libunwind.dll").unlink()
        self.prepare()
        self.assertEqual(self.unwind_at_bootstrap, ["Win64 unwinder", "Win64 unwinder"])

    def test_invalid_bootstrap_is_rejected_before_sdk_probing_or_building(self):
        for option, value in (("-iV", "3.0.4"), ("-iSP", "i386"), ("-iSO", "linux")):
            with (
                self.subTest(option=option),
                patch.dict(self.identity, {option: value}),
                self.assertRaisesRegex(RuntimeError, "native Win64 FPC"),
            ):
                self.prepare()
        self.llvm.assert_not_called()
        self.runner.assert_not_called()
        self.assertEqual(list(self.work.iterdir()), [])

    def test_spaced_paths_are_rejected_before_sdk_probing_or_building(self):
        with (
            patch.object(compiler, "WORK", self.work / "path with spaces"),
            self.assertRaisesRegex(RuntimeError, "paths without spaces"),
        ):
            self.prepare()
        self.llvm.assert_not_called()
        self.runner.assert_not_called()
        self.assertEqual(list(self.work.iterdir()), [])


if __name__ == "__main__":
    unittest.main()
