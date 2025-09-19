#!/bin/bash

set -e

source tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out

# Android needs the NDK
[ -z "$ANDROID_NDK_ROOT" ] && echo "You must supply the ANDROID_NDK_ROOT environment variable." && exit 1
[ -z "$ARCH" ] && ARCH=arm64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build
[ -z "$ANDROID_API" ] && ANDROID_API=23

configure() {
    log_file=$1

    export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"

    declare hosts=("linux-x86_64" "linux-x86" "darwin-x86_64" "darwin-x86")
    for host in "${hosts[@]}"; do
        if [ -d "$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin" ]; then
            ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin"
            export PATH="$ANDROID_TOOLCHAIN:$PATH"
            break
        fi
    done

    # Configure here (e.g. cmake or the like)
}

build() {
    log_file=$1

    echo "Building..."

    # Enter your target here (e.g build_libs) or cmake build command
    make -j$(nproc) 2>&1 1>>${log_file} \
        | tee -a ${log_file} || exit 1
}

strip_libs() {
    # Change to match your library's names
    find . -name "libcrypto*.so" -exec llvm-strip --strip-all {} \;
    find . -name "libssl*.so" -exec llvm-strip --strip-all {} \;
}

copy_build_artifacts() {
    mkdir $OUT_DIR/lib

    # Change to match your library's names
    cp lib{ssl,crypto}.{so,a} "$OUT_DIR/lib" || exit 1
}

copy_cmake() {
    cp $ROOTDIR/CMakeLists.txt "$OUT_DIR"

    # Rename "software" to your software's name
    cp $ROOTDIR/unix/software.cmake "$OUT_DIR"
}

package() {
    echo "Packaging..."
    mkdir -p "$ROOTDIR/artifacts"

    TARBALL=$FILENAME-android-$VERSION.tar

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

# You can change this for e.g. CMake
echo "Extracting $PRETTY_NAME $VERSION"
rm -fr $DIRECTORY
tar xf "$ROOTDIR/$ARTIFACT"

mv "$FILENAME-$VERSION" "$FILENAME-$VERSION-$ARCH"
pushd "$FILENAME-$VERSION-$ARCH"

log_file="build_${ARCH}_${VERSION}.log"
configure ${log_file}

# Delete existing build artifacts
rm -fr "$OUT_DIR"
mkdir -p "$OUT_DIR" || exit 1

build ${log_file}
strip_libs
copy_build_artifacts

# Copy the include dir only once since since it's the same for all abis
if [ ! -d "$OUT_DIR/include" ]; then
    cp -a include "$OUT_DIR/" || exit 1

    # Clean include folder
    find "$OUT_DIR/" -name "*.in" -delete
    find "$OUT_DIR/" -name "*.def" -delete
fi

copy_cmake
package

popd
popd
