#!/bin/sh -e

## Common variables ##

# In some projects you will want to fetch latest from gh/fj api
VERSION="8.0.1"
export COMMIT="5e56937b742b9110d38ce6fa4c7bdf2d5c355df4"
export PRETTY_NAME="FFmpeg"
export FILENAME="ffmpeg"
export REPO="FFmpeg/FFmpeg"
export DIRECTORY="FFmpeg-$COMMIT"
export TAG="n$VERSION"
export ARTIFACT="$COMMIT.zip"
export DOWNLOAD_URL="https://github.com/$REPO/archive/$ARTIFACT"

SHORTSHA=$(echo "$COMMIT" | cut -c1-10)
export VERSION="$VERSION-$SHORTSHA"
