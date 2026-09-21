#!/bin/sh

# shellcheck disable=SC1091

set -e

. tools/common.sh

OUT_DIR="$PWD/out"

cd "$DIRECTORY"

if android; then
	: "${ANDROID_NDK_ROOT:?-- You must supply the ANDROID_NDK_ROOT environment variable.}"
	: "${ANDROID_API:=23}"
	android_paths
fi

# MSVC
if msvc; then
	_group "MSVC Setup"

	vk_pc="$(cygpath -u "${VULKAN_SDK:?}"/lib/pkgconfig)"
	nv_pc="$(cygpath -u "${FFNVCODEC_DIR:?}"/lib/pkgconfig)"

	export PKG_CONFIG_PATH="$vk_pc:$nv_pc:$PKG_CONFIG_PATH"

	printf -- "-- cl: "
	command -v cl

	printf -- "-- mt: "
	command -v mt

	printf -- "-- rc: "
	command -v rc

	printf -- "-- link: "
	command -v link

	printf -- "-- pkg-config: "
	command -v pkg-config

	printf -- "-- cmake: "
	command -v cmake

	printf -- "-- ninja: "
	command -v ninja

	printf -- "-- ffnvcodec: "
	pkg-config --cflags --libs ffnvcodec

	printf -- "-- vulkan: "
	pkg-config --cflags --libs vulkan

	_end
fi


# helpers
on() {
	for i in "$@"; do
		echo "--enable-$i"
	done
}

off() {
	for i in "$@"; do
		echo "--disable-$i"
	done
}

hwaccel() {
	accels="$1"
	shift

	for accel in $accels; do
		for codec in "$@"; do
			on "hwaccel=${codec}_$accel"
		done
	done
}

# platform flags
vk() {
	on vulkan
	hwaccel "vulkan" h264 vp9
}

directx() {
	on d3d11va d3d12va dxva2
	hwaccel "d3d11va d3d11va2 d3d12va dxva2" h264 vp9
}

vaapi() {
	on vaapi
	hwaccel "vaapi" h264 vp8 vp9
}

nvdec() {
	on cuvid ffnvcodec nvdec
	hwaccel "nvdec" h264 vp8 vp9
}

videotoolbox() {
	on videotoolbox
	hwaccel "videotoolbox" h264 vp9
}

mediacodec() {
	on mediacodec jni
	for codec in h264 vp8 vp9; do
		on "decoder=${codec}_mediacodec"
	done
}

# build flags list
flags() {
	CC=gcc
	CXX=g++

	# Vulkan + nvdec
	if linux || windows; then
		vk
		nvdec
	fi

	# VAAPI
	if linux; then
		vaapi
	fi

	# DirectX
	if windows; then
		directx
	fi

	# android
	if android; then
		mediacodec

		case "$ARCH" in
			amd64) ABI=x86_64 ;;
			aarch64) ABI=aarch64 ;;
		esac

		on cross-compile
		cat <<-EOF
			--target-os=android
			--arch=$ABI
			--toolchain=llvm
			--extra-ldflags=-Wl,-z,max-page-size=16384,--hash-style=both
			--cross-prefix=${CROSS_PREFIX}/
		EOF

		CC="${CROSS_PREFIX}/${ABI}-linux-android${ANDROID_API}-clang"
		CXX="${CROSS_PREFIX}/${ABI}-linux-android${ANDROID_API}-clang++"

		if amd64; then
			off asm
		fi
	fi

	# macOS + iOS
	if macos || ios; then
		videotoolbox
		off iconv

		if macos; then
			echo "--extra-cflags=-mmacosx-version-min=13.0"
			echo "--extra-ldflags=-mmacosx-version-min=13.0"
		else
			: "${IOS_TARGET:=iphoneos}"

			# TODO: this should be a common func :()
			sysroot="$(xcrun --sdk "$IOS_TARGET" --show-sdk-path)"
			CC="$(xcrun --sdk "$IOS_TARGET" --find clang) -isysroot ${sysroot}"
			CXX="$(xcrun --sdk "$IOS_TARGET" --find clang++) -isysroot ${sysroot}"

			on cross-compile

			echo "--extra-cflags=-mios-version-min=16.0"
			echo "--extra-ldflags=-mios-version-min=16.0"
		fi
	fi

	# msvc
	if msvc; then
		cat <<-EOF
			--toolchain=msvc
			--arch=$ARCH
			--target-os=win64
		EOF

		CC=cl
		CXX=cl
	fi

	# mingw
	if macos || (mingw && arm64); then
		CC=clang
		CXX=clang++
	fi

	# sccache
	if [ -n "$SCCACHE_PATH" ]; then
		if windows; then
			SCCACHE_PATH="$(cygpath -u "$SCCACHE_PATH")"
		fi

		CC="$SCCACHE_PATH $CC"
		CXX="$SCCACHE_PATH $CXX"
	fi

	echo --cc="$CC"
	echo --cxx="$CXX"

	# main flags
	off avdevice avformat doc everything ffmpeg ffprobe network
	on static filter=yadif,scale small pic swresample

	for codec in h264 vp8 vp9 opus; do
		on decoder="$codec"
	done

	echo "--prefix=$OUT_DIR"

	export CC CXX
}

configure() {
	_group "Configuring $PRETTY_NAME"

	FLAGS_FILE=$(mktemp)
	flags > "$FLAGS_FILE"

	set --
	while IFS= read -r line; do
		set -- "$@" "$line"
	done < "$FLAGS_FILE"
	rm -f "$FLAGS_FILE"

	echo "Flags:"
	for flag in "$@"; do
		echo "  $flag"
	done

	./configure "$@"

	if msvc; then
		# backslash greatness
		sed -i 's/; gsub(\/\\\\\/, "\/"); /; /g' ffbuild/config.mak
		sed -i 's/; gsub(\/\\\\\/, "\/")/; /g' ffbuild/config.mak
	fi

	_end
}

# configure
configure