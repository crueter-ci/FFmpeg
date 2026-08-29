#!/bin/sh -e

# Generate build matrix

target() {
    printf '{"runs-on": "%s", "arch": "%s", "platform": "%s"}' "$1" "$2" "$3"
}

first=1
add() {
    [ "$first" -eq 1 ] && first=0 || printf ','
    target "$1" "$2" "$3"
}

printf '['

# winblows
for plat in windows mingw; do
    add windows-latest amd64 "$plat"
    add windows-11-arm aarch64 "$plat"
done

# loonix
add ubuntu-latest amd64 linux
add ubuntu-24.04-arm aarch64 linux

# android
for arch in amd64 aarch64; do
    add ubuntu-latest "$arch" android
done

# apple
add macos-latest aarch64 macos
add macos-latest aarch64 ios

echo ']'