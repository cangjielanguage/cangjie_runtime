// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_FLAGS_H
#define MRT_FLAGS_H

// adapted from modifier.h in MapleRuntime
#include "Base/Types.h"

namespace MapleRuntime {
enum TypeKind : I8 {
    // reference type
    TYPE_KIND_CLASS = -128,
    TYPE_KIND_INTERFACE = -127,
    TYPE_KIND_RAWARRAY = -126,
    TYPE_KIND_FUNC = -125,
    TYPE_KIND_TEMP_ENUM = -124,
    TYPE_KIND_WEAKREF_CLASS = -123,
    TYPE_KIND_FOREIGN_PROXY = -122,
    TYPE_KIND_EXPORTED_REF = -121,
    TYPE_KIND_GENERIC_TI = -1,
    TYPE_KIND_GENERIC_CUSTOM = -2,

    // value type
    TYPE_KIND_NOTHING = 0,
    TYPE_KIND_UNIT,
    TYPE_KIND_BOOL,
    TYPE_KIND_RUNE,
    TYPE_KIND_UINT8,
    TYPE_KIND_UINT16 = 5,
    TYPE_KIND_UINT32,
    TYPE_KIND_UINT64,
    TYPE_KIND_UINT_NATIVE,
    TYPE_KIND_INT8,
    TYPE_KIND_INT16 = 10,
    TYPE_KIND_INT32,
    TYPE_KIND_INT64,
    TYPE_KIND_INT_NATIVE,
    TYPE_KIND_FLOAT16,
    TYPE_KIND_FLOAT32 = 15,
    TYPE_KIND_FLOAT64,
    TYPE_KIND_CSTRING,
    TYPE_KIND_CPOINTER,
    TYPE_KIND_CFUNC,
    TYPE_KIND_VARRAY = 20,
    TYPE_KIND_TUPLE,
    TYPE_KIND_STRUCT,
    TYPE_KIND_ENUM,
    TYPE_KIND_MAX,
};


constexpr U32 FLAG_HAS_REF_FIELD = 0x1 << 0; // fast path to skip scanning some object
constexpr U32 FLAG_HAS_FINALIZER = 0x1 << 1;
constexpr U32 FLAG_FUTURE_CLASS = 0x1 << 2;
constexpr U32 FLAG_MUTEX_CLASS = 0x1 << 3;
constexpr U32 FLAG_MONITOR_CLASS = 0x1 << 4;
constexpr U32 FLAG_WAIT_QUEUE_CLASS = 0x1 << 5;
constexpr U32 FLAG_REFLECTION = 0x1 << 6;
constexpr U32 FLAG_HAS_EXT_PART = 0x1 << 7;

constexpr U32 MODIFIER_DEFAULT     = 0x1 << 0;
constexpr U32 MODIFIER_PRIVATE     = 0x1 << 1;
constexpr U32 MODIFIER_PROTECTED   = 0x1 << 2;
constexpr U32 MODIFIER_PUBLIC      = 0x1 << 3;
constexpr U32 MODIFIER_IMMUTABLE   = 0x1 << 4;
constexpr U32 MODIFIER_BOXCLASS    = 0x1 << 5;
constexpr U32 MODIFIER_OPEN        = 0x1 << 6;
constexpr U32 MODIFIER_OVERRIDE    = 0x1 << 7;
constexpr U32 MODIFIER_REDEF       = 0x1 << 8;
constexpr U32 MODIFIER_ABSTRACT    = 0x1 << 9;
constexpr U32 MODIFIER_SEALED      = 0x1 << 10;
constexpr U32 MODIFIER_MUT         = 0x1 << 11;
constexpr U32 MODIFIER_STATIC      = 0x1 << 12;

// EnumKind0 contains three enum types:
// 1. EXHAUSTIVE_ZERO_SIZE
//    enum E { A }
//    Memory layout of E.A: {}
// 2. NON_EXHAUSTIVE_UNASSOCIATED
//    enum E { A | B | ... }
//    Memory layout of E.A: { i32 tag }
// 3. EXHAUSITIVE_UNASSOCIATED
//    enum E { A | B }
//    Memory layout of E.A: { i32 tag }
constexpr U32 MODIFIER_ENUM_KIND0  = 0x1 << 13;

// EnumKind1 contains two enum types:
// 1. NON_EXHAUSTIVE_ASSOCIATED
//    enum E { A(Bool, Int64) | B(Int32) | C(Float32) | ... }
// 2. EXHAUSTIVE_OTHER
//    class C {}
//    enum E { A(C, Int64) | B(Int32) | C(Float32) }
// EnumKind1's memory layout is represented as an object.
// The object header stores the constructor's TypeInfo,
// and the object body stores this enum's tag and associated values.
// The memory alignment rules are the same as Struct.
// Memory layout of E.B(value): { E:1.ti, i32 tag, i32 value }
constexpr U32 MODIFIER_ENUM_KIND1  = 0x1 << 14;

// EnumKind2 contains three enum types:
// 1. EXHAUSTIVE_ASSOCIATED_OPTION_LIKE_NOREF
//    enum E { A(Int32) | B }
//    Memory layout of E.A(value): { i1 tag, i32 value }
//    Memory layout of E.B: { i1 tag, i32 0 }
// 2. EXHAUSTIVE_ASSOCIATED_OPTION_LIKE_REF
//    class C {}
//    enum E { A(C) | B }
//    Memory layout of E.A(value): { value }
//    Memory layout of E.B: { nullptr }
// 3. EXHAUSTIVE_ASSOCIATED_OPTION_LIKE_T
//    enum E<T> { A(T) | B }
constexpr U32 MODIFIER_ENUM_KIND2  = 0x1 << 15;


// ENUMKIND3: EXHAUSTIVE_ASSOCIATED_NONREF
// enum E { A(Bool, Int64) | B(Int8) | C(Float32) }
// This type has no padding in its memory layout.
// Memory layout of E.A(v1, v2): { i32 tag, i1 v1, i64 v2 }, offset: {0, 4, 5}
constexpr U32 MODIFIER_ENUM_KIND3  = 0x1 << 16;

constexpr U32 MODIFIER_HAS_SRET0   = 0x1 << 17; // has sret but it is'not generic'
constexpr U32 MODIFIER_HAS_SRET1   = 0x1 << 18; // has sret and it is 'T'
constexpr U32 MODIFIER_HAS_SRET2   = 0x1 << 19; // has sret and it is 'known struct T'
constexpr U32 MODIFIER_HAS_SRET3   = 0x1 << 20; // has sret and it is 'unknow struct T'
constexpr U32 MODIFIER_ENUM_CTOR   = 0x1 << 21;
constexpr U32 MODIFIER_UNKNOWN_SIZE     = 0x1 << 22;
constexpr U32 MODIFIER_ENUM_PARSED      = 0x1 << 23;

// Reflection does not support enum, tuple, and function types.
constexpr U32 MODIFIER_REFLECT_VER_BIT1 = 0x1 << 28;

// Reflection supports enum, tuple, and function types,
// but does not support getting enum constructor's annotations.
constexpr U32 MODIFIER_REFLECT_VER_BIT2 = 0x1 << 29;

// Reflection supports getting enum constructor annotations.
constexpr U32 MODIFIER_REFLECT_VER_BIT3 = 0x1 << 30;
constexpr U32 MODIFIER_INVALID     = 0x1 << 31;
} // namespace MapleRuntime

#endif // MRT_FLAGS_H
