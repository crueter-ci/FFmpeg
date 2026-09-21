#!/bin/sh -e

## Common variables ##

# In some projects you will want to fetch latest from gh/fj api
export TAG=8.0.1
export COMMIT=c7b5f1537d9c52efa50fd10d106ca015ddde1818

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
