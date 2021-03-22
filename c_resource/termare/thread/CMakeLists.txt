cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
add_compile_options(-std=c++11)
project(thread VERSION 1.0.0 LANGUAGES C)

SET(CMAKE_C_COMPILER g++)
aux_source_directory(. DIR_SRCS)
add_executable(thread thread.c)