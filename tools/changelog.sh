#!/bin/sh

# Generates a "changelog"/download utility table
# Requires: echo

# shellcheck disable=SC1091
. tools/common.sh || exit 1

# Change to the current repo
BASE_DOWNLOAD_URL="https://github.com/crueter-ci/FFmpeg/releases/download"
TAG=v$VERSION

artifact() {
    NAME="$1"
    PLATFORM="$2"

    BASE_URL="${BASE_DOWNLOAD_URL}/${TAG}/${FILENAME}-${PLATFORM}-${VERSION}.tar.zst"

    COL1="[$NAME]($BASE_URL)"

    printf '| %1 |' "$COL1"
    for sum in 1 256 512; do
        DOWNLOAD="[Download]($BASE_URL.sha${sum}sum)"
        printf " %1 |" "$DOWNLOAD" 
    done
    echo
}

echo "Builds for $PRETTY_NAME $VERSION"
echo
echo "| Build | sha1sum | sha256sum | sha512sum |"
echo "| ----- | ------- | --------- | --------- |"

artifact Android android
artifact "Windows (amd64)" windows-amd64
artifact "Windows (arm64)" windows-arm64
artifact "MinGW (amd64)" mingw-amd64
artifact "MinGW (arm64)" mingw-arm64
artifact "Linux (amd64)" linux-amd64
artifact "Linux (aarch64)" linux-aarch64
# artifact "Solaris (amd64)" solaris-amd64
# artifact "FreeBSD (amd64)" freebsd-amd64
# artifact "OpenBSD (amd64)" openbsd-amd64