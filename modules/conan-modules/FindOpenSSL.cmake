include(${CONAN_DEPS_DIR}/FindOpenSSL.cmake)
message("FindOpenSSL wrapper!")

# This module is needed to find the targets provided by CMake FindOpenSSL module
# Namely, this file adds OpenSSL::SSL and OpenSSL::Crypto targets based on the Conan FindOpenSSL

if(OpenSSL_FOUND AND NOT TARGET OpenSSL::SSL)
    message("Wrapper/FindOpenSSL: OpenSSL_FOUND AND NOT TARGET OpenSSL::SSL")
    message("Wrapper/FindOpenSSL: Hints: OpenSSL_LIB_DIRS: ${OpenSSL_LIB_DIRS}")
    message("Wrapper/FindOpenSSL: Hints: OpenSSL_INCLUDES: ${OpenSSL_INCLUDES}")

   # OpenSSL_LIB_DIRS
   # OpenSSL_INCLUDES

   set(_OPENSSL_FIND_LIBRARY_ARGS
       HINTS
         ${OpenSSL_LIB_DIRS}
       NO_PACKAGE_ROOT_PATH
       NO_CMAKE_PATH
       NO_CMAKE_ENVIRONMENT_PATH
       NO_SYSTEM_ENVIRONMENT_PATH
       NO_CMAKE_SYSTEM_PATH
   )

   # Find the libraries
   if(WIN32 AND NOT CYGWIN)
     if(MSVC)
       # /MD and /MDd are the standard values - if someone wants to use
       # others, the libnames have to change here too
       # use also ssl and ssleay32 in debug as fallback for openssl < 0.9.8b
       # enable OPENSSL_MSVC_STATIC_RT to get the libs build /MT (Multithreaded no-DLL)
       # In Visual C++ naming convention each of these four kinds of Windows libraries has it's standard suffix:
       #   * MD for dynamic-release
       #   * MDd for dynamic-debug
       #   * MT for static-release
       #   * MTd for static-debug

       # Implementation details:
       # We are using the libraries located in the VC subdir instead of the parent directory even though :
       # libeay32MD.lib is identical to ../libeay32.lib, and
       # ssleay32MD.lib is identical to ../ssleay32.lib
       # enable OPENSSL_USE_STATIC_LIBS to use the static libs located in lib/VC/static

       if (OPENSSL_MSVC_STATIC_RT)
         set(_OPENSSL_MSVC_RT_MODE "MT")
       else ()
         set(_OPENSSL_MSVC_RT_MODE "MD")
       endif ()

       # Since OpenSSL 1.1, lib names are like libcrypto32MTd.lib and libssl32MTd.lib
       if( "${CMAKE_SIZEOF_VOID_P}" STREQUAL "8" )
           set(_OPENSSL_MSVC_ARCH_SUFFIX "64")
       else()
           set(_OPENSSL_MSVC_ARCH_SUFFIX "32")
       endif()

       find_library(LIB_EAY_DEBUG
         NAMES
           libcrypto${_OPENSSL_MSVC_ARCH_SUFFIX}${_OPENSSL_MSVC_RT_MODE}d
           libcrypto${_OPENSSL_MSVC_RT_MODE}d
           libcryptod
           libeay32${_OPENSSL_MSVC_RT_MODE}d
           libeay32d
           cryptod
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       find_library(LIB_EAY_RELEASE
         NAMES
           libcrypto${_OPENSSL_MSVC_ARCH_SUFFIX}${_OPENSSL_MSVC_RT_MODE}
           libcrypto${_OPENSSL_MSVC_RT_MODE}
           libcrypto
           libeay32${_OPENSSL_MSVC_RT_MODE}
           libeay32
           crypto
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       find_library(SSL_EAY_DEBUG
         NAMES
           libssl${_OPENSSL_MSVC_ARCH_SUFFIX}${_OPENSSL_MSVC_RT_MODE}d
           libssl${_OPENSSL_MSVC_RT_MODE}d
           libssld
           ssleay32${_OPENSSL_MSVC_RT_MODE}d
           ssleay32d
           ssld
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       find_library(SSL_EAY_RELEASE
         NAMES
           libssl${_OPENSSL_MSVC_ARCH_SUFFIX}${_OPENSSL_MSVC_RT_MODE}
           libssl${_OPENSSL_MSVC_RT_MODE}
           libssl
           ssleay32${_OPENSSL_MSVC_RT_MODE}
           ssleay32
           ssl
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       set(LIB_EAY_LIBRARY_DEBUG "${LIB_EAY_DEBUG}")
       set(LIB_EAY_LIBRARY_RELEASE "${LIB_EAY_RELEASE}")
       set(SSL_EAY_LIBRARY_DEBUG "${SSL_EAY_DEBUG}")
       set(SSL_EAY_LIBRARY_RELEASE "${SSL_EAY_RELEASE}")

       include(SelectLibraryConfigurations)
       select_library_configurations(LIB_EAY)
       select_library_configurations(SSL_EAY)

       mark_as_advanced(LIB_EAY_LIBRARY_DEBUG LIB_EAY_LIBRARY_RELEASE
                        SSL_EAY_LIBRARY_DEBUG SSL_EAY_LIBRARY_RELEASE)
       set(OPENSSL_SSL_LIBRARY ${SSL_EAY_LIBRARY} )
       set(OPENSSL_CRYPTO_LIBRARY ${LIB_EAY_LIBRARY} )
     elseif(MINGW)
       # same player, for MinGW
       set(LIB_EAY_NAMES crypto libeay32)
       set(SSL_EAY_NAMES ssl ssleay32)
       find_library(LIB_EAY
         NAMES
           ${LIB_EAY_NAMES}
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       find_library(SSL_EAY
         NAMES
           ${SSL_EAY_NAMES}
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       mark_as_advanced(SSL_EAY LIB_EAY)
       set(OPENSSL_SSL_LIBRARY ${SSL_EAY} )
       set(OPENSSL_CRYPTO_LIBRARY ${LIB_EAY} )
       unset(LIB_EAY_NAMES)
       unset(SSL_EAY_NAMES)
     else()
       # Not sure what to pick for -say- intel, let's use the toplevel ones and hope someone report issues:
       find_library(LIB_EAY
         NAMES
           libcrypto
           libeay32
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       find_library(SSL_EAY
         NAMES
           libssl
           ssleay32
         ${_OPENSSL_FIND_LIBRARY_ARGS}
       )

       mark_as_advanced(SSL_EAY LIB_EAY)
       set(OPENSSL_SSL_LIBRARY ${SSL_EAY} )
       set(OPENSSL_CRYPTO_LIBRARY ${LIB_EAY} )
     endif()
   else() # (WIN32 AND NOT CYGWIN)

       find_library(OPENSSL_SSL_LIBRARY
       NAMES
         ssl
         ssleay32
         ssleay32MD
       ${_OPENSSL_FIND_LIBRARY_ARGS}
     )

     find_library(OPENSSL_CRYPTO_LIBRARY
       NAMES
         crypto
       ${_OPENSSL_FIND_LIBRARY_ARGS}
     )

     mark_as_advanced(OPENSSL_CRYPTO_LIBRARY OPENSSL_SSL_LIBRARY)

     # compat defines
     set(OPENSSL_SSL_LIBRARIES ${OPENSSL_SSL_LIBRARY})
     set(OPENSSL_CRYPTO_LIBRARIES ${OPENSSL_CRYPTO_LIBRARY})

   endif()

   # Find the includes
   find_path(OPENSSL_INCLUDE_DIR
     NAMES
       openssl/ssl.h
     HINTS
       ${OpenSSL_INCLUDES}
     PATH_SUFFIXES
       include
   )

  message("Wrapper/FindOpenSSL: OPENSSL_SSL_LIBRARIES: ${OPENSSL_SSL_LIBRARIES}")
  message("Wrapper/FindOpenSSL: OPENSSL_CRYPTO_LIBRARY: ${OPENSSL_CRYPTO_LIBRARY}")
  message("Wrapper/FindOpenSSL: OPENSSL_INCLUDE_DIR: ${OPENSSL_INCLUDE_DIR}")

  if(NOT TARGET OpenSSL::Crypto AND
      (EXISTS "${OPENSSL_CRYPTO_LIBRARY}" OR
        EXISTS "${LIB_EAY_LIBRARY_DEBUG}" OR
        EXISTS "${LIB_EAY_LIBRARY_RELEASE}")
      )
    add_library(OpenSSL::Crypto UNKNOWN IMPORTED)
    set_target_properties(OpenSSL::Crypto PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")
    if(EXISTS "${OPENSSL_CRYPTO_LIBRARY}")
      set_target_properties(OpenSSL::Crypto PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        IMPORTED_LOCATION "${OPENSSL_CRYPTO_LIBRARY}")
    endif()
    if(EXISTS "${LIB_EAY_LIBRARY_RELEASE}")
      set_property(TARGET OpenSSL::Crypto APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(OpenSSL::Crypto PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${LIB_EAY_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${LIB_EAY_LIBRARY_DEBUG}")
      set_property(TARGET OpenSSL::Crypto APPEND PROPERTY
        IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(OpenSSL::Crypto PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        IMPORTED_LOCATION_DEBUG "${LIB_EAY_LIBRARY_DEBUG}")
    endif()
  endif()

  if(NOT TARGET OpenSSL::SSL AND
      (EXISTS "${OPENSSL_SSL_LIBRARY}" OR
        EXISTS "${SSL_EAY_LIBRARY_DEBUG}" OR
        EXISTS "${SSL_EAY_LIBRARY_RELEASE}")
      )
    add_library(OpenSSL::SSL UNKNOWN IMPORTED)
    set_target_properties(OpenSSL::SSL PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${OPENSSL_INCLUDE_DIR}")
    if(EXISTS "${OPENSSL_SSL_LIBRARY}")
      set_target_properties(OpenSSL::SSL PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        IMPORTED_LOCATION "${OPENSSL_SSL_LIBRARY}")
    endif()
    if(EXISTS "${SSL_EAY_LIBRARY_RELEASE}")
      set_property(TARGET OpenSSL::SSL APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(OpenSSL::SSL PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${SSL_EAY_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${SSL_EAY_LIBRARY_DEBUG}")
      set_property(TARGET OpenSSL::SSL APPEND PROPERTY
        IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(OpenSSL::SSL PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        IMPORTED_LOCATION_DEBUG "${SSL_EAY_LIBRARY_DEBUG}")
    endif()
    if(TARGET OpenSSL::Crypto)
      set_target_properties(OpenSSL::SSL PROPERTIES
        INTERFACE_LINK_LIBRARIES OpenSSL::Crypto)
    endif()
  endif()
endif()
