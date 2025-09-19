#!/bin/sh -ex

sudo apt install build-essential nasm yasm cmake libc6 libc6-dev unzip wget libnuma1 libnuma-dev clang git libffmpeg-nvenc-dev libva-dev libvulkan-dev

if [ "$TARGET" = "windows-amd64" ]; then
  sudo apt-get gcc-mingw-w64-x86-64 mingw-w64-tools nvidia-driver-575

  wget https://developer.download.nvidia.com/compute/cuda/12.9.1/local_installers/cuda_12.9.1_575.57.08_linux.run
  sudo sh cuda_*_linux.run --no-man-page --toolkit --silent --override
  git clone --depth 1 https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git
  cd AMF
  sudo cp -r amf/public/include/* /usr/include/AMF
fi

if [ "$TARGET" = "windows-arm64" ]; then
  ARTIFACT=aarch64-w64-mingw32-msvcrt-toolchain.tar.gz
  wget https://github.com/Windows-on-ARM-Experiments/mingw-woarm64-build/releases/download/2025-07-15/$ARTIFACT

  mkdir -p mingw
  cd mingw
  tar xf ../$ARTIFACT

  echo "$PWD" >> $GITHUB_PATH
fi