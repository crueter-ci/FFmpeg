#!/bin/bash -e

set -e

export PKG_CONFIG_PATH=/usr/lib/pkgconfig/

. tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out

[ -z "$VERSION" ] && VERSION=8.0
[ -z "$ARCH" ] && ARCH=amd64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build

REQUIRED_DLLS_NAME=requirements.txt

configure() {
    echo "Configuring..."

    log_file=$1

    BASE_FLAGS=(
        --enable-cross-compile
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
        --enable-d3d11va
        --enable-shared
        --enable-dxva2
        --enable-decoder=h264
        --enable-decoder=vp8
        --enable-decoder=vp9
        --enable-vulkan
        --enable-avfilter
        --enable-filter=yadif,scale
        --extra-cflags=-I/usr/include/vulkan
        --extra-cflags=-I/usr/include/AMF
        --enable-hwaccel={h264_dxva2,h264_d3d11va,h264_d3d11va2,h264_vulkan,vp9_dxva2,vp9_d3d11va,vp9_d3d11va2,vp9_vulkan}
    )

    ARM_FLAGS=(
        --arch=arm64
        --target-os=mingw32
        --cross-prefix=aarch64-w64-mingw32-
    )

    AMD_FLAGS=(
        --arch=x86_64
        --target-os=mingw32
        --cross-prefix=x86_64-w64-mingw32-
        --enable-nvdec
        --enable-ffnvcodec
        --enable-hwaccel={h264_nvdec,vp8_nvdec,vp9_nvdec}
        --enable-cuvid
        --extra-cflags=-I/usr/local/cuda/include
        --extra-cflags=-I/usr/include/ffnvcodec
        --extra-ldflags=-L/usr/local/cuda/lib64
        --prefix=/
    )

    [ "$TARGET" = "windows-amd64" ] && ARCH_FLAGS="${AMD_FLAGS[@]}" || ARCH_FLAGS="${ARM_FLAGS[@]}"

    echo "Architecture flags: $ARCH_FLAGS"

    ./configure \
        "${BASE_FLAGS[@]}" \
        "$ARCH_FLAGS"
}

build() {
    log_file=$1

    echo "Building..."
    export CL=" /MP"

    make -j$(nproc)
}

strip_libs() {
    find . -name "*.dll" -exec x86_64-w64-mingw32-strip {} \;
}

copy_build_artifacts() {
    echo "Copying artifacts..."
    mkdir -p $OUT_DIR

    make install DESTDIR=${OUT_DIR}
    rm -rf $OUT_DIR/{share,lib/pkgconfig}
}

copy_cmake() {
    cp $ROOTDIR/CMakeLists.txt "$OUT_DIR"

    cp $ROOTDIR/windows/ffmpeg.cmake "$OUT_DIR"

    sed -i "s/AVCODEC_VER/$AVCODEC_VER/" "$OUT_DIR/ffmpeg.cmake"
    sed -i "s/AVUTIL_VER/$AVUTIL_VER/" "$OUT_DIR/ffmpeg.cmake"
    sed -i "s/SWSCALE_VER/$SWSCALE_VER/" "$OUT_DIR/ffmpeg.cmake"
    sed -i "s/AVFILTER_VER/$AVFILTER_VER/" "$OUT_DIR/ffmpeg.cmake"

    echo -n ${REQUIRED_DLLS} > ${OUT_DIR}/${REQUIRED_DLLS_NAME}
    cp $(find /usr/x86_64-w64-mingw32/ | grep libwinpthread-1.dll | head -n 1) ${OUT_DIR}/bin || true
}

package() {
    echo "Packaging..."
    mkdir -p "$ROOTDIR/artifacts"

    TARBALL=$FILENAME-windows-$ARCH-$VERSION.tar

    cd "$OUT_DIR"
    tar cf $ROOTDIR/artifacts/$TARBALL *

    cd "$ROOTDIR/artifacts"
    zstd -10 $TARBALL
    rm $TARBALL

    $ROOTDIR/tools/sums.sh $TARBALL.zst
}

ROOTDIR=$PWD

./tools/download.sh

[[ -e "$BUILD_DIR" ]] && rm -fr "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
pushd "$BUILD_DIR"

echo "Extracting $PRETTY_NAME $VERSION"
rm -fr $DIRECTORY
tar xf "$ROOTDIR/$ARTIFACT"

mv "$DIRECTORY" "$FILENAME-$VERSION-$ARCH"
pushd "$FILENAME-$VERSION-$ARCH"

AVCODEC_VER=$(grep '#define LIBAVCODEC_VERSION_MAJOR' libavcodec/version_major.h | sed 's/.* //g')
AVUTIL_VER=$(grep '#define LIBAVUTIL_VERSION_MAJOR' libavutil/version.h | sed 's/.* //g')
SWSCALE_VER=$(grep '#define LIBSWSCALE_VERSION_MAJOR' libswscale/version_major.h | sed 's/.* //g')
AVFILTER_VER=$(grep '#define LIBAVFILTER_VERSION_MAJOR' libavfilter/version_major.h | sed 's/.* //g')

REQUIRED_DLLS="avcodec-${AVCODEC_VER}.dll;avutil-${AVUTIL_VER}.dll;libwinpthread-1.dll;swscale-${SWSCALE_VER}.dll;avfilter-${AVFILTER_VER}.dll"

log_file="build_${ARCH}_${VERSION}.log"
configure ${log_file}

# Delete existing build artifacts
rm -fr "$OUT_DIR"
mkdir -p "$OUT_DIR" || exit 1

build ${log_file}
strip_libs
copy_build_artifacts

if [ ! -d "$OUT_DIR/include" ]; then
    cp -a include "$OUT_DIR/" || exit 1
fi

copy_cmake
package

echo "Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in $OUT_DIR"

popd
popd
