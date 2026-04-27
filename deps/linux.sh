#!/bin/sh -ex

sudo apt-get update

sudo apt-get install -y \
    nasm \
    cmake \
    build-essential \
    git \
    unzip \
    gcc \
    libdrm-dev \
    ninja-build \
	libx11-xcb-dev \
	libxrandr-dev