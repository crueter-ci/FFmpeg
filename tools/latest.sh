#!/bin/sh

# Grabs the latest version from the GitHub API.
# Requires: curl, jq, cut

source tools/common.sh || exit 1

# This shouldn't need to be changed unless the software is on GitLab or otherwise
API_URL=https://api.github.com/repos/$REPO/releases/latest

while true; do
    VERSION=`curl $API_URL | jq -r '.tag_name' | cut -d "-" -f2`
    [ "$VERSION" != "null" ] && echo "$VERSION" && exit 0
    sleep 5
done
