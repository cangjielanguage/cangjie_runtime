# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

# Defining dependencies for all backends, BACKEND_TYPE is defined outside where this file is included
# Build stdlib only when cross-compiling.

list(APPEND STD_CORE_DEPENDENCIES boundscheck)

set(BINARY_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)

set(STD_NET_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Binary
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Overflow)

set(SYNC_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core cangjie${BACKEND_TYPE}Time)
set(MATH_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
set(SORT_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core cangjie${BACKEND_TYPE}Math cangjie${BACKEND_TYPE}Collection)
set(OVERFLOW_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
set(ENCODING_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
set(ENCODING_BASE64_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
set(ENCODING_HEX_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
set(STD_CONVERT_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core cangjie${BACKEND_TYPE}Math)
set(RUNTIME_DEPENDENCIES ${STD_CORE_DEPENDENCIES} cangjie${BACKEND_TYPE}Core)
if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    list(APPEND RUNTIME_DEPENDENCIES
         cangjie${BACKEND_TYPE}Fs
         cangjie${BACKEND_TYPE}Io
         cangjie${BACKEND_TYPE}Sync
         cangjie${BACKEND_TYPE}PROCESS
         cangjie${BACKEND_TYPE}ENV
         cangjie${BACKEND_TYPE}Collection)
endif()

set(STD_DEPENDENCIES 
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(COLLECTION_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Math)

set(CONCURRENT_COLLECTION_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Time)

set(CONCURRENT_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Sync)

set(STD_AST_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Flatbuffers
    FLATC_OUTPUTS)

set(FLATBUFFERS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(IO_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(MATH_NUMERIC_DEPENDENCIES 
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}Random
    cangjie${BACKEND_TYPE}Convert)


set(TIME_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Convert)

set(FS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Collection)

set(CONSOLE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Sort)

set(POSIX_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(PROCESS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Time)

set(ENV_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Sync)

set(OS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Sync)

set(INTEROP_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(INTEROP_ARKTS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)
# Deliberately no cangjie${BACKEND_TYPE}Interop here: arkts.cj imports no
# symbol from the parent package (verify with `cjc --scan-dependency`), unlike
# math.numeric/collection.concurrent whose subpackages do import the parent.
# Add the parent only if such an import appears.
# ExternConversionException is hosted by std.interop.arkts (not the arkts.lang
# facade) so the generated preset wrapper bodies name it without an import; the
# facade re-exports it through its `public import std.interop.arkts.*`. The
# wrapper bodies also reference cj_arkts_context_v1 (ForeignRuntimeException,
# context accessors) and ohos.business_exception (BusinessException) directly;
# those packages are outside the stdlib tree and are wired into the gated
# std.interop.arkts build through CANGJIE_ARKTS_INTEROP_IMPORT_DIRS (see
# AddCJNATIVELibrary.cmake). The dependency direction is one-way: neither of
# them may import std.interop.arkts, or the preset package cycles.

set(REF_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(OBJECTPOOL_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}ConcurrentCollection)

set(LOG_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync)

set(LOGGER_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Log
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}JsonStream)

set(REGEX_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sync)


set(SERIALIZATIONBASE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(SERIALIZATION_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(ENCODING_JSON_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Serialization
    cangjie${BACKEND_TYPE}Convert)

set(ENCODING_JSON_STREAM_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}MathNumeric)

set(ENCODING_XML_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sync)

set(RANDOM_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Math)


set(REFLECT_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Sync)

set(ARGOPT_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(COMPRESS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(COMPRESS_ZLIB_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Io)

set(CRYPTOBASE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(CRYPTO_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Digest
    cangjie${BACKEND_TYPE}CryptoDigest
    cangjie${BACKEND_TYPE}Cipher)

set(CRYPTO_DIGEST_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Hex
    cangjie${BACKEND_TYPE}Digest)

set(CRYPTO_KEYS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}X509
    cangjie${BACKEND_TYPE}Digest
    cangjie${BACKEND_TYPE}MathNumeric
    cangjie${BACKEND_TYPE}Sync)

set(X509_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Hex
    cangjie${BACKEND_TYPE}Base64
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Crypto)

set(STD_DIGEST_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Io)

set(STD_CIPHER_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(STD_DERIVING_API_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}AST
)

set(STD_DERIVING_RESOLVE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}DerivingApi
)

set(STD_DERIVING_IMPL_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}DerivingApi
    cangjie${BACKEND_TYPE}DerivingResolve
)

set(STD_DERIVING_BUILTINS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}DerivingApi
    cangjie${BACKEND_TYPE}DerivingResolve
)

set(STD_DERIVING_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}DerivingApi
    cangjie${BACKEND_TYPE}DerivingImpl
    cangjie${BACKEND_TYPE}DerivingBuiltins
    cangjie${BACKEND_TYPE}DerivingResolve
)

set(UNITTEST_COMMON_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Sync)

set(UNITTEST_DEPENDENCIES
    ${UNITTEST_COMMON_DEPENDENCIES}
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Runtime
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Argopt
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}UnittestPropTest
    cangjie${BACKEND_TYPE}UnittestCommon
    cangjie${BACKEND_TYPE}UnittestDiff
    cangjie${BACKEND_TYPE}UnittestMock
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Regex
    cangjie${BACKEND_TYPE}PROCESS
    cangjie${BACKEND_TYPE}ENV
    cangjie${BACKEND_TYPE}Binary
    cangjie${BACKEND_TYPE}Net)

set(UNITTEST_PROPTEST_DEPENDENCIES
    ${UNITTEST_COMMON_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Random
    cangjie${BACKEND_TYPE}UnittestCommon)

set(UNITTEST_DIFF_DEPENDENCIES
    ${UNITTEST_COMMON_DEPENDENCIES}
    cangjie${BACKEND_TYPE}UnittestCommon)

set(TESTMACRO_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    ${UNITTEST_COMMON_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}UnittestCommon
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}ConcurrentCollection)

set(UNITTEST_MOCK_INTERNAL_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(UNITTEST_MOCK_DEPENDENCIES
    ${UNITTEST_COMMON_DEPENDENCIES}
    cangjie${BACKEND_TYPE}UnittestCommon
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}UnittestMockInternal)

set(UNITTEST_MOCKMACRO_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}AST
    cangjie${BACKEND_TYPE}Collection)

set(UNICODE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(ENCODING_URL_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection)

set(NETBASE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(NET_TLS_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Hex
    cangjie${BACKEND_TYPE}Base64
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Net
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}X509
    cangjie${BACKEND_TYPE}CryptoDigest)

set(NET_HTTP_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Fs
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Convert
    cangjie${BACKEND_TYPE}Console
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Base64
    cangjie${BACKEND_TYPE}Unicode
    cangjie${BACKEND_TYPE}Net
    cangjie${BACKEND_TYPE}Url
    cangjie${BACKEND_TYPE}Log
    cangjie${BACKEND_TYPE}Logger
    cangjie${BACKEND_TYPE}Tls
    cangjie${BACKEND_TYPE}PROCESS
    cangjie${BACKEND_TYPE}Crypto
    cangjie${BACKEND_TYPE}X509)


set(STD_DATABASE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(STD_SQL_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Time
    cangjie${BACKEND_TYPE}Io
    cangjie${BACKEND_TYPE}Sync
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}ConcurrentCollection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}Math
    cangjie${BACKEND_TYPE}MathNumeric
    cangjie${BACKEND_TYPE}Random)

set(FUZZBASE_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(FUZZ_FUZZ_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Collection
    cangjie${BACKEND_TYPE}Sort
    cangjie${BACKEND_TYPE}PROCESS
    cangjie${BACKEND_TYPE}Convert)

set(JAVA8_JAVA_LANG_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core)

set(STD_FFIJAVA_DEPENDENCIES
    ${STD_CORE_DEPENDENCIES}
    cangjie${BACKEND_TYPE}Core
    cangjie${BACKEND_TYPE}Java8_java.lang)
