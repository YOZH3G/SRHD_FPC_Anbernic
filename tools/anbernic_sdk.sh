#!/bin/bash
# Create the Anbernic/TrimUI cross SDK used by tools/build_linux.py and
# tools/package_anbernic.py on an Ubuntu 24.04 x86_64 host.
#
#   tools/anbernic_sdk.sh SDK_DIR [sysroot|fpc|all]
#
# sysroot: SDK_DIR/{arm64,armhf}/{root,bin}. Ubuntu 20.04 sysroots keep the
#          binaries at glibc 2.29 or older; SDL 2.32.4 is installed into them
#          for linking and QEMU checks only and is never packaged.
# fpc:     SDK_DIR/fpc/{arm64,armhf}, cross compilers and RTL from vendor/fpc.
#
# Host packages: clang-19 lld-19 llvm-19 fp-compiler fp-utils
# binutils-aarch64-linux-gnu binutils-arm-linux-gnueabihf cmake ninja-build make
# debootstrap curl. debootstrap needs root; sudo is used when not running as root.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SDK=$(realpath -m "${1:?usage: $0 SDK_DIR [sysroot|fpc|all]}")
STEP=${2:-all}
SUDO=$([ "$(id -u)" = 0 ] || echo sudo)
# FPC's LLVM backend calls the unversioned clang tools.
export PATH=/usr/lib/llvm-19/bin:$PATH

MIRROR=http://ports.ubuntu.com/ubuntu-ports
PACKAGES=libc6-dev,libgcc-9-dev,libstdc++-9-dev,libogg-dev,libvorbis-dev,libjpeg-turbo8-dev,libjpeg8-dev,libpng-dev,zlib1g-dev,libasound2-dev,libdrm-dev,libegl1-mesa-dev,libgles2-mesa-dev,libgbm-dev,libudev-dev
SDL_VERSION=2.32.4
SDL_SHA256=f15b478253e1ff6dac62257ded225ff4e7d0c5230204ac3450f1144ee806f934
# The bundled gptokeyb (stock firmware packages) links the firmware's libevdev.
EVDEV_URL=$MIRROR/pool/main/libe/libevdev
EVDEV_DEBS=(
    "libevdev-dev_1.9.0+dfsg-1ubuntu0.2_arm64.deb e51567e10a74123cc20b635cd0f6bed3128dbda873ef80914faeba0c599e7613"
    "libevdev2_1.9.0+dfsg-1ubuntu0.2_arm64.deb c3fd503df91e0db5455e239707f99a1f9c0beefdd5d451eda724ed9936b9f5f1"
)
# Defines the FPC runtime needs to keep Delphi-compatible random numbers and math.
RTL_DEFINES="-dCLASSESINLINE -dFPC_USE_SIMPLE_RANDOM -dFPC_USE_PC24_RANDOM -dFPC_USE_PC24_MATH"

triplet() { [ "$1" = arm64 ] && echo aarch64-linux-gnu || echo arm-linux-gnueabihf; }

fetch() {
    local url=$1 sha=$2 out=$3
    [ -f "$out" ] && echo "$sha  $out" | sha256sum -c --quiet - 2>/dev/null && return
    curl -fsSL --retry 3 -o "$out.part" "$url"
    echo "$sha  $out.part" | sha256sum -c --quiet -
    mv "$out.part" "$out"
}

build_sysroot() {
    local arch=$1 t root bin extra
    t=$(triplet "$arch")
    root=$SDK/$arch/root
    bin=$SDK/$arch/bin
    rm -rf "${SDK:?}/$arch"
    mkdir -p "$root" "$bin"
    # First stage only: it downloads and unpacks the packages without running
    # foreign binaries. Unpack every downloaded package for headers and libraries.
    $SUDO debootstrap --foreign --variant=minbase --arch="$arch" --include="$PACKAGES" focal "$root" "$MIRROR"
    for deb in "$root"/var/cache/apt/archives/*.deb; do
        $SUDO dpkg -x "$deb" "$root"
    done
    # Device nodes and the downloaded packages are not needed to build, and the
    # nodes cannot be restored from a cache without root.
    $SUDO rm -rf "$root"/dev/* "$root"/var/cache/apt/archives/*.deb
    $SUDO chown -R "$(id -u):$(id -g)" "$root"
    # Absolute links would resolve against the host; make them sysroot-relative.
    find "$root" -lname '/*' | while read -r link; do
        ln -sfn "$(realpath -m --relative-to="$(dirname "$link")" "$root$(readlink "$link")")" "$link"
    done
    extra=$([ "$arch" = armhf ] && echo "-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=hard" || true)
    for compiler in clang clang++; do
        cat > "$bin/$t-$compiler" <<EOF
#!/bin/sh
# Cross $compiler for $t against the Ubuntu 20.04 sysroot; lld only when linking.
link=-fuse-ld=lld
for arg in "\$@"; do case "\$arg" in -c|-S|-E|-M|-MM) link=;; esac; done
exec /usr/bin/$compiler-19 --target=$t --sysroot=$root $extra \$link "\$@"
EOF
        chmod +x "$bin/$t-$compiler"
    done
    for tool in /usr/bin/"$t"-*; do
        [ -e "$bin/$(basename "$tool")" ] || ln -s "$tool" "$bin/$(basename "$tool")"
    done
    ln -sfn "$(command -v fpcres)" "$bin/$t-fpcres"
    if [ "$arch" = arm64 ]; then
        for entry in "${EVDEV_DEBS[@]}"; do
            set -- $entry
            fetch "$EVDEV_URL/$1" "$2" "$SDK/src/$1"
            dpkg -x "$SDK/src/$1" "$root"
        done
    fi
    local build=$SDK/src/build-sdl-$arch
    rm -rf "$build"
    cmake -S "$SDK/src/SDL2-$SDL_VERSION" -B "$build" -G Ninja -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_SYSTEM_NAME=Linux -DCMAKE_SYSTEM_PROCESSOR="$([ "$arch" = arm64 ] && echo aarch64 || echo arm)" \
        -DCMAKE_C_COMPILER="$bin/$t-clang" -DCMAKE_CXX_COMPILER="$bin/$t-clang++" \
        -DCMAKE_SYSROOT="$root" -DCMAKE_FIND_ROOT_PATH="$root" \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DPKG_CONFIG_EXECUTABLE=/bin/false \
        -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DSDL_STATIC=OFF -DSDL_TEST=OFF \
        -DSDL_X11=OFF -DSDL_WAYLAND=OFF -DSDL_PULSEAUDIO=OFF -DSDL_PIPEWIRE=OFF -DSDL_JACK=OFF \
        -DSDL_SNDIO=OFF -DSDL_ESD=OFF -DSDL_ARTS=OFF -DSDL_NAS=OFF -DSDL_LIBSAMPLERATE=OFF \
        -DSDL_IBUS=OFF -DSDL_DBUS=OFF -DSDL_RPATH=OFF -DSDL_KMSDRM=ON -DSDL_OFFSCREEN=ON \
        -DSDL_OPENGLES=ON -DSDL_ALSA=ON > "$build.log"
    ninja -C "$build" >> "$build.log"
    DESTDIR="$root" ninja -C "$build" install >> "$build.log"
}

build_fpc() {
    local arch=$1 t dst compiler
    t=$(triplet "$arch")
    dst=$SDK/fpc/$arch
    rm -rf "$dst"
    mkdir -p "$dst"
    (cd "$ROOT/vendor/fpc" && git archive HEAD) | tar -x -C "$dst"
    # The bootstrap compiler must be the host's stock FPC.
    if [ "$arch" = arm64 ]; then
        make -C "$dst" compiler_cycle NOWPOCYCLE=1 PP="$(command -v fpc)" CPU_TARGET=aarch64 OS_TARGET=linux \
            CROSSINSTALL=1 LLVM=1 OPT="-O2" OPTNEW="-Clv17.0 -j2"
        compiler=$dst/compiler/ppcrossa64
        make -C "$dst/rtl" all CPU_TARGET=aarch64 OS_TARGET=linux FPC="$compiler" BINUTILSPREFIX="$t-" \
            CROSSBINDIR="$SDK/$arch/bin" OPT="-O2 -OoNOFASTMATH -Clv17.0 -Aclang-llvm -XR$SDK/$arch/root $RTL_DEFINES"
    else
        make -C "$dst" compiler_cycle NOWPOCYCLE=1 PP="$(command -v fpc)" CPU_TARGET=arm OS_TARGET=linux \
            CROSSINSTALL=1 OPT="-O2 -dFPC_ARMHF"
        compiler=$dst/compiler/ppcrossarm
        make -C "$dst/rtl" all CPU_TARGET=arm OS_TARGET=linux FPC="$compiler" BINUTILSPREFIX="$t-" \
            CROSSBINDIR="$SDK/$arch/bin" \
            OPT="-O2 -OoNOFASTMATH -CaEABIHF -CpARMV7A -CfVFPV3 -XR$SDK/$arch/root $RTL_DEFINES"
    fi
    test -x "$compiler"
    git -C "$ROOT/vendor/fpc" rev-parse HEAD > "$dst/REVISION"
}

mkdir -p "$SDK/src"
case "$STEP" in
    sysroot | all)
        fetch "https://github.com/libsdl-org/SDL/releases/download/release-$SDL_VERSION/SDL2-$SDL_VERSION.tar.gz" \
            "$SDL_SHA256" "$SDK/src/SDL2-$SDL_VERSION.tar.gz"
        rm -rf "$SDK/src/SDL2-$SDL_VERSION"
        tar -xzf "$SDK/src/SDL2-$SDL_VERSION.tar.gz" -C "$SDK/src"
        for arch in arm64 armhf; do build_sysroot "$arch"; done
        ;;
esac
case "$STEP" in
    fpc | all)
        for arch in arm64 armhf; do build_fpc "$arch"; done
        ;;
esac
case "$STEP" in
    sysroot | fpc | all) echo "SDK ready: $SDK" ;;
    *) echo "Unknown step: $STEP" >&2; exit 2 ;;
esac
