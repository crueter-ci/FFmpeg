#!/bin/bash -e

# Native compilation with msys2 (msvc sux)

[ -z "$VERSION" ] && export VERSION=8.0

. tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out

[ -z "$ARCH" ] && ARCH=amd64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build

REQUIRED_DLLS_NAME=requirements.txt

. ./windows/deps.sh

configure() {
    echo "Configuring..."

    log_file=$1

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
        --enable-shared
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

    echo "Package config path: $PKG_CONFIG_PATH"
    echo "Configure flags: ${CONFIGURE_FLAGS[@]}"

    ./configure \
        "${CONFIGURE_FLAGS[@]}"
}

build() {
    log_file=$1

    echo "Building..."
    export CL=" /MP"

    make -j$(nproc)
}

strip_libs() {
    if [ "$ARCH" = arm64 ]; then
        find . -name "*.dll" -exec aarch64-w64-mingw32-strip {} \;
    elif [ "$ARCH" = amd64 ]; then
        find . -name "*.dll" -exec strip {} \;
    fi
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
    if [ "$ARCH" = amd64 ]; then
        cp $(find C:/msys64/mingw64 -name libwinpthread-1.dll) ${OUT_DIR}/bin
    elif [ "$ARCH" = arm64 ]; then
        cp $(find C:/msys64/opt/aarch64-w64-mingw32 -name libwinpthread-1.dll) ${OUT_DIR}/bin
    fi
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
