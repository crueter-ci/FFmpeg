#!/bin/bash

set -e

source tools/common.sh || exit 1

[ -z "$OUT_DIR" ] && OUT_DIR=$PWD/out

[ -z "$VERSION" ] && VERSION=3.5.2
[ -z "$ARCH" ] && ARCH=amd64
[ -z "$BUILD_DIR" ] && BUILD_DIR=build

configure() {
    log_file=$1
    # Configure here (e.g. cmake or the like)
}

build() {
    log_file=$1

    echo "Building..."
    export CL=" /MP"
    
    # Enter your target here (e.g build_libs) or cmake build command
    nmake build_libs 2>&1 1>>${log_file} \
        | tee -a ${log_file} || exit 1
}

strip_libs() {
    # Change to match your library's names
    find . -name "libcrypto*.dll" -exec llvm-strip --strip-all {} \;
    find . -name "libssl*.dll" -exec llvm-strip --strip-all {} \;
    find . -name "libcrypto*.lib" -exec llvm-strip --strip-all {} \;
    find . -name "libssl*.lib" -exec llvm-strip --strip-all {} \;
}

copy_build_artifacts() {
    echo "Copying artifacts..."
    mkdir -p $OUT_DIR/lib

    # Change to match your library's names
    cp lib{ssl,crypto}.{dll,lib} "$OUT_DIR/lib" || exit 1
}

copy_cmake() {
    cp $ROOTDIR/CMakeLists.txt "$OUT_DIR"

    # Rename "software" to your software's name
    cp $ROOTDIR/windows/software.cmake "$OUT_DIR"
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

if [ ! -d "$OUT_DIR/include" ]; then
    cp -a include "$OUT_DIR/" || exit 1
fi

# Clean include folder
/bin/find "$OUT_DIR/" -name "*.in" -delete
/bin/find "$OUT_DIR/" -name "*.def" -delete

copy_cmake
package

echo "Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in $OUT_DIR"

popd
popd
