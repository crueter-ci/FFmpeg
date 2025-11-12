#!/bin/sh -e

AVCODEC_VER=$(grep '#define LIBAVCODEC_VERSION_MAJOR' libavcodec/version_major.h | sed 's/.* //g')
AVUTIL_VER=$(grep '#define LIBAVUTIL_VERSION_MAJOR' libavutil/version.h | sed 's/.* //g')
SWSCALE_VER=$(grep '#define LIBSWSCALE_VERSION_MAJOR' libswscale/version_major.h | sed 's/.* //g')
AVFILTER_VER=$(grep '#define LIBAVFILTER_VERSION_MAJOR' libavfilter/version_major.h | sed 's/.* //g')

echo "libavcodec-$AVCODEC_VER"
echo "avutil-$AVUTIL_VER"
echo "avfilter-$AVFILTER_VER"
echo "swscale-$SWSCALE_VER"

sed "s/avcodec-.*\.dll/avcodec-$AVCODEC_VER.dll/"    "$ROOTDIR"/CMakeLists.txt   > "$ROOTDIR"/CMakeLists.txt.1
sed "s/avutil-.*\.dll/avutil-$AVUTIL_VER.dll/"       "$ROOTDIR"/CMakeLists.txt.1 > "$ROOTDIR"/CMakeLists.txt.2
sed "s/swscale-.*\.dll/swscale-$SWSCALE_VER.dll/"    "$ROOTDIR"/CMakeLists.txt.2 > "$ROOTDIR"/CMakeLists.txt.3
sed "s/avfilter-.*\.dll/avfilter-$AVFILTER_VER.dll/" "$ROOTDIR"/CMakeLists.txt.3 > "$ROOTDIR"/CMakeLists.txt

rm "$ROOTDIR"/CMakeLists.txt.*

export AVCODEC_VER
export AVUTIL_VER
export AVFILTER_VER
export SWSCALE_VER