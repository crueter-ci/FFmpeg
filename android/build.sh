#!/bin/bash
set -e

# NB: use ndk 25

[ -z "$ANDROID_NDK_ROOT" ] && echo "You must supply the ANDROID_NDK_ROOT environment variable." && exit 1
[ -z "$ANDROID_SDK_ROOT" ] && echo "You must supply the ANDROID_SDK_ROOT environment variable." && exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out
[ -z "$ARCH" ] && ARCH=aarch64

# 8.0 requires more patching, so "fake" 8.0 for now for consistency
VERSION=${VERSION:-8.0}

ROOTDIR=$PWD
ARTIFACTS_DIR=$PWD/artifacts
mkdir -p "$ARTIFACTS_DIR"

REPO=ffmpeg-kit-16KB

ARCH=arm64-v8a

echo "-- Cloning..."
[ ! -d "$REPO" ] && git clone --depth 1 https://github.com/AliAkhgar/$REPO.git

cd $REPO

echo "-- Patching..."

# Version updates
sed -i 's/eaa68fad9e5d201d42fde51665f2d137ae96baf0/c24e06c2e184345ceb33eb20a15d1024d9fd3497/' scripts/source.sh
sed -i "s/n6.0/n7.1.1/" scripts/source.sh
sed -i 's|arthenica/FFmpeg|FFmpeg/FFmpeg|' scripts/source.sh
sed -i 's|arthenica/libvpx|webmproject/libvpx|' scripts/source.sh
sed -i 's/v1.13.0/v1.13.1/' scripts/source.sh
sed -i 's/v0.8.0/v0.10.1/' scripts/source.sh

# fixes
sed -i 's/--disable-static //' scripts/android/ffmpeg.sh
sed -i 's/emms.h/emms.asm/g' scripts/android/ffmpeg.sh
sed -i '/disable-postproc/d' scripts/android/ffmpeg.sh
sed -i '20i #include <string.h>' android/ffmpeg-kit-android-lib/src/main/cpp/ffprobekit.c

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
    --no-archive

echo "-- Packaging..."

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

cp -r prebuilt/android-arm64/{ffmpeg,libvpx,x264}/* "$OUT_DIR"

export PATH="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
find . -name "*.so" -exec llvm-strip --strip-all {} \;

cp "$ROOTDIR/CMakeLists.txt" "$OUT_DIR"

# left here for compat
cp "$ROOTDIR/android/ffmpeg.cmake" "$OUT_DIR"

TARBALL=$ARTIFACTS_DIR/ffmpeg-android-$VERSION.tar

cd "$OUT_DIR"
rm -rf share lib/pkgconfig

tar cf "$TARBALL" ./*

zstd -10 "$TARBALL"
rm "$TARBALL"

"$ROOTDIR"/tools/sums.sh "$TARBALL".zst