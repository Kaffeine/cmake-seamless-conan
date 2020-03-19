if(DOWNLOAD_CMAKE_CONAN)
    # Download automatically, you can also just copy the conan.cmake file
    if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
       message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
       file(DOWNLOAD "https://github.com/conan-io/cmake-conan/raw/v0.15/conan.cmake"
                     "${CMAKE_BINARY_DIR}/conan.cmake")
    endif()
else()
    # Include offline copy
    include(${CMAKE_CURRENT_LIST_DIR}/conan.cmake)
endif()

set(CONAN_DEPS_DIR "${CMAKE_BINARY_DIR}/conan-deps")
set(CONAN_FIND_WRAPPERS_DIR "${CMAKE_CURRENT_LIST_DIR}/conan-modules")

# To install conan:
# pip3 install conan
# To setup conan:
# conan remote clean
# conan remote add

conan_cmake_install(
    CONANFILE conanfile.txt
    INSTALL_FOLDER "${CONAN_DEPS_DIR}"
    BUILD missing
)

message(STATUS "CONAN_DEPS_DIR: ${CONAN_DEPS_DIR}")

set(CMAKE_MODULE_PATH "${CONAN_FIND_WRAPPERS_DIR}" "${CONAN_DEPS_DIR}" ${CMAKE_MODULE_PATH})
