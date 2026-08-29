#!/bin/sh -e

set -e

# shellcheck disable=SC1091

. tools/common.sh

ROOTDIR="$PWD"

copy_build_artifacts() {
	_group "Cleaning"
	rm -rf out/share out/lib/pkgconfig
	_end
}

copy_cmake() {
	_group "Copying CMake artifacts"

    cp "$ROOTDIR"/CMakeLists.txt out

	_end
}

sums() {
	for file in "$@"; do
		must_install sha512sum
		sha512sum "$file" | cut -d " " -f1 | tr -d "\n" >"$file".sha512sum
	done
}

package() {
    _group "Packaging"
    mkdir -p "$ROOTDIR/artifacts"

	TARBALL=$FILENAME-$PLATFORM-$ARCH-$VERSION.tar

    cd out
    tar cf "$ROOTDIR/artifacts/$TARBALL" ./*

    cd "$ROOTDIR/artifacts"
    zstd -10 "$TARBALL"
    rm "$TARBALL"

    sums "$TARBALL.zst"
	_end
}

copy_build_artifacts
copy_cmake
package

echo "-- Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in out"