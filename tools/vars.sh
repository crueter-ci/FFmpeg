#!/bin/sh -e

## Common variables ##

# In some projects you will want to fetch latest from gh/fj api
VERSION="8.0.1"
export COMMIT="e07daf85a40d84c8c3a021f4db577f5fd6090390"
export PRETTY_NAME="FFmpeg"
export FILENAME="ffmpeg"
export REPO="FFmpeg/FFmpeg"
export DIRECTORY="FFmpeg-$COMMIT"
export TAG="n$VERSION"
export ARTIFACT="$COMMIT.tar.gz"
export DOWNLOAD_URL="https://github.com/$REPO/archive/$ARTIFACT"

SHORTSHA=$(echo "$COMMIT" | cut -c1-10)
export VERSION="$VERSION-$SHORTSHA"
