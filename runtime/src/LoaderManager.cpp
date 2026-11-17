// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifdef __OHOS__
#include <cstring>
#include <dlfcn.h>
#endif

#include "Base/ImmortalWrapper.h"
#include "Interpreter/Options.h"
#include "Loader/ILoader.h"
#include "LoaderManager.h"

namespace MapleRuntime {
bool LoaderManager::isReleased;
LoaderManager* LoaderManager::GetInstance()
{
    // Keep the process-wide singleton alive until process exit. Exit-time static
    // destruction can race with still-running CJ threads that lazily query
    // loader state during shutdown.
    static ImmortalWrapper<LoaderManager> loaderManager;
    return &*loaderManager;
}

LoaderManager::LoaderManager() noexcept
{
    isReleased = false;
    loader = ILoader::CreateLoader();
    loader->Init();
    initStatus.store(false, std::memory_order_relaxed);
}

LoaderManager::~LoaderManager() noexcept
{
    LOG(RTLOG_WARNING, "LoaderManager destructor invoked for %p, loader=%p.", this, loader);
    delete loader;
    loader = nullptr;
    isReleased = true;
}

ILoader* LoaderManager::GetLoader() const
{
    if (UNLIKELY(loader == nullptr)) {
        LOG(RTLOG_ERROR, "LoaderManager::GetLoader returns nullptr, this=%p, isReleased=%d, initStatus=%d.",
            this, static_cast<int>(isReleased), static_cast<int>(GetInitStatus()));
    }
    return loader;
}

TypeInfo* LoaderManager::FindTypeInfoFromLoadedFiles(const char* typeInfoName)
{
    return loader->FindTypeInfoFromLoadedFiles(typeInfoName);
}

TypeTemplate* LoaderManager::FindTypeTemplateFromLoadedFiles(const char* typeTemplateName)
{
    return loader->FindTypeTemplateFromLoadedFiles(typeTemplateName);
}

void LoaderManager::RecordTypeInfo(TypeInfo* ti)
{
    return loader->RecordTypeInfo(ti);
}

PackageInfo* LoaderManager::GetPackageInfoByName(const char* packageName)
{
    return loader->GetPackageInfo(packageName);
}

PackageInfo* LoaderManager::GetPackageInfoByPath(const char* path)
{
    return loader->GetPackageInfoByPath(path);
}

void LoaderManager::RemovePackageInfo(const char* path)
{
    return loader->RemovePackageInfo(path);
}

bool LoaderManager::FileHasLoaded(const char* path)
{
    return loader->FileHasLoaded(path);
}

bool LoaderManager::FileHasMultiPackage(const char* path)
{
    return loader->FileHasMultiPackage(path);
}

void LoaderManager::GetSubPackages(PackageInfo* packageInfo, std::vector<PackageInfo*> &subPackages)
{
    loader->GetSubPackages(packageInfo, subPackages);
}

U32 LoaderManager::GetNumOfInterface(TypeInfo* ti)
{
    return loader->GetNumOfInterface(ti);
}

TypeInfo* LoaderManager::GetInterface(TypeInfo* ti, U32 idx)
{
    return loader->GetInterface(ti, idx);
}

bool LoaderManager::GetInitStatus() const { return initStatus.load(std::memory_order_acquire); }

void LoaderManager::LoadFile(Uptr address)
{
    std::lock_guard<std::mutex> lck(loadedImgsMtx);
    CheckPackageCompatibility(address);
    // MRT_LibraryOnLoad can be invoked before runtime init
    if (GetInitStatus()) {
        RegisterLoadFile(address);
    } else {
        AddPreLoadedImageMetaAddr(address);
    }
}

void LoaderManager::UnloadFile(Uptr address)
{
    std::lock_guard<std::mutex> lck(loadedImgsMtx);
    // MRT_LibraryUnLoad can be invoked before runtime init
    if (GetInitStatus()) {
        UnregisterLoadFile(address);
    } else {
        RemovePreLoadedImageMetaAddr(address);
    }
}

void LoaderManager::Init()
{
    LoadPreLoadedImages();
#ifdef __OHOS__
    RegisterLoadFunc();
#endif
    initStatus.store(true, std::memory_order_relaxed);
}

void LoaderManager::Fini()
{
    loader->Fini();
    initStatus.store(false, std::memory_order_relaxed);
}

void* LoaderManager::LoadCJLibrary(const char* libName) const
{
    return loader->LoadCJLibrary(libName);
}

#ifdef INTERPRETER_ENABLED
void* LoaderManager::LoadInterpreter(const char* libName) const
{
    return loader->LoadInterpreter(libName);
}
#endif

int LoaderManager::UnLoadLibrary(const char* libName) const
{
    return loader->UnloadLibrary(libName);
}

Uptr LoaderManager::FindSymbol(const CString libName, const CString symbolName) const
{
    return loader->FindSymbol(libName, symbolName);
}

bool LoaderManager::LibInit(const char* libName) const
{
    return loader->LibInit(libName);
}

void LoaderManager::LoadPreLoadedImages()
{
    std::lock_guard<std::mutex> lck(loadedImgsMtx);
    for (auto it = preLoadedImages.rbegin(); it != preLoadedImages.rend(); it++) {
        RegisterLoadFile(*it);
    }
    preLoadedImages.clear();
}

void LoaderManager::RegisterLoadFile(Uptr address) const
{
    loader->RegisterLoadFile(address);
}

void LoaderManager::UnregisterLoadFile(Uptr address) const
{
    loader->UnregisterLoadFile(address);
}

void LoaderManager::AddPreLoadedImageMetaAddr(Uptr address)
{
    preLoadedImages.push_back(address);
}

void LoaderManager::RemovePreLoadedImageMetaAddr(Uptr address)
{
    for (auto it = preLoadedImages.begin(); it != preLoadedImages.end();) {
        if (*it == address) {
            it = preLoadedImages.erase(it);
        } else {
            ++it;
        }
    }
}

bool LoaderManager::CheckPackageCompatibility(Uptr address)
{
    return loader->CheckPackageCompatibility(loader->CreateFileRefFromAddr(address));
};

#ifdef __OHOS__
struct CJEnvMethods {
    void (*initCJAppNS)(void* path) = nullptr;
    void (*initCJSDKNS)(void* path) = nullptr;
    void (*initCJSysNS)(void* path) = nullptr;
    void (*initCJChipSDKNS)(void* path) = nullptr;
    bool (*startRuntime)() = nullptr;
    bool (*startUIScheduler)() = nullptr;
    void* (*loadCJModule)(const char* dllName) = nullptr;
    void* (*loadLibrary)(uint32_t kind, const char* dllName) = nullptr;
    void* (*getSymbol)(void* handle, const char* symbol) = nullptr;
    void* (*loadCJLibrary)(const char* dllName) = nullptr;
    bool (*startDebugger)() = nullptr;
    void (*registerCJUncaughtExceptionHandler)(void* uncaughtExceptionInfo) = nullptr;
    void (*setSanitizerKindRuntimeVersion)(void* kind) = nullptr;
    bool (*checkLoadCJLibrary)() = nullptr;
    void (*registerArkVMInRuntime)(unsigned long long arkVM) = nullptr;
    void (*registerStackInfoCallbacks)(void* uFunc) = nullptr;
    void (*setAppVersion)(void* version) = nullptr;
    void (*dumpHeapSnapshot)(int fd) = nullptr;
    void (*forceFullGC)() = nullptr;
};

bool IsCJRomSdkNamespace()
{
    Dl_namespace dlns;
    dlns_get(nullptr, &dlns);
    return strcmp(dlns.name, "cj_rom_sdk") == 0;
}

const char* GetCJEnvFile()
{
#ifdef __arm__
    return "/system/lib/platformsdk/libcj_environment.z.so";
#else
    return "/system/lib64/platformsdk/libcj_environment.z.so";
#endif
}

void* OpenCJEnvFile(const char* cjEnvFile)
{
    void* handle = dlopen(cjEnvFile, RTLD_NOW);
    if (handle == nullptr) {
        const char* error = dlerror();
        LOG(RTLOG_ERROR, "LoaderManager::RegisterLoadFunc: dlopen %s failed: %s",
            cjEnvFile, error != nullptr ? error : "no dynamic loader error");
    }
    return handle;
}

CJEnvMethods* CreateCJEnvMethods(void* handle)
{
    using GenEnvFunc = CJEnvMethods* (*)();
    const char* createEnvFuncMangledName = "_ZN4OHOS13CJEnvironment16CreateEnvMethodsEv";
    // This lookup owns its error report; discard errors from earlier lookups.
    (void)dlerror();
    void* getEnvFunc = dlsym(handle, createEnvFuncMangledName);
    if (getEnvFunc == nullptr) {
        const char* error = dlerror();
        LOG(RTLOG_ERROR, "LoaderManager::RegisterLoadFunc: dlsym %s failed: %s",
            createEnvFuncMangledName, error != nullptr ? error : "no dynamic loader error");
        return nullptr;
    }

    CJEnvMethods* envFuncs = reinterpret_cast<GenEnvFunc>(getEnvFunc)();
    if (envFuncs == nullptr) {
        LOG(RTLOG_ERROR, "LoaderManager::RegisterLoadFunc: envFuncs is nullptr\n");
    }
    return envFuncs;
}

bool TryGetLoadFunctions(CJEnvMethods* envFuncs, void*& loadCJLibraryFunc, void*& loadLibraryFunc)
{
    loadCJLibraryFunc = reinterpret_cast<void*>(envFuncs->loadCJLibrary);
    if (loadCJLibraryFunc == nullptr) {
        LOG(RTLOG_ERROR, "LoaderManager::RegisterLoadFunc: get loadCJLibraryFunc fail\n");
        return false;
    }

#ifdef INTERPRETER_ENABLED
    loadLibraryFunc = reinterpret_cast<void*>(envFuncs->loadLibrary);
    if (loadLibraryFunc == nullptr) {
        LOG(RTLOG_ERROR, "LoaderManager::RegisterLoadFunc: get loadLibraryFunc fail\n");
        return false;
    }
#else
    loadLibraryFunc = nullptr;
#endif
    return true;
}

// Due to the namespace isolation mechanism of ohos, the runtime has no
// permission to directly open the dynamic library on the application side.
// The runtime opens the dynamic library on the application side by using
// the dynamic loading interface on the default namespace.
void LoaderManager::RegisterLoadFunc()
{
    if (!IsCJRomSdkNamespace()) {
        return;
    }

    void* handle = OpenCJEnvFile(GetCJEnvFile());
    if (handle == nullptr) {
        return;
    }

    CJEnvMethods* envFuncs = CreateCJEnvMethods(handle);
    if (envFuncs == nullptr) {
        dlclose(handle);
        return;
    }

    void* loadCJLibraryFunc = nullptr;
    void* loadLibraryFunc = nullptr;
    if (!TryGetLoadFunctions(envFuncs, loadCJLibraryFunc, loadLibraryFunc)) {
        dlclose(handle);
        return;
    }

    loader->RegisterLoadFunc(loadCJLibraryFunc, loadLibraryFunc);
    dlclose(handle);
}
#endif

void LoaderManager::PreInitializePackage(Uptr address) { loader->TryThrowException(address); };
} // namespace MapleRuntime
