set(FFmpeg_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include PARENT_SCOPE)

if (BUILD_SHARED_LIBS)
    set(LIB_TYPE SHARED)
else()
    set(LIB_TYPE SHARED)
endif()

add_library(FFmpeg::swscale ${LIB_TYPE} IMPORTED)
add_library(FFmpeg::avutil ${LIB_TYPE} IMPORTED)
add_library(FFmpeg::avcodec ${LIB_TYPE} IMPORTED)
add_library(FFmpeg::avfilter ${LIB_TYPE} IMPORTED)

if (BUILD_SHARED_LIBS)
    set(FFmpeg_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/bin PARENT_SCOPE)
    set_target_properties(FFmpeg::swscale PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/swscale-SWSCALE_VER.dll
        IMPORTED_IMPLIB ${FFmpeg_LIBRARY_DIR}/swscale.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avutil PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/avutil-AVUTIL_VER.dll
        IMPORTED_IMPLIB ${FFmpeg_LIBRARY_DIR}/avutil.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avcodec PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/avcodec-AVCODEC_VER.dll
        IMPORTED_IMPLIB ${FFmpeg_LIBRARY_DIR}/avcodec.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avfilter PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/avfilter-AVFILTER_VER.dll
        IMPORTED_IMPLIB ${FFmpeg_LIBRARY_DIR}/avfilter.lib
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )
else()
    set(FFmpeg_LIBRARY_DIR ${CMAKE_CURRENT_LIST_DIR}/lib PARENT_SCOPE)
    set_target_properties(FFmpeg::swscale PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libswscale.dll.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avutil PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavutil.dll.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avcodec PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavcodec.dll.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )

    set_target_properties(FFmpeg::avfilter PROPERTIES
        IMPORTED_LOCATION ${FFmpeg_LIBRARY_DIR}/libavfilter.dll.a
        INTERFACE_INCLUDE_DIRECTORIES ${FFmpeg_INCLUDE_DIR}
    )
endif()
