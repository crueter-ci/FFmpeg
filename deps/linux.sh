#!/bin/sh -e

sudo apt-get update
sudo apt-get install -y \
    nasm \
    build-essential \
    git \
    unzip \
    gcc \
    libffnvcodec-dev \
    vulkan-headers \
    libva-dev