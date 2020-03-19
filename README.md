# Seamless Conan dependencies integration for CMake

Usage:

    option(ENABLE_CONAN "Use Conan for dependencies" FALSE)

    if(ENABLE_CONAN)
        include(ConanIntegration)
    endif()
