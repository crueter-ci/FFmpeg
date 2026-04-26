#!/bin/sh -ex

# This is only used for the MSVC target

export PATH="/usr/local/bin:$PATH"
: "${DEPS_DIR:=build/deps}"

VULKAN_VER=1.4.341.1
VULKAN_SDK=/c/VulkanSDK/$VULKAN_VER

if [ ! -d "$VULKAN_SDK" ]; then
	_group "Installing Vulkan SDK"
	[ ! -f vulkan.exe ] && curl -L https://sdk.lunarg.com/sdk/download/$VULKAN_VER/windows/vulkan-sdk-windowxX64-$VULKAN_VER.exe -o vulkan.exe
	./vulkan.exe --root "$VULKAN_SDK" --accept-licenses --default-answer --confirm-command install
	_end
fi

export VULKAN_SDK

if amd64; then
	:
	## FFNVCODEC ##
	_group "Installing ffnvcodec-headers"
	echo "Root: $ROOT"

	FFNVCODEC_VER=n13.0.19.0
	FFNVCODEC_DIR="$ROOTDIR/$DEPS_DIR/ffnvcodec"

	mkdir -p "$FFNVCODEC_DIR" "$ROOTDIR/$BUILD_DIR"
	
	cd "$ROOTDIR/$BUILD_DIR"
	[ ! -d nv-codec-headers ] && git clone https://code.ffmpeg.org/FFmpeg/nv-codec-headers.git

	cd nv-codec-headers
	git checkout "$FFNVCODEC_VER"

	make install PREFIX="$FFNVCODEC_DIR"

	cd "$ROOTDIR"

	export FFNVCODEC_DIR
	_end

	# ## NASM ##
	# _group "Installing nasm"

	# NASM_VER=3.01

	# if ! command -v nasm 2>/dev/null; then
	# 	mkdir -p /usr/local/bin
	# 	curl -L https://nasm.us/pub/nasm/releasebuilds/$NASM_VER/win64/nasm-$NASM_VER-win64.zip -o nasm.zip
	# 	unzip nasm.zip
	# 	mv nasm*/nasm.exe /usr/local/bin/nasm.exe
	# 	rm -rf nasm*
	# fi

	# _end
	_group "Verifying dependencies"
	nasm --version
	if pkg-config ffnvcodec; then
		echo "ffnvcodec found"
	fi
	_end
else
	if ! command -v gas-preprocessor.pl 2>/dev/null; then
		_group "Installing gas-preprocessor"

		mkdir -p /usr/local/bin
		curl -L https://github.com/FFmpeg/gas-preprocessor/raw/refs/heads/master/gas-preprocessor.pl -o gas-preprocessor.pl

		install -Dm755 gas-preprocessor.pl /usr/local/bin/gas-preprocessor.pl
		rm gas-preprocessor.pl

		_end
	fi
fi