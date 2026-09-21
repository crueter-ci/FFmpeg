#!/bin/sh -e

## Common variables ##

# In some projects you will want to fetch latest from gh/fj api
export TAG=9.0.2
export COMMIT=946fcce07b6dcd0331c8cc609192aeff5e1924f8

export PRETTY_NAME="FFmpeg"
export FILENAME="ffmpeg"
export REPO="FFmpeg/FFmpeg"
export DIRECTORY="FFmpeg-$COMMIT"
export ARTIFACT="$COMMIT.tar.gz"
export DOWNLOAD_URL="https://github.com/$REPO/archive/$ARTIFACT"

if [ -f TIMESTAMP ]; then
	TIMESTAMP="$(cat TIMESTAMP)"
else
	TIMESTAMP=$(date +"%s")
	echo "$TIMESTAMP" > TIMESTAMP
fi

export TIMESTAMP

SHORTSHA=$(echo "$COMMIT" | cut -c1-10)
export VERSION="$TAG-$TIMESTAMP-$SHORTSHA"
