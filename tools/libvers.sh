#!/bin/sh -e

AVCODEC_VER=$(grep '#define LIBAVCODEC_VERSION_MAJOR' libavcodec/version_major.h | sed 's/.* //g')
AVUTIL_VER=$(grep '#define LIBAVUTIL_VERSION_MAJOR' libavutil/version.h | sed 's/.* //g')
SWSCALE_VER=$(grep '#define LIBSWSCALE_VERSION_MAJOR' libswscale/version_major.h | sed 's/.* //g')
AVFILTER_VER=$(grep '#define LIBAVFILTER_VERSION_MAJOR' libavfilter/version_major.h | sed 's/.* //g')

echo "$AVCODEC_VER"
echo "$AVUTIL_VER"
echo "$AVFILTER_VER"
echo "$SWSCALE_VER"

sed "s/AVCODEC_VER/$AVCODEC_VER/"   "$ROOTDIR"/CMakeLists.txt.in   > "$ROOTDIR"/CMakeLists.txt.in.1
sed "s/AVUTIL_VER/$AVUTIL_VER/"     "$ROOTDIR"/CMakeLists.txt.in.1 > "$ROOTDIR"/CMakeLists.txt.in.2
sed "s/SWSCALE_VER/$SWSCALE_VER/"   "$ROOTDIR"/CMakeLists.txt.in.2 > "$ROOTDIR"/CMakeLists.txt.in.3
sed "s/AVFILTER_VER/$AVFILTER_VER/" "$ROOTDIR"/CMakeLists.txt.in.3 > "$ROOTDIR"/CMakeLists.txt

rm "$ROOTDIR"/CMakeLists.txt.in.*

export AVCODEC_VER
export AVUTIL_VER
export AVFILTER_VER
export SWSCALE_VER