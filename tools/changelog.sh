#!/bin/sh -e

## Generates a "changelog"/download utility table ##

# shellcheck disable=SC1091
. tools/vars.sh

# Change to the current repo
BASE_DOWNLOAD_URL="https://github.com/crueter-ci/$PRETTY_NAME/releases/download"

artifact() {
    NAME="$1"
    PLATFORM="$2"

    BASE_URL="${BASE_DOWNLOAD_URL}/${TAG}/${FILENAME}-${PLATFORM}-${VERSION}.tar.zst"

    COL1="[$NAME]($BASE_URL)"

    printf "| %s |" "$COL1"
	printf " %s |" "[SHA512 sum]($BASE_URL.sha512sum)"
    echo
}

echo "Builds for $PRETTY_NAME $VERSION"
echo
echo "| Build | sha512sum |"
echo "| ----- | --------- |"

artifact "Android (aarch64)" android-aarch64
artifact "Android (x86_64)" android-amd64
artifact "Windows (amd64)" windows-amd64
artifact "Windows (aarch64)" windows-aarch64
artifact "MinGW (amd64)" mingw-amd64
artifact "MinGW (aarch64)" mingw-aarch64
artifact "Linux (amd64)" linux-amd64
artifact "Linux (aarch64)" linux-aarch64
artifact "macOS (aarch64)" macos-aarch64
artifact "iOS (aarch64)" ios-aarch64
