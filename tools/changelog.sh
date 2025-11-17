#!/bin/sh -e

## Generates a "changelog"/download utility table ##

# shellcheck disable=SC1091
. tools/vars.sh

# Change to the current repo
BASE_DOWNLOAD_URL="https://github.com/crueter-ci/$PRETTY_NAME/releases/download"
TAG=v$VERSION

artifact() {
    NAME="$1"
    PLATFORM="$2"

    BASE_URL="${BASE_DOWNLOAD_URL}/${TAG}/${FILENAME}-${PLATFORM}-${VERSION}.tar.zst"

    COL1="[$NAME]($BASE_URL)"

    printf "| %s |" "$COL1"
    for sum in 1 256 512; do
        DOWNLOAD="[Download]($BASE_URL.sha${sum}sum)"
        printf " %s |" "$DOWNLOAD"
    done
    echo
}

echo "Builds for $PRETTY_NAME $VERSION"
echo
echo "| Build | sha1sum | sha256sum | sha512sum |"
echo "| ----- | ------- | --------- | --------- |"

artifact "Android (aarch64)" android-aarch64
artifact "Android (x86_64)" android-x86_64
artifact "Windows (amd64)" windows-amd64
artifact "Windows (arm64)" windows-arm64
artifact "MinGW (amd64)" mingw-amd64
artifact "MinGW (arm64)" mingw-arm64
artifact "Linux (amd64)" linux-amd64
artifact "Linux (aarch64)" linux-aarch64
artifact "Solaris (amd64)" solaris-amd64
artifact "FreeBSD (amd64)" freebsd-amd64
artifact "OpenBSD (amd64)" openbsd-amd64