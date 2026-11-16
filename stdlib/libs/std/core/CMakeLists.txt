# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

add_subdirectory(native)

set(CANGJIE_CORE_SRCS
    native.cj
    box.cj
    object.cj
    duration.cj
    sleep.cj
    option.cj
    to_string.cj
    endian.cj
    float.cj
    iterator.cj
    collection.cj
    flow.cj
    hashable.cj
    equatable.cj
    c_pointer_resource.cj
    c_string_resource.cj
    c_type.cj
    libc.cj
    thread_common.cj
    thread_local.cj
    countable.cj
    range.cj
    arithmetic_exception.cj
    illegal_argument_exception.cj
    illegal_format_exception.cj
    illegal_state_exception.cj
    index_out_of_bounds_exception.cj
    negative_array_size_exception.cj
    stack_trace_element.cj
    none_value_exception.cj
    unsupported_exception.cj
    unimplemented_exception.cj
    overflow_exception.cj
    out_of_memory_error.cj
    local_region_out_of_memory_error.cj
    resource.cj
    spawn_exception.cj
    char_extension.cj
    byte_extension.cj
    type_alias.cj
    atexit.cj
    main_args.cj
    annotation.cj
    illegal_memory_exception.cj
    array_common.cj
    string_builder.cj
    string.cj
    timeout_exception.cj
    string_common.cj
    incompatible_package_exception.cj)
if(CANGJIE_CODEGEN_CJNATIVE_BACKEND)
    set(CJNATIVE_CORE_SRCS
        ${CANGJIE_CORE_SRCS}
        runtime_call_throw_exception.cj
        future.cj
        thread.cj
        exception.cj
        error.cj
        array.cj
        array_intrinsic.cj
        atomic.cj
        stack_overflow_error.cj
        print.cj
        comparable.cj
        exclusive_scope.cj
        CACHE INTERNAL "")
endif()
