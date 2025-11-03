#!/bin/sh -ex

# This is only used for the MSVC target

export PATH="/usr/local/bin:$PATH"

echo "-- Installing Vulkan SDK..."

VULKAN_VER=1.4.321.1
VULKAN_SDK=/c/VulkanSDK/$VULKAN_VER

if [ ! -d "$VULKAN_SDK" ]; then
	[ ! -f vulkan.exe ] && curl -L https://sdk.lunarg.com/sdk/download/$VULKAN_VER/windows/vulkan-sdk-windowxX64-$VULKAN_VER.exe -o vulkan.exe
	./vulkan.exe --root "$VULKAN_SDK" --accept-licenses --default-answer --confirm-command install
fi

export VULKAN_SDK

if [ "$ARCH" = amd64 ]; then
	echo "-- Installing ffnvcodec..."

	FFNVCODEC_VER=n13.0.19.0
	FFNVCODEC_DIR="/usr/local"

	mkdir -p "$FFNVCODEC_DIR"

	[ ! -d nv-codec-headers ] && git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
	cd nv-codec-headers
	git checkout "$FFNVCODEC_VER"

	make install PREFIX="$FFNVCODEC_DIR"
	cd ..

	export FFNVCODEC_DIR
fi

echo "-- Installing nasm..."

NASM_VER=3.01

if ! command -v nasm 2>/dev/null; then
	mkdir -p /usr/local/bin
	curl -L https://nasm.us/pub/nasm/releasebuilds/$NASM_VER/win64/nasm-$NASM_VER-win64.zip -o nasm.zip
	unzip nasm.zip
	mv nasm*/nasm.exe /usr/local/bin/nasm.exe
	rm -rf nasm*
fi
