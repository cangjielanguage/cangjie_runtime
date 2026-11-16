# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../third_party/boundscheck-v1.1.16/include)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

set(BACKEND "cjnative")
if(CANGJIELIB_IS_CJNATIVE_BACKEND)
    set(BACKEND "cjnative")
endif()

if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
    set(CMAKE_C_COVERAGE_FLAGS "--coverage")
endif()

add_subdirectory(std)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/")
# The cj codes are used only when building libs(.so, .a, .cjo etc.),
# so it should be controlled by CANGJIE_BUILD_STDLIB.
if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    include(MakeCJNATIVEStdSharedLib)
    include(AddCJNATIVELibrary)
endif()

if(CANGJIE_CODEGEN_CJNATIVE_BACKEND AND NOT TRIPLE STREQUAL "arm-linux-ohos" AND NOT CANGJIE_SANITIZER_SUPPORT_ENABLED)
    set(CJNATIVE_BACKEND "cjnative")
    set(libname stdFFI)
    add_library(${libname} SHARED ${CANGJIE_CORE_FFI_SRC})
    separate_arguments(LINK_FLAGS_LIST NATIVE_COMMAND "${LINK_FLAGS}")
    if(CMAKE_BUILD_TYPE MATCHES Release)
        target_link_options(${libname} PRIVATE ${LINK_FLAGS_LIST} ${STRIP_FLAG} ${useld})
    else()
        target_link_options(${libname} PRIVATE ${LINK_FLAGS_LIST} ${useld})
    endif()
    target_link_directories(${libname} PRIVATE ${CMAKE_BINARY_DIR}/lib
        PRIVATE ${CMAKE_BINARY_DIR}/lib/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND}
        PRIVATE ${CMAKE_BINARY_DIR}/runtime/lib/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND})
    set(pcre2_lib "pcre2-8")
    if(OHOS)
        set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:libpcre2.z.so)
    elseif(DARWIN)
        set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l${pcre2_lib})
    elseif(MINGW)
        set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:lib${pcre2_lib}${CMAKE_SHARED_LIBRARY_SUFFIX}.a)
    else()
        set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:lib${pcre2_lib}${CMAKE_SHARED_LIBRARY_SUFFIX})
    endif()
    target_link_libraries(${libname} boundscheck)
    target_link_libraries(${libname} ${CORE_FFI_OBJECTS_LIST})
    target_link_libraries(${libname} cangjie-std-mathFFI-objs)
    target_link_libraries(${libname} cangjie-std-convertFFI-objs)
    target_link_libraries(${libname} cangjie-std-fsFFI-objs)
    target_link_libraries(${libname} cangjie-std-envFFI-objs)
    target_link_libraries(${libname} cangjie-std-posixFFI-objs)
    target_link_libraries(${libname} cangjie-std-processFFI-objs)
    target_link_libraries(${libname} cangjie-std-randomFFI-objs)
    target_link_libraries(${libname} cangjie-std-regexFFI-objs)
    target_link_libraries(${libname} cangjie-std-netFFI-objs)
    target_link_libraries(${libname} cangjie-std-timeFFI-objs)
    target_link_libraries(${libname} cangjie-std-unittestFFI-objs)
    target_link_libraries(${libname} cangjie-std-objectpoolFFI-objs)
    target_link_libraries(${libname} cangjie-std-runtimeFFI-objs)
    if(CMAKE_SYSTEM_NAME MATCHES "Linux" AND NOT OHOS)
        # Linux: use the regexFFI archive without the pcre2 objects (see the
        # pcre2 block below) so the pcre2 symbols in libstdFFI.so stay private.
        target_link_libraries(${libname} cangjie-std-regexFFIwithoutPCRE2)
    else()
        target_link_libraries(${libname} cangjie-std-regexFFI)
    endif()
    if(OHOS)
        # OHOS ROM ships pcre2 as libpcre2.z.so: keep the dynamic link recorded
        # by ${pcre2_lib} (DT_NEEDED libpcre2.z.so) so the device shares the
        # single ROM copy. Note that the OHOS toolchains set
        # CMAKE_SYSTEM_NAME=Linux, so an unconditional Linux branch here would
        # wrongly capture OHOS aarch64/x86_64 builds too.
        target_link_libraries(${libname} ${pcre2_lib})
    elseif(CMAKE_SYSTEM_NAME MATCHES "Linux")
        # stdFFI is installed under CANGJIE_HOME/lib/, which envsetup.sh does
        # not export via LD_LIBRARY_PATH. It used to rely on the shipped
        # libpcre2-8.so.0 in runtime/lib/<triple>/ being reachable through that
        # variable; that library now lives in the pcre2/ subdirectory
        # (issue 2932/3519), so link pcre2 statically here instead.
        # Link against cangjie-std-regexFFIwithoutPCRE2 (regex bindings without
        # the pcre2 objects baked in) and libpcre2-8.a directly: linking the
        # plain cangjie-std-regexFFI archive would resolve the pcre2 symbols
        # from its embedded copies, making --exclude-libs a no-op and leaving
        # pcre2_* exported from libstdFFI.so (double copy with the dynamic
        # library loaded by libcangjie-std-regex.so). With the without-PCRE2
        # archive plus --exclude-libs, the pcre2 symbols stay private to
        # libstdFFI.so. Other platforms keep the original dynamic linking:
        # their loaders have no LD_LIBRARY_PATH-style global search path, so
        # the dependency resolves within their own delivery layout.
        target_link_libraries(${libname}
            cangjie-std-regexFFIwithoutPCRE2
            ${CMAKE_BINARY_DIR}/third_party/pcre2/lib/libpcre2-8.a
            -Wl,--exclude-libs=libpcre2-8.a)
    else()
        target_link_libraries(${libname} ${pcre2_lib})
    endif()
    add_dependencies(${libname} modify_typetemplate_object)
    target_link_libraries(${libname} m)
    if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
        target_link_libraries(${libname} -L$ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir} -l:libclang_rt-profile.a)
    endif()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        if(DARWIN)
            target_link_libraries(${libname} "-Wl,-force_load,${RUNTIME_COMMON_LIB_DIR}/libcangjie-aio.a")
        else()
            target_link_libraries(${libname} "-Wl,--whole-archive" ${RUNTIME_COMMON_LIB_DIR}/libcangjie-aio.a "-Wl,--no-whole-archive" )
        endif()
        if(IOS AND IOS_PLATFORM MATCHES "SIMULATOR")
            string(TOLOWER "ios_simulator_${CMAKE_SYSTEM_PROCESSOR}_${CJNATIVE_BACKEND}" tmpdir)
        elseif(ANDROID AND "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv7-a")
            string(TOLOWER "linux_android23_arm_${CJNATIVE_BACKEND}" tmpdir)    
        else()
            string(TOLOWER "${target_folder_name}_${CMAKE_SYSTEM_PROCESSOR}_${CJNATIVE_BACKEND}" tmpdir)
        endif()
        target_link_directories(${libname} PRIVATE ${RUNTIME_COMMON_LIB_DIR}/../../runtime/lib/${tmpdir})
        set(runtime_lib cangjie-runtime)
        if(MINGW)
            set(runtime_lib -L${RUNTIME_COMMON_LIB_DIR} -l:libcangjie-runtime.dll.a)
        endif()
        target_link_libraries(${libname} ${runtime_lib})
    endif()
    if(MINGW)
        target_link_libraries(${libname} crypt32)
        target_link_libraries(${libname} ws2_32)
    endif()
    set(tmpdir "lib")
    install(TARGETS ${libname} DESTINATION lib)
endif()

