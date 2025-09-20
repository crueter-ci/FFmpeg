#!/bin/sh -ex

# Explicitly disable man-db auto update (takes forever lol)
sudo rm /var/lib/man-db/auto-update

sudo apt-get update
sudo apt install build-essential nasm yasm cmake libc6 libc6-dev unzip wget libnuma1 libnuma-dev clang git libffmpeg-nvenc-dev libva-dev libvulkan-dev