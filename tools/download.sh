#!/bin/sh

# shellcheck disable=SC1091

set -e

date +"%s" > TIMESTAMP

. tools/common.sh

must_install curl

# download
download() {
	_group "Downloading $PRETTY_NAME $VERSION"

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

if [ -n "$GITHUB_RUN_ID" ]; then
	echo "ARTIFACT=$ARTIFACT" >> "$GITHUB_ENV"
fi

echo "$VERSION" > VERSION

download