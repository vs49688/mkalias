cmake_minimum_required(VERSION 3.13)

project(mkalias)

find_library(FOUNDATION Foundation REQUIRED)

add_executable(mkalias mkalias.m)
target_link_libraries(mkalias "${FOUNDATION}")

if (MKALIAS_VERSION)
    target_compile_definitions(mkalias PUBLIC MKALIAS_VERSION="${MKALIAS_VERSION}")
endif ()
