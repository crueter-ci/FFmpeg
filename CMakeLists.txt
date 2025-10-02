cmake_minimum_required(VERSION 3.10)

set(FFmpeg_PATH "${CMAKE_CURRENT_LIST_DIR}" PARENT_SCOPE)

set(FFMPEG_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)

if (APPLE)
    set(SHARED_SUFFIX dylib)
else()
    set(SHARED_SUFFIX so)
endif()

if (BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
    set(LIB_SUFFIX ${SHARED_SUFFIX})
else()
    set(LIB_TYPE STATIC)
    set(LIB_SUFFIX a)
endif()

# utility lib that links to everything
add_library(ffmpeg INTERFACE)
set_target_properties(ffmpeg PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
)

if (ANDROID)
    # conditional libs
    foreach (LIB avcodec avdevice avfilter avformat avutil postproc swresample
             swscale)
        add_library(${LIB} ${LIB_TYPE} IMPORTED GLOBAL)
        set_target_properties(${LIB} PROPERTIES
            IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.${LIB_SUFFIX}
            INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
        )

        add_library(FFmpeg::${LIB} ALIAS ${LIB})
        target_link_libraries(ffmpeg INTERFACE FFmpeg::${LIB})
    endforeach()

    # always-static
    foreach(LIB vpx x264)
        add_library(${LIB} STATIC IMPORTED GLOBAL)
        set_target_properties(${LIB} PROPERTIES
            IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.a
            INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
        )

        add_library(FFmpeg::${LIB} ALIAS ${LIB})
        target_link_libraries(ffmpeg INTERFACE FFmpeg::${LIB})
    endforeach()
else() # Unix and windows
    foreach (LIB swscale avutil avcodec avfilter)
        add_library(${LIB} ${LIB_TYPE} IMPORTED GLOBAL)
        set_target_properties(${LIB} PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
        )

        if (UNIX)
            set_target_properties(${LIB} PROPERTIES
                IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/lib${LIB}.${LIB_SUFFIX}
            )
        else()
            if (BUILD_SHARED_LIBS)
                set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/bin)
                set_target_properties(${LIB} PROPERTIES
                    IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/${LIB}.dll
                    IMPORTED_IMPLIB ${FFMPEG_LIB_DIR}/${LIB}.lib
                )
            else()
                set_target_properties(avutil PROPERTIES
                    IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/libavutil.a
                    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR}
                )
            endif()
        endif()

        add_library(FFmpeg::${LIB} ALIAS ${LIB})
        target_link_libraries(ffmpeg INTERFACE FFmpeg::${LIB})
    endforeach()
endif()

add_library(FFmpeg::FFmpeg ALIAS ffmpeg)
