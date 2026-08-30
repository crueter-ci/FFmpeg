#!/bin/sh

# shellcheck disable=SC1091

set -e

date +"%s" > TIMESTAMP

. tools/common.sh

download