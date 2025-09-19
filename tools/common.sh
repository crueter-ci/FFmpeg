#!/bin/sh

# Common variables (repo, artifact, etc) used by tools

[ -z "$VERSION" ] && echo "You must specify the VERSION environment variable." && exit 1

export PRETTY_NAME="OpenSSL"
export FILENAME="openssl"
export REPO="openssl/openssl"
export DIRECTORY="openssl-$VERSION"
export ARTIFACT="openssl-$VERSION.tar.gz"
export TAG="openssl-$VERSION"