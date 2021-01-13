cmake_minimum_required(VERSION 3.7 FATAL_ERROR)
add_compile_options(-std=c++11)
project(term)
include_directories(D:\\Windows Kits\\10\\Include\\10.0.18362.0\\um)
aux_source_directory(${PROJECT_SOURCE_DIR}/ SRC_FILES) # scan source code files
add_executable(term  EchoCon.cpp stdafx.cpp )
