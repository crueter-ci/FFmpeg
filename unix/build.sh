#!/bin/bash -e

# shellcheck disable=SC1091
. tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out
[ -z "$ARCH" ] && ARCH=amd64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build
[ -z "$PLATFORM" ] && PLATFORM=linux

[ "$PLATFORM" = "solaris" ] && MAKE="gmake" || MAKE="make"

configure() {
	echo "-- Configuring..."

    FFmpeg_HWACCEL_FLAGS=(
        --enable-cuvid
        --enable-ffnvcodec
        --enable-nvdec
        --enable-vulkan
        --enable-hwaccel={h264_nvdec,vp8_nvdec,vp9_nvdec,h264_vaapi,vp8_vaapi,vp9_vaapi,h264_vulkan,vp9_vulkan}
    )

    # Configure here (e.g. cmake or the like)
    ./configure \
        --disable-avdevice \
        --disable-avformat \
        --disable-doc \
        --disable-everything \
        --disable-ffmpeg \
        --disable-ffprobe \
        --disable-network \
        --disable-swresample \
        --enable-shared \
        --enable-decoder=h264 \
        --enable-decoder=vp8 \
        --enable-decoder=vp9 \
        --enable-filter=yadif,scale \
        --enable-pic \
        --prefix=/ \
        "${FFmpeg_HWACCEL_FLAGS[@]}"
}

build() {
    echo "-- Building..."

    $MAKE -j"$(nproc)"
}

strip_libs() {
    find . -name "lib*.so" -exec strip {} \;
}

copy_build_artifacts() {
    echo "-- Copying artifacts..."
    mkdir -p "$OUT_DIR"

    $MAKE install DESTDIR="$OUT_DIR"
    rm -rf "$OUT_DIR/lib/pkgconfig"
}

copy_cmake() {
    cp "$ROOTDIR"/CMakeLists.txt "$OUT_DIR"

	# left here for compat
    cp "$ROOTDIR"/unix/ffmpeg.cmake "$OUT_DIR"
}

package() {
    echo "Packaging..."
    mkdir -p "$ROOTDIR/artifacts"

    TARBALL=$FILENAME-$PLATFORM-$ARCH-$VERSION.tar

    cd "$OUT_DIR"
    tar cf "$ROOTDIR/artifacts/$TARBALL" ./*

    cd "$ROOTDIR/artifacts"
    zstd -10 "$TARBALL"
    rm "$TARBALL"

    "$ROOTDIR"/tools/sums.sh "$TARBALL".zst
}

ROOTDIR=$PWD
export ROOTDIR

./tools/download.sh

[ -e "$BUILD_DIR" ] && rm -fr "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
pushd "$BUILD_DIR"

echo "Extracting $PRETTY_NAME $VERSION"
rm -fr "$DIRECTORY"
tar xf "$ROOTDIR/$ARTIFACT"

mv "$DIRECTORY" "$FILENAME-$VERSION-$ARCH"
pushd "$FILENAME-$VERSION-$ARCH"

. "$ROOTDIR"/tools/libvers.sh

configure

# Delete existing build artifacts
rm -fr "$OUT_DIR"
mkdir -p "$OUT_DIR" || exit 1

build
strip_libs
copy_build_artifacts

if [ ! -d "$OUT_DIR/include" ]; then
    cp -p -R include "$OUT_DIR/" || exit 1
fi

copy_cmake
package

echo "Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in $OUT_DIR"

popd
popd
