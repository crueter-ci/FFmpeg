#!/bin/sh -e

pkg_add -u

# OpenBSD compiler situation is sad
pkg_add gawk gsed bash vulkan-headers unzip-6.0p18-iconv curl gcc-11.2.0p19 g++-11.2.0p19 nasm