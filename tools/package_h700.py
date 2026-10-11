#!/usr/bin/env python3
"""Package the Linux builds for H700 muOS and KNULLI using firmware SDL."""

import argparse
import hashlib
import json
import shutil
import subprocess
import zipfile
from pathlib import Path

from targets import ROOT


MODELS = [
    "RG35XX Plus",
    "RG35XX H",
    "RG35XX SP",
    "RG35XX 2024",
    "RG28XX",
    "RG40XX H",
    "RG40XX V",
]


def package(
    firmware: str,
    sdk_root: Path,
    output: Path,
    models: list[str] = MODELS,
    family: str = "H700",
    directory: str | None = None,
) -> Path:
    arches = ("armhf", "aarch64") if firmware == "muOS" else ("aarch64",)
    staging = output / f"{family}-{firmware}"
    if staging.exists():
        raise FileExistsError(f"Remove or choose another staging directory: {staging}")
    port = staging / "spacerangershd"
    port.mkdir(parents=True)
    launcher = staging / "Space Rangers HD.sh"
    shutil.copy2(ROOT / "platform/linux/Space Rangers HD PortMaster.sh", launcher)
    launcher.chmod(0o755)
    shutil.copy2(ROOT / "platform/linux/rangers.gptk", port / "rangers.gptk")
    licenses = port / "licenses"
    licenses.mkdir()
    for path, name in (
        (ROOT / "LICENSE", "LICENSE"),
        (ROOT / "NOTICE.md", "NOTICE.md"),
        (ROOT / "vendor/fpc/rtl/COPYING.txt", "FPC-runtime.txt"),
        (ROOT / "vendor/fpc/rtl/COPYING.FPC", "FPC-linking-exception.txt"),
        (ROOT / "vendor/okgf/LICENSE", "OKGF.txt"),
    ):
        shutil.copy2(path, licenses / name)
    for arch in arches:
        sdk_arch = "armhf" if arch == "armhf" else "arm64"
        triplet = "arm-linux-gnueabihf" if arch == "armhf" else "aarch64-linux-gnu"
        sdk = sdk_root / sdk_arch
        work = ROOT / ".local/anbernic" / sdk_arch
        library_dir = port / "lib" / arch
        library_dir.mkdir(parents=True)
        binary = port / f"Rangers.{arch}"
        shutil.copy2(work / "Rangers", binary)
        for name in (
            "libokgf.so",
            "libvorbisfile.so.3",
            "libvorbis.so.0",
            "libvorbisenc.so.2",
            "libogg.so.0",
        ):
            shutil.copy2(work / "lib" / name, library_dir / name)
        for name in ("libjpeg.so.8", "libpng16.so.16", "libz.so.1"):
            candidates = [
                sdk / "root" / folder / triplet / name for folder in ("usr/lib", "lib")
            ]
            source = next((path for path in candidates if path.is_file()), None)
            if source is None:
                raise FileNotFoundError(f"Missing SDK library: {name}")
            shutil.copy2(source, library_dir / name)
        probe = port / f"check-platform.{arch}"
        subprocess.run(
            [
                str(sdk / "bin" / f"{triplet}-clang"),
                "-O2",
                "-Wall",
                "-Wextra",
                "-Werror",
                str(ROOT / "tools/tests/handheld_probe.c"),
                f"-L{sdk}/root/usr/lib",
                "-lSDL2",
                "-o",
                str(probe),
            ],
            check=True,
        )
        for path in (binary, probe, *library_dir.iterdir()):
            # Keep upstream's game debug information and the exact tested binary.
            # Only the helper and native libraries are stripped for packaging.
            if path != binary:
                subprocess.run(
                    [str(sdk / "bin" / f"{triplet}-strip"), str(path)], check=True
                )
            path.chmod(0o755)
        for package_name in (
            "libjpeg-turbo8",
            "libpng16-16",
            "zlib1g",
            "libogg0",
            "libvorbis0a",
        ):
            shutil.copy2(
                sdk / "root/usr/share/doc" / package_name / "copyright",
                licenses / f"{package_name}.txt",
            )
    if directory is None:
        directory = (
            "/mnt/mmc/ROMS/Ports" if firmware == "muOS" else "/userdata/roms/ports"
        )
    model_note = (
        "RG35XX 2024 — версия с H700, не оригинальный RG35XX 2022/2023.\n"
        if family == "H700"
        else "Используйте прошивку, предназначенную для конкретной модели.\n"
    )
    storage_note = (
        "   На второй карте muOS каталог может быть /mnt/sdcard/ROMS/Ports.\n"
        if firmware == "muOS"
        else "   ArkOS: на второй карте /roms2/ports; ROCKNIX: также /storage/roms/ports.\n"
    )
    architecture_note = (
        "В пакет muOS входят ARMHF и AArch64; выбор по разрядности userland.\n"
        if firmware == "muOS"
        else "В пакет входит AArch64; требуется 64-битная Linux-прошивка.\n"
    )
    display_note = (
        "Стики не обязательны. RG28XX: экран 640x480; масштабирование fullscreen.\n"
        if family == "H700"
        else "Стики не обязательны. Изображение масштабируется в fullscreen.\n"
    )
    (port / "game").mkdir()
    (port / "game/README.txt").write_text(
        "Скопируйте сюда ресурсы игры; см. ../README.txt.\n"
    )
    (port / "README.txt").write_text(
        f"Space Rangers HD FPC — {family} / {firmware}, экспериментальная сборка\n\n"
        "Модели для проверки: " + ", ".join(models) + ".\n" + model_note + "\n"
        "Установка:\n"
        "1. Установите актуальную прошивку для своей модели и обновите PortMaster.\n"
        f"2. Распакуйте содержимое архива в {directory}.\n"
        + storage_note
        + "3. Скопируйте в spacerangershd/game ресурсы оригинальной игры:\n"
        "   INSTALL.TXT, INSTALL_ENGLISH.TXT, INSTALL_RUSSIAN.TXT, CFG.TXT,\n"
        "   CFG/, DATA/*.pkg; при необходимости Mods/. Сохраняйте регистр имён.\n"
        "4. Обновите список игр и запустите Space Rangers HD из раздела Ports.\n\n"
        + architecture_note
        + "Нужны glibc >= 2.29 и системная SDL2 >= 2.26.0.\n"
        "SDL2, ALSA, GPU-драйверы и glibc используются из прошивки.\n"
        "По умолчанию --renderer=sdl; при ошибке ускорения включается software.\n"
        "Для принудительного программного режима передайте --renderer=software.\n"
        "Ogg/Vorbis, JPEG, PNG, zlib и библиотеки игры включены.\n"
        "Не копируйте SDL2 из предыдущего архива в lib/: прошивка использует\n"
        "собственные драйверы дисплея и настройки его поворота.\n\n"
        "Управление:\n"
        "Крестовина/левый стик — курсор; A/B — левая/правая кнопка мыши;\n"
        "Start/R1 — Enter; Select — Escape; X — пробел; Y — Tab;\n"
        "L1 — медленный курсор; Select+Start — выход через PortMaster.\n"
        "Экранная клавиатура: A на текстовом поле или L2 для активного поля.\n"
        "Y — RU/EN; R2 — регистр; B — стереть; Start/R1 — OK; Select — отмена.\n"
        "Пробел и перемещение каретки доступны экранными кнопками.\n"
        "Отмена сохраняет исходный текст; действуют ограничения поля.\n"
        + display_note
        + "Профиль/сохранения: spacerangershd/profile; журнал: spacerangershd/log.txt.\n\n"
        "Диагностика по SSH из каталога spacerangershd:\n"
        "  getconf LONG_BIT\n"
        "  getconf GNU_LIBC_VERSION\n"
        '  LD_LIBRARY_PATH="$PWD/lib/aarch64" ./check-platform.aarch64\n'
        "  Для 32-битной muOS замените aarch64 на armhf.\n\n"
        "Основа — актуальная main-ветка автора, с клавиатурой RU/EN и портом Anbernic.\n"
        "Проверки конкретного релиза и хеши бинарников — в RUNTIME-REPORT.md и JSON.\n"
        "QEMU позволяет проверить ввод, кампанию, вылет и fallback;\n"
        "физические GPU, дисплей, звук и контроллеры ещё нужно проверить.\n"
        "Длительное прохождение не проверено.\n\n"
        "Исходники с локальными изменениями: SpaceRangersHD-Anbernic-sources.zip.\n"
        "Репозиторий: https://github.com/YOZH3G/SpaceRangersHD_FPC\n",
        encoding="utf-8",
    )
    (port / "build-info.json").write_text(
        json.dumps(
            {
                "firmware": firmware,
                "models_to_test": models,
                "family": family,
                "architectures": arches,
                "base_commit": subprocess.check_output(
                    ["git", "rev-parse", "HEAD"], cwd=ROOT, text=True
                ).strip(),
                "local_changes": bool(subprocess.check_output(["git", "status", "--porcelain"], cwd=ROOT, text=True).strip()),
                "minimum_glibc": "2.29",
                "minimum_system_sdl": "2.26.0",
                "sdl_source": "firmware",
                "default_renderer": "sdl",
                "renderer_fallback": "software",
                "hardware_tested": False,
                "on_screen_keyboard": {
                    "languages": ["ru", "en"],
                    "enabled_by_launcher": True,
                },
                "resource_checks": [
                    "main menu",
                    "new-game settings",
                    "new campaign generation",
                    "station",
                    "hangar",
                    "takeoff",
                    "space rendering for 20 seconds",
                ],
                "full_campaign_check": "new game and takeoff passed under QEMU; extended play untested",
                "game_assets_included": False,
            },
            indent=2,
        )
        + "\n"
    )
    archive = output / f"SpaceRangersHD-{family}-{firmware}.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zipped:
        for path in sorted(staging.rglob("*")):
            if path.is_file():
                zipped.write(path, path.relative_to(staging))
    with zipfile.ZipFile(archive) as zipped:
        if zipped.testzip() is not None:
            raise RuntimeError(f"Archive integrity check failed: {archive}")
    return archive


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sdk-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    archives = [
        package(firmware, args.sdk_root.resolve(), args.output)
        for firmware in ("muOS", "KNULLI")
    ]
    (args.output / "SHA256SUMS").write_text(
        "".join(
            hashlib.sha256(path.read_bytes()).hexdigest() + "  " + path.name + "\n"
            for path in archives
        )
    )
    for path in archives:
        print(f"Packaged: {path} ({path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
