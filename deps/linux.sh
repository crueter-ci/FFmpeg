#!/bin/sh -ex

pacman -Syu --needed --noconfirm \
    nasm \
    yasm \
    cmake \
    base-devel \
    git \
    unzip \
    gcc \
    ffnvcodec-headers \
    vulkan-headers \
    libva