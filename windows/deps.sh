#!/bin/sh -e

# normal packages
PACKAGES="make pkgconf diffutils mingw-w64-x86_64-gcc"

# mingw packages
if [ "$ARCH" = arm64 ]; then
    # cross
    for i in gcc winpthreads; do
        PACKAGES="$PACKAGES mingw-w64-cross-mingwarm64-$i"
    done

    for i in vulkan-loader pkg-config vulkan-headers; do
        PACKAGES="$PACKAGES mingw-w64-clang-aarch64-$i"
    done

elif [ "$ARCH" = amd64 ]; then
    for i in nasm ffnvcodec-headers vulkan-headers winpthreads; do
        PACKAGES="$PACKAGES mingw-w64-x86_64-$i"
    done
fi

pacman -S --noconfirm --needed $PACKAGES
