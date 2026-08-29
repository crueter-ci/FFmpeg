#!/bin/sh -e

sudo apt-get update
sudo apt-get install gnome-desktop-testing libasound2-dev libpulse-dev libaudio-dev libjack-dev \
  libsndio-dev libusb-1.0-0-dev libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxtst-dev \
  libxfixes-dev libxi-dev libxss-dev libwayland-dev libxkbcommon-dev libdrm-dev libgbm-dev \
  libgl1-mesa-dev libgles2-mesa-dev libegl1-mesa-dev libdbus-1-dev libibus-1.0-dev libudev-dev fcitx-libs-dev \
  libpipewire-0.3-dev libdecor-0-dev build-essential git make autoconf automake libtool pkg-config cmake ninja-build \
  unzip