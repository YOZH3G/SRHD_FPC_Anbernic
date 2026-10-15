"""Check the Windows runtime import closure without a Windows build."""

import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / ".github/scripts"))
import package


class WindowsPackageTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name)
        self.binary = self.root / "Rangers.exe"
        self.binary.write_bytes(b"executable")
        self.imports = {}
        reader = patch.object(package.subprocess, "check_output", side_effect=self.read_imports)
        reader.start()
        self.addCleanup(reader.stop)

    def read_imports(self, command, **kwargs):
        return "\n".join(
            f"Import {{\n  Name: {name}\n}}" for name in self.imports[Path(command[-1]).name]
        )

    def test_transitive_imports_exclude_unused_dlls(self):
        for name in ("SDL2.dll", "vorbisfile.dll", "libvorbis.dll", "ogg.dll", "vorbisenc.dll"):
            (self.root / name).write_bytes(b"library")
        self.imports = {
            "Rangers.exe": ["SDL2.DLL", "vorbisfile.dll", "kernel32.dll"],
            "SDL2.dll": ["USER32.dll", "api-ms-win-crt-runtime-l1-1-0.dll"],
            "vorbisfile.dll": ["libvorbis.dll", "ogg.dll"],
            "libvorbis.dll": ["OGG.DLL"],
            "ogg.dll": [],
        }
        files = package.windows_runtime_files(self.binary, Path("llvm-readobj"))
        self.assertEqual(
            {path.name for path in files},
            {"Rangers.exe", "SDL2.dll", "vorbisfile.dll", "libvorbis.dll", "ogg.dll"},
        )

    def test_missing_import_fails_packaging(self):
        self.imports = {"Rangers.exe": ["libunwind.dll"]}
        with self.assertRaisesRegex(FileNotFoundError, "libunwind.dll"):
            package.windows_runtime_files(self.binary, Path("llvm-readobj"))

    def test_new_dependency_requires_packaging_review(self):
        (self.root / "new-codec.dll").write_bytes(b"library")
        self.imports = {"Rangers.exe": ["new-codec.dll"]}
        with self.assertRaisesRegex(RuntimeError, "new-codec.dll"):
            package.windows_runtime_files(self.binary, Path("llvm-readobj"))


if __name__ == "__main__":
    unittest.main()
