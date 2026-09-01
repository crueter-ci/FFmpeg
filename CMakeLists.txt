cmake_minimum_required(VERSION 3.10)

set(FFmpeg_PATH "${CMAKE_CURRENT_LIST_DIR}" PARENT_SCOPE)

set(FFMPEG_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)
set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)

set(LIB_TYPE STATIC)
set(LIB_SUFFIX a)

# utility lib that links to everything
add_library(ffmpeg INTERFACE)
set_target_properties(ffmpeg PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})

foreach (LIB swscale avcodec swresample avfilter avutil)
    add_library(${LIB} ${LIB_TYPE} IMPORTED GLOBAL)
    add_library(FFmpeg::${LIB} ALIAS ${LIB})
    target_link_libraries(ffmpeg INTERFACE FFmpeg::${LIB})

    set_target_properties(${LIB} PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${FFMPEG_INCLUDE_DIR})

    if (MSVC)
        set(libname ${LIB}.lib)
    else()
        set(libname lib${LIB}.${LIB_SUFFIX})
    endif()

    set_target_properties(${LIB} PROPERTIES
        IMPORTED_LOCATION ${FFMPEG_LIB_DIR}/${libname})

    if (WIN32)
        target_link_libraries(${LIB} INTERFACE bcrypt)
    endif()
endforeach()

if (MINGW)
    find_library(ICONV_LIBRARY iconv REQUIRED)
    target_link_libraries(ffmpeg INTERFACE ${ICONV_LIBRARY})
elseif(ANDROID)
    find_library(MEDIANDK_LIBRARY mediandk REQUIRED)
    target_link_libraries(ffmpeg INTERFACE ${MEDIANDK_LIBRARY})
elseif(APPLE)
    find_library(VIDEOTOOLBOX_FRAMEWORK VideoToolbox REQUIRED)
    find_library(COREMEDIA_FRAMEWORK CoreMedia REQUIRED)
    target_link_libraries(ffmpeg INTERFACE ${VIDEOTOOLBOX_FRAMEWORK}
        ${COREMEDIA_FRAMEWORK})
endif()

add_library(FFmpeg::FFmpeg ALIAS ffmpeg)

set(FFmpeg_LIBRARY_DIR "${FFMPEG_LIB_DIR}" PARENT_SCOPE)
set(FFmpeg_INCLUDE_DIR "${FFMPEG_INCLUDE_DIR}" PARENT_SCOPE)