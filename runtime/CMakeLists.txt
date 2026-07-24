# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

cmake_minimum_required(VERSION 3.16.3)
if (OHOS_FLAG MATCHES 1 OR OHOS_FLAG MATCHES 2 OR OHOS_FLAG MATCHES 3)
    # Target OHOS is Linux-like system.
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_C_COMPILER_WORKS 1)
    set(CMAKE_CXX_COMPILER_WORKS 1)
endif()

# 1 means android_aarch64, 2 means android_x86_64, 3 means android_arm
if (ANDROID_FLAG MATCHES 1 OR ANDROID_FLAG MATCHES 2 OR ANDROID_FLAG MATCHES 3)
    set(ANDROID_OS "linux")
    if (CMAKE_ANDROID_API MATCHES 26)
        set(ANDROID_TARGET_API "android26")
    elseif (CMAKE_ANDROID_API MATCHES 31)
        set(ANDROID_TARGET_API "android31")
    elseif (CMAKE_ANDROID_API MATCHES 23)
        if (ANDROID_FLAG MATCHES 1 OR ANDROID_FLAG MATCHES 2)
            set(ANDROID_TARGET_API "android23")
        elseif (ANDROID_FLAG MATCHES 3)
            set(ANDROID_TARGET_API "androideabi23")
        endif()
    else ()
        message(FATAL_ERROR "ANDROID_TARGET_API is not set, please check the target option.")
    endif()
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_C_COMPILER_WORKS 1)
    set(CMAKE_CXX_COMPILER_WORKS 1)
    if (ANDROID_FLAG MATCHES 1)
        set(ANDROID_ARCH "aarch64")
    elseif (ANDROID_FLAG MATCHES 2)
        set(ANDROID_ARCH "x86_64")
    elseif (ANDROID_FLAG MATCHES 3)
        set(ANDROID_ARCH "armv7a")
    endif()
endif()

if (WINDOWS_FLAG MATCHES 1)
    set(CMAKE_SYSTEM_NAME Windows)
endif()
# Windows target must be set before project(CangjieRuntime).
if (WINDOWS_FLAG MATCHES 1)
    # Use target x86_64-w64-mingw32 instead of x86_64-windows-gnu
    # to make sure clang can find x86_64-w64-mingw32-ld (linker for cross-compiling)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -target x86_64-w64-mingw32 -pthread -femulated-tls --rtlib=compiler-rt")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static -target x86_64-w64-mingw32 -pthread -femulated-tls -stdlib=libc++ --rtlib=compiler-rt")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -static -target x86_64-w64-mingw32 --rtlib=compiler-rt")
    if (NOT CMAKE_AR_PATH)
        set(CMAKE_AR_PATH "llvm-ar.exe")
    endif()
endif ()

# project name: CangjieRuntime
project(CangjieRuntime C CXX ASM)

if(BUILD_GCC_TOOLCHAIN AND (CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    message(STATUS "Add compile option for clang, --gcc-toolchain=${BUILD_GCC_TOOLCHAIN}")
    add_compile_options(--gcc-toolchain=${BUILD_GCC_TOOLCHAIN})
    add_link_options(--gcc-toolchain=${BUILD_GCC_TOOLCHAIN})
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/config.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/SetupAr.cmake)

message("-- BUILD_CJTHREAD: " ${BUILD_CJTHREAD})
message("-- BUILD_RUNTIME: "   ${BUILD_RUNTIME})

if (SANITIZER_SUPPORT_FLAG MATCHES 1)
    add_compile_definitions(CANGJIE_SANITIZER_SUPPORT)
endif()

if (SANITIZER_SUPPORT_FLAG MATCHES 1 OR GWPASAN_SUPPORT_FLAG MATCHES 1)
    set(SANITIZER_LIB "-Wl,--whole-archive" "Sanitizer" "-Wl,--no-whole-archive")
    set(SANITIZER_LIB_STATIC "$<TARGET_OBJECTS:Sanitizer>")
endif ()

set(CJTHREAD_SAN_PRARM "cj")
set(SANITIZER_SUBPATH "")
if (ASAN_SUPPORT_FLAG MATCHES 1)
    set(CJTHREAD_SAN_PRARM "cjasan")
    add_compile_definitions(CANGJIE_ASAN_SUPPORT)
    add_compile_definitions(GENERAL_ASAN_SUPPORT_INTERFACE)
    set(SANITIZER_SUBPATH "/asan")
elseif (TSAN_SUPPORT_FLAG MATCHES 1)
    set(CJTHREAD_SAN_PRARM "cjtsan")
    add_compile_definitions(CANGJIE_TSAN_SUPPORT)
    set(SANITIZER_SUBPATH "/tsan")
elseif (HWASAN_SUPPORT_FLAG MATCHES 1)
    set(CJTHREAD_SAN_PRARM "cjhwasan")
    add_compile_definitions(CANGJIE_HWASAN_SUPPORT)
    add_compile_definitions(GENERAL_ASAN_SUPPORT_INTERFACE)
    set(SANITIZER_SUBPATH /hwasan)
elseif (GWPASAN_SUPPORT_FLAG MATCHES 1)
    add_compile_definitions(CANGJIE_GWPASAN_SUPPORT)
endif ()

set(OTHER_DEFINITIONS " ")
if (RUNTIME_FORWARD_PTRAUTH_CFI MATCHES 1)
    set(OTHER_DEFINITIONS "${OTHER_DEFINITIONS} -DRUNTIME_FORWARD_PTRAUTH_CFI=1")
    add_compile_definitions(ENABLE_FORWARD_PTRAUTH_CFI)
endif ()
if (RUNTIME_BACKWARD_PTRAUTH_CFI MATCHES 1)
    set(OTHER_DEFINITIONS "${OTHER_DEFINITIONS} -DRUNTIME_BACKWARD_PTRAUTH_CFI=1")
    add_compile_definitions(ENABLE_BACKWARD_PTRAUTH_CFI)
endif ()
if (ANDROID_FLAG IN_LIST ANDROID_FLAG_LIST)
    set(OTHER_DEFINITIONS "-DCMAKE_C_COMPILER_FORCED=ON -DCMAKE_CXX_COMPILER_FORCED=ON")
endif ()

if (BUILD_DEMANGLE)
    message("-- BUILD_DEMANGLE: " ${BUILD_DEMANGLE})
    add_subdirectory(src)
endif() # BUILD_DEMANGLE

if (BUILD_CJTHREAD) # BUILD_CJTHREAD
# build cjthread
if (WINDOWS_FLAG MATCHES 1)
    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("build cjthread for windows on windows")
        # build\build_cjthread_windows.bat -p windows_x86_64 Debug STATIC
        execute_process(COMMAND build\\build_cjthread_windows.bat -p windows_x86_64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} "${OTHER_DEFINITIONS}" "${CMAKE_INSTALL_PREFIX}" ${TARGET_ARCH})
    elseif (CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        message("build cjthread for windows on linux")
        execute_process(COMMAND bash build/build_cjthread.sh -p cross_windows_x86_64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} "${OTHER_DEFINITIONS}" "${CMAKE_INSTALL_PREFIX}" ${TARGET_ARCH})
    else ()
        message("Only the Windows and Linux platforms are supported.")
    endif ()
elseif (OHOS_FLAG MATCHES 1) # for ohos-aarch64
    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("build cjthread for ohos on windows")
        execute_process(COMMAND build\\build_cjthread_windows.bat -p ohos_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    else ()
        message("build cjthread for ohos")
        execute_process(COMMAND bash build/build_cjthread.sh -p ohos_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    endif ()
elseif (OHOS_FLAG MATCHES 2) # for ohos-x86_64
    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("build cjthread for ohos on windows")
        execute_process(COMMAND build\\build_cjthread_windows.bat -p ohos_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    else ()
        message("build cjthread for ohos")
        execute_process(COMMAND bash build/build_cjthread.sh -p ohos_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    endif ()
elseif (OHOS_FLAG MATCHES 3) # for ohos-arm
    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        message("build cjthread for ohos on windows")
        execute_process(COMMAND build\\build_cjthread_windows.bat -p ohos_arm_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    else ()
        message("build cjthread for ohos")
        execute_process(COMMAND bash build/build_cjthread.sh -p ohos_arm_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    endif ()
elseif (ANDROID_FLAG MATCHES 1) # for android-aarch64
    message("build cjthread for ${ANDROID_TARGET_API}")
    set(ENV{ANDROID_ROOT} "${ANDROID_ROOT}")
    set(ENV{ANDROID_ARCH} "${ANDROID_ARCH}")
    set(ENV{ANDROID_TARGET_API} "${ANDROID_TARGET_API}")
    execute_process(COMMAND sh build/build_cjthread.sh -p android_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
elseif (ANDROID_FLAG MATCHES 2) # for android-x86_64
    message("build cjthread for ${ANDROID_TARGET_API}")
    set(ENV{ANDROID_ROOT} "${ANDROID_ROOT}")
    set(ENV{ANDROID_ARCH} "${ANDROID_ARCH}")
    set(ENV{ANDROID_TARGET_API} "${ANDROID_TARGET_API}")
    execute_process(COMMAND sh build/build_cjthread.sh -p android_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
elseif (ANDROID_FLAG MATCHES 3) # for android-armv7a
    message("build cjthread for ${ANDROID_TARGET_API}")
    set(ENV{ANDROID_ROOT} "${ANDROID_ROOT}")
    set(ENV{ANDROID_ARCH} "${ANDROID_ARCH}")
    set(ENV{ANDROID_TARGET_API} "${ANDROID_TARGET_API}")
    execute_process(COMMAND sh build/build_cjthread.sh -p android_arm_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
elseif (MACOS_FLAG MATCHES 1)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        message("build cjthread for macos x86_64")
        execute_process(COMMAND bash build/build_cjthread.sh -p macos_x86_64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    else()
        message("build cjthread for macos aarch64")
        execute_process(COMMAND bash build/build_cjthread.sh -p macos_aarch64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    endif()
elseif (IOS_FLAG MATCHES 1)
    message("build cjthread for ios")
    execute_process(COMMAND sh build/build_cjthread.sh -p ios_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
elseif (IOS_SIMULATOR_FLAG MATCHES 2)
        message("build cjthread for ios simulator x86_64")
        execute_process(COMMAND sh build/build_cjthread.sh -p ios_simulator_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
elseif (IOS_SIMULATOR_FLAG MATCHES 1)
        message("build cjthread for ios simulator aarch64")
        execute_process(COMMAND sh build/build_cjthread.sh -p ios_simulator_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
else ()
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
        message("build cjthread for aarch64")
        # bash build/build_cjthread.sh -p linux_aarch64_cangjie Debug STATIC ${CJTHREAD_SAN_PRARM}
        execute_process(COMMAND sh build/build_cjthread.sh -p linux_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    else ()
        # bash build/build_cjthread.sh -p linux_x86_64_cangjie Debug STATIC ${CJTHREAD_SAN_PRARM}
        message("build cjthread for x86_64")
        execute_process(COMMAND bash build/build_cjthread.sh -p linux_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH})
    endif ()
endif () # WINDOWS_FLAG

message("build cjthread done!!!")
endif() # BUILD_CJTHREAD

if (BUILD_RUNTIME)
include_directories(${DOPRA_INCLUDE})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

if (DOPRA_FLAG MATCHES 1)
    add_definitions(-DMRT_USE_CJTHREAD_RENAME)
endif ()
if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    add_definitions(-D_XOPEN_SOURCE=600)
    add_definitions(-D_DARWIN_C_SOURCE)
    # add_definitions(-D__USE_GNU)
endif()

# Build the runtime for ARM-based Euler operating system
# the -outline-atomics option is enabled by default, which can cause symbol not found.
# To resolve the issue, disable the option by default.
if (EULER_FLAG MATCHES 1 AND CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" AND WINDOWS_FLAG MATCHES 1)
    message("disable option -mno-outline-atomics")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mno-outline-atomics")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mno-outline-atomics")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -mno-outline-atomics")
endif ()

if (COPYGC_FLAG MATCHES 1)
    add_definitions(-DMRT_USE_COPYGC)
endif ()

if (DUMPADDRESS_FLAG MATCHES 1)
    add_definitions(-DMRT_DUMP_ADDRESS)
endif ()

if (CJ_SDK_VERSION)
    add_definitions(-DCJ_SDK_VERSION="${CJ_SDK_VERSION}")
endif()

if (DISABLE_VERSION_CHECK MATCHES 1)
    add_definitions(-DDISABLE_VERSION_CHECK)
endif()

# add singal handle function for the coverage calculation
if (COV MATCHES 1)
    add_definitions(-DCOV_SIGNALHANDLE)
endif ()

link_directories(${DOPRA_LIBS})
link_directories(${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
if (ANDROID_FLAG MATCHES 1)
    FILE(GLOB_RECURSE CLANG_LIB_FILES ${ANDROID_ROOT}/libclang_rt.builtins-aarch64-android.a)
    list(GET CLANG_LIB_FILES 0 FIRST_FILE)
    get_filename_component(CLANG_LIB_PARENT_DIR ${FIRST_FILE} DIRECTORY)
    link_directories(${CLANG_LIB_PARENT_DIR})
    set(CMAKE_SYSTEM_PROCESSOR "aarch64")
elseif (ANDROID_FLAG MATCHES 2)
    FILE(GLOB_RECURSE CLANG_LIB_FILES ${ANDROID_ROOT}/libclang_rt.builtins-x86_64-android.a)
    list(GET CLANG_LIB_FILES 0 FIRST_FILE)
    get_filename_component(CLANG_LIB_PARENT_DIR ${FIRST_FILE} DIRECTORY)
    link_directories(${CLANG_LIB_PARENT_DIR})
    set(CMAKE_SYSTEM_PROCESSOR "x86_64")
elseif (ANDROID_FLAG MATCHES 3)
    FILE(GLOB_RECURSE CLANG_LIB_FILES ${ANDROID_ROOT}/libclang_rt.builtins-arm-android.a)
    list(GET CLANG_LIB_FILES 0 FIRST_FILE)
    get_filename_component(CLANG_LIB_PARENT_DIR ${FIRST_FILE} DIRECTORY)
    link_directories(${CLANG_LIB_PARENT_DIR})
    set(CMAKE_SYSTEM_PROCESSOR "arm")
elseif (MACOS_FLAG MATCHES 1)
    execute_process(COMMAND xcrun --show-sdk-path OUTPUT_VARIABLE output OUTPUT_STRIP_TRAILING_WHITESPACE)
    # set(output "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk")
    link_directories(${output}/usr/lib)
    link_directories(/usr/local/lib)
    set(CMAKE_OSX_DEPLOYMENT_TARGET 12.0.0)
elseif (IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    set(IOS_PLATFORM "SIMULATOR")
    set(IOS_PLATFORM_LOCATION "iPhoneSimulator.platform")
    set(CMAKE_IOS_DEVELOPER_ROOT "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer")
    set(CMAKE_IOS_SDK_ROOT "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk")
    set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator17.5.sdk")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "")
elseif (IOS_FLAG MATCHES 1)
    set(IOS ON)
    set(IOS_PLATFORM OS)
    set(IOS_PLATFORM_LOCATION "iPhoneOS.platform")
    set(CMAKE_IOS_DEVELOPER_ROOT "/Applications/Xcode.app/Contents/Developer/Platforms/${IOS_PLATFORM_LOCATION}/Developer")
    set(CMAKE_IOS_SDK_ROOT "${CMAKE_IOS_DEVELOPER_ROOT}/SDKs/iPhoneOS17.5.sdk")
    set(CMAKE_OSX_SYSROOT "${CMAKE_IOS_DEVELOPER_ROOT}/SDKs/iPhoneOS17.5.sdk")
    set(CMAKE_OSX_DEPLOYMENT_TARGET "")
    set(CMAKE_SYSTEM_PROCESSOR "aarch64")
    message(STATUS "IOS_FLAG=${IOS_FLAG}: iOS real device (aarch64) config, force CMAKE_SYSTEM_PROCESSOR=${CMAKE_SYSTEM_PROCESSOR}, SDK=${CMAKE_IOS_SDK_ROOT}")
endif()

link_directories(${OHOS_LIB})
include_directories(${BOUNDSCHECK_INCLUDE})
add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/src)
add_subdirectory(third_party/third_party_bounds_checking_function)
if (ANDROID_FLAG MATCHES 0 AND OHOS_FLAG MATCHES 0 AND WINDOWS_FLAG MATCHES 0 AND MACOS_FLAG MATCHES 0 AND IOS_FLAG MATCHES 0 AND IOS_SIMULATOR_FLAG MATCHES 0)
if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    set(LINK_SCRIPTS "-Wl,-T${CMAKE_CURRENT_SOURCE_DIR}/build/lds/aarch64_linux/cjnative_runtime.lds")
    add_library(cjNativeStartAndEnd OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/aarch64_linux/CjNativeRuntimeStartAndEnd.S)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
    set(LINK_SCRIPTS "-Wl,-T${CMAKE_CURRENT_SOURCE_DIR}/build/lds/x86_64_linux/cjnative_runtime.lds")
    add_library(cjNativeStartAndEnd OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_linux/CjNativeRuntimeStartAndEnd.S)
endif()
endif()

if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    set(COMMON_LINK_FLAGS "-rdynamic")
else()
    set(COMMON_LINK_FLAGS "-Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack -Wl,--gc-sections \
        -Wl,-Bsymbolic -Wl,--no-undefined -rdynamic ${LINK_SCRIPTS}")
endif()

if (COV MATCHES 1)
    set_target_properties(cangjie-runtime PROPERTIES LINK_FLAGS "${COMMON_LINK_FLAGS} ${CMAKE_COV_FLAGS}")
    target_compile_definitions(cangjie-runtime PUBLIC COMPILE_DYNAMIC)
    target_compile_options(cangjie-runtime PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Base PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(CjFile PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Common PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Concurrency PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Exception PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Heap PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Allocator PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Barrier PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Collector PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Loader PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Mutator PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(ObjectModel PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Inspector PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Signal PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(BinaryFile PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(CjFileLoader PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(UnwindStack PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(Sync PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(WCollector PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(CjSemanticVersion PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    target_compile_options(CpuProfiler PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    if (DOPRA_FLAG MATCHES 1)
        target_compile_options(cjthreadmodel PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    elseif (DOPRA_FLAG MATCHES 0)
        target_compile_options(threadmodel PUBLIC "SHELL:${CMAKE_COV_FLAGS}")
    endif ()
else ()
    target_compile_definitions(cangjie-runtime PUBLIC COMPILE_DYNAMIC)
    if (WINDOWS_FLAG MATCHES 1)
        set_target_properties(cangjie-runtime PROPERTIES LINK_FLAGS " -Wl,--gc-sections")
    elseif (WINDOWS_FLAG MATCHES 0)
        set_target_properties(cangjie-runtime PROPERTIES LINK_FLAGS "${COMMON_LINK_FLAGS}")
        target_compile_definitions(cangjie-runtime PUBLIC COMPILE_DYNAMIC)
    endif ()
endif ()

# Difference in Windows: remove signal module
# Signal processing use sigaction() as signal-catching function currently, it`s linux related, which can get context when signal was triggered. In Windows, signal() is the only function we can use, but there is no context.
if (WINDOWS_FLAG MATCHES 1)
    list(APPEND LINK_LIBS "boundscheck" "Base" "Common" "Concurrency" "Loader" "Inspector" "Exception" "Heap" "Mutator" "ObjectModel" "UnwindStack"
    "Allocator" "Barrier" "Collector" "WCollector" "BinaryFile" "CjFile" "CjFileLoader" "CjSemanticVersion" "Sync" "dbghelp" "ws2_32" "shlwapi" "CpuProfiler" "Interpreter" ${SANITIZER_LIB})
elseif (WINDOWS_FLAG MATCHES 0)
    list(APPEND LINK_LIBS "boundscheck" "Base" "Common" "Concurrency" "Loader" "Inspector" "Exception" "Heap" "Mutator" "ObjectModel" "UnwindStack" "Signal"
    "Allocator" "Barrier" "Collector" "WCollector" "BinaryFile" "CjFile" "CjFileLoader" "CjSemanticVersion" "Sync" "CpuProfiler" "Interpreter" ${SANITIZER_LIB})
endif()

if (DOPRA_FLAG MATCHES 1)
    if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
        list(APPEND LINK_LIBS "cjthreadmodel" "cangjie-thread")
    else()
        list(APPEND LINK_LIBS "cjthreadmodel" "-Wl,--whole-archive" "cangjie-thread" "-Wl,--no-whole-archive")
    endif()
elseif (DOPRA_FLAG MATCHES 0)
    list(APPEND LINK_LIBS "threadmodel")
endif ()

if (ASAN_FLAG MATCHES 1)
    list(APPEND LINK_LIBS "-fsanitize=address")
endif()

if (HWASAN_FLAG MATCHES 1)
    list(APPEND LINK_LIBS "-shared-libsan -fsanitize=hwaddress -fno-emulated-tls -fno-lto -fno-sanitize=cfi -mllvm -hwasan-globals=0 -fno-whole-program-vtables")
endif()

if (ANDROID_FLAG MATCHES 1)
    list(APPEND LINK_LIBS "clang_rt.builtins-aarch64-android")
endif()
if (ANDROID_FLAG MATCHES 2)
    list(APPEND LINK_LIBS "clang_rt.builtins-x86_64-android")
endif()
if (ANDROID_FLAG MATCHES 3)
    list(APPEND LINK_LIBS "clang_rt.builtins-arm-android")
endif()

if (DOPRA_FLAG MATCHES 1 AND OHOS_FLAG MATCHES 0 AND WINDOWS_FLAG MATCHES 0) # linux
    if (COV MATCHES 1) # linux - cov
        target_link_libraries(cangjie-runtime "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/local_export.map"
            "-lstdc++ -lpthread -ldl" ${LINK_LIBS} "cjNativeStartAndEnd" "-Wl,--end-group")
    else ()
        if (ANDROID_FLAG IN_LIST ANDROID_FLAG_LIST) # android
            if (ANDROID_FLAG MATCHES 3) # arm
                target_link_libraries(cangjie-runtime
                    "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/arm_local_export.map"
                    ${LINK_LIBS} "-Wl,--end-group -nodefaultlibs -Wl,-Bdynamic -lc++ -lunwind -lm -lc -ldl -landroid -llog")
            else()
                target_link_libraries(cangjie-runtime
                    "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/local_export.map"
                    ${LINK_LIBS} "-Wl,--end-group -nodefaultlibs -Wl,-Bdynamic -lc++ -lunwind -lm -lc -ldl -landroid -llog")
            endif()
        elseif (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2) # macos,ios
            target_link_libraries(cangjie-runtime ${LINK_LIBS} "-Wl,-no_compact_unwind -nodefaultlibs -lc++ -lm -lc -lpthread -ldl")
        else() # normal
            target_link_libraries(cangjie-runtime "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/${EXPORT_MAP}"
                ${LINK_LIBS} "cjNativeStartAndEnd" "-Wl,--end-group -nodefaultlibs -Wl,-Bdynamic -lstdc++ -lm -lc -lgcc_s -lpthread -ldl")
        endif()
    endif ()
elseif (DOPRA_FLAG MATCHES 1 AND OHOS_FLAG IN_LIST OHOS_FLAG_LIST AND WINDOWS_FLAG MATCHES 0) # OHOS
    target_link_libraries(cangjie-runtime "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/${EXPORT_MAP}"
        "-lstdc++" ${LINK_LIBS} "-Wl,--end-group -lunwind -lclang_rt.builtins -lhilog_ndk.z -lhitrace_ndk.z")
elseif (DOPRA_FLAG MATCHES 1 AND OHOS_FLAG MATCHES 0 AND WINDOWS_FLAG MATCHES 1) # Windows
    target_link_libraries(cangjie-runtime PRIVATE "-Wl,--start-group"
        "-Wl,--export-all-symbols" "-lc++" "-lunwind" ${LINK_LIBS} "-Wl,--end-group -Wl,--no-insert-timestamp")
elseif (DOPRA_FLAG MATCHES 0 AND WINDOWS_FLAG MATCHES 0) # thread module
    target_link_libraries(cangjie-runtime "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/${EXPORT_MAP}"
        ${LINK_LIBS} "-Wl,--end-group -nodefaultlibs -Wl,-Bdynamic -lstdc++ -lm -lc -lgcc_s -lpthread -ldl")
elseif (DOPRA_FLAG MATCHES 0 AND WINDOWS_FLAG MATCHES 1) # thread module on windows
    target_link_libraries(cangjie-runtime "-Wl,--start-group -Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/src/local_export.map"
        ${LINK_LIBS} "-Wl,--end-group -nodefaultlibs -Wl,-Bdynamic -lstdc++ -lc -lgcc_s -Wl,--no-insert-timestamp")
endif ()


# setting for cjthread trace
if (DOPRA_FLAG MATCHES 1 AND RUNTIME_TRACE_FLAG MATCHES 1)
    file(WRITE ${CMAKE_BINARY_DIR}/null.c "")
    if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
        link_libraries("-Wl" "cjthread-trace" "-Wl" "boundscheck")
    elseif(WINDOWS_FLAG MATCHES 1)
        link_libraries("-Wl,--whole-archive" "cjthread-trace" "-Wl,--no-whole-archive" "boundscheck")
    else()
        link_libraries("-Wl,--whole-archive" "cjthread-trace" "-Wl,--no-whole-archive" "boundscheck" "-Wl,-z,relro -Wl,-z,now")
    endif()
    add_library(cangjie-trace SHARED null.c)
    if (WINDOWS_FLAG MATCHES 1)
        target_link_libraries(cangjie-trace cangjie-runtime)
        target_link_options(cangjie-trace PRIVATE "-Wl,--no-insert-timestamp")
    endif()
    install(TARGETS cangjie-trace DESTINATION runtime/lib/${TARGET_ARCH}${SANITIZER_SUBPATH})
endif()

install(TARGETS cangjie-runtime DESTINATION runtime/lib/${TARGET_ARCH}${SANITIZER_SUBPATH})

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/src/RuntimeConfig.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/Cangjie.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/Interpreter/RuntimeAPI.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/Interpreter/RTInterface.h
        DESTINATION include)

if (EULER_FLAG MATCHES 1)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/build/scripts/envsetup.sh DESTINATION runtime)
endif()

if (WINDOWS_FLAG MATCHES 1)
    add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_windows/Cjstart.S)
    add_library(section OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/os/Windows/Section.cpp)
elseif (MACOS_FLAG MATCHES 1)
    add_library(section OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/os/Macos/section.cpp)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/X86_64_macos/Cjstart.S)
    else()
        add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/Aarch64_macos/Cjstart.S)
    endif()
elseif (IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    add_library(section OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/os/Macos/Section.cpp)
    if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
        add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_ios/Cjstart.S)
    else()
        if (IOS_SIMULATOR_FLAG MATCHES 2)
            add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_ios/Cjstart.S)
        else ()
            add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/aarch64_ios/Cjstart.S)
        endif()
    endif()
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64")
    add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/aarch64_linux/Cjstart.S)
    install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/aarch64_linux/cjld.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/aarch64_linux/discard_eh_frame.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/aarch64_linux/cld.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/aarch64_linux/cjld.shared.lds
            DESTINATION lib/${TARGET_ARCH})
    if (OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
    add_library(cjpgo OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/aarch64_linux/Cjpgo.S)
    install(PROGRAMS $<TARGET_OBJECTS:cjpgo>
        RENAME cjpgo.o
        DESTINATION lib/${TARGET_ARCH})
    endif()
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
    add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/arm_linux/Cjstart.S)
    install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/arm_linux/cjld.lds
        ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/arm_linux/discard_eh_frame.lds
        ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/arm_linux/cld.lds
        ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/arm_linux/cjld.shared.lds
        DESTINATION lib/${TARGET_ARCH})
else()
    add_library(cjstart OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_linux/Cjstart.S)
    install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/x86_64_linux/cjld.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/x86_64_linux/discard_eh_frame.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/x86_64_linux/cld.lds
            ${CMAKE_CURRENT_SOURCE_DIR}/build/lds/x86_64_linux/cjld.shared.lds
            DESTINATION lib/${TARGET_ARCH})
    if (OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
    add_library(cjpgo OBJECT ${CMAKE_CURRENT_SOURCE_DIR}/src/arch/x86_64_linux/Cjpgo.S)
    install(PROGRAMS $<TARGET_OBJECTS:cjpgo>
        RENAME cjpgo.o
        DESTINATION lib/${TARGET_ARCH})
    endif()
endif()
install(PROGRAMS $<TARGET_OBJECTS:cjstart>
        RENAME cjstart.o
        DESTINATION lib/${TARGET_ARCH})
if (MACOS_FLAG MATCHES 1 OR WINDOWS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    install(PROGRAMS $<TARGET_OBJECTS:section>
        RENAME section.o
        DESTINATION lib/${TARGET_ARCH})
endif()

if (CMAKE_BUILD_TYPE MATCHES "^(Release|MinSizeRel)$")
    message("strip: ${CMAKE_INSTALL_PREFIX}")
    set(STRIP_PROGRAM strip)
    if(OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
        # System installed `strip` may not support aarch64 targets. We use llvm-strip in OHOS toolchain.
        if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
            set(STRIP_PROGRAM $ENV{OHOS_ROOT}/prebuilts/clang/ohos/windows-x86_64/llvm/bin/llvm-strip)
        endif()
        if (CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
            set(STRIP_PROGRAM $ENV{OHOS_ROOT}/prebuilts/clang/ohos/linux-x86_64/llvm/bin/llvm-strip)
        endif()
        if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
            set(STRIP_PROGRAM $ENV{OHOS_ROOT}/prebuilts/clang/ohos/${CMAKE_HOST_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}/llvm/bin/llvm-strip)
        endif()
    endif()
    if (ANDROID_FLAG IN_LIST ANDROID_FLAG_LIST)
        if (CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
            set(STRIP_PROGRAM $ENV{ANDROID_ROOT}/llvm/prebuilt/darwin-x86_64/bin/llvm-strip)
        else()
            set(STRIP_PROGRAM $ENV{ANDROID_ROOT}/llvm/prebuilt/linux-x86_64/bin/llvm-strip)
        endif()
    endif()
    if (WINDOWS_FLAG MATCHES 1)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -p ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}/libcangjie-runtime.dll)"
            COMPONENT cangjie-runtime)
        if (ASAN_SUPPORT_FLAG MATCHES 0)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/bin/cjfilt.exe)"
            COMPONENT cjfilt)
        endif()
        if (RUNTIME_TRACE_FLAG MATCHES 1)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -p ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}/libcangjie-trace.dll)"
            COMPONENT cangjie-trace)
        endif()
    elseif (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -x ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}/libcangjie-runtime.dylib)"
                COMPONENT cangjie-runtime)
        if (ASAN_SUPPORT_FLAG MATCHES 0)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -u -r ${CMAKE_INSTALL_PREFIX}/bin/cjfilt)"
                COMPONENT cjfilt)
        endif()
        if (RUNTIME_TRACE_FLAG MATCHES 1)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}/libcangjie-trace.dylib)"
            COMPONENT cangjie-trace)
        endif()
    else()
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}${SANITIZER_SUBPATH}/libcangjie-runtime.so)"
                COMPONENT cangjie-runtime)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -g ${CMAKE_INSTALL_PREFIX}/lib/${TARGET_ARCH}/cjstart.o)"
                COMPONENT cjstart)
        if (OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}/libcangjie-demangle.so)"
                COMPONENT cangjie-demangle)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -g ${CMAKE_INSTALL_PREFIX}/lib/${TARGET_ARCH}/cjpgo.o)"
                COMPONENT cjpgo)
        endif()
        if (ASAN_SUPPORT_FLAG MATCHES 0)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/bin/cjfilt)"
                COMPONENT cjfilt)
        endif()
        if (RUNTIME_TRACE_FLAG MATCHES 1)
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} ${CMAKE_INSTALL_PREFIX}/runtime/lib/${TARGET_ARCH}${SANITIZER_SUBPATH}/libcangjie-trace.so)"
            COMPONENT cangjie-trace)
        endif()
    endif()
endif () # CMAKE_BUILD_TYPE MATCHES "^(Release|MinSizeRel)$"


if (IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2 OR WINDOWS_FLAG MATCHES 1
    OR MACOS_FLAG MATCHES 1 OR (ANDROID_FLAG MATCHES 0 AND OHOS_FLAG MATCHES 0))
    add_library(cangjie-runtime-static STATIC)
    if (WINDOWS_FLAG MATCHES 1)
        target_sources(cangjie-runtime-static PRIVATE
            $<TARGET_OBJECTS:runtime>
            $<TARGET_OBJECTS:Base>
            $<TARGET_OBJECTS:CjFile>
            $<TARGET_OBJECTS:Concurrency>
            $<TARGET_OBJECTS:Common>
            $<TARGET_OBJECTS:Exception>
            $<TARGET_OBJECTS:Heap>
            $<TARGET_OBJECTS:Allocator>
            $<TARGET_OBJECTS:Barrier>
            $<TARGET_OBJECTS:Collector>
            $<TARGET_OBJECTS:Loader>
            $<TARGET_OBJECTS:Inspector>
            $<TARGET_OBJECTS:Mutator>
            $<TARGET_OBJECTS:ObjectModel>
            $<TARGET_OBJECTS:BinaryFile>
            $<TARGET_OBJECTS:CjFileLoader>
            $<TARGET_OBJECTS:UnwindStack>
            $<TARGET_OBJECTS:Sync>
            $<TARGET_OBJECTS:WCollector>
            $<TARGET_OBJECTS:cjthreadmodel>
            $<TARGET_OBJECTS:CjSemanticVersion>
            $<TARGET_OBJECTS:CpuProfiler>
            $<TARGET_OBJECTS:Interpreter>
            ${SANITIZER_LIB_STATIC}
        )
    else()
        target_sources(cangjie-runtime-static PRIVATE
            $<TARGET_OBJECTS:runtime>
            $<TARGET_OBJECTS:Base>
            $<TARGET_OBJECTS:CjFile>
            $<TARGET_OBJECTS:Concurrency>
            $<TARGET_OBJECTS:Common>
            $<TARGET_OBJECTS:Exception>
            $<TARGET_OBJECTS:Heap>
            $<TARGET_OBJECTS:Allocator>
            $<TARGET_OBJECTS:Barrier>
            $<TARGET_OBJECTS:Collector>
            $<TARGET_OBJECTS:Loader>
            $<TARGET_OBJECTS:Inspector>
            $<TARGET_OBJECTS:Mutator>
            $<TARGET_OBJECTS:ObjectModel>
            $<TARGET_OBJECTS:Signal>
            $<TARGET_OBJECTS:BinaryFile>
            $<TARGET_OBJECTS:CjFileLoader>
            $<TARGET_OBJECTS:UnwindStack>
            $<TARGET_OBJECTS:Sync>
            $<TARGET_OBJECTS:WCollector>
            $<TARGET_OBJECTS:cjthreadmodel>
            $<TARGET_OBJECTS:CjSemanticVersion>
            $<TARGET_OBJECTS:CpuProfiler>
            $<TARGET_OBJECTS:Interpreter>
            ${SANITIZER_LIB_STATIC}
        )
    endif()
    if (IOS_FLAG MATCHES 1)
        add_custom_command(TARGET cangjie-runtime-static POST_BUILD
            COMMAND sh build/build_cjthread.sh -p ios_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} "apple_static_lib" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            VERBATIM
        )
    elseif (IOS_SIMULATOR_FLAG MATCHES 2)
        add_custom_command(TARGET cangjie-runtime-static POST_BUILD
            COMMAND sh ${CMAKE_SOURCE_DIR}/build/build_cjthread.sh -p ios_simulator_x86_64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} "apple_static_lib" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            VERBATIM
        )
    elseif (IOS_SIMULATOR_FLAG MATCHES 1)
        add_custom_command(TARGET cangjie-runtime-static POST_BUILD
            COMMAND sh ${CMAKE_SOURCE_DIR}/build/build_cjthread.sh -p ios_simulator_aarch64_cangjie ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} "apple_static_lib" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            VERBATIM
        )
    elseif (MACOS_FLAG MATCHES 1)
        if (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64")
            add_custom_command(TARGET cangjie-runtime-static POST_BUILD
                COMMAND sh ${CMAKE_SOURCE_DIR}/build/build_cjthread.sh -p macos_x86_64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} "apple_static_lib" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                VERBATIM
            )
        else()
            add_custom_command(TARGET cangjie-runtime-static POST_BUILD
                COMMAND sh ${CMAKE_SOURCE_DIR}/build/build_cjthread.sh -p macos_aarch64 ${CMAKE_BUILD_TYPE} STATIC ${CJTHREAD_SAN_PRARM} ${OTHER_DEFINITIONS} ${CMAKE_INSTALL_PREFIX} ${TARGET_ARCH} "apple_static_lib" WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                VERBATIM
            )
        endif()
    endif()
    if (IOS_FLAG MATCHES 1)
        set(RENAME_PLATFORM "ios_cangjie")
    elseif (IOS_SIMULATOR_FLAG MATCHES 2)
        set(RENAME_PLATFORM "ios_simulator_x86_64_cangjie")
    elseif (IOS_SIMULATOR_FLAG MATCHES 1)
        set(RENAME_PLATFORM "ios_simulator_aarch64_cangjie")
    elseif (MACOS_FLAG MATCHES 1)
        set(RENAME_PLATFORM "macos_cangjie")
    else()
        set(RENAME_PLATFORM "empty")
    endif()
    if (IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2 OR MACOS_FLAG MATCHES 1)
        add_custom_command(TARGET cangjie-runtime-static PRE_BUILD
            COMMAND sh ${CMAKE_SOURCE_DIR}/build/apple_rename_section.sh
                "${RENAME_PLATFORM}"
                "${CMAKE_C_COMPILER}"
                "$<TARGET_OBJECTS:runtime>"
                "$<TARGET_OBJECTS:Base>"
                "$<TARGET_OBJECTS:CjFile>"
                "$<TARGET_OBJECTS:Concurrency>"
                "$<TARGET_OBJECTS:Common>"
                "$<TARGET_OBJECTS:Exception>"
                "$<TARGET_OBJECTS:Heap>"
                "$<TARGET_OBJECTS:Allocator>"
                "$<TARGET_OBJECTS:Barrier>"
                "$<TARGET_OBJECTS:Collector>"
                "$<TARGET_OBJECTS:Loader>"
                "$<TARGET_OBJECTS:Inspector>"
                "$<TARGET_OBJECTS:Mutator>"
                "$<TARGET_OBJECTS:ObjectModel>"
                "$<TARGET_OBJECTS:Signal>"
                "$<TARGET_OBJECTS:BinaryFile>"
                "$<TARGET_OBJECTS:CjFileLoader>"
                "$<TARGET_OBJECTS:UnwindStack>"
                "$<TARGET_OBJECTS:Sync>"
                "$<TARGET_OBJECTS:WCollector>"
                "$<TARGET_OBJECTS:cjthreadmodel>"
                "$<TARGET_OBJECTS:CjSemanticVersion>"
                "$<TARGET_OBJECTS:CpuProfiler>"
                "$<TARGET_OBJECTS:Interpreter>"
                "${SANITIZER_LIB_STATIC}"
            VERBATIM
        )
    endif()
    install(TARGETS cangjie-runtime-static ARCHIVE DESTINATION lib/${TARGET_ARCH}${SANITIZER_SUBPATH})
    set_target_properties(cangjie-runtime-static PROPERTIES OUTPUT_NAME "cangjie-runtime")

    set(OBJCOPY_PROGRAM objcopy)
    set(STRIP_PROGRAM strip)
    if (WINDOWS_FLAG MATCHES 1)
        install(CODE "execute_process(COMMAND bash ${CMAKE_SOURCE_DIR}/build/windows_rename_section.sh \
                ${CMAKE_INSTALL_PREFIX}/lib/${TARGET_ARCH}${SANITIZER_SUBPATH}/libcangjie-runtime.a)"
            COMPONENT cangjie-runtime)
    else()
        install(CODE "execute_process(COMMAND ${OBJCOPY_PROGRAM} -D --rename-section .text=.text_runtime \
                    ${CMAKE_INSTALL_PREFIX}/lib/${TARGET_ARCH}${SANITIZER_SUBPATH}/libcangjie-runtime.a)"
                COMPONENT cangjie-runtime)
    endif()
    if((CMAKE_BUILD_TYPE MATCHES "Release" OR CMAKE_BUILD_TYPE MATCHES "MinSizeRel") AND NOT (WINDOWS_FLAG MATCHES 1))
        install(CODE "execute_process(COMMAND ${STRIP_PROGRAM} -D --strip-unneeded \
                    ${CMAKE_INSTALL_PREFIX}/lib/${TARGET_ARCH}${SANITIZER_SUBPATH}/libcangjie-runtime.a)"
            COMPONENT cangjie-runtime)
    endif()
endif()

endif() # BUILD_RUNTIME
