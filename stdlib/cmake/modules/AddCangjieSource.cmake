# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

set(CANGJIE_NATIVE_CANGJIE_TOOLS_PATH ${CMAKE_BINARY_DIR}/bin)
set(CANGJIE_LIB_DIR "modules")
set(CANGJIE_EXECUTABLE_OUTPUT_DIR ${CMAKE_BINARY_DIR}/bin)
set(CJNATIVE_BACKEND "cjnative")

# Reusing this module must not enable experimental language features implicitly.
option(CANGJIE_ENABLE_LOCAL_MODE "Enable experimental local mode for Cangjie libraries" OFF)
# Value of the user-defined condition `local_mode_api` (see @When[local_mode_api == "on"]).
# Passed as --cfg local_mode_api=on|off regardless of CANGJIE_ENABLE_LOCAL_MODE, because the
# sources reference the condition in @When and cjc rejects undefined conditions.
option(CANGJIE_ENABLE_LOCAL_MODE_API "Compile declarations guarded by @When[local_mode_api == \"on\"]" OFF)
# Compiling the local-mode APIs requires the parser to accept local-mode syntax.
if(CANGJIE_ENABLE_LOCAL_MODE_API AND NOT CANGJIE_ENABLE_LOCAL_MODE)
    message(FATAL_ERROR "CANGJIE_ENABLE_LOCAL_MODE_API=ON requires CANGJIE_ENABLE_LOCAL_MODE=ON")
endif()
# The experimental std.interop.arkts package follows the same opt-in pattern as the
# local-mode APIs: only a compatible compiler accepts its ArkTS interop declarations,
# so the package target is added to the build only when this is ON, and the declarations
# themselves are additionally guarded by @When[arkts_interop == "on"]. The condition is
# always forwarded to cjc: an explicit value from CANGJIE_BUILD_ARGS is respected and not
# repeated, otherwise this option selects the injected `on` or `off` default. Reusing
# this module keeps the OFF default; the full stdlib project and build.py opt in
# explicitly.
option(CANGJIE_ENABLE_ARKTS_INTEROP "Compile the experimental std.interop.arkts package" OFF)
# Whether CANGJIE_BUILD_ARGS carries the std.interop.arkts condition as a whole
# argument. build.py turns every --build-args value into one list element and the
# module forwards each element as is, so one element may itself hold a command line
# (`--cfg arkts_interop=on`, `--cfg=arkts_interop=on`, or a longer run). A whole
# argument match keeps values such as `arkts_interop=onn` or a longer word ending in
# `arkts_interop=on` from counting.
function(cangjie_build_args_has_arkts_interop OUT_VAR)
    set(has_interop OFF)
    foreach(build_arg IN LISTS CANGJIE_BUILD_ARGS)
        separate_arguments(build_tokens NATIVE_COMMAND "${build_arg}")
        set(previous_token "")
        foreach(token IN LISTS build_tokens)
            if(token STREQUAL "--cfg=arkts_interop=on" OR
                (previous_token STREQUAL "--cfg" AND token STREQUAL "arkts_interop=on"))
                set(has_interop ON)
                break()
            endif()
            set(previous_token "${token}")
        endforeach()
        if(has_interop)
            break()
        endif()
    endforeach()
    set(${OUT_VAR} ${has_interop} PARENT_SCOPE)
endfunction()

# Whether CANGJIE_BUILD_ARGS explicitly sets the arkts_interop key with any value
# (`--cfg=arkts_interop=<value>` or `--cfg arkts_interop=<value>`). An explicit value is
# respected: the build must not inject a second copy of the key, because cjc rejects a
# repeated config key. The key itself is matched as a whole, so `arkts_interop_extra=on`
# does not count; any value (on, off, onn, ...) does.
function(cangjie_build_args_has_arkts_interop_key OUT_VAR)
    set(has_key OFF)
    foreach(build_arg IN LISTS CANGJIE_BUILD_ARGS)
        separate_arguments(build_tokens NATIVE_COMMAND "${build_arg}")
        set(previous_token "")
        foreach(token IN LISTS build_tokens)
            if(token MATCHES "^--cfg=arkts_interop=" OR
                (previous_token STREQUAL "--cfg" AND token MATCHES "^arkts_interop="))
                set(has_key ON)
                break()
            endif()
            set(previous_token "${token}")
        endforeach()
        if(has_key)
            break()
        endif()
    endforeach()
    set(${OUT_VAR} ${has_key} PARENT_SCOPE)
endfunction()

# The cjc arguments that supply the std.interop.arkts condition. An explicit value in
# CANGJIE_BUILD_ARGS is forwarded as is and nothing is injected, so the key appears
# exactly once. Only an absent key injects the default from CANGJIE_ENABLE_ARKTS_INTEROP,
# so cjc never sees an undefined condition.
function(cangjie_arkts_interop_cfg_flags OUT_VAR)
    cangjie_build_args_has_arkts_interop_key(has_key)
    set(flags)
    if(has_key)
        # Respect any explicit value (on, off, ...); a repeated key is rejected by cjc.
    elseif(CANGJIE_ENABLE_ARKTS_INTEROP)
        list(APPEND flags "--cfg" "arkts_interop=on")
    else()
        list(APPEND flags "--cfg" "arkts_interop=off")
    endif()
    set(${OUT_VAR} "${flags}" PARENT_SCOPE)
endfunction()

# Resolve a list of CMake target names / plain file paths to the actual output
# files those targets produce, so that add_custom_command(OUTPUT) DEPENDS can
# track them via file timestamps.
#
# Targets created by add_cangjie_library store their primary output path in the
# CJ_OUTPUT_FILE property.  Targets created by make_cangjie_lib store theirs in
# CJ_LIB_OUTPUT_FILE.  For any other CMake target the property is absent and we
# fall back to the raw name (which covers plain-file dependencies and native
# add_library / add_executable targets whose output CMake tracks automatically).
#
# Usage:
#   cj_resolve_depends(out_var dep1 dep2 ...)
function(cj_resolve_depends out_var)
    set(resolved)
    foreach(dep ${ARGN})
        if(TARGET ${dep})
            get_target_property(dep_file ${dep} CJ_OUTPUT_FILE)
            if(NOT dep_file)
                get_target_property(dep_file ${dep} CJ_LIB_OUTPUT_FILE)
            endif()
            if(dep_file)
                list(APPEND resolved ${dep_file})
            else()
                # Native target (add_library/add_executable) or custom target
                # without a tracked output – keep the name so CMake can at
                # least enforce ordering.
                list(APPEND resolved ${dep})
            endif()
        else()
            # Plain file path.
            list(APPEND resolved ${dep})
        endif()
    endforeach()
    set(${out_var} ${resolved} PARENT_SCOPE)
endfunction()

# Compile cangjie files into an object file(as a library or executable)
# Usage:
# add_cangjie_library(
#     target_name                 # The target name you want to generate
#     IS_STDLIB                   # This is a kind of stdlib
#     IS_PACKAGE                  # This is a package
#     IS_PRELUDE                  # This option will append a option to cjc: --no-prelude
#
#     [BACKEND]                   # Specify the backend, default is cjnative
#     [OUTPUT_NAME]               # Specify the output file name
#     [OUTPUT_DIR]                # Specify the lib name, and will install to the directory with this name
#     [PACKAGE_NAME]              # Package name of target cangjie source file
#     [MODULE_NAME]               # Module name of target cangjie source file and we will generate product to a directory with this name
#     [BACKEND_OPTS]              # Backend/frontend options passed to cjc. They are
#                                 # appended to the shared compile flags, so they reach
#                                 # both the normal and the LTO (bitcode) compile
#                                 # commands. Pass only options defined in this file or
#                                 # in a caller under the same review; do not feed them
#                                 # from unvalidated environment input, user arguments
#                                 # or other external variables. Each list element is
#                                 # forwarded as exactly one command argument; quote a
#                                 # value that contains spaces.
#     [WHEN_CONFIG_NAME_OPTS]     # This argument is other options passed to cjc
#     [WHEN_CONFIG_VALUES_OPTS]   # This argument is other options passed to cjc
#     [CONFIG_OPTS]               # This argument is other options passed to cjc
#     [SOURCE_DIR]                # Input source directory
#     [DISABLE_REFLECTION]        # Disable reflection for specific package
#
#     [SOURCES]                   # Input source files
#     [DEPENDS]                   # This target should be dependent on these targets
#     [NO_SUB_PKG]                # This package doesn't have sub-packages
#     )
function(add_cangjie_library target_name)
    set(options
        IS_PRELUDE
        IS_PACKAGE
        IS_STDLIB
        IS_CJNATIVE_BACKEND
        IS_JS_BACKEND
        DISABLE_REFLECTION
        NO_SUB_PKG
        NO_INSTALL)
    set(one_value_args
        OUTPUT_NAME
        OUTPUT_DIR
        PACKAGE_NAME
        MODULE_NAME
        WHEN_CONFIG_NAME_OPTS
        WHEN_CONFIG_VALUES_OPTS
        CONFIG_OPTS
        SOURCE_DIR)
    set(multi_value_args SOURCES BACKEND_OPTS DEPENDS FFI)
    cmake_parse_arguments(
        CANGJIELIB
        "${options}"
        "${one_value_args}"
        "${multi_value_args}"
        ${ARGN})

    # pre-process source files
    file(GLOB source_files CONFIGURE_DEPENDS ${CANGJIELIB_SOURCE_DIR}/*.cj)

    set(BACKEND)
    if(CANGJIELIB_IS_CJNATIVE_BACKEND)
        set(BACKEND "cjnative")
    endif()
    # setting output directory
    set(output_dir)
    set(output_bc_dir)
    if(CANGJIELIB_IS_STDLIB)
        if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
            set(output_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}/${CANGJIELIB_MODULE_NAME}")
            set(output_bc_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}_bc/${CANGJIELIB_MODULE_NAME}")
        else()
            set(output_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}")
            set(output_bc_dir "${CANGJIE_LIB_DIR}/${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND}_bc")
        endif()
        if(NOT ("${CANGJIELIB_OUTPUT_DIR}" STREQUAL ""))
            set(output_dir "${output_dir}/${CANGJIELIB_OUTPUT_DIR}")
            set(output_bc_dir "${output_bc_dir}/${CANGJIELIB_OUTPUT_DIR}")
        endif()
    endif()

    set(cangjie_compile_flags)
    if(CMAKE_BUILD_TYPE MATCHES Debug)
        list(APPEND cangjie_compile_flags "-g")
    elseif(CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
        list(APPEND cangjie_compile_flags "-g")
        if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
            # -g will enable aggressive-parallel-compile, so we need limit --apc to 1 to disable it forcibly.
            list(APPEND cangjie_compile_flags "--apc=1")
        endif()
    else()
       if(NOT CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
            list(APPEND cangjie_compile_flags "--trimpath")
            list(APPEND cangjie_compile_flags "${CMAKE_SOURCE_DIR}/libs/")
        endif()
    endif()

    # Conditional compilation filters local APIs after parsing their syntax.
    # OHOS therefore needs the parser flags too, even when @When omits those APIs.
    if(CANGJIE_ENABLE_LOCAL_MODE)
        list(APPEND cangjie_compile_flags "--experimental" "--enable-local-mode")
    endif()

    # The user-defined condition `local_mode_api` is independent of the parser flags above:
    # sources reference it in @When, and cjc rejects @When that references an undefined
    # condition. It is therefore always passed explicitly, even when
    # CANGJIE_ENABLE_LOCAL_MODE is OFF, which yields a plain-only build. cjc also rejects a
    # repeated key (e.g. another `--cfg local_mode_api=...` from CANGJIE_BUILD_ARGS), so the
    # value cannot be bypassed silently.
    if(CANGJIE_ENABLE_LOCAL_MODE_API)
        list(APPEND cangjie_compile_flags "--cfg" "local_mode_api=on")
    else()
        list(APPEND cangjie_compile_flags "--cfg" "local_mode_api=off")
    endif()

    # The user-defined condition `arkts_interop` mirrors the local-mode pattern: the
    # std.interop.arkts declarations are guarded by @When[arkts_interop == "on"], so the
    # value is always passed explicitly and cjc never sees an undefined condition. An
    # explicit value from CANGJIE_BUILD_ARGS (any value, including off) is forwarded as is
    # instead of being injected again, so the key appears exactly once on the command line;
    # only an absent key injects `on` or `off` from CANGJIE_ENABLE_ARKTS_INTEROP.
    cangjie_arkts_interop_cfg_flags(ARKTS_INTEROP_CFG_FLAGS)
    list(APPEND cangjie_compile_flags ${ARKTS_INTEROP_CFG_FLAGS})

    if (CANGJIELIB_IS_CJNATIVE_BACKEND)
        if (CANGJIE_ASAN_SUPPORT)
            list(APPEND cangjie_compile_flags "--sanitize=address")
        elseif (CANGJIE_TSAN_SUPPORT)
            list(APPEND cangjie_compile_flags "--sanitize=thread")
        elseif (CANGJIE_HWASAN_SUPPORT)
            list(APPEND cangjie_compile_flags "--sanitize=hwaddress")
        endif()
    endif()

    set(MKDIR_TEMP_FILES_CMD)
    # append backend-options. cmake_parse_arguments stores the BACKEND_OPTS
    # values in CANGJIELIB_BACKEND_OPTS; read the backend options from that
    # variable. Each element is appended as one quoted flag so a value that
    # contains spaces stays a single argument.
    list(LENGTH CANGJIELIB_BACKEND_OPTS options_length)
    if(NOT (options_length EQUAL 0))
        foreach(backend_opt IN LISTS CANGJIELIB_BACKEND_OPTS)
            list(APPEND cangjie_compile_flags "${backend_opt}")
        endforeach()
    endif()
    # append config options
    if(NOT ("${CANGJIELIB_CONFIG_OPTS}" STREQUAL ""))
        list(APPEND cangjie_compile_flags "--cfg=\"${CANGJIELIB_CONFIG_OPTS}\"")
    endif()

    if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
        set(output_full_name "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
    else()
        set(output_full_name "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_PACKAGE_NAME}")
    endif()
    
    set(output_full_name_prefix "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_PACKAGE_NAME}")
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        set(output_full_name "${output_full_name}.a") # set output path and output name
        if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
            set(output_lto_bc_full_name "${CMAKE_BINARY_DIR}/${output_bc_dir}/lib${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
        else()
            set(output_lto_bc_full_name "${CMAKE_BINARY_DIR}/${output_bc_dir}/lib${CANGJIELIB_PACKAGE_NAME}")
        endif()        
        
        set(output_lto_bc_full_name "${output_lto_bc_full_name}.bc") # set output path and output name
    endif()

    # build.py turns every --build-args value into one CMake list element, so a single element may still carry a
    # shell-level command line such as `-g --apc=1`. Under VERBATIM each option must be its own argv entry, so split
    # every element on shell rules; quotes inside the value keep a space-containing option as one argument.
    foreach(cangjie_build_arg IN LISTS CANGJIE_BUILD_ARGS)
        separate_arguments(cangjie_build_tokens NATIVE_COMMAND "${cangjie_build_arg}")
        list(APPEND cangjie_compile_flags ${cangjie_build_tokens})
    endforeach()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        list(APPEND cangjie_compile_flags "--output-type=staticlib")
    endif()
    if(TRIPLE STREQUAL "arm-linux-ohos" OR TRIPLE STREQUAL "arm-linux-android23")
        list(APPEND cangjie_compile_flags "--disable-reflection")
    endif()

    # set compiler path
    if(CMAKE_CROSSCOMPILING)
        set(CANGJIE_NATIVE_CANGJIE_TOOLS_PATH ${CMAKE_BINARY_DIR}/../build/bin)
    endif()
    # Do not use ${CMAKE_EXECUTABLE_SUFFIX} here, because its value is determined by the target platform, not the host.
    # Determine the suffix according to the host instead.
    set(cangjie_compiler_tool "cjc$<$<BOOL:${CMAKE_HOST_WIN32}>:.exe>")

    # create building task
    if(CANGJIELIB_IS_PRELUDE)
        set(no_prelude "--no-prelude") # not to import prelude libraries while compiling core library
    endif()
    # no-sub-pkg
    if(CANGJIELIB_NO_SUB_PKG)
        set(no_sub_pkg "--no-sub-pkg")
    endif()

    set(output_argument "--output") # output argument to specify the output file dir and name
    set(module_name_argument) # module name argument to specify which module the project belongs to
    set(CJNATIVE_PATH)
    if(CMAKE_CROSSCOMPILING)
        # When cross-compiling stdlib, use the installed llvm tools,
        # in case the backend is compiled from source in previous native-building step
        set(CJNATIVE_PATH $ENV{CANGJIE_HOME}/third_party/llvm/bin)
        # $ENV{CANGJIE_HOME}
    else()
        set(CJNATIVE_PATH $ENV{CANGJIE_HOME}/third_party/llvm/bin)
    endif()
    set(COMPILE_CMD)
    if(CANGJIELIB_IS_PACKAGE)
        set(COMPILE_CMD
            ${cangjie_compiler_tool}
            ${no_prelude}
            ${no_sub_pkg}
            ${cangjie_compile_flags}
            -p
            ${CANGJIELIB_SOURCE_DIR}
            ${module_name_argument})
    else()
        set(COMPILE_CMD
            ${cangjie_compiler_tool}
            ${no_prelude}
            ${cangjie_compile_flags}
            ${source_files}
            ${module_name_argument})
    endif()
    if(CMAKE_CROSSCOMPILING)
        set(COMPILE_CMD ${COMPILE_CMD} "--target=${TRIPLE}")
        if(NOT ("${CANGJIE_TARGET_TOOLCHAIN}" STREQUAL ""))
            set(COMPILE_CMD ${COMPILE_CMD} "-B${CANGJIE_TARGET_TOOLCHAIN}")
        endif()
    endif()

    set(COMPILE_BC_CMD
        ${COMPILE_CMD}
        --lto=full
        $<$<BOOL:${IOS}>:--experimental>
        ${output_argument}
        ${output_lto_bc_full_name})
    set(COMPILE_CMD ${COMPILE_CMD} ${output_argument} ${output_full_name})

    if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
        set(temp_files_dir "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}-temp-files")
    else()
        set(temp_files_dir "${CMAKE_BINARY_DIR}/${output_dir}/${CANGJIELIB_PACKAGE_NAME}-temp-files")
    endif()
    
    set(COMPILE_CMD ${COMPILE_CMD} "-j1")
    set(COMPILE_CMD ${COMPILE_CMD} "--save-temps=${temp_files_dir}")
    set(MKDIR_TEMP_FILES_CMD COMMAND ${CMAKE_COMMAND} -E make_directory ${temp_files_dir})

    if(CANGJIE_BUILD_STDLIB_WITH_COVERAGE)
        list(APPEND COMPILE_CMD "--coverage")
    endif()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        if(TRIPLE STREQUAL "arm-linux-ohos")
            list(APPEND COMPILE_CMD "$<IF:$<CONFIG:MinSizeRel>,-Os,-O0>")
            # .bc files is for LTO mode and LTO mode does not support -Os and -Oz.
            list(APPEND COMPILE_BC_CMD "-O0")
        else()
            list(APPEND COMPILE_CMD "$<IF:$<CONFIG:MinSizeRel>,-Os,-O2>")
            # .bc files is for LTO mode and LTO mode does not support -Os and -Oz.
            list(APPEND COMPILE_BC_CMD "-O2")
        endif()
    endif()

    set(ENV{LD_LIBRARY_PATH} $ENV{LD_LIBRARY_PATH}:${CMAKE_BINARY_DIR}/lib)
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND} output_cj_lib_dir)

    cj_resolve_depends(resolved_depends ${CANGJIELIB_DEPENDS})

    add_custom_command(
        OUTPUT ${output_full_name}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${output_dir}
        ${MKDIR_TEMP_FILES_CMD}
        COMMAND ${CMAKE_COMMAND} -E env "CANGJIE_PATH=${CMAKE_BINARY_DIR}/modules/${output_cj_lib_dir}"  "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib"
                ${COMPILE_CMD}
        DEPENDS ${resolved_depends} ${source_files} ${CANGJIELIB_SOURCE_DIR}
        COMMENT "Generating ${target_name}"
        # VERBATIM keeps the arguments of the compile command (including
        # BACKEND_OPTS values such as --import-path directories with spaces or
        # other special characters) intact for the invoked build tool.
        VERBATIM)

    add_custom_target(
        ${target_name} ALL
        DEPENDS ${output_full_name} ${CANGJIELIB_DEPENDS})

    set_target_properties(${target_name} PROPERTIES CJ_OUTPUT_FILE ${output_full_name})

    set(generate_lto_bc OFF)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND
       AND NOT WIN32
       AND (NOT DARWIN OR IOS)
       AND NOT CANGJIE_SANITIZER_SUPPORT_ENABLED)
        set(generate_lto_bc ON)
    endif()

    if(generate_lto_bc)
        add_custom_command(
            OUTPUT ${output_lto_bc_full_name}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/${output_bc_dir}
            COMMAND ${CMAKE_COMMAND} -E env "CANGJIE_PATH=${CMAKE_BINARY_DIR}/modules/${output_cj_lib_dir}" "LIBRARY_PATH=${CMAKE_BINARY_DIR}/lib"
                     ${COMPILE_BC_CMD}
            # ${target_name}_bc depends on ${target_name} so they will not run simultaneously. <target> and <target>_bc
            # compile the same package, which means they may write the same bc cache file. Running simultaneously
            # may cause IO error on windows in some cases.
            DEPENDS ${target_name}
            COMMENT "Generating ${target_name}_bc"
            VERBATIM)

        add_custom_target(
            ${target_name}_bc ALL
            DEPENDS ${output_lto_bc_full_name})
    endif()

    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        set(TARGET_AR ar)
        if(CMAKE_CROSSCOMPILING)
            if(IOS)
                set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/ar)
            elseif(CMAKE_C_COMPILER_ID STREQUAL "Clang")
                set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/llvm-ar)
            else()
                set(TARGET_AR ${CANGJIE_TARGET_TOOLCHAIN}/${TRIPLE}-ar)
            endif()
        endif()
        if(CMAKE_HOST_UNIX)
            set(MOVE_CMD mv)
        elseif(CMAKE_HOST_WIN32)
            set(MOVE_CMD move)
        endif()
        add_custom_command(
            TARGET ${target_name}
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E make_directory ${target_name} && cd ${target_name}
            COMMAND ${CMAKE_COMMAND} -E remove_directory tmp
            COMMAND ${CMAKE_COMMAND} -E make_directory tmp && cd tmp
            COMMAND ${TARGET_AR} x ${output_full_name}
            COMMAND ${MOVE_CMD} *.o ${output_full_name_prefix}.o
            COMMAND cd ..
            COMMAND ${CMAKE_COMMAND} -E remove_directory tmp
            BYPRODUCTS ${output_full_name_prefix}.o)
    endif()

    # install
    # sanitizer version only needs library files, cjo, bchir, pdba files are not needed
    if (CANGJIE_SANITIZER_SUPPORT_ENABLED)
        return()
    endif()
    if(NOT ("${CANGJIELIB_MODULE_NAME}" STREQUAL ""))
        set(file_name "${CANGJIELIB_MODULE_NAME}.${CANGJIELIB_PACKAGE_NAME}")
    else()
        set(file_name "${CANGJIELIB_PACKAGE_NAME}")
    endif()
    set(install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.cjo")
    
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    else()
        list(APPEND install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.bchir")
        list(APPEND install_files "${CMAKE_BINARY_DIR}/${output_dir}/${file_name}.pdba")
    endif()

    if(generate_lto_bc)
        list(APPEND install_files ${output_lto_bc_full_name})
    endif()
    if(CANGJIELIB_NO_INSTALL)
        return()
    endif()
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        install(FILES ${install_files} DESTINATION ${output_dir})
    endif()
endfunction()

set(CJNATIVE_BACKEND "cjnative")
# Install cangjie library FFI
function(install_cangjie_library_ffi lib_name)
    # set install dir
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_lib_dir)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        install(TARGETS ${lib_name} DESTINATION lib/${output_lib_dir}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
    endif()
endfunction()

function(install_cangjie_library_ffi_s lib_name)
    # set install dir
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_lib_dir)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        install(TARGETS ${lib_name} DESTINATION runtime/lib/${output_lib_dir}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
    endif()
endfunction()

function(install_ast_library_ffi lib_name)
    # set install dir
    string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_lib_dir)
    if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
        install(FILES ${lib_name} DESTINATION lib/${output_lib_dir}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
    endif()
endfunction()
