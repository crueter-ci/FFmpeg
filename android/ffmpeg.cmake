set(FFMPEG_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)

if (BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX so)
else()
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX a)
endif()

# utility lib that links to everything
add_library(ffmpeg INTERFACE)
set_target_properties(ffmpeg PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
)

# conditional libs
foreach (LIB avcodec avdevice avfilter avformat avutil postproc swresample swscale)
    add_library(${LIB} ${LIB_TYPE} IMPORTED GLOBAL)
    set_target_properties(${LIB} PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.${LIB_SUFFIX}
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )
    add_library(FFmpeg::${LIB} ALIAS ${LIB})
    target_link_libraries(ffmpeg PUBLIC FFmpeg::${LIB})
endforeach()

# always-static
foreach(LIB vpx x264)
    add_library(${LIB} STATIC IMPORTED GLOBAL)
    set_target_properties(${LIB} PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
    )
    add_library(FFmpeg::${LIB} ALIAS ${LIB})
    target_link_libraries(ffmpeg PUBLIC FFmpeg::${LIB})
endforeach()

add_library(FFmpeg::FFmpeg ALIAS ffmpeg)
