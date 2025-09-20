#!/bin/sh -ex

pacman -Syu --needed --noconfirm \
    nasm \
    yasm \
    cmake \
    base-devel \
    git \
    wget \
    unzip \
    gcc \
    ffnvcodec-headers \
    vulkan-headers \
    libva