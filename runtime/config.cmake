# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

#Introduction to Compilation Macros
#	__OHOS__ : Using Open Harmony Operating System tool chain.
#	__AARCH64_LINUX_GNU__ : Using Aarch64 Linux GNU tool chain.
#	MRT_DEBUG : Indicates whether to use the debug mode.
#	MRT_USE_CJTHREAD_RENAME ：Indicates whether to use CJThread Rename.
#	MRT_USE_COPYGC ： Indicates whether to use copyGC.
#	MRT_DUMP_ADDRESS ：Indicates whether the runtime dumps the address in the log.
#	COV_SIGNALHANDLE : Indicates whether to perform a coverage test.

set(CMAKE_VERBOSE_MAKEFILEON ON)
set(CMAKE_SKIP_RPATH TRUE)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/output/cj" CACHE PATH "My default install prefix" FORCE)
endif()
message(STATUS "install path: ${CMAKE_INSTALL_PREFIX}")
set(CMAKE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/output/temp)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_OUTPUT_DIRECTORY}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_OUTPUT_DIRECTORY}/ar)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY  ${CMAKE_OUTPUT_DIRECTORY}/bin)

if (NOT DOPRA_FLAG)
    set(DOPRA_FLAG 1 CACHE STRING "dopra default is true" FORCE)
endif ()
message(STATUS "DOPRA_FLAG : ${DOPRA_FLAG}")

if (NOT COV)
    set(COV 0 CACHE STRING "cover default is false" FORCE)
endif ()
message(STATUS "COV : ${COV}")

if (NOT ASAN_FLAG)
    set(ASAN_FLAG 0 CACHE STRING "asan default is false" FORCE)
endif ()
message(STATUS "ASAN_FLAG : ${ASAN_FLAG}")

if (NOT HWASAN_FLAG)
    set(HWASAN_FLAG 0 CACHE STRING "hardware asan default is false" FORCE)
endif ()
message(STATUS "HWASAN_FLAG : ${HWASAN_FLAG}")

if (NOT OHOS_FLAG)
    set(OHOS_FLAG 0 CACHE STRING "ohos default is false" FORCE)
endif ()
set(OHOS_FLAG_LIST "1" "2" "3")
message(STATUS "OHOS_FLAG : ${OHOS_FLAG}")

if (NOT WINDOWS_FLAG)
    set(WINDOWS_FLAG 0 CACHE STRING "windows default is false" FORCE)
endif()
message(STATUS "WINDOWS_FLAG : ${WINDOWS_FLAG}")

if (NOT ANDROID_FLAG)
    set(ANDROID_FLAG 0 CACHE STRING "android default is false" FORCE)
endif()
set(ANDROID_FLAG_LIST "1" "2" "3")
message(STATUS "ANDROID_FLAG : ${ANDROID_FLAG}")

if (NOT MACOS_FLAG)
    set(MACOS_FLAG 0 CACHE STRING "macos flag is false" FORCE)
endif()
message(STATUS "MACOS_FLAG : ${MACOS_FLAG}")

if (NOT IOS_FLAG AND NOT IOS_SIMULATOR_FLAG)
    set(IOS_FLAG 0 CACHE STRING "ios flag is false" FORCE)
    set(IOS_SIMULATOR_FLAG 0 CACHE STRING "ios simulator flag is false" FORCE)
endif()
message(STATUS "IOS_FLAG : ${IOS_FLAG}")
message(STATUS "IOS_SIMULATOR_FLAG : ${IOS_SIMULATOR_FLAG}")

if (NOT DEFINED  GLOBAL_EXPORT_FLAG)
    set(GLOBAL_EXPORT_FLAG 1)
endif()
message(STATUS "GLOBAL_EXPORT_FLAG : ${GLOBAL_EXPORT_FLAG}")

set(EXPORT_MAP export.map)
if (GLOBAL_EXPORT_FLAG MATCHES 0)
    if (OHOS_FLAG MATCHES 1)
        set(EXPORT_MAP ohos_local_export.map)
    elseif (ANDROID_FLAG MATCHES 3) # arm
        set(EXPORT_MAP arm_local_export.map)
    else()
        set(EXPORT_MAP local_export.map)
    endif()
endif ()

# If flag is not defined, enable it on linux/ohos by default.
# If other sanitizer is enabled, disable gwpasan (see below).
if (NOT DEFINED GWPASAN_SUPPORT_FLAG)
    if (WINDOWS_FLAG MATCHES 0 AND MACOS_FLAG MATCHES 0 AND
        ANDROID_FLAG MATCHES 0 AND IOS_FLAG MATCHES 0 AND
        IOS_SIMULATOR_FLAG MATCHES 0)
        set(GWPASAN_SUPPORT_FLAG 1)
    else ()
        set(GWPASAN_SUPPORT_FLAG 0)
    endif ()
else()
    if (GWPASAN_SUPPORT_FLAG AND (WINDOWS_FLAG MATCHES 1 OR MACOS_FLAG MATCHES 1 OR
        IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2))
        message(WARNING "Runtime gwpasan support is only available on linux and ohos, gwpasan will be disabled")
        set(GWPASAN_SUPPORT_FLAG 0)
    endif ()
endif()

set(ASAN_SUPPORT_FLAG 0)
set(TSAN_SUPPORT_FLAG 0)
set(HWASAN_SUPPORT_FLAG 0)
set(SANITIZER_SUPPORT_FLAG 0)
if ("${SANITIZER_SUPPORT}" STREQUAL "asan")
    if (WINDOWS_FLAG MATCHES 0 AND ASAN_FLAG MATCHES 0 AND HWASAN_FLAG MATCHES 0)
        set(ASAN_SUPPORT_FLAG 1)
        set(SANITIZER_SUPPORT_FLAG 1)
        set(GWPASAN_SUPPORT_FLAG 0)
    else ()
        message(FATAL_ERROR "Runtime asan support is not available on windows or ASAN_FLAG/HWASAN_FLAG is on")
    endif ()
elseif ("${SANITIZER_SUPPORT}" STREQUAL "tsan")
    if (OHOS_FLAG MATCHES 0 AND ASAN_FLAG MATCHES 0 AND HWASAN_FLAG MATCHES 0)
        set(TSAN_SUPPORT_FLAG 1)
        set(SANITIZER_SUPPORT_FLAG 1)
        set(GWPASAN_SUPPORT_FLAG 0)
    else ()
        message(FATAL_ERROR "Runtime tsan support is not available on ohos or ASAN_FLAG/HWASAN_FLAG is on")
    endif ()
elseif ("${SANITIZER_SUPPORT}" STREQUAL "hwasan")
    if (WINDOWS_FLAG MATCHES 0 AND ASAN_FLAG MATCHES 0 AND HWASAN_FLAG MATCHES 0)
        set(HWASAN_SUPPORT_FLAG 1)
        set(SANITIZER_SUPPORT_FLAG 1)
        set(GWPASAN_SUPPORT_FLAG 0)
    else ()
        message(FATAL_ERROR "Runtime hwasan support is not available on windows or ASAN_FLAG/HWASAN_FLAG is on")
    endif ()
endif()
message(STATUS "ASAN_SUPPORT_FLAG : ${ASAN_SUPPORT_FLAG}")
message(STATUS "TSAN_SUPPORT_FLAG : ${TSAN_SUPPORT_FLAG}")
message(STATUS "HWASAN_SUPPORT_FLAG : ${HWASAN_SUPPORT_FLAG}")
message(STATUS "GWPASAN_SUPPORT_FLAG : ${GWPASAN_SUPPORT_FLAG}")
message(STATUS "SANITIZER_SUPPORT_FLAG : ${SANITIZER_SUPPORT_FLAG}")

string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" cmake_host_system_name)
string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" cmake_host_system_processor)
message(STATUS "CMAKE_HOST_SYSTEM_PROCESSOR : ${CMAKE_HOST_SYSTEM_PROCESSOR}")
message(STATUS "cmake_host_system_processor : ${cmake_host_system_processor}")
if("${cmake_host_system_processor}" STREQUAL "arm64")
    if (IOS_SIMULATOR_FLAG MATCHES 2)
        set(cmake_host_system_processor x86_64)
        set(CMAKE_OSX_ARCHITECTURES "x86_64" CACHE STRING "" FORCE)
    else()
        set(cmake_host_system_processor aarch64)
    endif()
endif()
if("${cmake_host_system_processor}" STREQUAL "amd64")
    set(cmake_host_system_processor x86_64)
endif()

if (OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
    set(CMAKE_C_COMPILER "${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/clang")
    set(CMAKE_ASM_COMPILER "${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/clang")
    set(CMAKE_CXX_COMPILER "${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/clang++")
    set(CMAKE_RANLIB "${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/llvm-ranlib")
    set(CMAKE_AR_PATH "${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/llvm-ar")
    message("set c/cxx ${OHOS_ROOT}/prebuilts/clang/ohos/${cmake_host_system_name}-${cmake_host_system_processor}/llvm/bin/clang/clang++")
    add_definitions(-D__OHOS__)
elseif (ANDROID_FLAG IN_LIST ANDROID_FLAG_LIST)
    set(CMAKE_C_COMPILER "${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/${ANDROID_ARCH}-${ANDROID_OS}-${ANDROID_TARGET_API}-clang")
    set(CMAKE_ASM_COMPILER "${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/${ANDROID_ARCH}-${ANDROID_OS}-${ANDROID_TARGET_API}-clang")
    set(CMAKE_CXX_COMPILER "${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/${ANDROID_ARCH}-${ANDROID_OS}-${ANDROID_TARGET_API}-clang++")
    set(CMAKE_RANLIB "${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/llvm-ranlib")
    set(CMAKE_AR_PATH "${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/llvm-ar")
    message("set c/cxx ${ANDROID_ROOT}/llvm/prebuilt/${cmake_host_system_name}-x86_64/bin/${ANDROID_ARCH}-${ANDROID_OS}-${ANDROID_TARGET_API}-clang++")
    if(ANDROID_FLAG MATCHES 1)
        set(CMAKE_SYSTEM_PROCESSOR "aarch64")
    elseif(ANDROID_FLAG MATCHES 2)
        set(CMAKE_SYSTEM_PROCESSOR "x86_64")
    elseif(ANDROID_FLAG MATCHES 3)
        set(CMAKE_SYSTEM_PROCESSOR "arm")
    endif()
    add_definitions(-D__ANDROID__)
    # add_definition for future
elseif (EULER_FLAG MATCHES 1)
    add_definitions(-D__EULER__)
elseif (WINDOWS_FLAG MATCHES 1)
    message("Building runtime in Windows.")
    if (CMAKE_HOST_SYSTEM_NAME MATCHES "Windows")
        # The compiler path needs to be added in the system PATH.
        set(CMAKE_C_COMPILER "clang.exe")
        set(CMAKE_ASM_COMPILER "clang.exe")
        set(CMAKE_CXX_COMPILER "clang++.exe")
    elseif (CMAKE_HOST_SYSTEM_NAME MATCHES "Linux")
        set(CMAKE_C_COMPILER "clang")
        set(CMAKE_ASM_COMPILER "clang")
        set(CMAKE_CXX_COMPILER "clang++")
    else ()
        message("Only the Windows and Linux platforms are supported.")
    endif ()
elseif (MACOS_FLAG MATCHES 1)
    set(CMAKE_C_COMPILER "clang")
    set(CMAKE_ASM_COMPILER "clang")
    set(CMAKE_CXX_COMPILER "clang++")
elseif (IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    set(CMAKE_C_COMPILER "clang")
    set(CMAKE_ASM_COMPILER "clang")
    set(CMAKE_CXX_COMPILER "clang++")
    add_definitions(-D__IOS__)
    add_definitions(-D__ENVIRONMENT_OS_VERSION_MIN_REQUIRED__=110000)
else()
    message(STATUS "HOST_SYSTEM_NAME is not set. Use pre-installed clang.")
    message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
endif()

if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2 OR
    CMAKE_HOST_SYSTEM_NAME MATCHES "Darwin")
    if (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "arm64")
        message("set CMAKE_HOST_SYSTEM_PROCESSOR aarch64 on macos/ios")
        set(CMAKE_HOST_SYSTEM_PROCESSOR "aarch64" CACHE FILEPATH "" FORCE)
    else()
        message("set CMAKE_HOST_SYSTEM_PROCESSOR x86_64 on macos/ios")
        set(CMAKE_HOST_SYSTEM_PROCESSOR "x86_64" CACHE FILEPATH "" FORCE)
    endif()
endif()

set(CMAKE_SYSTEM_PROCESSOR "${CMAKE_HOST_SYSTEM_PROCESSOR}" CACHE FILEPATH "" FORCE)
if (IOS_SIMULATOR_FLAG MATCHES 2)
    set(CMAKE_SYSTEM_PROCESSOR "x86_64" CACHE FILEPATH "" FORCE)
endif()

# Cross compile
if (OHOS_FLAG MATCHES 1 OR ANDROID_FLAG MATCHES 1)
    message("set CMAKE_SYSTEM_PROCESSOR aarch64")
    set(CMAKE_SYSTEM_PROCESSOR "aarch64" CACHE FILEPATH "" FORCE)
    set(OHOS_SDK_OUT_PATH "sdk")
    set(OHOS_COMPILE_OPTION "-flto -fsanitize=cfi -fno-sanitize=cfi-nvcall,cfi-icall -mbranch-protection=pac-ret+b-key")
endif ()
if (ANDROID_FLAG MATCHES 2)
    message("set CMAKE_SYSTEM_PROCESSOR x86_64")
    set(CMAKE_SYSTEM_PROCESSOR "x86_64" CACHE FILEPATH "" FORCE)
endif ()
if (OHOS_FLAG MATCHES 2)
    message("set CMAKE_SYSTEM_PROCESSOR x86_64")
    set(CMAKE_SYSTEM_PROCESSOR "x86_64" CACHE FILEPATH "" FORCE)
    set(OHOS_SDK_OUT_PATH "sdk")
    set(OHOS_COMPILE_OPTION "-flto -fsanitize=cfi -fno-sanitize=cfi-nvcall,cfi-icall")
endif ()
if (OHOS_FLAG MATCHES 3)
    message("set CMAKE_SYSTEM_PROCESSOR arm")
    set(CMAKE_SYSTEM_PROCESSOR "arm" CACHE FILEPATH "" FORCE)
    set(OHOS_SDK_OUT_PATH "sdk")
    set(OHOS_COMPILE_OPTION "-mfpu=neon -mfloat-abi=softfp -march=armv7-a")
endif()
if (ANDROID_FLAG MATCHES 3)
    message("set CMAKE_SYSTEM_PROCESSOR arm")
    set(CMAKE_SYSTEM_PROCESSOR "arm" CACHE FILEPATH "" FORCE)
    set(ANDROID_COMPILE_OPTION "-mfpu=neon -mfloat-abi=softfp -march=armv7-a")
endif()

# Detect operating system and host processor
message(STATUS "System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Host processor:${CMAKE_HOST_SYSTEM_PROCESSOR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_SYSTEM_PROCESSOR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${CMAKE_SYSTEM_PROCESSOR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_SYSTEM_PROCESSOR})

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "No build type selected, default to Release")
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type (default Release)" FORCE)
endif ()

string(TOUPPER "${CMAKE_BUILD_TYPE}" uppercase_CMAKE_BUILD_TYPE)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}_${CMAKE_BUILD_TYPE})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}_${CMAKE_BUILD_TYPE})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}_${CMAKE_BUILD_TYPE})
message(STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
message(STATUS "CMAKE_ARCHIVE_OUTPUT_DIRECTORY: ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
message(STATUS "CMAKE_RUNTIME_OUTPUT_DIRECTORY: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")

if (OHOS_FLAG IN_LIST OHOS_FLAG_LIST)
    set(OHOS_INCLUDE
        "-I${CMAKE_CURRENT_SOURCE_DIR}/third_party/third_party_bounds_checking_function/include"
    )

    set(CMAKE_INIT_FLAGS "-fPIC -Wdeprecated-copy -fno-strict-aliasing --param=ssp-buffer-size=4 -Wno-builtin-macro-redefined \
        -D__DATE__= -D__TIME__= -D__TIMESTAMP__= -funwind-tables -fcolor-diagnostics -fmerge-all-constants \
        -Xclang -mllvm -Xclang -instcombine-lower-dbg-declare=0 -no-canonical-prefixes \
        -fno-short-enums --target=${CMAKE_SYSTEM_PROCESSOR}-linux-ohos -Wthread-safety \
        -Wno-missing-field-initializers -Wno-error=deprecated-copy -Wno-unneeded-internal-declaration \
        -Wno-error=c99-designator -Wno-error=anon-enum-enum-conversion -Wno-error=implicit-fallthrough \
        -Wno-error=sizeof-array-div -Wno-error=reorder-init-list -Wno-error=range-loop-construct \
        -Wno-error=implicit-int-float-conversion -Wno-error=inconsistent-dllimport \
        -Wno-error=unknown-warning-option -Wno-error=abstract-final-class \
        -Wno-error=int-in-bool-context -Wno-error=xor-used-as-pow -Wno-error=return-stack-address \
        -Wno-error=dangling-gsl -Wno-undefined-var-template -Wno-nonportable-include-path -Wno-user-defined-warnings \
        -Wno-unused-lambda-capture -Wno-null-pointer-arithmetic -Wno-enum-compare-switch \
        -fdata-sections -g2 -ggnu-pubnames -fno-common -Wheader-hygiene ${OHOS_COMPILE_OPTION} \
        -Wstring-conversion -Wtautological-overlap-compare -Wl,--allow-shlib-undefined \
        -Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=default -fno-exceptions -fno-rtti \
        -ffunction-sections -Wall -fstack-protector-strong -fno-emulated-tls \
        -Wl,--hash-style=gnu \
        --sysroot=${OHOS_ROOT}/out/sdk/obj/third_party/musl/sysroot ${OHOS_INCLUDE}"
    )
elseif (WINDOWS_FLAG MATCHES 1)
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=hidden -fno-exceptions \
        -fno-rtti -Wall -fstack-protector-strong -Wno-inconsistent-dllimport -fno-strict-aliasing -fno-common")
elseif (ANDROID_FLAG MATCHES 1 OR ANDROID_FLAG MATCHES 2)
    message("android toolchain, clang version=${CLANG_VERSION_STRING}")
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer \
    -fvisibility=hidden -fno-exceptions -fno-rtti -ffunction-sections -Wall \
        -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common ${ANDROID_INCLUDE}"
    )
elseif (ANDROID_FLAG MATCHES 3)
    message("android toolchain, clang version=${CLANG_VERSION_STRING}")
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer \
    -fvisibility=hidden -fno-exceptions -fno-rtti -ffunction-sections -Wall \
        -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common ${ANDROID_COMPILE_OPTION} ${ANDROID_INCLUDE}"
    )
elseif (IOS_SIMULATOR_FLAG MATCHES 2)
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=default -fno-exceptions \
            -fno-rtti -Wall -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common -target x86_64-apple-ios11-simulator")
elseif (IOS_SIMULATOR_FLAG MATCHES 1)
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=default -fno-exceptions \
            -fno-rtti -Wall -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common -mcmodel=large -target arm64-apple-ios11-simulator")
elseif (IOS_FLAG MATCHES 1)
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=default -fno-exceptions \
        -fno-rtti -Wall -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common -mcmodel=large -target arm64-apple-ios11")
else ()
    set(CMAKE_INIT_FLAGS "-Wno-unused-command-line-argument -fno-omit-frame-pointer -fvisibility=default -fno-exceptions \
        -fno-rtti -ffunction-sections -Wall -fstack-protector-strong -fPIC -fno-strict-aliasing -fno-common")
endif ()
set(ASAN_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
set(HWASAN_FLAGS "-shared-libsan -fsanitize=hwaddress -fno-omit-frame-pointer -fno-emulated-tls -fno-lto -fno-sanitize=cfi -mllvm -hwasan-globals=0 -fno-whole-program-vtables")
set(CMAKE_INIT_FLAGS "${CMAKE_INIT_FLAGS} -pipe -Wdate-time -Wformat=2 -Wfloat-equal -Wextra \
    -Wconversion -Wcast-align \
    -Wvla -Wundef \
    -Wno-implicit-int-conversion -Wno-sign-conversion -Wno-implicit-int-float-conversion \
    -Wno-shorten-64-to-32 -Wswitch-default -Wunused -Wcast-qual -Wno-unused-parameter \
    -fno-common")

if (NOT CMAKE_AR_PATH)
    # The command "which llvm-ar" to obtain ar path
    EXECUTE_PROCESS(COMMAND which llvm-ar OUTPUT_VARIABLE AR_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
    if (NOT AR_PATH)
        EXECUTE_PROCESS(COMMAND which ar OUTPUT_VARIABLE AR_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    set(CMAKE_AR ${AR_PATH} CACHE FILEPATH "" FORCE)
else ()
    set(CMAKE_AR ${CMAKE_AR_PATH} CACHE FILEPATH "" FORCE)
endif ()
message(STATUS "CMAKE_AR : ${CMAKE_AR}")

# Set C flags
set(CMAKE_C_FLAGS "${CMAKE_INIT_FLAGS} ${CMAKE_C_FLAGS} -std=c11 -Wstrict-prototypes")
set(CMAKE_C_FLAGS_DEBUG "-O0 -gdwarf-4 -DMRT_DEBUG=1")
if (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    set(CMAKE_C_FLAGS_RELEASE "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")
else ()
    set(CMAKE_C_FLAGS_RELEASE "-O2 -D_FORTIFY_SOURCE=2 -gdwarf-4")
endif()
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_MINSIZERELWITHDEBINFO "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")

# Set CXX flags
if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2 OR
    IOS_SIMULATOR_FLAG MATCHES 1)
    set(CMAKE_CXX_FLAGS "${CMAKE_INIT_FLAGS} ${CMAKE_CXX_FLAGS} -std=c++14 -Woverloaded-virtual \
        -Wnon-virtual-dtor -Wdelete-non-virtual-dtor")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_INIT_FLAGS} ${CMAKE_CXX_FLAGS} -std=gnu++14 -Woverloaded-virtual \
        -Wnon-virtual-dtor -Wdelete-non-virtual-dtor")
endif()

set(CMAKE_CXX_FLAGS_DEBUG "-O0 -gdwarf-4 -DMRT_DEBUG=1")
if (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    set(CMAKE_CXX_FLAGS_RELEASE "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")
else ()
    set(CMAKE_CXX_FLAGS_RELEASE "-O2 -D_FORTIFY_SOURCE=2 -gdwarf-4")
endif()
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_MINSIZERELWITHDEBINFO "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")

if (MACOS_FLAG MATCHES 1 OR IOS_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    set(CMAKE_ASM_FLAGS "${CMAKE_INIT_FLAGS} ${CMAKE_ASM_FLAGS} -std=c++14")
else()
    set(CMAKE_ASM_FLAGS "${CMAKE_INIT_FLAGS} ${CMAKE_ASM_FLAGS} -std=gnu++14")
endif()

set(CMAKE_ASM_FLAGS_DEBUG "-O0 -gdwarf-4 -DMRT_DEBUG=1")
if (CMAKE_BUILD_TYPE MATCHES "MinSizeRel")
    set(CMAKE_ASM_FLAGS_RELEASE "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")
else ()
    set(CMAKE_ASM_FLAGS_RELEASE "-O2 -D_FORTIFY_SOURCE=2 -gdwarf-4")
endif()
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "${CMAKE_ASM_FLAGS_RELEASE}")
set(CMAKE_ASM_FLAGS_MINSIZERELWITHDEBINFO "-Os -D_FORTIFY_SOURCE=2 -gdwarf-4")

# Set Asan flags
if (ASAN_FLAG MATCHES 1)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${ASAN_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ASAN_FLAGS}")
endif ()

if (HWASAN_FLAG MATCHES 1)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${HWASAN_FLAGS}")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${HWASAN_FLAGS}")
endif ()

# Limit the size of a single frame.
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wframe-larger-than=10240")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wframe-larger-than=10240")


# Set cjthread path.
set(OUTPUT_TEMP_PATH ${CMAKE_CURRENT_SOURCE_DIR}/output/temp CACHE FILEPATH "" FORCE)
message(STATUS "OUTPUT_TEMP_PATH : ${OUTPUT_TEMP_PATH}")
set(DOPRA_INCLUDE ${OUTPUT_TEMP_PATH}/include)
set(DOPRA_LIBS ${OUTPUT_TEMP_PATH}/lib)

# Provide secure functions.
set(BOUNDSCHECK ${CMAKE_SOURCE_DIR}/third_party/third_party_bounds_checking_function)
if(NOT EXISTS ${BOUNDSCHECK})
    set(REPOSITORY_PATH https://gitcode.com/openharmony/third_party_bounds_checking_function)
    message(STATUS "Set boundscheck REPOSITORY_PATH: ${REPOSITORY_PATH}")
    execute_process(
        COMMAND git clone --branch OpenHarmony-v6.0-Release ${REPOSITORY_PATH} ${BOUNDSCHECK}
    )
endif()
file(COPY build/cmake/CMakeLists.txt DESTINATION ${BOUNDSCHECK}/)
set(BOUNDSCHECK_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/third_party/third_party_bounds_checking_function CACHE FILEPATH "" FORCE)
set(BOUNDSCHECK_INCLUDE ${BOUNDSCHECK_ROOT}/include)
if (OHOS_FLAG MATCHES 1 OR WINDOWS_FLAG MATCHES 1)
    set(OHOS_LIB ${OHOS_ROOT}/prebuilts/ohos-sdk/linux/11/native/sysroot/usr/lib/aarch64-linux-ohos)
elseif (OHOS_FLAG MATCHES 2)
    set(OHOS_LIB ${OHOS_ROOT}/prebuilts/ohos-sdk/linux/11/native/sysroot/usr/lib/x86_64-linux-ohos)
elseif (OHOS_FLAG MATCHES 3)
    set(OHOS_LIB ${OHOS_ROOT}/prebuilts/ohos-sdk/linux/11/native/sysroot/usr/lib/arm-linux-ohos)
endif ()
include_directories(${BOUNDSCHECK_INCLUDE})

# Set coverage compilation flags.
set(CMAKE_COV_FLAGS "-fprofile-arcs -ftest-coverage -O0 -fno-inline")

# Set compilation option of each module.
option(BUILD_CJTHREAD "Build cjthread module" ON)
option(BUILD_RUNTIME   "Build runtime module"   ON)
option(BUILD_DEMANGLE  "Build demangle module"  OFF)

set(TARGET_ARCH "linux_${CMAKE_HOST_SYSTEM_PROCESSOR}_cjnative")
if (OHOS_FLAG MATCHES 1)
    set(TARGET_ARCH "linux_ohos_aarch64_cjnative")
endif()
if (OHOS_FLAG MATCHES 2)
    set(TARGET_ARCH "linux_ohos_x86_64_cjnative")
endif()
if (OHOS_FLAG MATCHES 3)
    set(TARGET_ARCH "linux_ohos_arm_cjnative")    
endif()
if (MACOS_FLAG MATCHES 1)
    set(TARGET_ARCH "darwin_${CMAKE_HOST_SYSTEM_PROCESSOR}_cjnative")
endif()
if (WINDOWS_FLAG MATCHES 1)
    set(TARGET_ARCH "windows_x86_64_cjnative")
endif()
if (ANDROID_FLAG MATCHES 1)
    if (CMAKE_ANDROID_API MATCHES 26)
        set(TARGET_ARCH "linux_android_aarch64_cjnative")
    elseif (CMAKE_ANDROID_API MATCHES 31)
        set(TARGET_ARCH "linux_android31_aarch64_cjnative")
    else ()
        message(FATAL_ERROR "ANDROID_TARGET_API is not set, please check the target option.")
    endif()
endif()
if (ANDROID_FLAG MATCHES 2)
    if (CMAKE_ANDROID_API MATCHES 26)
        set(TARGET_ARCH "linux_android_x86_64_cjnative")
    elseif (CMAKE_ANDROID_API MATCHES 31)
        set(TARGET_ARCH "linux_android31_x86_64_cjnative")
    else ()
        message(FATAL_ERROR "ANDROID_TARGET_API is not set, please check the target option.")
    endif()
endif()
if (ANDROID_FLAG MATCHES 3)
    if (CMAKE_ANDROID_API MATCHES 23)
        set(TARGET_ARCH "linux_android23_arm_cjnative")
    else ()
        message(FATAL_ERROR "ANDROID_TARGET_API is not set, please check the target option.")
    endif ()
endif()
if (IOS_FLAG MATCHES 1)
    set(TARGET_ARCH "ios_${CMAKE_HOST_SYSTEM_PROCESSOR}_cjnative")
endif()
if (IOS_SIMULATOR_FLAG MATCHES 1 OR IOS_SIMULATOR_FLAG MATCHES 2)
    set(TARGET_ARCH "ios_simulator_${CMAKE_SYSTEM_PROCESSOR}_cjnative")
endif()
