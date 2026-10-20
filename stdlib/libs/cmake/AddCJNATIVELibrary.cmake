# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
#
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

include(AddAndCombineStaticLib)
include(ExtractArchive)

set(BACKEND_TYPE CJNATIVE)

##  make shared/static library
# if we support cross-compiling, we need to change here for target type
string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${BACKEND_TYPE} output_cj_object_dir)
string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX} output_triple_name)
set(CJNATIVE_BACKEND "cjnative")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
set(output_cj_object_dir ${CMAKE_BINARY_DIR}/modules/${output_cj_object_dir})
# file(MAKE_DIRECTORY ${output_cj_object_dir}/std)

# Hide the duplicated CJ_* FFI exports in env/process/console shared libraries.
# OHOS invokes ld.lld directly so the option must be passed without the -Wl,
# prefix (LINKER_OPTION_PREFIX is empty for the OHOS toolchains). Darwin uses
# -load_hidden below: its ld64.lld rejects --exclude-libs. MinGW keeps the
# archives' symbols exported: the llvm-mingw toolchain links through lld's
# MinGW driver, which does not implement --exclude-libs (GNU ld's PE port does,
# but the Windows CI toolchain is llvm-mingw), so hiding is skipped there.
set(EXCLUDE_ENV_FFI_OPTION)
set(EXCLUDE_PROCESS_FFI_OPTION)
if(NOT DARWIN AND NOT MINGW)
    set(EXCLUDE_ENV_FFI_OPTION ${LINKER_OPTION_PREFIX}--exclude-libs=libcangjie-std-envFFI.a)
    set(EXCLUDE_PROCESS_FFI_OPTION ${LINKER_OPTION_PREFIX}--exclude-libs=libcangjie-std-processFFI.a)
endif()
# Darwin's ld64.lld rejects --exclude-libs and exports whole-archive force-load
# members at default visibility. -load_hidden resolves the archive members as
# hidden instead, so duplicated CJ_* FFI symbols stay out of the exported
# symbol table the same way --exclude-libs does on ELF.
# -load_hidden takes a literal archive path: it does no -l-style -L search,
# so the target output locations are resolved via generator expressions.
# Same resolution as the FORCE_LINK_ARCHIVES path in MakeCJNATIVEStdSharedLib.cmake:
# COMBINED_STATIC_LIB_LOC first, $<TARGET_FILE> fallback, and fail at configure
# time if the target has neither, so a bare "-load_hidden" never reaches the linker.
if(TARGET cangjie-std-envFFI)
    get_target_property(_env_ffi_combined_loc cangjie-std-envFFI COMBINED_STATIC_LIB_LOC)
    if(NOT _env_ffi_combined_loc)
        # Combined archive not created (e.g. FFI objects only); fall back to the
        # target's output file, evaluated at build time.
        set(_env_ffi_combined_loc "$<TARGET_FILE:cangjie-std-envFFI>")
    endif()
else()
    message(FATAL_ERROR
        "cangjie-std-envFFI target not found; cannot build -load_hidden flags "
        "for env/process/console")
endif()
if(DARWIN)
    set(ENV_FFI_LINK_FLAG -load_hidden ${_env_ffi_combined_loc})
    set(PROCESS_FFI_LINK_FLAG -load_hidden $<TARGET_FILE:cangjie-std-processFFI>)
else()
    set(ENV_FFI_LINK_FLAG -lcangjie-std-envFFI)
    set(PROCESS_FFI_LINK_FLAG -lcangjie-std-processFFI)
endif()

make_cangjie_lib(
    std-core IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Core cangjie-std-coreFFI
    OBJECTS ${output_cj_object_dir}/std/core.o
    FORCE_LINK_ARCHIVES
        cangjie-std-coreFFI
    FLAGS
        ${MAKE_SO_STACK_PROTECTOR_OPTION})

add_library(cangjie-std-core STATIC ${CORE_FFI_OBJECTS_LIST} ${output_cj_object_dir}/std/core.o)
add_dependencies(cangjie-std-core modify_typetemplate_object)
set_target_properties(cangjie-std-core PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-core DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Std
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std.o)

add_library(cangjie-std STATIC ${output_cj_object_dir}/std.o)
set_target_properties(cangjie-std PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-binary IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Binary
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/binary.o)

add_library(cangjie-std-binary STATIC ${output_cj_object_dir}/std/binary.o)
set_target_properties(cangjie-std-binary PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-binary DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-sync IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Sync
    CANGJIE_STD_LIB_DEPENDS std-core std-time
    OBJECTS ${output_cj_object_dir}/std/sync.o)

    add_library(cangjie-std-sync STATIC ${output_cj_object_dir}/std/sync.o)
    set_target_properties(cangjie-std-sync PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-sync DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-overflow IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Overflow
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/overflow.o)

add_library(cangjie-std-overflow STATIC ${output_cj_object_dir}/std/overflow.o)
set_target_properties(cangjie-std-overflow PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-overflow DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-math IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Math cangjie-std-mathFFI
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/math.o
    FLAGS -lcangjie-std-mathFFI)

add_library(cangjie-std-math STATIC $<TARGET_OBJECTS:cangjie-std-mathFFI-objs>
                                    ${output_cj_object_dir}/std/math.o)
set_target_properties(cangjie-std-math PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-math DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-math.numeric IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}MathNumeric
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-math
        std-random
        std-convert
    OBJECTS ${output_cj_object_dir}/std/math.numeric.o)

add_library(cangjie-std-math.numeric STATIC ${output_cj_object_dir}/std/math.numeric.o)
set_target_properties(cangjie-std-math.numeric PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-math.numeric DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-collection IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Collection
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-math
    OBJECTS ${output_cj_object_dir}/std/collection.o)

add_library(cangjie-std-collection STATIC ${output_cj_object_dir}/std/collection.o)
set_target_properties(cangjie-std-collection PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-collection DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-objectpool IS_SHARED ${SANITIZER_COMPILE_OPTION}
    DEPENDS cangjie${BACKEND_TYPE}ObjectPool cangjie-std-objectpoolFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-sync
        std-collection.concurrent
    OBJECTS ${output_cj_object_dir}/std/objectpool.o
    FLAGS -lcangjie-std-objectpoolFFI)

add_library(cangjie-std-objectpool STATIC $<TARGET_OBJECTS:cangjie-std-objectpoolFFI-objs>
                                            ${output_cj_object_dir}/std/objectpool.o)
install(TARGETS cangjie-std-objectpool DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-collection.concurrent IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}ConcurrentCollection cangjie-std-collection.concurrentFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-sync
        std-collection
        std-time
    CANGJIE_STD_LIB_INDIRECT_DEPENDS
        std-math
    OBJECTS ${output_cj_object_dir}/std/collection.concurrent.o
    FLAGS -lcangjie-std-collection.concurrentFFI)

add_library(cangjie-std-collection.concurrent STATIC
    $<TARGET_OBJECTS:cangjie-std-collection.concurrentFFI-objs>
    ${output_cj_object_dir}/std/collection.concurrent.o)
set_target_properties(cangjie-std-collection.concurrent PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-collection.concurrent DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

if(NOT OHOS)
    make_cangjie_lib(
        std-concurrent IS_SHARED
        DEPENDS cangjie${BACKEND_TYPE}Concurrent
        CANGJIE_STD_LIB_DEPENDS
            std-core
            std-collection
            std-collection.concurrent
            std-sync
        OBJECTS ${output_cj_object_dir}/std/concurrent.o)

    add_library(cangjie-std-concurrent STATIC ${output_cj_object_dir}/std/concurrent.o)
    set_target_properties(cangjie-std-concurrent PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-concurrent DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
endif()

if(NOT DARWIN)
    make_cangjie_lib(
        std-reflect IS_SHARED
        DEPENDS cangjie${BACKEND_TYPE}Reflect
        CANGJIE_STD_LIB_DEPENDS
            std-core
            std-collection
            std-sync
            std-overflow
            std-time
            std-sort
            std-fs
        CANGJIE_STD_LIB_INDIRECT_DEPENDS
            std-math
            std-unicode
        OBJECTS ${output_cj_object_dir}/std/reflect.o)

    add_library(cangjie-std-reflect STATIC ${output_cj_object_dir}/std/reflect.o)
    set_target_properties(cangjie-std-reflect PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-reflect DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
endif()

make_cangjie_lib(
    std-interop IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Interop
    CANGJIE_STD_LIB_DEPENDS
        std-core
    OBJECTS ${output_cj_object_dir}/std/interop.o)

    add_library(cangjie-std-interop ${output_cj_object_dir}/std/interop.o)
    set_target_properties(cangjie-std-interop PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-interop DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-ref IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Ref
    CANGJIE_STD_LIB_DEPENDS
        std-core
    OBJECTS ${output_cj_object_dir}/std/ref.o)

    add_library(cangjie-std-ref ${output_cj_object_dir}/std/ref.o)
    set_target_properties(cangjie-std-ref PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-ref DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-sort IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Sort
    CANGJIE_STD_LIB_DEPENDS std-core std-math std-collection
    OBJECTS ${output_cj_object_dir}/std/sort.o)

add_library(cangjie-std-sort ${output_cj_object_dir}/std/sort.o)
set_target_properties(cangjie-std-sort PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-sort DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-io IS_SHARED
    DEPENDS
        cangjie${BACKEND_TYPE}Io
        std-core
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/io.o)

add_library(cangjie-std-io ${output_cj_object_dir}/std/io.o)
set_target_properties(cangjie-std-io PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-io DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-convert IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Convert cangjie-std-convertFFI
    CANGJIE_STD_LIB_DEPENDS std-core
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/convert.o
    FLAGS -lcangjie-std-convertFFI)

add_library(cangjie-std-convert STATIC $<TARGET_OBJECTS:cangjie-std-convertFFI-objs>
                                        ${output_cj_object_dir}/std/convert.o)
set_target_properties(cangjie-std-convert PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-convert DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-time IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Time cangjie-std-timeFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-convert
        std-math
        std-collection
        std-io
        std-binary
    CANGJIE_STD_LIB_INDIRECT_DEPENDS
        std-sort
    OBJECTS ${output_cj_object_dir}/std/time.o
    FLAGS -lcangjie-std-timeFFI)

add_library(cangjie-std-time STATIC $<TARGET_OBJECTS:cangjie-std-timeFFI-objs>
                                    ${output_cj_object_dir}/std/time.o)
set_target_properties(cangjie-std-time PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-time DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-fs IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Fs cangjie-std-fsFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-io
        std-time
        std-collection
    CANGJIE_STD_LIB_INDIRECT_DEPENDS
        std-math
        std-sort
    OBJECTS ${output_cj_object_dir}/std/fs.o
    FLAGS -lcangjie-std-fsFFI)

add_library(cangjie-std-fs STATIC $<TARGET_OBJECTS:cangjie-std-fsFFI-objs> ${output_cj_object_dir}/std/fs.o)
install(TARGETS cangjie-std-fs DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-console IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Console cangjie-std-envFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-io
        std-sync
        std-sort
    OBJECTS ${output_cj_object_dir}/std/console.o
    FLAGS ${ENV_FFI_LINK_FLAG} ${EXCLUDE_ENV_FFI_OPTION})

add_library(cangjie-std-console STATIC  $<TARGET_OBJECTS:cangjie-std-envFFI-objs> ${output_cj_object_dir}/std/console.o)
install(TARGETS cangjie-std-console DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-posix IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}POSIX cangjie-std-posixFFI
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/posix.o
    FLAGS
        -lcangjie-std-posixFFI)

add_library(
    cangjie-std-posix STATIC
    $<TARGET_OBJECTS:cangjie-std-posixFFI-objs>
    ${output_cj_object_dir}/std/posix.o)
install(TARGETS cangjie-std-posix DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-process IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}PROCESS cangjie-std-processFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-fs
        std-io
        std-time
        std-sort
        std-sync
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/process.o
    FLAGS
        ${PROCESS_FFI_LINK_FLAG} ${EXCLUDE_PROCESS_FFI_OPTION})

add_library(
    cangjie-std-process STATIC
    $<TARGET_OBJECTS:cangjie-std-processFFI-objs>
    ${output_cj_object_dir}/std/process.o)
install(TARGETS cangjie-std-process DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-env IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}ENV cangjie-std-envFFI cangjie-std-processFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-fs
        std-io
        std-sync
        std-sort
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/env.o
    FLAGS ${ENV_FFI_LINK_FLAG} ${PROCESS_FFI_LINK_FLAG} ${EXCLUDE_ENV_FFI_OPTION} ${EXCLUDE_PROCESS_FFI_OPTION})

    add_and_combine_static_lib(
        OUTPUT_NAME libcangjie-std-env.a
        TARGET cangjie-std-env
        LIBRARIES
            $<TARGET_OBJECTS:cangjie-std-envFFI-objs>
            ${output_cj_object_dir}/std/env.o
            $<TARGET_OBJECTS:cangjie-std-processFFI-objs>
        DEPENDS
            cangjie${BACKEND_TYPE}ENV
            cangjie-std-envFFI
            cangjie-std-processFFI)
    install(FILES ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/libcangjie-std-env.a
            DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

set(pcre2_lib "pcre2-8")
if(OHOS)
    # OHOS ROM ships pcre2 as libpcre2.z.so. Link against the locally
    # re-linked libpcre2.z.so (built by Pcre2.cmake) so that DT_NEEDED
    # records libpcre2.z.so and resolves against the ROM library at runtime.
    set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:libpcre2.z.so)
elseif(DARWIN)
    set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l${pcre2_lib})
elseif(MINGW)
    set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:lib${pcre2_lib}${CMAKE_SHARED_LIBRARY_SUFFIX}.a)
else()
    set(pcre2_lib -L${CMAKE_BINARY_DIR}/third_party/pcre2/lib -l:lib${pcre2_lib}${CMAKE_SHARED_LIBRARY_SUFFIX})
endif()
make_cangjie_lib(
    std-regex IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Regex cangjie-std-regexFFIwithoutPCRE2
    CANGJIE_STD_LIB_DEPENDS std-core std-collection std-sort std-sync
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/regex.o $<TARGET_OBJECTS:cangjie-std-regexFFIwithoutPCRE2-objs>
    FLAGS ${pcre2_lib})

get_target_property(REGEXFFI_OBJS cangjie-std-regexFFI SOURCES)
add_library(cangjie-std-regex STATIC ${REGEXFFI_OBJS} ${output_cj_object_dir}/std/regex.o)
install(TARGETS cangjie-std-regex DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-random IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Random cangjie-std-randomFFI
    CANGJIE_STD_LIB_DEPENDS std-core
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/random.o
    FLAGS -lcangjie-std-randomFFI)

add_library(cangjie-std-random STATIC $<TARGET_OBJECTS:cangjie-std-randomFFI-objs>
                                        ${output_cj_object_dir}/std/random.o)
set_target_properties(cangjie-std-random PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-random DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-argopt IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Argopt
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
    CANGJIE_STD_LIB_INDIRECT_DEPENDS
        std-sort
        std-math
    OBJECTS ${output_cj_object_dir}/std/argopt.o)

add_library(cangjie-std-argopt STATIC ${output_cj_object_dir}/std/argopt.o)
set_target_properties(cangjie-std-argopt PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-argopt DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})


make_cangjie_lib(
    std-unicode IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Unicode
    CANGJIE_STD_LIB_DEPENDS std-core std-collection
    OBJECTS ${output_cj_object_dir}/std/unicode.o)

add_library(cangjie-std-unicode STATIC ${output_cj_object_dir}/std/unicode.o)
set_target_properties(cangjie-std-unicode PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unicode DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-net IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Net cangjie-std-netFFI
    CANGJIE_STD_LIB_DEPENDS
    std-core
    std-convert
    std-binary
    std-overflow
    std-collection
    std-sort
    std-time
    std-io
    std-sync
    std-math
    OBJECTS ${output_cj_object_dir}/std/net.o
    FORCE_LINK_ARCHIVES
        cangjie-std-netFFI
    FLAGS
        $<$<BOOL:${MINGW}>:-lws2_32>)

string(TOLOWER ${TARGET_TRIPLE_DIRECTORY_PREFIX}_${CJNATIVE_BACKEND} output_cj_lib_dir)

add_and_combine_static_lib(
    TARGET cangjie-std-net
    OUTPUT_NAME libcangjie-std-net.a
    LIBRARIES
        $<TARGET_OBJECTS:cangjie-std-netFFI-objs>
        ${output_cj_object_dir}/std/net.o
        ${RUNTIME_COMMON_LIB_DIR}/libcangjie-aio.a
    DEPENDS
        cangjie${BACKEND_TYPE}Net
        cangjie-std-netFFI)
install(FILES ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/libcangjie-std-net.a
        DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})


make_cangjie_lib(
    std-crypto IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}StdCrypto
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/crypto.o)

add_library(cangjie-std-crypto STATIC ${output_cj_object_dir}/std/crypto.o)
set_target_properties(cangjie-std-crypto PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-crypto DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-crypto.digest IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Digest
    CANGJIE_STD_LIB_DEPENDS std-core std-io
    OBJECTS ${output_cj_object_dir}/std/crypto.digest.o)

add_library(cangjie-std-crypto.digest STATIC ${output_cj_object_dir}/std/crypto.digest.o)
set_target_properties(cangjie-std-crypto.digest PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-crypto.digest DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-crypto.cipher IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Cipher
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/crypto.cipher.o)

add_library(cangjie-std-crypto.cipher STATIC ${output_cj_object_dir}/std/crypto.cipher.o)
set_target_properties(cangjie-std-crypto.cipher PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-crypto.cipher DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-database IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Database
    CANGJIE_STD_LIB_DEPENDS std-core
    OBJECTS ${output_cj_object_dir}/std/database.o)
add_library(cangjie-std-database STATIC ${output_cj_object_dir}/std/database.o)
set_target_properties(cangjie-std-database PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-database DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})


make_cangjie_lib(
    std-database.sql IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Sql
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-time
        std-io
        std-collection
        std-collection.concurrent
        std-sort
        std-sync
        std-random
        std-math
        std-math.numeric
    OBJECTS ${output_cj_object_dir}/std/database.sql.o)
add_library(cangjie-std-database.sql STATIC ${output_cj_object_dir}/std/database.sql.o)
set_target_properties(cangjie-std-database.sql PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-database.sql DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-runtime IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Runtime cangjie-std-runtimeFFI
    CANGJIE_STD_LIB_DEPENDS std-core std-io std-sync std-fs std-process std-env std-collection
    OBJECTS ${output_cj_object_dir}/std/runtime.o
FLAGS -lcangjie-std-runtimeFFI)

add_library(cangjie-std-runtime STATIC $<TARGET_OBJECTS:cangjie-std-runtimeFFI-objs>
                                        ${output_cj_object_dir}/std/runtime.o)
set_target_properties(cangjie-std-runtime PROPERTIES LINKER_LANGUAGE C)
set(CJNATIVE_BACKEND "cjnative")
install(TARGETS cangjie-std-runtime DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

if(CANGJIE_ENABLE_COMPILER_TSAN)
    set(STD_AST_ALLOW_UNDEFINED ALLOW_UNDEFINED)
endif()
if (NOT OHOS AND NOT MINGW AND NOT DARWIN AND NOT ANDROID)
    set(GCC_S_FLAG -lgcc_s)
endif()
set(EXCLUDE_STD_AST_FFI_OPTION)
set(EXCLUDE_FLATBUFFERS_OPTION)
if(NOT DARWIN AND NOT MINGW)
    set(EXCLUDE_STD_AST_FFI_OPTION ${LINKER_OPTION_PREFIX}--exclude-libs=libcangjie-std-astFFI.a)
    # Hide Cangjie package `flatbuffers` symbols force-linked into libcangjie-std-ast.so.
    # stdx.syntax / stdx.chir also compile the same package from CANGJIE_HOME and
    # statically embed it. If these mangled names stay DEFAULT-visible, a process
    # that loads both DSOs (stdx.syntax already DT_NEEDED's std-ast) is subject to
    # ELF interposition. The package currently has no process-global mutable state,
    # but hidden visibility keeps the copies isolated if that ever changes.
    # Darwin uses two-level namespace so it does not interpose; MinGW exports all
    # symbols. Same skip as EXCLUDE_STD_AST_FFI_OPTION.
    set(EXCLUDE_FLATBUFFERS_OPTION ${LINKER_OPTION_PREFIX}--exclude-libs=libcangjie-flatbuffers.a)
endif()
set(STDCPP_FLAG -lstdc++)
if(DARWIN)
    set(STDCPP_FLAG -lc++)
elseif(OHOS)
    set(STDCPP_FLAG -l:libc++.a)
endif()

set(arm32_ast_support)
if(TRIPLE STREQUAL "arm-linux-ohos")
    set(arm32_ast_support -L$ENV{CANGJIE_HOME}/lib/linux_ohos_arm_cjnative)
elseif(TRIPLE STREQUAL "arm-linux-android23")
    set(arm32_ast_support -L$ENV{CANGJIE_HOME}/lib/linux_android23_arm_cjnative)
endif()

# Build only the flatbuffers static library: no shared library, and do not install it.
# Users never use flatbuffers directly; it only supports serialization/deserialization for ast.
# Consumers should use the ast library instead. The flatbuffers static archive is force-linked
# into the ast shared library (see FORCE_LINK_ARCHIVES below), and flatbuffers.o is also
# packaged into the ast static archive. On ELF, --exclude-libs hides those package symbols
# so they are not dynamically exported (see EXCLUDE_FLATBUFFERS_OPTION).
add_library(cangjie-flatbuffers STATIC ${output_cj_object_dir}/flatbuffers.o)
set_target_properties(cangjie-flatbuffers PROPERTIES LINKER_LANGUAGE C)
set_source_files_properties(${output_cj_object_dir}/flatbuffers.o PROPERTIES GENERATED TRUE)

make_cangjie_lib(
    std-ast IS_SHARED ${STD_AST_ALLOW_UNDEFINED}
    IOS_DEPLOYMENT_VERSION 12.0.0
    DEPENDS cangjie${BACKEND_TYPE}AST cangjie-std-astFFI-objs cangjie-flatbuffers
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
    CANGJIE_STD_LIB_INDIRECT_DEPENDS
        std-math
    OBJECTS ${output_cj_object_dir}/std/ast.o
    FORCE_LINK_ARCHIVES
        cangjie-flatbuffers
    FLAGS
        $<TARGET_OBJECTS:cangjie-std-astFFI-objs>
        ${arm32_ast_support}
        -lcangjie-ast-support
        ${STDCPP_FLAG}
        ${GCC_S_FLAG}
        $<$<NOT:$<BOOL:${ANDROID}>>:-lpthread>
        ${EXCLUDE_STD_AST_FFI_OPTION}
        ${EXCLUDE_FLATBUFFERS_OPTION}
        # if(NOT WIN32) then add -ldl, because there is no libdl on Windows.
        $<$<NOT:$<BOOL:${WIN32}>>:-ldl>)

add_library(cangjie-std-ast STATIC
    ${output_cj_object_dir}/std/ast.o
    ${output_cj_object_dir}/flatbuffers.o)
set_target_properties(cangjie-std-ast PROPERTIES LINKER_LANGUAGE C)
add_dependencies(cangjie-std-ast cangjie${BACKEND_TYPE}AST cangjie-flatbuffers)
install(TARGETS cangjie-std-ast DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

# Confirm the force-linked Cangjie flatbuffers package is not in the dynamic
# symbol table. Link+run coverage of "std.ast together with stdx.syntax/chir"
# lives in cangjie_test LLT/API/stdx/chir/mix_build, not in this repo.
if(NOT DARWIN AND NOT MINGW AND NOT WIN32)
    get_target_property(_std_ast_so std-ast CJ_LIB_OUTPUT_FILE)
    add_custom_command(
        TARGET std-ast POST_BUILD
        COMMAND ${CMAKE_COMMAND}
            -DLIB=${_std_ast_so}
            -DNM=${CMAKE_NM}
            -P ${CMAKE_CURRENT_LIST_DIR}/CheckFlatbuffersSymbolsHidden.cmake
        COMMENT "Checking Cangjie flatbuffers symbols are hidden in libcangjie-std-ast"
        VERBATIM)
endif()

make_cangjie_lib(
    std-unittest IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}Unittest cangjie-std-unittestFFI
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-collection.concurrent
        std-io
        std-argopt
        std-runtime
        std-fs
        std-time
        std-sort
        std-sync
        std-unittest.prop_test
        std-unittest.common
        std-unittest.diff
        std-unittest.mock.internal
        std-unittest.mock
        std-process
        std-env
        std-convert
        std-regex
        std-net
        std-binary
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math std-random std-unicode std-overflow
    OBJECTS ${output_cj_object_dir}/std/unittest.o
    FLAGS -lcangjie-std-unittestFFI)

add_library(cangjie-std-unittest STATIC $<TARGET_OBJECTS:cangjie-std-unittestFFI-objs>
                                        ${output_cj_object_dir}/std/unittest.o)
set_target_properties(cangjie-std-unittest PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-unittest.prop_test IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}UnittestPropTest
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-convert
        std-random
        std-sort
        std-unittest.common
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/unittest.prop_test.o)

add_library(cangjie-std-unittest.prop_test STATIC ${output_cj_object_dir}/std/unittest.prop_test.o)
set_target_properties(cangjie-std-unittest.prop_test PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest.prop_test DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-unittest.common IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}UnittestCommon
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-convert
        std-sort
        std-sync
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math
    OBJECTS ${output_cj_object_dir}/std/unittest.common.o)

add_library(cangjie-std-unittest.common STATIC ${output_cj_object_dir}/std/unittest.common.o)
set_target_properties(cangjie-std-unittest.common PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest.common DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-unittest.diff IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}UnittestDiff
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-sync
        std-sort
        std-fs
        std-collection
        std-convert
        std-math
        std-unittest.common
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-unicode std-overflow std-time
    OBJECTS ${output_cj_object_dir}/std/unittest.diff.o)

add_library(cangjie-std-unittest.diff STATIC ${output_cj_object_dir}/std/unittest.diff.o)
set_target_properties(cangjie-std-unittest.diff PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest.diff DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-unittest.mock.internal IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}UnittestMockInternal
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math std-time std-overflow std-unicode
    OBJECTS ${output_cj_object_dir}/std/unittest.mock.internal.o)

add_library(cangjie-std-unittest.mock.internal STATIC ${output_cj_object_dir}/std/unittest.mock.internal.o)
set_target_properties(cangjie-std-unittest.mock.internal PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest.mock.internal DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-unittest.mock IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}UnittestMock
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sync
        std-sort
        std-fs
        std-unittest.common
        std-unittest.mock.internal
    CANGJIE_STD_LIB_INDIRECT_DEPENDS std-math std-time std-overflow std-unicode std-convert
    OBJECTS ${output_cj_object_dir}/std/unittest.mock.o)

add_library(cangjie-std-unittest.mock STATIC ${output_cj_object_dir}/std/unittest.mock.o)
set_target_properties(cangjie-std-unittest.mock PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-unittest.mock DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-deriving.api IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}DerivingApi
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
        std-math
        std-sync
        std-ast
        std-unicode
    OBJECTS ${output_cj_object_dir}/std/deriving.api.o
)
add_library(cangjie-std-deriving.api STATIC ${output_cj_object_dir}/std/deriving.api.o)
set_target_properties(cangjie-std-deriving.api PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-deriving.api DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-deriving.resolve IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}DerivingResolve
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
        std-math
        std-sync
        std-ast
        std-convert
        std-unicode
        std-deriving.api
    OBJECTS ${output_cj_object_dir}/std/deriving.resolve.o
)
add_library(cangjie-std-deriving.resolve STATIC ${output_cj_object_dir}/std/deriving.resolve.o)
set_target_properties(cangjie-std-deriving.resolve PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-deriving.resolve DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-deriving.impl IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}DerivingImpl
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
        std-math
        std-convert
        std-ast
        std-sync
        std-unicode
        std-deriving.api
        std-deriving.resolve
    OBJECTS ${output_cj_object_dir}/std/deriving.impl.o
)
add_library(cangjie-std-deriving.impl STATIC ${output_cj_object_dir}/std/deriving.impl.o)
set_target_properties(cangjie-std-deriving.impl PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-deriving.impl DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

make_cangjie_lib(
    std-deriving.builtins IS_SHARED
    DEPENDS cangjie${BACKEND_TYPE}DerivingBuiltins
    CANGJIE_STD_LIB_DEPENDS
        std-core
        std-collection
        std-sort
        std-math
        std-convert
        std-ast
        std-sync
        std-unicode
        std-deriving.api
        std-deriving.resolve
    OBJECTS ${output_cj_object_dir}/std/deriving.builtins.o
)
add_library(cangjie-std-deriving.builtins STATIC ${output_cj_object_dir}/std/deriving.builtins.o)
set_target_properties(cangjie-std-deriving.builtins PROPERTIES LINKER_LANGUAGE C)
install(TARGETS cangjie-std-deriving.builtins DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})




if(NOT CMAKE_CROSSCOMPILING OR MINGW OR OHOS)
    make_cangjie_lib(
        std-unittest.testmacro IS_SHARED
        DEPENDS cangjie${BACKEND_TYPE}UnittestTestmacro
        CANGJIE_STD_LIB_DEPENDS
            std-core
            std-ast
            std-collection
            std-collection.concurrent
            std-sync
            std-unicode
            std-unittest.common
        CANGJIE_STD_LIB_INDIRECT_DEPENDS std-sort std-math std-time
        OBJECTS ${output_cj_object_dir}/std/unittest.testmacro.o)

    add_library(cangjie-std-unittest.testmacro STATIC ${output_cj_object_dir}/std/unittest.testmacro.o)
    set_target_properties(cangjie-std-unittest.testmacro PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-unittest.testmacro
            DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

    make_cangjie_lib(
        std-unittest.mock.mockmacro IS_SHARED
        DEPENDS cangjie${BACKEND_TYPE}UnittestMockmacro
        CANGJIE_STD_LIB_DEPENDS
            std-core
            std-ast
            std-collection
        CANGJIE_STD_LIB_INDIRECT_DEPENDS std-sort std-math
        OBJECTS ${output_cj_object_dir}/std/unittest.mock.mockmacro.o)

    add_library(cangjie-std-unittest.mock.mockmacro STATIC ${output_cj_object_dir}/std/unittest.mock.mockmacro.o)
    set_target_properties(cangjie-std-unittest.mock.mockmacro PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-unittest.mock.mockmacro
            DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})

    make_cangjie_lib(
        std-deriving IS_SHARED
        DEPENDS cangjie${BACKEND_TYPE}Deriving
        CANGJIE_STD_LIB_DEPENDS
            std-core
            std-collection
            std-sort
            std-math
            std-convert
            std-ast
            std-sync
            std-unicode
            std-deriving.api
            std-deriving.impl
            std-deriving.builtins
            std-deriving.resolve
        OBJECTS ${output_cj_object_dir}/std/deriving.o
    )
    add_library(cangjie-std-deriving STATIC ${output_cj_object_dir}/std/deriving.o)
    set_target_properties(cangjie-std-deriving PROPERTIES LINKER_LANGUAGE C)
    install(TARGETS cangjie-std-deriving DESTINATION lib/${output_triple_name}_${CJNATIVE_BACKEND}${SANITIZER_SUBPATH})
endif()

include(LibraryDependencies)

add_cangjie_library(
    cangjie${BACKEND_TYPE}Core
    NO_SUB_PKG
    IS_PRELUDE
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjieCore"
    PACKAGE_NAME "core"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_CORE_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/core
    DEPENDS ${STD_CORE_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Std
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjieStd"
    PACKAGE_NAME "std"
    MODULE_NAME ""
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std
    DEPENDS ${STD_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Binary IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    PACKAGE_NAME "binary"
    MODULE_NAME "std"
    SOURCES ${BINARY_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/binary
    DEPENDS ${BINARY_DEPENDENCIES})

add_cangjie_library(
        cangjie${BACKEND_TYPE}Net IS_STDLIB IS_CJNATIVE_BACKEND
        NO_SUB_PKG
        PACKAGE_NAME "net"
        MODULE_NAME "std"
        SOURCES ${CJNATIVE_STD_NET_SRCS}
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/net
        DEPENDS ${STD_NET_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Sync IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    PACKAGE_NAME "sync"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_SYNC_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/sync
    DEPENDS ${SYNC_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Overflow IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    PACKAGE_NAME "overflow"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_OVERFLOW_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/overflow
    DEPENDS ${OVERFLOW_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Math IS_STDLIB IS_CJNATIVE_BACKEND
    PACKAGE_NAME "math"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_MATH_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/math
    DEPENDS ${MATH_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Collection
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "collection"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/collection
    DEPENDS ${COLLECTION_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}ConcurrentCollection
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "collection.concurrent"
    MODULE_NAME "std"
    SOURCES ${CONCURRENT_COLLECTION_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/collection/concurrent
    DEPENDS ${CONCURRENT_COLLECTION_DEPENDENCIES})

if(NOT OHOS)
    add_cangjie_library(
        cangjie${BACKEND_TYPE}Concurrent
        NO_SUB_PKG
        IS_STDLIB
        IS_PACKAGE
        IS_CJNATIVE_BACKEND
        PACKAGE_NAME "concurrent"
        MODULE_NAME "std"
        SOURCES ${CONCURRENT_SRCS}
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/concurrent
        DEPENDS ${CONCURRENT_DEPENDENCIES})
endif()

add_cangjie_library(
    cangjie${BACKEND_TYPE}MathNumeric
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "math.numeric"
    MODULE_NAME "std"
    SOURCES ${MATH_NUMERIC_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/math/numeric
    DEPENDS ${MATH_NUMERIC_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}ObjectPool IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    ${SANITIZER_COMPILE_OPTION}
    PACKAGE_NAME "objectpool"
    MODULE_NAME "std"
    SOURCES ${OBJECTPOOL_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/objectpool
    DEPENDS ${OBJECTPOOL_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Interop
    NO_SUB_PKG
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "interop"
    MODULE_NAME "std"
    SOURCES ${INTEROP_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/interop
    DEPENDS ${INTEROP_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Ref
    NO_SUB_PKG
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "ref"
    MODULE_NAME "std"
    SOURCES ${REF_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/ref
    DEPENDS ${REF_DEPENDENCIES})

if(NOT DARWIN)
    add_cangjie_library(
        cangjie${BACKEND_TYPE}Reflect
        NO_SUB_PKG
        IS_STDLIB
        IS_CJNATIVE_BACKEND
        PACKAGE_NAME "reflect"
        MODULE_NAME "std"
        SOURCES ${REFLECT_SRCS}
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/reflect
        DEPENDS ${REFLECT_DEPENDENCIES})
endif()

add_cangjie_library(
    cangjie${BACKEND_TYPE}Sort
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "sort"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/sort
    DEPENDS ${SORT_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Io
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "io"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/io
    DEPENDS ${IO_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Convert
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "convert"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/convert
    DEPENDS ${STD_CONVERT_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Time
    NO_SUB_PKG
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "time"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_TIME_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/time
    DEPENDS ${TIME_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Fs
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "fs"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/fs
    DEPENDS ${FS_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Console
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "console"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/console
    DEPENDS ${CONSOLE_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}POSIX
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjiePOSIX"
    PACKAGE_NAME "posix"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/posix
    DEPENDS ${POSIX_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}PROCESS
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjiePROCESS"
    PACKAGE_NAME "process"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/process
    DEPENDS ${PROCESS_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}ENV
    NO_SUB_PKG
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    OUTPUT_NAME "cangjieENV"
    PACKAGE_NAME "env"
    MODULE_NAME "std"
    SOURCES ${ENV_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/env
    DEPENDS ${ENV_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Regex IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    PACKAGE_NAME "regex"
    MODULE_NAME "std"
    SOURCES ${REGEX_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/regex
    DEPENDS ${REGEX_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Random
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "random"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/random
    DEPENDS ${RANDOM_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}StdCrypto
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "crypto"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/crypto
    DEPENDS ${STD_DIGEST_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Digest
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "crypto.digest"
    MODULE_NAME "std"
    SOURCES ${DIGEST_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/crypto/digest
    DEPENDS ${STD_DIGEST_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Cipher
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "crypto.cipher"
    MODULE_NAME "std"
    SOURCES ${CIPHER_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/crypto/cipher
    DEPENDS ${STD_CIPHER_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Argopt
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "argopt"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/argopt
    DEPENDS ${ARGOPT_DEPENDENCIES})



add_cangjie_library(
    cangjie${BACKEND_TYPE}Unicode
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unicode"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unicode
    DEPENDS ${UNICODE_DEPENDENCIES})



add_cangjie_library(
    cangjie${BACKEND_TYPE}Database
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    IS_PACKAGE
    PACKAGE_NAME "database"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/database
    DEPENDS ${STD_DATABASE_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Sql IS_STDLIB IS_CJNATIVE_BACKEND
    NO_SUB_PKG
    PACKAGE_NAME "database.sql"
    MODULE_NAME "std"
    SOURCES ${SQL_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/database/sql
    DEPENDS ${STD_SQL_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Runtime
    NO_SUB_PKG
    IS_STDLIB
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "runtime"
    MODULE_NAME "std"
    SOURCES ${CJNATIVE_RUNTIME_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/runtime
    DEPENDS ${RUNTIME_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Flatbuffers
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    NO_INSTALL
    PACKAGE_NAME "flatbuffers"
    SOURCE_DIR $ENV{CANGJIE_HOME}/third_party/flatbuffers/cangjie
    DEPENDS ${FLATBUFFERS_DEPENDENCIES})
add_dependencies(cangjie-flatbuffers cangjie${BACKEND_TYPE}Flatbuffers)
# flatbuffers.cjo is a third-party module artifact; install next to the compiler SDK's
# third_party/flatbuffers/{bin,include,cangjie} layout instead of modules/<triple>/.
if(NOT CANGJIE_SANITIZER_SUPPORT_ENABLED)
    install(FILES ${output_cj_object_dir}/flatbuffers.cjo
            DESTINATION third_party/flatbuffers/modules)
    # Also install into CANGJIE_HOME so the compiler SDK can resolve flatbuffers.cjo.
    # Runtime is the sole producer of this cjo; compiler and stdx only consume it.
    # Use install(CODE) so CANGJIE_HOME is read at install time, not configure time.
    install(CODE "
        if(\"\$ENV{CANGJIE_HOME}\" STREQUAL \"\")
            message(FATAL_ERROR \"CANGJIE_HOME is not set; cannot install flatbuffers.cjo\")
        endif()
        set(_flatbuffers_modules_dir \"\$ENV{CANGJIE_HOME}/third_party/flatbuffers/modules\")
        file(MAKE_DIRECTORY \"\${_flatbuffers_modules_dir}\")
        file(INSTALL \"${output_cj_object_dir}/flatbuffers.cjo\"
             DESTINATION \"\${_flatbuffers_modules_dir}\")
    ")
endif()

add_cangjie_library(
    cangjie${BACKEND_TYPE}AST
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "ast"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/ast
    DEPENDS ${STD_AST_DEPENDENCIES})


add_cangjie_library(
    cangjie${BACKEND_TYPE}Unittest
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest
    DEPENDS ${UNITTEST_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestDiff
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.diff"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/diff
    DEPENDS ${UNITTEST_DIFF_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestPropTest
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.prop_test"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/prop_test
    DEPENDS ${UNITTEST_PROPTEST_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestCommon
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.common"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/common
    DEPENDS ${UNITTEST_COMMON_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestMock
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.mock"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/mock
    DEPENDS ${UNITTEST_MOCK_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestMockInternal
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.mock.internal"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/mock/internal
    DEPENDS ${UNITTEST_MOCK_INTERNAL_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}DerivingApi
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "deriving.api"
    MODULE_NAME "std"
    SOURCES ${DERIVING_API_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/deriving/api
    DEPENDS ${STD_DERIVING_API_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}DerivingResolve
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "deriving.resolve"
    MODULE_NAME "std"
    SOURCES ${DERIVING_RESOLVE_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/deriving/resolve
    DEPENDS ${STD_DERIVING_RESOLVE_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}DerivingImpl
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "deriving.impl"
    MODULE_NAME "std"
    SOURCES ${DERIVING_IMPL_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/deriving/impl
    DEPENDS ${STD_DERIVING_IMPL_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}DerivingBuiltins
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "deriving.builtins"
    MODULE_NAME "std"
    SOURCES ${DERIVING_BUILTINS_SRCS}
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/deriving/builtins
    DEPENDS ${STD_DERIVING_BUILTINS_DEPENDENCIES})


add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestTestmacro
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.testmacro"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/testmacro
    DEPENDS ${TESTMACRO_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}UnittestMockmacro
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "unittest.mock.mockmacro"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/unittest/mock/mockmacro
    DEPENDS ${UNITTEST_MOCKMACRO_DEPENDENCIES})

add_cangjie_library(
    cangjie${BACKEND_TYPE}Deriving
    NO_SUB_PKG
    IS_STDLIB
    IS_PACKAGE
    IS_CJNATIVE_BACKEND
    PACKAGE_NAME "deriving"
    MODULE_NAME "std"
    SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/std/deriving
    DEPENDS ${STD_DERIVING_DEPENDENCIES})
