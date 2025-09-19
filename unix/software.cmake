set(SHARED_SUFFIX so)
set(STATIC_SUFFIX a)

set(SOFTWARE_LIB_DIR ${CMAKE_CURRENT_LIST_DIR}/lib)
set(SOFTWARE_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/include)

# Change to match imported library names
if (BUILD_SHARED_LIBS)
    add_library(OpenSSL::Crypto SHARED IMPORTED)
    set_target_properties(OpenSSL::Crypto PROPERTIES
        IMPORTED_LOCATION ${SOFTWARE_LIB_DIR}/libcrypto.${SHARED_SUFFIX}
        INTERFACE_INCLUDE_DIRECTORIES ${SOFTWARE_INCLUDE_DIR}
    )

    add_library(OpenSSL::SSL SHARED IMPORTED)
    set_target_properties(OpenSSL::SSL PROPERTIES
        IMPORTED_LOCATION ${SOFTWARE_LIB_DIR}/libssl.${SHARED_SUFFIX}
        INTERFACE_INCLUDE_DIRECTORIES ${SOFTWARE_INCLUDE_DIR}
    )
else()
    add_library(OpenSSL::Crypto STATIC IMPORTED)
    set_target_properties(OpenSSL::Crypto PROPERTIES
        IMPORTED_LOCATION ${SOFTWARE_LIB_DIR}/libcrypto.${STATIC_SUFFIX}
        INTERFACE_INCLUDE_DIRECTORIES ${SOFTWARE_INCLUDE_DIR}
    )

    add_library(OpenSSL::SSL STATIC IMPORTED)
    set_target_properties(OpenSSL::SSL PROPERTIES
        IMPORTED_LOCATION ${SOFTWARE_LIB_DIR}/libssl.${STATIC_SUFFIX}
        INTERFACE_INCLUDE_DIRECTORIES ${SOFTWARE_INCLUDE_DIR}
    )
endif()

function(link_software)
    foreach(TARGET ${ARGN})
        if (TARGET ${TARGET})
            target_link_libraries(${TARGET} PUBLIC OpenSSL::SSL OpenSSL::Crypto)
        endif()
    endforeach()
endfunction()
