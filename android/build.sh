#!/bin/bash
set -e

# NB: use ndk 25
# shellcheck disable=SC2034
PLATFORM=android

# shellcheck disable=SC1091
. ./tools/common.sh

[ -z "$ANDROID_NDK_ROOT" ] && echo "You must supply the ANDROID_NDK_ROOT environment variable." && exit 1
[ -z "$ANDROID_SDK_ROOT" ] && echo "You must supply the ANDROID_SDK_ROOT environment variable." && exit 1

ARTIFACTS_DIR=$PWD/artifacts
mkdir -p "$ARTIFACTS_DIR"

REPO=ffmpeg-kit

echo "-- Cloning..."
[ ! -d "$REPO" ] && git clone --depth 1 https://github.com/crueter-ci/$REPO.git

cd $REPO

# echo "-- Patching..."

echo "-- Building..."

./android.sh \
    --enable-gpl \
    --enable-x264 \
    --enable-libvpx \
    --enable-android-media-codec \
    --disable-arm-v7a-neon \
    --disable-arm-v7a \
    --disable-x86-64 \
    --disable-x86 \
    --no-archive || { cat build.log; grep -re 'cmake_minimum_required' src; exit 1; }

echo "-- Packaging..."

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp -r prebuilt/android-arm64/{ffmpeg,libvpx,x264}/* "$OUT_DIR"

export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
find . -name "*.so" -exec llvm-strip --strip-all {} \;

copy_cmake

cd "$OUT_DIR"
rm -rf share lib/pkgconfig

package