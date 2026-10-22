cmake_minimum_required(VERSION 3.20)
project(rangers_native LANGUAGES C)
get_filename_component(RANGERS_SOURCE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/.." REALPATH)
add_compile_options("-ffile-prefix-map=${RANGERS_SOURCE_ROOT}=."
                    "-ffile-prefix-map=${CMAKE_BINARY_DIR}=./build")
set(OKGF_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../vendor/okgf")
if(NOT EXISTS "${OKGF_ROOT}/CMakeLists.txt")
  message(FATAL_ERROR "Initialize dependencies with: git submodule update --init --recursive")
endif()
# Use host arithmetic for graphics on every target. FORCE also updates existing build directories
# that previously selected EXACT on x86.
set(OKGF_MATH_BACKEND
    NATIVE
    CACHE STRING "OKGF arithmetic backend" FORCE)
add_subdirectory("${OKGF_ROOT}" okgf)
set_target_properties(okgf PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
                                      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
                                      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
