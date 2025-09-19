#!/bin/sh

# Common variables (repo, artifact, etc) used by tools

[ -z "$VERSION" ] && echo "You must specify the VERSION environment variable." && exit 1

export PRETTY_NAME="FFmpeg"
export FILENAME="ffmpeg"
export REPO="FFmpeg/FFmpeg"
export DIRECTORY="FFmpeg-n$VERSION"
export TAG="n$VERSION"
export ARTIFACT="$TAG.tar.gz"