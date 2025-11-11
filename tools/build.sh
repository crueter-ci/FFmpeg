#!/bin/bash

set -e

# shellcheck disable=SC1091

. tools/common.sh

## Buildtime/Input Variables ##

: "${ARCH:=amd64}"
: "${BUILD_DIR:=build}"

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

case "$PLATFORM" in
	linux)
		FFmpeg_HWACCEL_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${VAAPI_ACCEL[@]}"
			"${NVDEC_ACCEL[@]}"
        )
		;;
	freebsd)
		FFmpeg_HWACCEL_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${VAAPI_ACCEL[@]}"
			"${NVDEC_ACCEL[@]}"
        )
		;;
	openbsd)
		FFmpeg_HWACCEL_FLAGS=(
			"${VULKAN_ACCEL[@]}"

			--extra-cflags="-I/usr/local/include"
        )
		;;
	solaris)
		;;
	macos)
		FFmpeg_HWACCEL_FLAGS=(
            --enable-videotoolbox
            --disable-iconv
        )
		;;
	windows)
		FFmpeg_HWACCEL_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${DXVA_ACCEL[@]}"
			"${D3D_ACCEL[@]}"

			--toolchain=msvc
			--arch="$ARCH"
			--target-os=win64
			--extra-cflags="-I\"$VULKAN_SDK/include\""
		)

		FFmpeg_HWACCEL_FLAGS+=(--extra-cflags="-I\"$FFNVCODEC_DIR/include\"")
		[ "$ARCH" = amd64 ] && FFmpeg_HWACCEL_FLAGS+=("${NVDEC_ACCEL[@]}")
		;;
	mingw)
		FFmpeg_HWACCEL_FLAGS=(
			"${VULKAN_ACCEL[@]}"
			"${DXVA_ACCEL[@]}"
			"${D3D_ACCEL[@]}"
		)

		[ "$ARCH" = amd64 ] && FFmpeg_HWACCEL_FLAGS+=("${NVDEC_ACCEL[@]}")
		;;
esac

FFmpeg_HWACCEL_FLAGS+=(
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

	# shellcheck disable=SC2054
	CONFIGURE_FLAGS=(
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
		--disable-shared
        --enable-filter=yadif,scale
        --enable-pic
		--enable-small
        --prefix=/
        "${FFmpeg_HWACCEL_FLAGS[@]}"
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
		ls "$OUT_DIR"/lib -l
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
