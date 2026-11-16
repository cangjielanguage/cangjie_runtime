# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.
 
get_filename_component(CMAKE_DIR "${CMAKE_CURRENT_LIST_FILE}" PATH)
include("${CMAKE_DIR}/linux_toolchain.cmake")
 
set(CMAKE_SYSTEM_NAME "Android")
set(CMAKE_SYSTEM_PROCESSOR "armv7-a")
if(NOT CMAKE_ANDROID_API)
    set(CMAKE_ANDROID_API 23)
    message(STATUS "Android API level is not set, use default setting: ${CMAKE_ANDROID_API}")
endif()
set(CMAKE_ANDROID_ARCH_ABI "armeabi-v7a")

set(ANDROID_ABI "armeabi-v7a")
set(ANDROID_PLATFORM "android-23")
set(ANDROID_NATIVE_API_LEVEL 23)
set(ANDROID_TARGET_API "android23")
set(CMAKE_SYSTEM_VERSION 23)

string(TOLOWER ${CMAKE_HOST_SYSTEM_NAME} lower_host_os)
set(CANGJIE_TARGET_TOOLCHAIN "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/${lower_host_os}-${CMAKE_HOST_SYSTEM_PROCESSOR}/bin")
set(TRIPLE arm-linux-android${CMAKE_ANDROID_API})
set(TARGET_TRIPLE_DIRECTORY_PREFIX linux_android${CMAKE_ANDROID_API}_arm)

# Android 32-bit ARM runs with 4 KB pages.
set(ANDROID_MAX_PAGE_SIZE 4096)
set(LINK_FLAGS "${LINK_FLAGS} -Wl,-z,max-page-size=${ANDROID_MAX_PAGE_SIZE}")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,-z,max-page-size=${ANDROID_MAX_PAGE_SIZE}")

# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-error=shorten-64-to-32 -Wno-error=conversion -Wno-shift-count-overflow")
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-error=shorten-64-to-32 -Wno-error=conversion -Wno-shift-count-overflow")

# Add libatomic for synchronization primitives
#add_link_options(-latomic)
 
# Variable ANDROID will be set by CMake. Custom variables are not necessary here.