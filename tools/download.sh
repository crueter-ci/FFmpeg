#!/bin/sh

# Downloads the specified version of FFmpeg.
# Requires: wget, curl, or fetch

# shellcheck disable=SC1091
. tools/common.sh || exit 1

DOWNLOAD_URL="https://github.com/$REPO/archive/refs/tags/$ARTIFACT"

# Função de download universal
download() {  
    url="$1"; out="$2"  
    if command -v wget >/dev/null 2>&1; then  
        wget --retry-connrefused --tries=30 "$url" -O "$out"  
    elif command -v curl >/dev/null 2>&1; then  
        curl -L --retry 30 -o "$out" "$url"  
    elif command -v fetch >/dev/null 2>&1; then  
        fetch -o "$out" "$url"  
    else  
        echo "Error: no downloader found." >&2  
        exit 1  
    fi  
}

while true; do
    if [ ! -f "$ARTIFACT" ]; then
        download "$DOWNLOAD_URL" "$ARTIFACT" && exit 0
        echo "Download failed, trying again in 5 seconds..."
        sleep 5
    else
        exit 0
    fi
done
