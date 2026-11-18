# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# flatc, StdAstFormat.fbs and flatbuffers cangjie runtime come from the compiler SDK.
set(FLATBUFFERS_TOOLCHAIN_DIR $ENV{CANGJIE_HOME}/third_party/flatbuffers)
set(FLATBUFFERS_INCLUDE_DIR ${FLATBUFFERS_TOOLCHAIN_DIR}/include)
set(SCHEMA_SRC $ENV{CANGJIE_HOME}/schema/StdAstFormat.fbs)
get_filename_component(FILENAME ${SCHEMA_SRC} NAME_WE)
set(FLATC_EXECUTABLE ${FLATBUFFERS_TOOLCHAIN_DIR}/bin/flatc)

if(NOT EXISTS ${FLATC_EXECUTABLE})
    message(FATAL_ERROR "flatc not found at ${FLATC_EXECUTABLE}. Build cangjie_compiler and source envsetup.sh first.")
endif()
if(NOT EXISTS ${SCHEMA_SRC})
    message(FATAL_ERROR "StdAstFormat.fbs not found at ${SCHEMA_SRC}. Build cangjie_compiler and source envsetup.sh first.")
endif()
if(NOT EXISTS ${FLATBUFFERS_TOOLCHAIN_DIR}/cangjie)
    message(FATAL_ERROR "flatbuffers cangjie runtime not found at ${FLATBUFFERS_TOOLCHAIN_DIR}/cangjie. Build cangjie_compiler and source envsetup.sh first.")
endif()
if(NOT EXISTS ${FLATBUFFERS_INCLUDE_DIR}/flatbuffers/flatbuffers.h)
    message(FATAL_ERROR "flatbuffers headers not found at ${FLATBUFFERS_INCLUDE_DIR}. Rebuild and reinstall cangjie_compiler to update third_party/flatbuffers.")
endif()

if(IOS)
    get_directory_property(SRC_COMPILE_OPTIONS COMPILE_OPTIONS)
    list(REMOVE_ITEM SRC_COMPILE_OPTIONS "--target=${TRIPLE}")
    set_directory_properties(PROPERTIES COMPILE_OPTIONS "${SRC_COMPILE_OPTIONS}")
    add_compile_options(--target=${CXX_COMPATIABLE_TRIPLE})
endif()

# Generate cpp code for ast using flatc with cpp backend.
set(FLATC_CPP_OUTPUT "${CMAKE_BINARY_DIR}/include/flatbuffers/${FILENAME}_generated.h")
add_custom_command(
    OUTPUT ${FLATC_CPP_OUTPUT}
    COMMAND ${FLATC_EXECUTABLE} ARGS --no-warnings -c -o "${CMAKE_BINARY_DIR}/include/flatbuffers" ${SCHEMA_SRC}
    DEPENDS ${FLATC_EXECUTABLE} ${SCHEMA_SRC}
    COMMENT "generate cpp file using flatc"
    WORKING_DIRECTORY ${FLATBUFFERS_TOOLCHAIN_DIR})

# Generate cangjie code for ast using flatc with cangjie backend.
set(FLATC_CJ_OUTPUT "${CMAKE_BINARY_DIR}/${FILENAME}_generated.cj")
set(AST_CJ_DIR ${CMAKE_SOURCE_DIR}/libs/std/ast)
set(AST_GENERATED_CJ ${AST_CJ_DIR}/${FILENAME}_generated.cj)

add_custom_command(
    OUTPUT ${FLATC_CJ_OUTPUT} ${AST_GENERATED_CJ}
    COMMAND ${FLATC_EXECUTABLE} ARGS --no-warnings --cangjie -o "${CMAKE_BINARY_DIR}" ${SCHEMA_SRC}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${FLATC_CJ_OUTPUT} ${AST_GENERATED_CJ}
    DEPENDS ${FLATC_EXECUTABLE} ${SCHEMA_SRC}
    COMMENT "generate and install StdAstFormat_generated.cj"
    WORKING_DIRECTORY ${FLATBUFFERS_TOOLCHAIN_DIR})

add_custom_target(FLATC_OUTPUTS ALL DEPENDS ${FLATC_CJ_OUTPUT} ${FLATC_CPP_OUTPUT} ${AST_GENERATED_CJ})

file(GLOB ast_ffi_src
    ./ast_api.cpp)
set(libname cangjie-std-astFFI) 
add_library(${libname}-objs OBJECT ${ast_ffi_src})
set_target_properties(${libname}-objs PROPERTIES COMPILE_FLAGS "-fPIC")
add_dependencies(${libname}-objs FLATC_OUTPUTS)

set(CANGJIE_INC_DIR)
set(AST_SUPPORT_LIB_DIR)
# using CANGJIE_HOME or cangjie source directory
if(DEFINED ENV{CANGJIE_HOME})
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)
    if(TRIPLE STREQUAL "arm-linux-android23")
        set(output_cj_lib_dir linux_android23_arm_cjnative)
    endif()
    set(AST_SUPPORT_LIB_DIR $ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir})
    set(CANGJIE_INC_DIR $ENV{CANGJIE_HOME}/include)
    if(NOT EXISTS "${CANGJIE_INC_DIR}/cangjie")
        # using local cangjie source
        set(CANGJIE_INC_DIR ~/dev/cangjie/cangjie/include)
        if(NOT EXISTS "${CANGJIE_INC_DIR}/cangjie")
            message(FATAL_ERROR "NOT FOUND CANGJIE HEADERS")
        endif()
    endif()
else()
    message(FATAL_ERROR "NOT FOUND CJC")
endif()

target_compile_options(${libname}-objs PRIVATE ${CMAKE_C_COVERAGE_FLAGS})
if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
    target_compile_options(${libname}-objs PUBLIC "-fno-exceptions")
    target_compile_definitions(${libname}-objs PRIVATE CANGJIE_ENABLE_GCOV)
endif()
# CANGJIE_AST_LOCAL_MODE_API tells ast_api.cpp whether the local-mode APIs are
# compiled into the library. When they are not (CANGJIE_ENABLE_LOCAL_MODE_API=OFF,
# the AddCangjieSource default), the cj side of std.ast trims the local-mode
# tokens and AST builders, so the FFI's lexer and parsers must keep local mode
# off; OHOS is handled by __ohos__ in the source.
if(CANGJIE_ENABLE_LOCAL_MODE_API)
    target_compile_definitions(${libname}-objs PRIVATE CANGJIE_AST_LOCAL_MODE_API)
endif()
target_include_directories(${libname}-objs PRIVATE ${CANGJIE_INC_DIR} ${CMAKE_BINARY_DIR}/include ${FLATBUFFERS_INCLUDE_DIR})

set(TARGET_AR ar)
if(MINGW OR DARWIN)
    set(TARGET_AR ${CMAKE_AR})
elseif(CMAKE_CROSSCOMPILING)
    if(IOS)
        set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/ar)
    elseif(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
        set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/llvm-ar)
    else()
        set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/${TRIPLE}-ar)
    endif()
endif()

set(AST_FFI_LIB ${CMAKE_BINARY_DIR}/lib${libname}.a)

# add ast_api.obj to ast-support.a, because the same-named files will be overwritten when decompressing ast-suppor.a.
add_custom_command(
    OUTPUT ${AST_FFI_LIB}
    COMMAND ${CMAKE_COMMAND} -E copy 
        $ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir}/libcangjie-ast-support.a
        ${AST_FFI_LIB}
    COMMAND ${TARGET_AR} qD ${AST_FFI_LIB} $<TARGET_OBJECTS:${libname}-objs>
    DEPENDS ${libname}-objs
)

add_custom_target(AST_SUPPORT ALL DEPENDS ${AST_FFI_LIB})

# install for static lib
install_ast_library_ffi(${AST_FFI_LIB})
