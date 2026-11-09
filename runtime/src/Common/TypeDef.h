// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_TYPE_DEF_H
#define MRT_TYPE_DEF_H

#include <limits>
#include <climits>

#include "Base/Macros.h"
#include "Base/Types.h"

// commonly agreed type interfaces for a managed runtime:
//    they're opaque across modules, but we still want it provides a degree
//    of type safety.
namespace MapleRuntime {
// Those are mostly managed pointer types for GC
using MAddress = Uptr; // Managed address
constexpr Uptr NULL_ADDRESS = 0;

// object model related types
class BaseObject;

// basic types for managed world: modify them together
using MSize = U32;   // managed object size
using MOffset = U32; // managed offset inside managed object
using MIndex = U64;  // index of array
constexpr size_t GENERIC_PAYLOAD_SIZE = INT_MAX; // only for CJ_MCC_WriteGenericPayload

constexpr MIndex MAX_ARRAY_SIZE = std::numeric_limits<MIndex>::max();

class MObject;
using ObjRef = MObject*;

class MArray;
using ArrayRef = MArray*;

class MFunc;
using FuncRef = MFunc*;

class MFuncDesc;
using FuncDescRef = MFuncDesc*;

class MString;
using StringRef = MString*;

using MException = MObject;
using ExceptionRef = MException*;

class ExceptionWrapper;

class MethodInfo;
using MethodInfoRef = MethodInfo*;

class PackageInfo;
using PackageInfoRef = PackageInfo*;

class ParameterInfo;
using ParameterInfoRef = ParameterInfo*;

using FuncPtr = void(*)(void*);

// at first glance, there is no need to expose this type or at least RAW_POINTER_OBJECT.
// however in consideration that there are lots of differences for runtime apis to support different gc,
// this is acceptable.
enum class AllocType {
    MOVEABLE_OBJECT = 0,
    PINNED_OBJECT,
    RAW_POINTER_OBJECT
};

#ifdef __cplusplus
extern "C" {
#endif
/* Get the aligned value. */
#define MRT_ALIGN(x, a) (((x) + (a)-1) & ~((a)-1))
#ifdef __cplusplus
}
#endif
} // namespace MapleRuntime

#endif // MRT_TYPE_DEF_H
