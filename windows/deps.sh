#!/bin/sh -e

# normal packages
PACKAGES="make pkgconf diffutils mingw-w64-x86_64-gcc"

# mingw packages
if [ "$ARCH" = arm64 ]; then
    PACKAGES="$PACKAGES mingw-w64-cross-mingwarm64-gcc"
    for i in vulkan-loader pkg-config vulkan-headers; do
        PACKAGES="mingw-w64-clang-aarch64-$i $PACKAGES"
    done

elif [ "$ARCH" = amd64 ]; then
    for i in nasm ffnvcodec-headers vulkan-headers; do
        PACKAGES="$PACKAGES mingw-w64-x86_64-$i"
    done
fi

pacman -S --noconfirm --needed $PACKAGES
