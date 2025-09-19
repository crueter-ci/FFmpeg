set(FFmpeg_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include PARENT_SCOPE)
set(FFmpeg_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/lib PARENT_SCOPE)

if (BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX so)
else()
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX a)
endif()

add_library(FFmpeg::swscale ${LIB_TYPE} IMPORTED)

set_target_properties(FFmpeg::swscale PROPERTIES
    IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libswscale.${LIB_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
)

add_library(FFmpeg::avutil ${LIB_TYPE} IMPORTED)

set_target_properties(FFmpeg::avutil PROPERTIES
    IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavutil.${LIB_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
)

add_library(FFmpeg::avcodec ${LIB_TYPE} IMPORTED)

set_target_properties(FFmpeg::avcodec PROPERTIES
    IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavcodec.${LIB_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
)

add_library(FFmpeg::avfilter ${LIB_TYPE} IMPORTED)

set_target_properties(FFmpeg::avfilter PROPERTIES
    IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavfilter.${LIB_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
)
