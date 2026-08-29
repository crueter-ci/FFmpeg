#!/bin/sh -e

sudo apt-get update
sudo apt-get install -y \
    nasm \
    build-essential \
    git \
    unzip \
    gcc \
    libffmpeg-nvenc-dev \
    libvulkan-dev \
    libva-dev