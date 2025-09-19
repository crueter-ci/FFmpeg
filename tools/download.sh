#!/bin/sh

# Downloads the specified version of the software.
# Requires: wget

source tools/common.sh || exit 1

# This shouldn't need to be changed unless the software is on GitLab or otherwise
DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/$ARTIFACT"

while true; do
   if [ ! -f $ARTIFACT ]; then
       wget $DOWNLOAD_URL && exit 0
       echo "Download failed, trying again in 5 seconds..."
       sleep 5
    else
        exit 0
    fi
done
