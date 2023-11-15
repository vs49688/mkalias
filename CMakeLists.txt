cmake_minimum_required(VERSION 3.13)

project(mkalias)

find_library(FOUNDATION Foundation REQUIRED)

add_executable(mkalias mkalias.m)
target_link_libraries(mkalias "${FOUNDATION}")
