// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef RT_INTERFACE_H
#define RT_INTERFACE_H

#include <stddef.h>
#include <stdint.h>

#include "RuntimeTypes.h"

#ifdef __cplusplus
extern "C" {
#endif // __cplusplus

// region Types

// Pointer to traceable object reference. Binary layout of object is defined by CJNative runtime.
typedef void* DYN_ObjRef;

// Pointer to RefField
typedef void* DYN_FieldRef;

// Pointer to the place that contains traceable object reference.
typedef void* DYN_Placeholder;

// State that's passed during visiting stack frames.
typedef void* DYN_VisitingState;

// Pointer to TypeTemplate. Binary layout of this structure is defined by CJNative runtime.
typedef void* DYN_TypeTemplate;

// Pointer to ThreadLocalData that is currently executing current cjThread.
typedef void* DYN_ThreadLocalData;

// Pointer to cjThread specific data that is used by interpreter during execution.
// This pointer is stored in cjThread specific storage.
typedef void* DYN_CJThreadSpecificData;

// Handle of a cjThread.
typedef void* DYN_CJThreadHandle;

// This is alias for frame pointer. CJNative runtime should pass this pointer to `INT_FrameInfoProviderFn` function.
// Interpreter would return description of corresponding frame (e.g. fileName, lineNumber).
typedef const void* DYN_FramePointer;

// This is alias for instruction pointer. CJNative runtime should pass this pointer to `INT_FrameInfoProviderFn`
// function. Interpreter would return description of corresponding frame (e.g. fileName, lineNumber).
typedef const void* DYN_InstructionPointer;

// Visitor of interpreter pointer placeholders.
// Interpreter cannot use this data directly but should pass it to the callbacks defined in `DYN_CJNativeInterface`.
typedef const void* DYN_RootVisitor;

// Visitor of placeholders that contain derived pointers (intrapointers).
// Interpreter cannot use this data directly but should pass it to the callbacks defined in `DYN_CJNativeInterface`.
typedef const void* DYN_DerivedPtrVisitor;

// Pointer to ExceptionWrapper.
typedef void* DYN_ExceptionWrapper;

// Interpreter specific data, used for getting interpreted frame description.
typedef const void* INT_FunctionHandle;

// Interpreter specific data, used for getting interpreted frame description.
typedef const void* INT_BytecodePos;

typedef const char* INT_InterpreterArg;
typedef const INT_InterpreterArg* INT_InterpreterArgs;

// Frame description used by interpreter frame visitors.
typedef struct INT_FrameDesc {
    DYN_FramePointer fp;
    DYN_InstructionPointer ip;
} INT_FrameDesc;

// This struct is used for getting interpreted frame info.
typedef struct INT_InterpretedFrameInfo {
    INT_FunctionHandle fuh;
    INT_BytecodePos bcPos;
} INT_InterpretedFrameInfo;

// This struct describes interpreted method. Interpreter would fill this structure in `INT_FrameDescProviderFn` function
// using `INT_InterpretedFrameInfo`.
typedef struct INT_InterpretedFrameDesc {
    size_t lineNumber;
    char* methodName;
    char* className;
    char* fileName;
    void (*freeResources)(char* methodName, char* className, char* fileName);
} INT_InterpretedFrameDesc;

// endregion Types

// region Calling Conventions

// C Calling convention (CCall)
//   This is default calling convention used by any C/C++ code.
//   Provided callbacks use this calling convention to simplify interoperability of CJNative and interpreter.

// Managed Cangjie Calling convention (ManagedCall)
//   This is default calling convention used by compiled Cangjie code. Parameter passing is similar to CCall but there
//   are some differences. For example, there is dedicated non-volatile register that holds pointer to thread local data
//   (e.g. r15 on x86_64). Take care of this calling convention when making C2I or I2C transitions.

// endregion Calling Conventions

#define INT_INTERPRETER_INTERFACE_VERSION 2
#define DYN_CJNATIVE_INTERFACE_VERSION 2

// region interpreter interface

// Prepares state and calls callback with initialized state and provided context. After callback returns, performs
// necessary cleanup of the state.
// params:
// - cjThreadData - pointer to interpreter data for current cjThread.
// - callback - continuation that expects initialized state and context.
// - ctx - context that should be passed to callback.
typedef void (*INT_IterateFramesWithStateFn)(
    DYN_CJThreadSpecificData cjThreadData, void (*callback)(DYN_VisitingState, void*), void* ctx);

// Visit all frame slots that contain pointers to stack using provided visitor.
// params:
// - state - visiting state that was initialized in iterateFramesWithState callback. This state is passed between
// consecutive calls to this function for different frames.
// - frameDesc - description of the frame which slots are being visited.
// - stackPtrVisitor - visitor callback provided by CJNative runtime for processing slots with stack pointers.
// - derivedPtrVisitor - derived pointers visitor callback provided by CJNative runtime for processing slots with
// intrapointers (which point to stack).
// Notes:
// Provided visitors cannot be called directly by interpreter. Interpreter should pass visitor to the callbacks defined
// in `DYN_CJNativeInterface` to process slots.
typedef void (*INT_VisitFrameRootsExpansionFn)(DYN_VisitingState state, INT_FrameDesc frameDesc,
    DYN_RootVisitor stackPtrVisitor, DYN_DerivedPtrVisitor derivedPtrVisitor);

// Visit frame roots (local variables) of interpreted code with marking visitor.
// params:
// - state - visiting state that was initialized in iterateFramesWithState callback. This state is passed between
// consecutive calls to this function for different frames.
// - frameDesc - description of the frame which roots are being visited.
// - rootVisitor - marking root visitor callback provided by CJNative runtime. Interpreter should call this callback for
// each root it needs to process.
// Notes:
// Root visitor cannot be called directly by interpreter. Interpreter should pass root visitor to the callbacks defined
// in `DYN_CJNativeInterface` to process roots.
typedef void (*INT_VisitFrameRootsMarkingFn)(
    DYN_VisitingState state, INT_FrameDesc frameDesc, DYN_RootVisitor rootVisitor);

// Visit frame roots (local variables) of interpreted code with adjusting visitor.
// params:
// - state - visiting state that was initialized in iterateFramesWithState callback. This state is passed between
// consecutive calls to this function for different frames.
// - frameDesc - description of the frame which roots are being visited.
// - rootVisitor - adjusting root visitor callback provided by CJNative runtime. Interpreter should call this callback
// for each root it needs to process.
// - derivedPtrVisitor - derived pointers visitor callback provided by CJNative runtime.
// Notes:
// Root visitors cannot be called directly by interpreter. Interpreter should pass root visitor to the callbacks defined
// in `DYN_CJNativeInterface` to process roots.
typedef void (*INT_VisitFrameRootsAdjustingFn)(DYN_VisitingState state, INT_FrameDesc frameDesc,
    DYN_RootVisitor rootVisitor, DYN_DerivedPtrVisitor derivedPtrVisitor);

// Visit static roots (global variables) of interpreted code with some visitor.
// Can be used to add interpreted roots for GC root-set or for references adjusting.
// params:
// - visitor - root visitor callback provided by CJNative runtime. Interpreter should call this callback for each root
// it needs to process.
// Notes:
// Root visitor cannot be called directly by interpreter. Interpreter should pass root visitor to the callbacks defined
// in `DYN_CJNativeInterface` to process roots.
typedef void (*INT_VisitGlobalRootsFn)(DYN_RootVisitor visitor);

// Registers newly created cjThread in interpreter. This method could be called by any thread (e.g. auxiliary scheduler
// thread) to notify interpreter about creation of new cjThread.
// params:
// - Pointer to CJThreadSpecificData
// Notes:
//  Interpreter will save auxiliary metadata in [DYN_CJThreadSpecificData + offsetToCJThreadSpecificMemory] memory area
//  to simplify support of interpretation and Garbage collection.
typedef void (*INT_CJThreadOnStartFn)(DYN_CJThreadSpecificData*);

// Unregisters cjThread in interpreter. This method could be called by any thread (e.g. auxiliary scheduler thread) to
// notify interpreter about termination of some completed cjThread.
// params:
// - Pointer to CJThreadSpecificData
typedef void (*INT_CJThreadOnDestroyFn)(DYN_CJThreadSpecificData*);

// Provides size of interpreted frame by frame pointer.
// Notes:
//  Frame pointer should point on valid interpreter frame that is not cleared at the moment of
//  this function call.
typedef uint32_t (*INT_GetFrameSize)(DYN_FramePointer fp);

// Provides description of given frame which could be used for precise stack trace generation.
// This method could be called by any thread (e.g. auxiliary stack dumper thread) to query information about
// interpreter frames.
// Important: this function may invoke "long-running" tasks (fseek, pthread_mutex_lock) so CJNative runtime
//            should treat this method as "foreign" code.
// params:
// - fuh - Internal interpreter data pointer that's got by `INT_FrameInfoProviderFn`.
// - bc - Internal interpreter data pointer that's got by `INT_FrameInfoProviderFn`.
// - frameDesc - [OUT] Pointer to INT_InterpretedFrameDesc. Fields of this struct will be initialized by interpreter.
typedef void (*INT_FrameDescProviderFn)(
    INT_FunctionHandle fuh, INT_BytecodePos pos, INT_InterpretedFrameDesc* frameDesc);

// Provides information related to interpreted frame that can be used later for getting a description of the frame
// for printable stacktrace collection.
// This method could be called by any thread (e.g. auxiliary stack dumper thread) to query information about
// interpreter frames.
// Important: this function may invoke "long-running" tasks (fseek, pthread_mutex_lock) so CJNative runtime
//            should treat this method as "foreign" code.
// params:
// - ip - Instruction pointer in frame (callsite position).
// - fp - Frame pointer. Must be provided by CJNative runtime.
// - frameInfo - [OUT] Pointer to INT_InterpretedFrameInfo. Fields of this struct will be initialized by interpreter.
typedef void (*INT_FrameInfoProviderFn)(
    DYN_InstructionPointer ip, DYN_FramePointer fp, INT_InterpretedFrameInfo* frameInfo);

// Landing pad which handles pending exception.
// If there is suitable catch block in current last interpreted frame, interprets catch block.
// Otherwise, drops current frame and rethrows exception.
typedef void (*INT_LandingPadFn)();

// endregion interpreter interface

// region CJNative interface

// Allocate new object.
// params:
// - Pointer to TypeInfo describing the object to be allocated
// return: allocated object or NULL
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_ObjAllocFn)(struct DYN_TypeInfo*);

// Allocate new array.
// params:
// - arrayType - pointer to TypeInfo describing the array to be allocated
// - size - size of the array to be allocated
// return: allocated array object or NULL
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_ArrayAllocFn)(struct DYN_TypeInfo* arrayType, uint64_t size);

// Poll a safe point.
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_SafePointFn)();

// Check if safepoint is pending.
// params:
// - threadLocalData - pointer to current `ThreadLocalData`.
// return: non-zero if safepoint is pending, zero otherwise.
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef int (*DYN_IsPendingSafePointFn)(DYN_ThreadLocalData);

// Provide a TypeInfo for type with given signature.
// params:
// - type description as char string.
// return: pointer to TypeInfo
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef struct DYN_TypeInfo* (*DYN_TypeInfoProviderFn)(const char*);

// Provide a TypeTemplate for type with given signature.
// params:
// - type description as char string.
// return: pointer to TypeTemplate
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_TypeTemplate (*DYN_TypeTemplateFn)(const char*);

// Get or create specialized TypeInfo from a TypeTemplate and type arguments.
// params:
// - typeTemplate - pointer to the TypeTemplate
// - argSize - number of type arguments
// - typeArgs - array of pointers to TypeInfo (type arguments)
// return: pointer to the specialized TypeInfo
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef struct DYN_TypeInfo* (*DYN_GetOrCreateTypeInfoFn)(
    DYN_TypeTemplate typeTemplate, uint32_t argSize, struct DYN_TypeInfo** typeArgs);

// Get the instance size of a type from its TypeInfo.
// params:
// - typeInfo - pointer to the TypeInfo
// return: size of the instance in bytes
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef uint32_t (*DYN_GetInstanceSizeFn)(struct DYN_TypeInfo* typeInfo);

// Get method table for a concrete type using the method layout of another type.
// VMT for type is split into subtables keyed by the type that owns the method layout.
// The layout owner is interface, concrete class itself or one of its supertypes.
// params:
// - concreteTi - concrete type
// - ownerTi - method layout owner type, interface/supertype
// return: methods array of ownerTi implemented by concreteTi
typedef DYN_FuncPtr* (*DYN_GetMTableFn)(struct DYN_TypeInfo* concreteTi, struct DYN_TypeInfo* ownerTi);

// Get the outer TypeInfo for the implementation in a method-table slot.
// The method table is selected by concreteTi and ownerTi: ownerTi provides the
// method layout and index selects a slot in that layout. "Outer TypeInfo" means
// the TypeInfo that owns the selected implementation. If concreteTi overrides
// the slot, this is concreteTi. If concreteTi inherits the same function pointer
// from a supertype, this is the supertype that provides it.
// params:
// - concreteTi - concrete type
// - ownerTi - method layout owner type, interface/supertype
// - index - method index in the owner method table
// return: outer TypeInfo for the selected method
typedef struct DYN_TypeInfo* (*DYN_GetMethodOuterTIFn)(
    struct DYN_TypeInfo* concreteTi, struct DYN_TypeInfo* ownerTi, uint64_t index);

// Refresh an ExtensionData function table used for virtual dispatch.
// concreteTi is the concrete type whose dispatch table is being refreshed.
// ownerTi is the method layout owner whose current function-table size is used
// as the target size. extensionData is the dispatch metadata entry for
// concreteTi under ownerTi's method layout. If the table is already marked
// updated, this call is a no-op. Otherwise the runtime may allocate a larger
// function table, copy existing slots, fill newly added slots from a compatible
// direct supertype, reset cached outer TypeInfo entries, and mark the table as
// updated.
// params:
// - concreteTi - concrete type
// - ownerTi - method layout owner type, interface/supertype
// - extensionData - dispatch metadata entry to refresh
typedef void (*DYN_UpdateVMTFn)(
    struct DYN_TypeInfo* concreteTi, struct DYN_TypeInfo* ownerTi, struct DYN_ExtensionData* extensionData);

// Get TypeInfo UUID.
// params:
// - ti - type info
// return: UUID assigned to type by runtime
typedef uint32_t (*DYN_GetTypeInfoUUIDFn)(struct DYN_TypeInfo* ti);

// Throw OutOfMemoryError exception.
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_ThrowOOMFn)();

// Throw given exception.
// params:
// - exception object to throw
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_ThrowExceptionFn)(DYN_ObjRef exceptionObject);

// Get pending exception instance.
// This method hasn't any side effects (doesn't affect pending status).
// return: pointer to pending object
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_GetPendingExceptionFn)();

// Get and clear pending exception instance.
// Any call to `DYN_GetPendingExceptionFn` after execution of this method should return null.
// return: pointer to pending object
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_GetAndClearPendingExceptionFn)();

// Check that given object is an instance of given type.
// params:
// - object which type will be checked
// - pointer to TypeInfo
// return: non-zero if object's type is a subtype of `ti`, zero otherwise.
// Notes:
//  This method will be invoked by interpreter as a part of interpretation loop.
typedef int (*DYN_InstanceOfFn)(DYN_ObjRef obj, struct DYN_TypeInfo* ti);

// Check that typeInfo is a subtype of superTypeInfo.
// params:
// - typeInfo - type to check
// - superTypeInfo - base type
// return: non-zero if typeInfo is a subtype of superTypeInfo.
// Notes:
typedef int (*DYN_IsSubTypeFn)(struct DYN_TypeInfo* typeInfo, struct DYN_TypeInfo* superTypeInfo);

// Applies visitor to the given placeholder.
// params:
// - visitor - root visitor callback provided by CJNative runtime. Interpreter should call this callback for each root
// it needs to process.
// - placeholder - pointer to the place that contains reference which should be visited.
typedef void (*DYN_VisitRootFromInterpreterFn)(DYN_RootVisitor visitor, DYN_Placeholder placeholder);

// Applies visitor to the given derived and base pointers.
// params:
// - visitor - root visitor callback provided by CJNative runtime.
// - basePtrHolder - pointer to the place that contains base pointer.
// - derivedPtrHolder - pointer to the place that contains derived pointer (intrapointer).
typedef void (*DYN_VisitDerivedPtrFromInterpreterFn)(
    DYN_DerivedPtrVisitor visitor, DYN_Placeholder basePtrHolder, DYN_Placeholder derivedPtrHolder);

// Read reference from static field.
// params:
// - source - pointer to static reference field
// return: object reference stored in the field
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_ReadStaticFieldFn)(DYN_FieldRef source);

// Write reference to static field.
// params:
// - destination - pointer to static reference field
// - newValue - object reference to store in the field
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_WriteStaticFieldFn)(DYN_FieldRef destination, DYN_ObjRef newValue);

// Read reference from instance field.
// params:
// - source - object that contains instance field
// - field - pointer to instance reference field
// return: object reference stored in the field
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_ReadInstanceFieldFn)(DYN_ObjRef source, DYN_FieldRef field);

// Write reference to instance field.
// params:
// - destination - object that contains instance field
// - field - pointer to instance reference field
// - newValue - object reference to store in the field
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_WriteInstanceFieldFn)(DYN_ObjRef destination, DYN_FieldRef field, DYN_ObjRef newValue);

// Read a struct field from an object.
// params:
// - dstPtr - pointer to the destination memory
// - obj - object containing the struct field
// - srcField - pointer to the start of the struct
// - size - size of the struct in bytes
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_ReadStructFieldFn)(uintptr_t dstPtr, DYN_ObjRef obj, uintptr_t srcField, size_t size);

// Write a struct field to an object.
// params:
// - obj - object containing the struct field
// - dst - pointer to the destination memory (start of struct field inside object)
// - src - pointer to the source memory
// - size - size of the struct in bytes
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_WriteStructFieldFn)(DYN_ObjRef obj, uintptr_t dst, uintptr_t src, size_t size);

// Read a static struct field.
// params:
// - dst - pointer to the destination memory
// - dstSize - size of destination memory
// - src - pointer to the source static struct
// - srcSize - size of source struct
// - tib - The GCTib value (can be a pointer to StdGCTib or a ShortGCTib bitmap)
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_ReadStaticStructFieldFn)(
    uintptr_t dst, size_t dstSize, uintptr_t src, size_t srcSize, DYN_GCTib tib);

// Write a static value type field (struct).
// params:
// - dst - pointer to the destination static struct
// - dstSize - size of destination struct
// - src - pointer to the source memory
// - srcSize - size of source memory
// - tib - The GCTib value (can be a pointer to StdGCTib or a ShortGCTib bitmap)
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_WriteStaticStructFieldFn)(uintptr_t dst, size_t dstSize, uintptr_t src, size_t srcSize, DYN_GCTib tib);

// Read a generic field from an object.
// Should be used if generic type resolves to struct/value at runtime, otherwise use DYN_ReadInstanceFieldFn.
// params:
// - dst - pointer to the destination box-object of generic struct/value
// - srcObj - the source object on the heap (can be box of generic struct/value)
// - srcField - address of the field inside srcObj
// - size - size of the data to copy
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_ReadGenericFieldFn)(DYN_ObjRef dst, DYN_ObjRef srcObj, uintptr_t srcField, size_t size);

// Write a generic field to an object.
// Should be used if generic type resolves to struct/value at runtime, otherwise use DYN_WriteInstanceFieldFn.
// params:
// - dstObj - destination object (can be box of generic struct/value)
// - dstField - address of the field inside dstObj
// - srcObj - source box-object of generic struct/value
// - size - size of the generic value
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_WriteGenericFieldFn)(DYN_ObjRef dstObj, uintptr_t dstField, DYN_ObjRef srcObj, size_t size);

// Read reference from array.
// params:
// - source - RawArray object containing references
// - index - index of the element to read
// return: object reference stored in the array at the specified index
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef DYN_ObjRef (*DYN_GetArrayRefElementFn)(DYN_ObjRef source, uint64_t index);

// Write reference to array.
// params:
// - source - RawArray object containing references
// - index - index of the element to write
// - newValue - object reference to store
// Notes:
// This method will be invoked by interpreter as a part of interpretation loop.
typedef void (*DYN_SetArrayRefElementFn)(DYN_ObjRef destination, uint64_t index, DYN_ObjRef newValue);

// Get ThreadLocalData.
typedef DYN_ThreadLocalData (*DYN_GetThreadLocalDataFn)();

// Creates and schedules a new Cangjie thread that executes a managed Future task.
// The new cjThread startup payload keeps `future` as a GC-visible object reference.
// When the cjThread starts, runtime prepares managed execution and invokes `execute`
// with the future object and its type info as managed arguments.
// params:
// - execute - managed-call entry pointer for Future.execute. Must be non-null.
// - future - Future object passed to `execute` and used for task result/completion.
//            Must be a non-null valid object reference.
// - scheduler - target scheduler handle, or null to use the current runtime scheduler.
// return: opaque cjThread handle for the created thread, or null if creation or scheduling fails.
typedef DYN_CJThreadHandle (*DYN_NewCJThreadFn)(void* execute, DYN_ObjRef future, void* scheduler);

// Returns non-zero if the GC is in an "active" phase.
// In active phase fast-path write barriers can`t be used.
typedef int (*DYN_IsActiveGcPhaseFn)(DYN_ThreadLocalData);

// Runtime stack-growth entry used by interpreter-owned transition/prologue stubs.
// `DYN_CJNativeInterface::stackGrowStub` is initialized by runtime with
// `CJ_MCC_StackGrowStub`, an architecture-specific assembly stub. It is intended
// to be called only after a transition/prologue stack-limit check has failed,
// while the caller frame is still materialized and visible for runtime unwinding.
// No C parameters are declared here because the actual call ABI is defined by the
// assembly stub for each architecture. The caller must pass the required stack
// size in the architecture-specific scratch register consumed by the stub (for
// example, `rax` on x86_64 and `x9` on AArch64). The caller must also keep a
// regular frame record/return address so the stub can pass the frame base,
// required size, and call-site PC to runtime stack-growth code.
// Behavior:
// - saves and restores caller general-purpose and vector registers, while
//   refreshing the managed thread-local-data register from runtime after stack
//   movement;
// - updates runtime unwind context, grows the current cjThread stack when
//   possible, fixes stack-resident pointers and derived pointers using stack maps
//   and interpreter frame-expansion visitors, moves stack frames by the runtime
//   returned stack offset, frees the old stack, and refreshes thread-local data;
// - if stack growth cannot be performed, leaves a pending StackOverflowError in
//   runtime exception state and returns to the caller.
// Before calling this stub, transition code must initialize any callee-saved
// register slots that stack-map based pointer adjustment may inspect. After the
// call returns, the caller should check runtime pending-exception state and route
// StackOverflowError to the appropriate exception-handling path.
typedef void (*DYN_StackGrowStubFn)();

// I2N (interpreter-to-native) entry stub.
// This function points to an architecture-specific assembly stub used by the
// interpreter to invoke native code while preserving managed thread and stack in safe state.
// Assembly stub expects following arguments:
// params:
// - 5-th architecture-specific ABI integer argument - address of the native function to call.
// - 6-th architecture-specific ABI integer argument - current thread local data of the calling interpreter thread.
// return:
// - return value produced by the native callee using architecture-specific ABI.
// Notes:
// - The function can be null on platforms that do not provide an I2N stub.
// - The concrete register/stack mapping is architecture-dependent and defined by the corresponding assembly
// implementation.
typedef void (*DYN_I2NStubFn)();

// Retrieves the current ExceptionWrapper.
// return: pointer to ExceptionWrapper
typedef DYN_ExceptionWrapper (*DYN_GetExceptionWrapperFn)();

// Get PC of function which caught exception.
// Can be used as return address for interpreter landing pad.
typedef uintptr_t (*DYN_GetCurrentCatchFunctionPcFn)();

// Begins exception catch block using the provided ExceptionWrapper.
// params:
// - exceptionWrapper - current exception wrapper
// return: exception object
typedef DYN_ObjRef (*DYN_PostThrowExceptionFn)(DYN_ExceptionWrapper exceptionWrapper);

// Native logger function. E.g. hilog can be used to log events in interpreter on OHOS devices.
// params:
// - tag - log tag
// - message - log message
typedef void (*DYN_NativeLoggerFn)(int logLevel, char* tag, char* message);

// endregion CJNative interface

// region Interfaces

// Collection of callbacks implemented by interpreter.
struct INT_InterpreterInterface {
    // current supported version is INT_INTERPRETER_INTERFACE_VERSION
    int64_t version;

    size_t cjThreadSpecificDataSize;

    uintptr_t c2iStubStartAddr;
    uintptr_t c2iStubEndAddr;

    uintptr_t i2iAdapterStartAddr;
    uintptr_t i2iAdapterEndAddr;

    INT_IterateFramesWithStateFn iterateFramesWithState;
    INT_VisitFrameRootsExpansionFn visitFrameRootsExpansion;
    INT_VisitFrameRootsMarkingFn visitFrameRootsMarking;
    INT_VisitFrameRootsAdjustingFn visitFrameRootsAdjusting;
    INT_VisitGlobalRootsFn visitGlobalRoots;

    INT_CJThreadOnStartFn cjThreadOnStart;
    INT_CJThreadOnDestroyFn cjThreadOnDestroy;

    INT_GetFrameSize getFrameSize;
    INT_FrameDescProviderFn frameDescProvider;
    INT_FrameInfoProviderFn frameInfoProvider;
    INT_LandingPadFn landingPad;
};

// Collection of callbacks implemented by CJNative.
struct DYN_CJNativeInterface {
    // current supported version is DYN_CJNATIVE_INTERFACE_VERSION
    int64_t version;

    void* appLibHandle;
    size_t carrierSpecificOffset;
    size_t cjThreadSpecificOffset;
    DYN_NewCJThreadFn newCJThread;

    DYN_TypeInfoProviderFn typeInfo;
    DYN_TypeTemplateFn typeTemplate;
    DYN_GetOrCreateTypeInfoFn getOrCreateTypeInfo;
    DYN_GetInstanceSizeFn getInstanceSize;
    DYN_GetMTableFn getMTable;
    DYN_GetMethodOuterTIFn getMethodOuterTI;
    DYN_UpdateVMTFn updateVMT;
    DYN_GetTypeInfoUUIDFn getTypeInfoUUID;

    DYN_ObjAllocFn objectAlloc;
    DYN_ArrayAllocFn arrayAlloc;
    DYN_SafePointFn safePoint;
    DYN_IsPendingSafePointFn isPendingSafePoint;

    DYN_ThrowExceptionFn throwException;
    DYN_ThrowOOMFn throwOom;
    DYN_GetPendingExceptionFn getPendingException;
    DYN_GetAndClearPendingExceptionFn getAndClearPendingException;
    DYN_GetExceptionWrapperFn getExceptionWrapper;
    DYN_PostThrowExceptionFn postThrowException;
    DYN_GetCurrentCatchFunctionPcFn getCurrentCatchFunctionPc;

    DYN_InstanceOfFn instanceOf;
    DYN_IsSubTypeFn isSubType;

    DYN_VisitRootFromInterpreterFn visitRootFromInterpreter;
    DYN_VisitDerivedPtrFromInterpreterFn visitDerivedPtrFromInterpreter;

    DYN_ReadStaticFieldFn readStaticField;
    DYN_WriteStaticFieldFn writeStaticField;
    DYN_ReadInstanceFieldFn readInstanceField;
    DYN_WriteInstanceFieldFn writeInstanceField;

    DYN_ReadStructFieldFn readStructField;
    DYN_WriteStructFieldFn writeStructField;
    DYN_ReadStaticStructFieldFn readStaticStructField;
    DYN_WriteStaticStructFieldFn writeStaticStructField;

    DYN_ReadGenericFieldFn readGenericField;
    DYN_WriteGenericFieldFn writeGenericField;

    size_t arrayBodyOffset;
    DYN_GetArrayRefElementFn getArrayRefElement;
    DYN_SetArrayRefElementFn setArrayRefElement;

    DYN_GetThreadLocalDataFn getThreadLocalData;
    DYN_IsActiveGcPhaseFn isActiveGcPhase;
    DYN_StackGrowStubFn stackGrowStub;
    DYN_I2NStubFn i2nStub;

    DYN_NativeLoggerFn nativeLogger;
};

// Initalize interpreter and fill it`s interface.
// params:
// - interpreterInterface - [OUT] Pointer to `INT_InterpreterInterface` which filled by callee.
// - cjnativeInterface - Pointer to `DYN_CJNativeInterface`. Pointer owned by caller, callee should copy the content.
// - interpreterArgsCount - Number of interpreter arguments in `interpreterArgs`.
// - interpreterArgs - Interpreter arguments array (null-terminated).
//                     Pointer owned by caller, callee should copy the content.
// return: 0 on success.
typedef int (*INT_InitInterpreter)(struct INT_InterpreterInterface* interpreterInterface,
    struct DYN_CJNativeInterface* cjnativeInterface, int interpreterArgsCount, INT_InterpreterArgs interpreterArgs);

#ifdef __cplusplus
} // extern "C"
#endif // __cplusplus

// endregion Interfaces
#endif
