# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

get_filename_component(CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
include("${CMAKE_DIR}/linux_toolchain.cmake")
 
set(CMAKE_SYSTEM_NAME "Android")
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
if(NOT CMAKE_ANDROID_API)
    set(CMAKE_ANDROID_API 31)
    message(STATUS "Android API level is not set, use default setting: ${CMAKE_ANDROID_API}")
endif()
set(CMAKE_ANDROID_ARCH_ABI "x86_64")
string(TOLOWER ${CMAKE_HOST_SYSTEM_NAME} lower_host_os)
set(CANGJIE_TARGET_TOOLCHAIN "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/${lower_host_os}-${CMAKE_HOST_SYSTEM_PROCESSOR}/bin")
set(TRIPLE x86_64-linux-android${CMAKE_ANDROID_API})
if(CMAKE_ANDROID_API EQUAL 26)
    set(TARGET_TRIPLE_DIRECTORY_PREFIX linux_android_x86_64)
else()
    set(TARGET_TRIPLE_DIRECTORY_PREFIX linux_android${CMAKE_ANDROID_API}_x86_64)
endif()

# Add support for 16k page size (required for Android 13+)
set(ANDROID_MAX_PAGE_SIZE 16384)
set(LINK_FLAGS "${LINK_FLAGS} -Wl,-z,max-page-size=${ANDROID_MAX_PAGE_SIZE}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=${ANDROID_MAX_PAGE_SIZE}")
 
# Variable ANDROID will be set by CMake. Custom variables are not necessary here.