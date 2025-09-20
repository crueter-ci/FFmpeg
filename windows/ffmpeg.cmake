set(FFMPEG_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)

if (BUILD_SHARED_LIBS)
    set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/bin)

    add_library(swscale  SHARED IMPORTED GLOBAL)
    add_library(avutil   SHARED IMPORTED GLOBAL)
    add_library(avcodec  SHARED IMPORTED GLOBAL)
    add_library(avfilter SHARED IMPORTED GLOBAL)

    set_target_properties(swscale PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/swscale-SWSCALE_VER.dll
        IMPORTED_IMPLIB ${FFMPEG_LIB_DIR}/swscale.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avutil PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/avutil-AVUTIL_VER.dll
        IMPORTED_IMPLIB ${FFMPEG_LIB_DIR}/avutil.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avcodec PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/avcodec-AVCODEC_VER.dll
        IMPORTED_IMPLIB ${FFMPEG_LIB_DIR}/avcodec.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avfilter PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/avfilter-AVFILTER_VER.dll
        IMPORTED_IMPLIB ${FFMPEG_LIB_DIR}/avfilter.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )
else()
    set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)

    add_library(swscale  STATIC IMPORTED GLOBAL)
    add_library(avutil   STATIC IMPORTED GLOBAL)
    add_library(avcodec  STATIC IMPORTED GLOBAL)
    add_library(avfilter STATIC IMPORTED GLOBAL)

    set_target_properties(swscale PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/libswscale.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avutil PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/libavutil.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avcodec PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/libavcodec.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )

    set_target_properties(avfilter PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/libavfilter.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )
endif()

add_library(FFmpeg::swscale  ALIAS swscale)
add_library(FFmpeg::avutil   ALIAS avutil)
add_library(FFmpeg::avcodec  ALIAS avcodec)
add_library(FFmpeg::avfilter ALIAS avfilter)
