# Запись от главного меню до космоса

Эта запись относится к прежнему тегу `anbernic-keyboard-2026.10.11`
на enhanced-ветке. После переноса на upstream `main` её бинарник не изменён;
это историческая демонстрация, а не проверка новой сборки с SDL по умолчанию.

[Смотреть MP4](https://github.com/YOZH3G/SpaceRangersHD_FPC/blob/main/docs/media/aarch64-menu-to-space.mp4)
· [Сведения о записи](aarch64-menu-to-space.json)

- Платформа: Linux AArch64 через QEMU user-mode, SDL software renderer из SDK.
- Использован исполняемый файл из пакета для ArkOS. Прошивка ArkOS не запускалась;
  физическая приставка в записи не участвовала.
- Продолжительность: 2:28,2; 1024×768, 10 кадров/с, H.264 и AAC stereo.
- Последовательность: главное меню → создание персонажа → генерация галактики
  → центр рейнджеров → ангар → вылет → 20 секунд в космосе.
- Кадры считаны из SDL renderer. Когда игра считает галактику и не обновляет
  изображение, запись удерживает последний кадр, сохраняя реальное время.
- Звуковая дорожка захвачена из callback SDL_mixer с dummy audio backend.
  Это не проверка звукового драйвера или динамиков приставки.
- Монтажа, ускорения и замены кадров скриншотами нет. Стандартные быстрые
  переходы порта включены параметром `--transitions=fast`.
- Ресурсы: предоставленная лицензионная копия 2.1.2500. Игровые пакеты и
  сохранения в репозиторий не входят.
- Игра завершилась с кодом 0 после вылета. Хеш проверенного бинарника находится
  в JSON; он совпадает с AArch64-файлом опубликованного релиза.

## Повторная запись в подготовленной среде

Команды ниже относятся к исходникам тега `anbernic-keyboard-2026.10.11`
и его тестовому адаптеру. Используйте отдельную копию этого тега и бинарник
из соответствующего релиза. Компилируется только тестовая библиотека:

```sh
source /workspace/.cloud-setup/env.sh
/workspace/.cloud-setup/anbernic/arm64/bin/aarch64-linux-gnu-clang \
  -D_GNU_SOURCE -shared -fPIC -O2 -Wall -Wextra -Werror \
  tools/tests/linux_video_capture.c -lSDL2 -ldl \
  -o .local/anbernic/resource-tests/video-capture-aarch64.so
python tools/tests/record_linux_video.py \
  --game-dir /path/to/licensed-game \
  --sdk-root /workspace/.cloud-setup/anbernic \
  --qemu /workspace/.cloud-setup/sysroot/usr/bin/qemu-aarch64 \
  --preload .local/anbernic/resource-tests/video-capture-aarch64.so \
  --profile .local/anbernic/resource-tests/aarch64-video-new \
  --output .local/anbernic/aarch64-menu-to-space.mp4
```

Нужны собранный AArch64-порт, SDK, QEMU и ffmpeg с libx264/AAC.
Каталог `--profile` должен быть новым; исходный профиль игрока не используется.

English: real-time footage of the Linux AArch64 build used in the ArkOS package,
recorded under QEMU, not on an Anbernic device. It includes the complete new-game
sequence and actual mixer audio. Metadata and reproducible commands are above.
