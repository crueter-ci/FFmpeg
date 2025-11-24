#!/bin/bash

set -e

# shellcheck disable=SC1091

. tools/common.sh

## Buildtime/Input Variables ##

android() {
	[ "$PLATFORM" = android ]
}

DEFAULT_ARCH=amd64
if android; then
	DEFAULT_ARCH=aarch64
	: "${ANDROID_NDK_ROOT:?-- You must supply the ANDROID_NDK_ROOT environment variable.}"
	: "${ANDROID_API:=23}"
	android_paths
fi

: "${ARCH:=$DEFAULT_ARCH}"
: "${BUILD_DIR:=build}"

if android; then
	CC="${ARCH}"-linux-android"${ANDROID_API}"-clang
	CXX="${ARCH}"-linux-android"${ANDROID_API}"-clang++
fi

## Platform Stuff ##

msvc() {
	[ "$PLATFORM" = windows ]
}

msys() {
	[ "$PLATFORM" = mingw ]
}

if msvc; then
 	# shellcheck disable=SC2154
	# gets cl.exe and link.exe into the PATH
	CLPATH=$(cygpath -u "$VCToolsInstallDir\\bin\\Host${VSCMD_ARG_HOST_ARCH}\\${VSCMD_ARG_TGT_ARCH}")
 	export PATH="$CLPATH:$PATH"
	echo "$CLPATH"
	ls "$CLPATH"
	cl.exe
fi

# shellcheck disable=SC1091
msvc && . windows/prepare.sh

VULKAN_ACCEL=(--enable-vulkan --enable-hwaccel={h264,vp9}_vulkan)
NVDEC_ACCEL=(--enable-cuvid
            --enable-ffnvcodec
            --enable-nvdec
			--enable-hwaccel={h264,vp8,vp8}_nvdec)
VAAPI_ACCEL=(--enable-vaapi --enable-hwaccel={h264,vp8,vp9}_vaapi)
DXVA_ACCEL=(--enable-dxva2 --enable-hwaccel={h264,vp9}_dxva2)
D3D_ACCEL=(--enable-d3d11va --enable-hwaccel={h264,vp9}_d311vda{,2})
MEDIACODEC_ACCEL=(--enable-mediacodec
				  --enable-jni
				  --enable-decoder={h264,vp8,vp9}_mediacodec)

case "$PLATFORM" in
	linux)
		PLATFORM_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${VAAPI_ACCEL[@]}"
			"${NVDEC_ACCEL[@]}"
        )
		;;
	freebsd)
		PLATFORM_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${VAAPI_ACCEL[@]}"
			"${NVDEC_ACCEL[@]}"
        )
		;;
	openbsd)
		PLATFORM_FLAGS=(
			"${VULKAN_ACCEL[@]}"

			--extra-cflags="-I/usr/local/include"
        )
		;;
	solaris)
		;;
	android)
		PLATFORM_FLAGS=(
			"${MEDIACODEC_ACCEL[@]}"

			--extra-ldflags="-Wl,-z,max-page-size=16384,--hash-style=both"
			--strip=llvm-strip

			--enable-cross-compile
			--target-os=android
			--arch="$ARCH"
		)
		;;
	macos)
		PLATFORM_FLAGS=(
            --enable-videotoolbox
            --disable-iconv

			--extra-cflags="-mmacosx-version-min=11.0"
			--extra-ldflags="-mmacosx-version-min=11.0"
        )
		;;
	windows)
		PLATFORM_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${DXVA_ACCEL[@]}"
			"${D3D_ACCEL[@]}"

			--toolchain=msvc
			--arch="$ARCH"
			--target-os=win64
			--extra-cflags="-I\"$VULKAN_SDK/include\""
		)

		PLATFORM_FLAGS+=(--extra-cflags="-I\"$FFNVCODEC_DIR/include\"")
		[ "$ARCH" = amd64 ] && PLATFORM_FLAGS+=("${NVDEC_ACCEL[@]}")
		;;
	mingw)
		PLATFORM_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${DXVA_ACCEL[@]}"
			"${D3D_ACCEL[@]}"
		)

		[ "$ARCH" = amd64 ] && PLATFORM_FLAGS+=("${NVDEC_ACCEL[@]}")
		;;
esac

PLATFORM_FLAGS+=(
	--cc="$CC"
	--cxx="$CXX"
)

## Build Functions ##

# cmake
configure() {
	echo "-- Configuring $PRETTY_NAME..."

	msvc && [ "$ARCH" = amd64 ] && export PKG_CONFIG_PATH="$FFNVCODEC_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
    echo "-- Package config path: $PKG_CONFIG_PATH"

	msvc && [ "$ARCH" = amd64 ] && pkg-config --cflags ffnvcodec

	# TODO: WINDOWS SHARED
	if ! msvc && ! msys; then
		CONFIGURE_FLAGS+=(--enable-shared)
	fi

	# FFmpeg's x86_64 assembly on Android sucks
	# Remember folks: this is why you use C :)
	android && [ "$ARCH" = "x86_64" ] && CONFIGURE_FLAGS+=(--disable-asm)

	# shellcheck disable=SC2054
	CONFIGURE_FLAGS+=(
		--disable-avdevice
        --disable-avformat
        --disable-doc
        --disable-everything
        --disable-ffmpeg
        --disable-ffprobe
        --disable-network
        --disable-swresample
        --enable-decoder=h264
        --enable-decoder=vp8
        --enable-decoder=vp9
		--enable-static
        --enable-filter=yadif,scale
		--enable-small
		--enable-pic
        --prefix=/
        "${PLATFORM_FLAGS[@]}"
	)

	echo "-- Configure flags: ${CONFIGURE_FLAGS[*]}"

	./configure "${CONFIGURE_FLAGS[@]}"
}

build() {
    echo "-- Building $PRETTY_NAME..."
    export CL=" /MP"

    $MAKE -j"$(num_procs)"
}

strip_libs() {
	echo "-- Stripping shared libraries..."

	case "$PLATFORM" in
		windows) ;;
		android) find "$OUT_DIR" -name "*.so" -exec llvm-strip --strip-all {} \; ;;
		*) find "$OUT_DIR" -name "*.$SHARED_SUFFIX" -exec strip {} \; ;;
	esac
}

## Packaging ##
copy_build_artifacts() {
    echo "-- Copying artifacts..."
    mkdir -p "$OUT_DIR"

	if [ "$PLATFORM" = "solaris" ]; then
		mkdir -p "$OUT_DIR"/lib
		find . -name "*.a" -exec cp {} "$OUT_DIR"/lib \;
		ls "$OUT_DIR"/lib
		echo
	    $MAKE install-headers INSTALL="/usr/bin/install -C" DESTDIR="${OUT_DIR}"
	else
    	$MAKE install-libs DESTDIR="${OUT_DIR}"
	    $MAKE install-headers DESTDIR="${OUT_DIR}"
	fi
    rm -rf "$OUT_DIR"/{share,lib/pkgconfig}
}


## Cleanup ##
rm -rf "$BUILD_DIR" "$OUT_DIR"
mkdir -p "$BUILD_DIR" "$OUT_DIR"

## Download + Extract ##
download
cd "$BUILD_DIR"
extract

## Configure ##
cd "$DIRECTORY"
configure

## Build ##
build

# TODO: We don't need shared ffmpeg for now
# Their stuff sucks and doesn't let you build both at once on Windows only
# KSJKSDNFKJSDBFJKNSDBJKFBSDJKFB

## Package ##
copy_build_artifacts
copy_cmake

# strip_libs
package

echo "-- Done! Artifacts are in $ROOTDIR/artifacts, raw lib/include data is in $OUT_DIR"
