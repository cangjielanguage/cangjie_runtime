# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

macro(to_link_library_option lib_name)
    if(DARWIN)
        set(${lib_name} -l${${lib_name}})
    else()
        set(${lib_name} -l:lib${${lib_name}}${CMAKE_SHARED_LIBRARY_SUFFIX})
    endif()
endmacro()

function(make_cangjie_lib target_name)
    set(options IS_SHARED IS_STATIC ALLOW_UNDEFINED)
    set(oneValueArgs IOS_DEPLOYMENT_VERSION)
    set(multiValueArgs
        DEPENDS
        OBJECTS
        FORCE_LINK_ARCHIVES
        FLAGS
        CANGJIE_STD_LIB_LINK
        CANGJIE_STD_LIB_DEPENDS
        CANGJIE_STD_LIB_INDIRECT_DEPENDS)

    cmake_parse_arguments(
        CANGJIE_LIBRARY
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN})

    set(clang_compiler "${CMAKE_C_COMPILER}")
    if(OHOS)
        list(APPEND flags_to_compile -z max-page-size=${OHOS_MAX_PAGE_SIZE})
        list(APPEND flags_to_compile -z relro -z now -z noexecstack)
        # Standard system images pack relative relocations for all native components by default
        # (build/config/compiler/BUILD.gn) and musl ldso handles DT_RELR, so pack them here too.
        # Std shared libraries are linked by ld.lld directly here, bypassing the cjc driver, hence
        # the toolchain-level default does not reach this link and the flag is passed explicitly.
        list(APPEND flags_to_compile -z pack-relative-relocs)
        # Unfortunately, a bug in library `winpthread` our ld.lld depends causes deadlock occasionally
        # while linking. We disable multi-threading for now until we have a work-around.
        list(APPEND flags_to_compile --threads=1)
        set(clang_compiler "$ENV{CANGJIE_HOME}/third_party/llvm/bin/ld.lld")
        set(linker_ld_library_path "$ENV{CANGJIE_HOME}/third_party/llvm/lib")
    elseif(DARWIN)
        set(clang_compiler "$ENV{CANGJIE_HOME}/third_party/llvm/bin/ld64.lld")
        set(linker_ld_library_path "$ENV{CANGJIE_HOME}/third_party/llvm/lib")
    elseif(NOT MINGW)
        list(APPEND flags_to_compile "-Wl,-z,relro,-z,now,-z,noexecstack")
        if(ANDROID OR CANGJIE_HWASAN_SUPPORT)
            # We need use our lld since we have modification to make it link properly,
            # otherwise it will has false alignment and finally lead to a SEGV when load std-lib.
            list(APPEND flags_to_compile "-fuse-ld=$ENV{CANGJIE_HOME}/third_party/llvm/bin/ld.lld")
        endif()    
    endif()

    if(MINGW)
        list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--no-insert-timestamp")
        list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--export-all-symbols")
    endif()

    if(DARWIN)
        if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "aarch64")
            list(APPEND flags_to_compile -arch arm64)
        elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "x86_64")
            list(APPEND flags_to_compile -arch x86_64)
        endif()
        if(IOS)
            list(APPEND flags_to_compile -syslibroot "${CMAKE_IOS_SDK_ROOT}")
            # Default minimum iOS deployment target is 11. Libraries that link against C++
            # (libc++ is only available from iOS 12 onward), e.g. std-ast, override it via
            # IOS_DEPLOYMENT_VERSION.
            if(NOT CANGJIE_LIBRARY_IOS_DEPLOYMENT_VERSION)
                set(CANGJIE_LIBRARY_IOS_DEPLOYMENT_VERSION "11.0.0")
            endif()
            if(IOS_PLATFORM MATCHES "SIMULATOR")
                set(ios_sim_deployment_version "${CANGJIE_LIBRARY_IOS_DEPLOYMENT_VERSION}")
                if(ios_sim_deployment_version VERSION_LESS "13.0.0")
                    set(ios_sim_deployment_version "13.0.0")
                endif()
                list(APPEND flags_to_compile -platform_version ios-simulator ${ios_sim_deployment_version} 17.5)
            else()
                list(APPEND flags_to_compile -platform_version ios ${CANGJIE_LIBRARY_IOS_DEPLOYMENT_VERSION} 17.5)
            endif()
        else()
            list(APPEND flags_to_compile -syslibroot "${CANGJIE_MACOSX_SDK_PATH}")
            list(APPEND flags_to_compile -platform_version macos 12.0.0 "${CANGJIE_MACOSX_SDK_VERSION}")
        endif()
    endif()

    set(target_lib_full_name)
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_std_cj_lib_dir)
    set(output_cj_lib_dir ${output_cj_lib_dir}${SANITIZER_SUBPATH})
    set(output_std_cj_lib_dir ${output_std_cj_lib_dir}${SANITIZER_SUBPATH})
    if(CANGJIE_LIBRARY_IS_SHARED)
        if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
            if(NOT OHOS AND NOT DARWIN AND NOT MINGW)
                if(CANGJIE_DISCARD_EH_FRAME)
                    list(APPEND flags_to_compile "-Wl,-T" ${RUNTIME_COMMON_LIB_DIR}/discard_eh_frame.lds)
                endif()
                list(APPEND flags_to_compile "-Wl,-T,${RUNTIME_COMMON_LIB_DIR}/cjld.shared.lds")
            elseif(NOT DARWIN AND NOT MINGW)
                list(APPEND flags_to_compile "-T" ${RUNTIME_COMMON_LIB_DIR}/cjld.shared.lds)
            endif()
            if(DARWIN OR MINGW)
                list(APPEND flags_to_compile "${RUNTIME_COMMON_LIB_DIR}/section.o")
            endif()
            list(APPEND flags_to_compile "${RUNTIME_COMMON_LIB_DIR}/cjstart.o")

            if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
                list(APPEND flags_to_compile "$ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir}/libclang_rt-profile.a")
            endif()

            string(TOLOWER "${target_folder_name}_${CMAKE_SYSTEM_PROCESSOR}_${CJNATIVE_BACKEND}" tmpdir)
            if(ANDROID AND "${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv7-a")
                string(TOLOWER "linux_android23_arm_${CJNATIVE_BACKEND}" tmpdir)
            endif()
            list(APPEND flags_to_compile "-L${RUNTIME_COMMON_LIB_DIR}/../../runtime/lib/${tmpdir}${SANITIZER_SUBPATH}")
            set(runtime_link_option "cangjie-runtime")
            to_link_library_option(runtime_link_option)
            list(APPEND flags_to_compile "${runtime_link_option}")
        endif()
        # Hot reload relies on .gnu.hash section.
        if(MINGW)
            # MinGW ld doesn't support --hash-style
            list(APPEND flags_to_compile "-static")
            # Use -fstack-protector-all to let gcc help judge which libssp to link against. Don't use simply -lssp.
            list(APPEND flags_to_compile "-fstack-protector-all")
        elseif(NOT DARWIN AND NOT OHOS)
            # Linux / Android: both -> .hash + .gnu.hash 
            list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--hash-style=both")
        elseif(OHOS)
            # OHOS: gnu -> only .gnu.hash
            list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--hash-style=gnu")
        endif()
        foreach(libpath ${CANGJIE_TARGET_LIB})
            list(APPEND flags_to_compile "-L${libpath}")
        endforeach()
        if(MINGW)
            list(APPEND flags_to_compile "-L${CMAKE_BINARY_DIR}/bin")
        endif()
        list(APPEND flags_to_compile "-L${CMAKE_BINARY_DIR}/lib/${output_std_cj_lib_dir}")
        list(APPEND flags_to_compile "-L$ENV{CANGJIE_HOME}/runtime/lib/${output_cj_lib_dir}")
        list(APPEND flags_to_compile "-L$ENV{CANGJIE_HOME}/lib/${output_cj_lib_dir}")
        if(NOT DARWIN AND NOT MINGW)
            # In cross-compilation, we need -L (above one) for library searching and -rpath-link (below one) for
            # secondary dependencies (DSOs) searching.
            list(APPEND flags_to_compile
                "${LINKER_OPTION_PREFIX}-rpath-link=$ENV{CANGJIE_HOME}/runtime/lib/${output_cj_lib_dir}")
        endif()
        list(APPEND flags_to_compile "-L${CMAKE_BINARY_DIR}/lib")
        if(WIN32)
            # For Windows target, CMake will place dll in "bin" directory.
            list(APPEND flags_to_compile "-L${CMAKE_BINARY_DIR}/bin")
        endif()
        if(CMAKE_C_COMPILER_ID STREQUAL "Clang" OR CMAKE_C_COMPILER_ID STREQUAL "AppleClang")
            if(OHOS)
                if(TRIPLE STREQUAL "arm-linux-ohos")
                    list(APPEND flags_to_compile "-L${CANGJIE_TARGET_TOOLCHAIN}/../lib/clang/15.0.4/lib/arm-linux-ohos")
                endif()
                list(APPEND flags_to_compile "-lclang_rt.builtins")
                list(APPEND flags_to_compile "--exclude-libs=libclang_rt.builtins.a")
            elseif(IOS)
                if(IOS_PLATFORM MATCHES "SIMULATOR")
                    list(APPEND flags_to_compile "-lclang_rt.iossim")
                else()
                    list(APPEND flags_to_compile "-lclang_rt.ios")
                endif()
            elseif(DARWIN)
                # If native code (C or C++) uses compiler built-in features, the following library needs to be linked.
                # For example for `__builtin_cpu_init()` function, clang will generate references to `___cpu_model`
                # symbol, which is supplied by libclang_rt.osx.a.
                list(APPEND flags_to_compile "-lclang_rt.osx")
            elseif(${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
                list(APPEND flags_to_compile "-lclang_rt-builtins")
            endif()
        endif()
        if(MINGW)
            list(APPEND flags_to_compile "-lclang_rt-builtins")
        endif()
        set(boundscheck_link_option "boundscheck")
        to_link_library_option(boundscheck_link_option)
        # --as-needed is only supported by ELF linkers; MachO/PE keep the
        # unconditional link.
        if(DARWIN OR MINGW)
            list(APPEND flags_to_compile "${boundscheck_link_option}")
        else()
            list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--as-needed")
            list(APPEND flags_to_compile "${boundscheck_link_option}")
            list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--no-as-needed")
        endif()
        if(NOT DARWIN)
            if(TRIPLE STREQUAL "arm-linux-ohos")
                list(APPEND flags_to_compile "-L${CANGJIE_TARGET_SYSROOT}/usr/lib/arm-linux-ohos")
            elseif(TRIPLE STREQUAL "arm-linux-android23")
                set(NDK_PREBUILT_ARCH "linux-x86_64")
                if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Darwin")
                    set(NDK_PREBUILT_ARCH "darwin-x86_64")
                endif()
                list(APPEND flags_to_compile "-L${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/${NDK_PREBUILT_ARCH}/lib/clang/18/lib/linux/arm")
            endif()
            list(APPEND flags_to_compile "-lm")
        endif()
        if(OHOS)
            if(TRIPLE STREQUAL "arm-linux-ohos")
                list(APPEND flags_to_compile "-L${CANGJIE_TARGET_TOOLCHAIN}/../lib/arm-linux-ohos")
            endif()
            list(APPEND flags_to_compile "-lc")
            # -l:libunwind.a: use archive form so --exclude-libs can hide its symbols.
            list(APPEND flags_to_compile "-l:libunwind.a")
            list(APPEND flags_to_compile "--exclude-libs=libunwind.a")
            # Hide C++ runtime symbols so downstream .so's don't bind to ast.so via DT_NEEDED.
            # libc++.a is a linker script (INPUT(-lc++_static -lc++abi)); exclude the real archives.
            list(APPEND flags_to_compile "--exclude-libs=libc++.a,libc++_static.a,libc++abi.a")
        endif()
        if(NOT DARWIN AND NOT CANGJIE_LIBRARY_ALLOW_UNDEFINED AND NOT CANGJIE_ENABLE_HWASAN AND NOT CANGJIE_SANITIZER_SUPPORT_ENABLED)
            # Extra checkes when generating cangjie shared libraries. If symbols are used in Cangjie but not
            # defined in the shared library, an error will be reported. If any of such errors are reported,
            # we are likely missing some dependencies to link or functions to implement (e.g. using an
            # unimplemented native function in Cangjie).
            list(APPEND flags_to_compile "${LINKER_OPTION_PREFIX}--no-undefined")
        endif()
        # The undefined reference is not allow while linking MachO shared library by default. The following options
        # could suppress ld64 from reporting undefined reference errors.
        if(DARWIN AND CANGJIE_LIBRARY_ALLOW_UNDEFINED)
            list(APPEND flags_to_compile "-undefined" "suppress" "-flat_namespace")
        endif()
        # For bep, in debug mode, we cannot have the symbol of object's absolute path
        if(NOT DARWIN)
            if(CMAKE_BUILD_TYPE MATCHES Debug OR CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
                list(APPEND flags_to_compile "-g")
            else()
                list(APPEND flags_to_compile "-s")
            endif()
        endif()

        if(CANGJIE_LIBRARY_IS_SHARED)
            if(DARWIN)
                list(APPEND flags_to_compile "-dylib")
            else()
                list(APPEND flags_to_compile "-shared")
            endif()

            set(target_lib_full_name
                ${CMAKE_BINARY_DIR}/lib/${output_std_cj_lib_dir}/libcangjie-${target_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
        else()
            set(target_lib_full_name ${CMAKE_BINARY_DIR}/bin/${target_name}${CMAKE_EXECUTABLE_SUFFIX})
        endif()
        if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
            if(OHOS)
                list(APPEND flags_to_compile "-m")
                if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL aarch64)
                    list(APPEND flags_to_compile "aarch64linux")
                else()
                    list(APPEND flags_to_compile "elf_x86_64")
                endif()
            elseif(NOT DARWIN)
                list(APPEND flags_to_compile "--target=${TRIPLE}")
            endif()
        endif()
        if(CANGJIE_TARGET_TOOLCHAIN AND NOT OHOS AND NOT IOS)
            list(APPEND flags_to_compile "-B${CANGJIE_TARGET_TOOLCHAIN}")
        endif()
        if(OHOS)
            list(APPEND flags_to_compile "-L${CMAKE_SYSROOT}/usr/lib/${CMAKE_SYSTEM_PROCESSOR}-linux-ohos")
        endif()
        if(CMAKE_SYSROOT AND NOT IOS)
            list(APPEND flags_to_compile "--sysroot=${CMAKE_SYSROOT}")
        endif()
        if(DARWIN)
            list(APPEND flags_to_compile "-lSystem")
        endif()

        # All shared libraries of standard library are placed in the same location. Adding $ORIGIN into RPATH so
        # standard libraries can find each other.
        if(NOT CMAKE_SKIP_RPATH AND ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
            list(APPEND flags_to_compile ${LINKER_OPTION_PREFIX}--disable-new-dtags ${LINKER_OPTION_PREFIX}-rpath="\\$$ORIGIN")
        endif()
        if(DARWIN)
            list(APPEND flags_to_compile -install_name "@rpath/libcangjie-${target_name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
            list(APPEND flags_to_compile -rpath "@loader_path")
        endif()

        if(WIN32)
            list(APPEND set_env_path "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib/;${ENV_LIBRARY_PATH}")
        else()
            list(APPEND set_env_path "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib/:${ENV_LIBRARY_PATH}")
            list(APPEND set_env_path "LD_LIBRARY_PATH=${linker_ld_library_path}:${ENV_LD_LIBRARY_PATH}")
        endif()

        set(link_std_libraries_flag)
        if(ANDROID)
            list(APPEND link_std_libraries_flag "-Wl,-z,max-page-size=${ANDROID_MAX_PAGE_SIZE}")
        endif()
        foreach(library_name ${CANGJIE_LIBRARY_CANGJIE_STD_LIB_DEPENDS})
            set(lib_link_option "cangjie-${library_name}")
            to_link_library_option(lib_link_option)
            list(APPEND link_std_libraries_flag "${lib_link_option}")
        endforeach()

        foreach(library_name ${CANGJIE_LIBRARY_CANGJIE_STD_LIB_LINK})
            if(DARWIN)
                list(APPEND link_std_libraries_flag
                -L$ENV{CANGJIE_HOME}/runtime/lib/${output_cj_lib_dir} -lcangjie-${library_name})
            else()
                list(APPEND link_std_libraries_flag  -L $ENV{CANGJIE_HOME}/runtime/lib/${output_cj_lib_dir} -l:libcangjie-${library_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
            endif()

        endforeach()

        foreach(indirect_library_name ${CANGJIE_LIBRARY_CANGJIE_STD_LIB_INDIRECT_DEPENDS})
            if(DARWIN)
                list(APPEND link_std_libraries_flag
                    -lcangjie-${indirect_library_name})
            elseif(NOT MINGW)
                list(APPEND link_std_libraries_flag ${LINKER_OPTION_PREFIX}--as-needed)
                list(APPEND link_std_libraries_flag
                    -l:libcangjie-${indirect_library_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
                list(APPEND link_std_libraries_flag ${LINKER_OPTION_PREFIX}--no-as-needed)
            else()
                list(APPEND link_std_libraries_flag -l:libcangjie-${indirect_library_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
            endif()
        endforeach()

        set(force_link_archives_option)
        foreach(force_link_archive ${CANGJIE_LIBRARY_FORCE_LINK_ARCHIVES})
            set(archive_path "${force_link_archive}")
            if(TARGET ${force_link_archive})
                get_target_property(target_location ${force_link_archive} COMBINED_STATIC_LIB_LOC)
                if(NOT target_location)
                    set(archive_path $<TARGET_FILE:${force_link_archive}>)
                else()
                    set(archive_path "${target_location}")
                endif()
            endif()
            if(DARWIN)
                list(APPEND force_link_archives_option "-force_load")
                list(APPEND force_link_archives_option "${archive_path}")
            else()
                list(APPEND force_link_archives_option "${LINKER_OPTION_PREFIX}--whole-archive")
                list(APPEND force_link_archives_option "${archive_path}")
                list(APPEND force_link_archives_option "${LINKER_OPTION_PREFIX}--no-whole-archive")
            endif()
        endforeach()

        cj_resolve_depends(resolved_depends
            ${CANGJIE_LIBRARY_DEPENDS}
            ${CANGJIE_LIBRARY_CANGJIE_STD_LIB_DEPENDS}
            ${CANGJIE_LIBRARY_CANGJIE_STD_LIB_INDIRECT_DEPENDS})

        add_custom_command(
            OUTPUT ${target_lib_full_name}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/lib/${output_std_cj_lib_dir}
            COMMAND ${CMAKE_COMMAND} -E env ${set_env_path} ${clang_compiler} ${CANGJIE_LIBRARY_OBJECTS} ${force_link_archives_option}
                    ${CANGJIE_LIBRARY_FLAGS}  ${link_std_libraries_flag} ${flags_to_compile} -o ${target_lib_full_name}
            DEPENDS
                ${resolved_depends}
                ${CANGJIE_LIBRARY_OBJECTS}
                boundscheck
            COMMENT "Generating ${target_lib_full_name}")

        add_custom_target(
            ${target_name} ALL
            DEPENDS ${target_lib_full_name})

        set_target_properties(${target_name} PROPERTIES CJ_LIB_OUTPUT_FILE ${target_lib_full_name})
    else()
        message(FATAL_ERROR "only support SHARED or EXE for now")
    endif()

    if(CANGJIE_LIBRARY_IS_SHARED)
        install(FILES ${target_lib_full_name} DESTINATION runtime/lib/${output_cj_lib_dir})
        if(target_name STREQUAL "std-regex" AND NOT OHOS)
            # On OHOS, libpcre2.z.so is provided by the ROM; do not ship libpcre2-8.so.
            file(GLOB PCRE2_DYNAMIC_LIB
                ${CMAKE_BINARY_DIR}/third_party/pcre2/bin/libpcre2-8.dll
                ${CMAKE_BINARY_DIR}/third_party/pcre2/lib/libpcre2-8.so*
                ${CMAKE_BINARY_DIR}/third_party/pcre2/lib/libpcre2-8.*dylib
            )
            message("PCRE2_DYNAMIC_LIB: ${PCRE2_DYNAMIC_LIB}")
            install(FILES ${PCRE2_DYNAMIC_LIB} DESTINATION runtime/lib/${output_cj_lib_dir})
        endif()
    endif()
endfunction()
