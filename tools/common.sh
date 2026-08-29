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
CYGWIN* | MINGW* | MSYS*)
	# awesome microsoft moment
	if [ -n "$MYSTEM" ]; then
		"${PLATFORM:=mingw}"
	else
		"${PLATFORM:=windows}"
	fi
	;;
*) : "${PLATFORM:?-- You must supply the PLATFORM environment variable.}" ;;
esac

## Command Checks ##

must_install() {
	for cmd in "$@"; do
		command -v "$cmd" >/dev/null 2>&1 || { echo "-- $cmd must be installed" && exit 1; }
	done
}

## Platform Stuff ##

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

###############
# Other utils #
###############

# download, store version/artifact names
download() {
	_group "Downloading $PRETTY_NAME $VERSION"

	must_install curl

	if [ -n "$GITHUB_RUN_ID" ]; then
		echo "ARTIFACT=$ARTIFACT" >> "$GITHUB_ENV"
	fi

	echo "$VERSION" > VERSION

	echo "-- URL: $DOWNLOAD_URL"

	TRIES=0
	if [ -f "$ARTIFACT" ]; then
		echo "-- Already downloaded, skipping"
		_end
		return
	fi

	while [ "$TRIES" -le 30 ]; do
		if curl -L "$DOWNLOAD_URL" -o "$ARTIFACT"; then
			echo "-- Succeeded"
			_end
			return
		fi

		TRIES=$((TRIES + 1))
		echo "-- Download failed, trying again in 5 seconds..."
		sleep 5
	done

	echo "-- Download failed after 30 tries, aborting"
	_end
	exit 1
}

# Copy CMakeLists.txt (if applicable)
copy_cmake() {
	_group "Copying CMake artifacts"

    cp "$ROOTDIR"/CMakeLists.txt out

	_end
}

# Get a sha512 sum
sums() {
	for file in "$@"; do
		must_install sha512sum
		sha512sum "$file" | cut -d " " -f1 | tr -d "\n" >"$file".sha512sum
	done
}

# package
package() {
    _group "Packaging"
    mkdir -p "$ROOTDIR/artifacts"

	TARBALL=$FILENAME-$PLATFORM-$ARCH-$VERSION.tar

    cd out
    tar cf "$ROOTDIR/artifacts/$TARBALL" ./*

    cd "$ROOTDIR/artifacts"
    zstd -10 "$TARBALL"
    rm "$TARBALL"

    sums "$TARBALL.zst"
	_end
}