#!/bin/sh

# Downloads the specified version of FFmpeg.
# Requires: wget

. tools/common.sh || exit 1

DOWNLOAD_URL="https://github.com/$REPO/archive/refs/tags/$ARTIFACT"

while true; do
   if [ ! -f $ARTIFACT ]; then
       wget $DOWNLOAD_URL && exit 0
       echo "Download failed, trying again in 5 seconds..."
       sleep 5
    else
        exit 0
    fi
done
