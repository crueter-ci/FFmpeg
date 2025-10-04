#!/bin/bash -e

# Native compilation with msys2 (msvc sux)

[ -z "$VERSION" ] && export VERSION=8.0

# shellcheck disable=SC1091
. tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR="$PWD/out"

[ -z "$ARCH" ] && ARCH=amd64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build

REQUIRED_DLLS_NAME=requirements.txt

configure() {
    echo "-- Configuring (SHARED=$SHARED)..."

    # shellcheck disable=SC2054
    CONFIGURE_FLAGS=(
        --disable-avdevice
        --disable-avformat
        --disable-doc
        --disable-everything
        --disable-ffmpeg
        --disable-ffprobe
        --disable-iconv
        --disable-network
        --disable-swresample
        --disable-vaapi
        --disable-vdpau
        --enable-decoder=h264
        --enable-decoder=vp8
        --enable-decoder=vp9
        --enable-vulkan
        --enable-avfilter
        --enable-filter=yadif,scale
        --enable-hwaccel={h264_dxva2,h264_vulkan,vp9_vulkan,h264_d3d11va,h264_d3d11va2,vp9_dxva2,vp9_d3d11va,vp9_d3d11va2}
        --enable-dxva2
        --enable-d3d11va
        --prefix=/
    )

    [ "$SHARED" = true ] && CONFIGURE_FLAGS+=(--enable-shared)

    if [ "$ARCH" = amd64 ]; then
        CONFIGURE_FLAGS+=(
            --arch=x86_64
            --enable-hwaccel={h264_nvdec,vp8_nvdec,vp9_nvdec}
            --enable-cuvid
            --enable-ffnvcodec
            --enable-nvdec
        )
    elif [ "$ARCH" = arm64 ]; then
        # needed for cross-comp stuff
        export PATH="/opt/bin:$PATH"
        export PKG_CONFIG_PATH="/clangarm64/lib/pkgconfig/:$PKG_CONFIG_PATH"

        CONFIGURE_FLAGS+=(
            --arch=arm64
            --target-os=mingw32
            --enable-cross-compile
            --cross-prefix=aarch64-w64-mingw32-
            --extra-cflags="-I/clangarm64/include"
            --extra-ldflags="-L/clangarm64/bin"
        )
        fi

    echo "-- Package config path: $PKG_CONFIG_PATH"
    # shellcheck disable=SC2145
    echo "-- Configure flags: ${CONFIGURE_FLAGS[@]}"

    ./configure \
        "${CONFIGURE_FLAGS[@]}"
}

build() {
    echo "-- Building (SHARED=$SHARED)..."
    export CL=" /MP"

    make -j"$(nproc)"
}

strip_libs() {
    echo "-- Stripping DLLs..."

    if [ "$ARCH" = arm64 ]; then
        find . -name "*.dll" -exec aarch64-w64-mingw32-strip {} \;
    elif [ "$ARCH" = amd64 ]; then
        find . -name "*.dll" -exec strip {} \;
    fi
}

copy_build_artifacts() {
    echo "-- Copying artifacts (SHARED=$SHARED)..."
    mkdir -p "$OUT_DIR"

    make install DESTDIR="${OUT_DIR}"
    rm -rf "$OUT_DIR"/{share,lib/pkgconfig}

	if [ "$SHARED" = true ]; then
		pushd "$OUT_DIR"/bin

		popd
	fi
}

copy_cmake() {
    echo "-- Copying CMake artifacts..."

    cp "$ROOTDIR"/CMakeLists.txt "$OUT_DIR"

	# left here for compat
    cp "$ROOTDIR"/windows/ffmpeg.cmake "$OUT_DIR"

	echo -n "${REQUIRED_DLLS}" > "${OUT_DIR}"/${REQUIRED_DLLS_NAME}

    if [ "$ARCH" = amd64 ]; then
        cp /mingw64/bin/libwinpthread-1.dll "$OUT_DIR"/bin
    elif [ "$ARCH" = arm64 ]; then
        cp /opt/aarch64-w64-mingw32/bin/libwinpthread-1.dll "$OUT_DIR"/bin
    fi
}

package() {
    echo "-- Packaging..."
    mkdir -p "$ROOTDIR/artifacts"

    TARBALL=$FILENAME-windows-$ARCH-$VERSION.tar

    cd "$OUT_DIR"
    # shellcheck disable=SC2035
    tar cf "$ROOTDIR/artifacts/$TARBALL" *

    cd "$ROOTDIR/artifacts"
    zstd -10 "$TARBALL"
    rm "$TARBALL"

    "$ROOTDIR/tools/sums.sh" "$TARBALL".zst
}

ROOTDIR=$PWD

./tools/download.sh

[[ -e "$BUILD_DIR" ]] && rm -fr "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
pushd "$BUILD_DIR"

echo "-- Extracting $PRETTY_NAME $VERSION"
rm -fr "$DIRECTORY"
tar xf "$ROOTDIR/$ARTIFACT"

mv "$DIRECTORY" "$FILENAME-$VERSION-$ARCH"
pushd "$FILENAME-$VERSION-$ARCH"

"$ROOTDIR"/tools/libvers.sh

REQUIRED_DLLS="avcodec-${AVCODEC_VER}.dll;avutil-${AVUTIL_VER}.dll;libwinpthread-1.dll;swscale-${SWSCALE_VER}.dll;avfilter-${AVFILTER_VER}.dll"

# Delete existing build artifacts
rm -fr "$OUT_DIR"
mkdir -p "$OUT_DIR" || exit 1

# Shared
export SHARED=true

configure
build
strip_libs
copy_build_artifacts

# Static
export SHARED=false

configure
build
copy_build_artifacts

copy_cmake
package

echo "-- Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in $OUT_DIR"

popd
popd
