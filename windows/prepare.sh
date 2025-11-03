#!/bin/sh -ex

# This is only used for the MSVC target

echo "-- Installing Vulkan SDK..."

VULKAN_VER=1.4.321.1
VULKAN_SDK=C:/VulkanSDK/$VULKAN_VER

FFNVCODEC_VER=n13.0.19.0

[ ! -f vulkan.exe ] && curl -L https://sdk.lunarg.com/sdk/download/$VULKAN_VER/windows/vulkan-sdk-windowxX64-$VULKAN_VER.exe -o vulkan.exe
./vulkan.exe --root "$VULKAN_SDK" --accept-licenses --default-answer --confirm-command install

export VULKAN_SDK

echo "-- Installing ffnvcodec..."

git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
cd nv-codec-headers
git checkout "$FFNVCODEC_VER"
make install PREFIX=/usr/local
cd ..