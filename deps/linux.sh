#!/bin/sh -ex

pacman -Syu --needed --noconfirm \
    nasm \
    base-devel \
    git \
    unzip \
    gcc \
    ffnvcodec-headers \
    vulkan-headers \
    libva
