#!/bin/sh -ex

# This is only used for the MSVC target

export PATH="/usr/local/bin:$PATH"

_group "Installing Vulkan SDK"

VULKAN_VER=1.4.321.1
VULKAN_SDK=/c/VulkanSDK/$VULKAN_VER

if [ ! -d "$VULKAN_SDK" ]; then
	[ ! -f vulkan.exe ] && curl -L https://sdk.lunarg.com/sdk/download/$VULKAN_VER/windows/vulkan-sdk-windowxX64-$VULKAN_VER.exe -o vulkan.exe
	./vulkan.exe --root "$VULKAN_SDK" --accept-licenses --default-answer --confirm-command install
fi

export VULKAN_SDK

if [ "$ARCH" = amd64 ]; then
	## FFNVCODEC ##
	_group "Installing ffnvcodec-headers"
	echo "Root: $ROOT"

	FFNVCODEC_VER=n13.0.19.0
	FFNVCODEC_DIR="$ROOT/usr/local"

	mkdir -p "$FFNVCODEC_DIR"

	[ ! -d nv-codec-headers ] && git clone https://code.ffmpeg.org/FFmpeg/nv-codec-headers.git
	cd nv-codec-headers
	git checkout "$FFNVCODEC_VER"

	# TODO(crueter): try mingw's build
	make install PREFIX="$FFNVCODEC_DIR"

	sed -i 's|D:/a/_temp/msys64||' "$FFNVCODEC_DIR/lib/pkgconfig/ffnvcodec.pc"

	set -x
	cat D:/a/_temp/msys64/usr/local/lib/pkgconfig/ffnvcodec.pc
	cat /usr/local/lib/pkgconfig/ffnvcodec.pc
	set +x

	cd ..

	export FFNVCODEC_DIR

	## NASM ##
	_group "Installing nasm"

	NASM_VER=3.01

	if ! command -v nasm 2>/dev/null; then
		mkdir -p /usr/local/bin
		curl -L https://nasm.us/pub/nasm/releasebuilds/$NASM_VER/win64/nasm-$NASM_VER-win64.zip -o nasm.zip
		unzip nasm.zip
		mv nasm*/nasm.exe /usr/local/bin/nasm.exe
		rm -rf nasm*
	fi

	_end
else
	_group "Installing gas-preprocessor"

	if ! command -v gas-preprocessor 2>/dev/null; then
		mkdir -p /usr/local/bin
		curl -L https://github.com/FFmpeg/gas-preprocessor/raw/refs/heads/master/gas-preprocessor.pl -o gas-preprocessor.pl

		cp gas-preprocessor.pl /usr/local/bin/gas-preprocessor

		chmod a+x /usr/local/bin/gas-preprocessor

		gas-preprocessor -help
	fi
	_end
fi