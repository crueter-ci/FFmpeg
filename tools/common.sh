#!/bin/sh -e

## Build variables ##

# shellcheck disable=SC1091
. ./tools/vars.sh

export ROOTDIR="$PWD"

_group() {
    if [ -n "$GITHUB_RUN_ID" ]; then
		echo "##[group]$*"
	else
		echo "======= $* ======="
	fi
}

_end() {
	if [ -n "$GITHUB_RUN_ID" ]; then
		echo "##[endgroup]"
	fi
}

# vcvarsall.bat outputs Platform for some asinine reason...
# windows is case-insensitive, so attempts to set PLATFORM
# will keep the variable name as Platform
# so we have to normalize it here. thank you, microslop
if [ -n "$Platform" ] && [ -z "$PLATFORM" ]; then
	export PLATFORM="$Platform"
fi

# default platform
case "$(uname -s)" in
Linux) : "${PLATFORM:=linux}" ;;
Darwin) : "${PLATFORM:=macos}" ;;
# TODO: detect msys2
*) : "${PLATFORM:?-- You must supply the PLATFORM environment variable.}" ;;
esac

## Command Checks ##

must_install() {
	for cmd in "$@"; do
		command -v "$cmd" >/dev/null 2>&1 || { echo "-- $cmd must be installed" && exit 1; }
	done
}

must_install curl zstd

case "$ARTIFACT" in
	*.zip) must_install unzip ;;
	*.tar.*) ;;
	*.7z) must_install 7z ;;
	*) echo "-- Unsupported extension ${ARTIFACT##.*}"; exit 1 ;;
esac

## Platform Stuff ##

must_install tar

android_paths() {
	export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"

    for host in linux-x86_64 linux-x86 darwin-x86_64 darwin-x86 windows-x86_64; do
        if [ -d "$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin" ]; then
            ANDROID_TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$host/bin"
            export PATH="$ANDROID_TOOLCHAIN:$PATH"
            break
        fi
    done
}

## Platform Utility Functions ##

linux() {
	[ "$PLATFORM" = linux ]
}

macos() {
	[ "$PLATFORM" = macos ]
}

ios() {
	[ "$PLATFORM" = ios ]
}

msvc() {
	[ "$PLATFORM" = windows ]
}

mingw() {
	[ "$PLATFORM" = mingw ]
}

windows() {
	msvc || mingw
}

android() {
	[ "$PLATFORM" = android ]
}

arm64() {
	[ "$ARCH" = arm64 ] || [ "$ARCH" = aarch64 ]
}

amd64() {
	[ "$ARCH" = amd64 ] || [ "$ARCH" = x86_64 ]
}