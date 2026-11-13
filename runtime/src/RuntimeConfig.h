// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_RUNTIME_CONFIG_H
#define MRT_RUNTIME_CONFIG_H

#include <cstddef>
#include <cstdint>

#include "Cangjie.h"
#include "os/Loader.h"

#ifdef __cplusplus
namespace MapleRuntime {
extern "C" {
#endif

enum LibraryKind {
    SYSTEM,
    SDK,
    APP,
};

struct BinLoadApi {
    void* (*binLoadLib)(LibraryKind, const char*);
    void* (*binLoad)(const char*);
    int (*binUnload)(void*);
    int (*getBinaryInfoFromAddress)(const void*, Os::Loader::BinaryInfo*);
    void* (*getBinHandle)(const char*);
    void* (*findSymbol)(void*, const char* symbolName);
    BinLoadApi()
        : binLoadLib(nullptr),
          binLoad(nullptr),
          binUnload(nullptr),
          getBinaryInfoFromAddress(nullptr),
          getBinHandle(nullptr),
          findSymbol(nullptr)
    {
    }
};

MRT_EXPORT uintptr_t MRT_StopGCWork();
MRT_EXPORT uintptr_t MRT_GetThreadLocalData();
MRT_EXPORT void MRT_VisitorCaller(void* argPtr, void* handle);
MRT_EXPORT void MRT_DumpLog(const char* message);
uintptr_t MRT_GetSafepointProtectedPage();
uintptr_t MRT_CreateMutator();
uintptr_t MRT_TransitMutatorToExit();
#if defined(__APPLE__) && defined(__aarch64__)
void* ExecuteCangjieStub(void*, void*, void*, void*, void*, void*);
void* ApplyCangjieMethodStub(void*, void*, void*, void*, void*);
float ApplyCangjieMethodStubFloat32(void*, void*, void*, void*);
double ApplyCangjieMethodStubFloat64(void*, void*, void*, void*);
bool InitCJLibraryStub(void*);
#ifdef __OHOS__
MRT_EXPORT void* CJ_MRT_ARKTS_CreateEngineStub();
#endif
#else
void* ExecuteCangjieStub(...);
bool InitCJLibraryStub(...);
void* ApplyCangjieMethodStub(...);
float ApplyCangjieMethodStubFloat32(...);
double ApplyCangjieMethodStubFloat64(...);
#endif
#if defined(MRT_DEBUG) && (MRT_DEBUG == 1)
void MRT_DumpAllStackTrace();
#endif

MRT_EXPORT bool MRT_CJLibInit(const char* libName);
MRT_EXPORT int LoadCJLibraryWithInit(const char* libName);
MRT_EXPORT int MRT_IsLoadedFile(const char* libName);
#ifdef __cplusplus
}
}
#endif
#endif // MRT_RUNTIME_CONFIG_H
