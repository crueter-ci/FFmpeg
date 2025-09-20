#!/bin/sh -e

# normal packages
PACKAGES="make pkgconf diffutils"

# mingw packages
if [ "$ARCH" = arm64 ]; then
    PACKAGES="mingw-w64-cross-mingwarm64-gcc mingw-w64-clang-aarch64-vulkan-loader mingw-w64-clang-aarch64-vulkan-headers mingw-w64-clang-aarch64-pkg-config"
elif [ "$ARCH" = amd64 ]; then
    for i in nasm gcc SDL2 ffnvcodec-headers vulkan-headers; do
        PACKAGES="mingw-w64-x86_64-$i $PACKAGES"
    done
fi

pacman -S --noconfirm --needed $PACKAGES
