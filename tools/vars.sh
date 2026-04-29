#!/bin/sh -e

## Common variables ##

# In some projects you will want to fetch latest from gh/fj api
VERSION="8.1"
export COMMIT="55f88acbe3942d60207aa947bed8d2645789f9fb"
export PRETTY_NAME="FFmpeg"
export FILENAME="ffmpeg"
export REPO="crueter/FFmpeg"
# export DIRECTORY="FFmpeg-$COMMIT"
export DIRECTORY=ffmpeg
export TAG="n$VERSION"
export ARTIFACT="$COMMIT.tar.gz"
export DOWNLOAD_URL="https://code.ffmpeg.org/$REPO/archive/$ARTIFACT"

SHORTSHA=$(echo "$COMMIT" | cut -c1-10)
export VERSION="$VERSION-$SHORTSHA"
