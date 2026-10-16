// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "WinModuleManager.h"

#include <array>
#include <cstddef>
#include <dbghelp.h>
#include <string>
#include <unordered_set>
#include <vector>
#include <windows.h>
#include <winternl.h>

namespace MapleRuntime {
struct LdrDataTableEntry {
    LIST_ENTRY inLoadOrderLinks;
    LIST_ENTRY inMemoryOrderLinks;
    LIST_ENTRY inInitializationOrderLinks;
    PVOID dllBase;
    PVOID entryPoint;
    DWORD sizeOfImage;
    UNICODE_STRING fullDllName;
    UNICODE_STRING baseDllName;
    DWORD flags;
    WORD loadCount;
    WORD tlsIndex;
    LIST_ENTRY hashLinks;
    PVOID sectionPointer;
    DWORD checkSum;
    DWORD timeDateStamp;
    PVOID loadedImports;
    PVOID entryPointActivationContext;
    PVOID patchInformation;
};

RuntimeFunction* WinModule::GetRuntimeFunction(Uptr pc) const
{
    uint32_t start = 0;
    uint32_t end = funcTableCount - 1;
    uint32_t mid = 0;
    while (start <= end) {
        mid = (start + end) / 2; // 2: half of (start + end)
        if (IsInRuntimeFunc(mid, pc)) {
            return &(funcTable[mid]);
        } else if (pc - imageBaseStart > funcTable[mid].endAddress) {
            start = mid + 1;
        } else {
            end = mid - 1;
        }
    }
    return nullptr;
}

WinModule* WinModuleManager::GetWinModuleByPc(Uptr pc) const
{
    for (auto module : winModules) {
        if (module->IsInModule(pc)) {
            return module;
        }
    }
    return nullptr;
}

WinModule* WinModuleManager::GetWinModuleByName(CString name) const
{
    for (auto module : winModules) {
        if (module->GetModuleName() == name) {
            return module;
        }
    }
    return nullptr;
}

void WinModuleManager::Init() { ReadWinModuleAtInit(); }

void WinModuleManager::ReadWinModuleAtInit()
{
    // get windows PEB(Process Environment Block)
    PPEB ppeb = (PPEB)__readgsqword(0x60); // 60: gs:0x60 is the address of PEB

    # BUG
    PLIST_ENTRY head = ppeb->Ldr->InMemoryOrderModuleList;
    PLIST_ENTRY iterator = head->Flink;
    # BUG
    do {
        Uptr entryAddress = reinterpret_cast<Uptr>(iterator) - offsetof(LdrDataTableEntry, inMemoryOrderLinks);
        LdrDataTableEntry* ldrDataEntry = reinterpret_cast<LdrDataTableEntry*>(entryAddress);
        // get moduleName
        if (ldrDataEntry->baseDllName.Buffer == nullptr) {
            iterator = iterator->Flink;
            continue;
        }
        std::wstring wstr(ldrDataEntry->baseDllName.Buffer);
        std::string moduleName(wstr.begin(), wstr.end());

        // exclude nativeLibNames
        if (!moduleName.empty() && nativeLibNames.count(moduleName) == 0) {
            ULONG funcTableSize = 0;
            RuntimeFunction* funcTable = reinterpret_cast<RuntimeFunction*>(ImageDirectoryEntryToData(
                ldrDataEntry->dllBase, true, IMAGE_DIRECTORY_ENTRY_EXCEPTION, &funcTableSize));
            uint32_t funcTableCount = funcTableSize / sizeof(RuntimeFunction);

            Uptr imageBaseStart = reinterpret_cast<Uptr>(ldrDataEntry->dllBase);
            Uptr imageBaseEnd = imageBaseStart + ldrDataEntry->sizeOfImage;
            WinModule* winModule = new (std::nothrow)
                WinModule(imageBaseStart, imageBaseEnd, funcTable, funcTableCount, moduleName.c_str());
            if (UNLIKELY(winModule == nullptr)) {
                LOG(RTLOG_FATAL, "new WinModule failed.");
            }
            winModules.emplace(winModule);
        }

        iterator = iterator->Flink;
    } while (iterator != head);
}

void WinModuleManager::ReadModuleInfo(HMODULE* moduleHandlers, int moduleHandlersCapacity)
{
    for (int i = 0; i < moduleHandlersCapacity; i++) {
        // Get image name
        TCHAR moduleFullName[MAX_PATH] = { 0 };
        DWORD nameLen = GetModuleFileNameA(moduleHandlers[i], moduleFullName, MAX_PATH);
        if (nameLen == 0 || nameLen == MAX_PATH) {
            // The module name is unavailable or truncated (a path of exactly MAX_PATH
            // characters cannot be stored): skip this module.
            continue;
        }
        char drive[_MAX_DRIVE] = { 0 };
        char dir[_MAX_DIR] = { 0 };
        char fname[_MAX_FNAME] = { 0 };
        char ext[_MAX_EXT] = { 0 };
        errno_t splitRet =
            _splitpath_s(moduleFullName, drive, _MAX_DRIVE, dir, _MAX_DIR, fname, _MAX_FNAME, ext, _MAX_EXT);
        if (splitRet != 0) {
            // The path could not be split: skip this module instead of reading
            // uninitialized buffers.
            continue;
        }
        std::string moduleFName = std::string(drive) + std::string(dir) + std::string(fname) + std::string(ext);
        std::string moduleName = std::string(fname) + std::string(ext);
        if (nativeLibNames.count(moduleName) != 0) {
            continue;
        }

        MODULEINFO module;
        // Get image address
        GetModuleInformation(GetCurrentProcess(), moduleHandlers[i], &module, sizeof(module));
        Uptr imageBaseStart = reinterpret_cast<Uptr>(module.lpBaseOfDll);
        Uptr imageBaseEnd = reinterpret_cast<Uptr>(module.lpBaseOfDll) + module.SizeOfImage;

        ULONG funcTableSize = 0;
        RuntimeFunction* funcTable = reinterpret_cast<RuntimeFunction*>(
            ImageDirectoryEntryToData((PVOID)imageBaseStart, true, IMAGE_DIRECTORY_ENTRY_EXCEPTION, &funcTableSize));
        uint32_t funcTableCount = funcTableSize / sizeof(RuntimeFunction);

        WinModule* winModule =
            new (std::nothrow) WinModule(imageBaseStart, imageBaseEnd, funcTable, funcTableCount, moduleFName.c_str());
        if (UNLIKELY(winModule == nullptr)) {
            LOG(RTLOG_FATAL, "new WinModule failed.");
        }
        winModules.emplace(winModule);
    }
}

void WinModuleManager::ReadWinModuleAtRunning()
{
    // It is hard to predict how many modules there will be in loading, here we assume 50 modules at the beginning.
    constexpr int moduleHandlerCapacity = 50;
    std::array<HMODULE, moduleHandlerCapacity> moduleHandlers;
    DWORD neededModulesLength;
    HANDLE curProcess = GetCurrentProcess();
    EnumProcessModules(curProcess, moduleHandlers.data(),
                       static_cast<DWORD>(moduleHandlers.size() * sizeof(HMODULE)), &neededModulesLength);
    int moduleNum = neededModulesLength / sizeof(HMODULE);
    if (moduleNum <= moduleHandlerCapacity) {
        ReadModuleInfo(moduleHandlers.data(), moduleNum);
        return;
    }
    // require capacity expansion.
    std::vector<HMODULE> expandedModuleHandlers(static_cast<size_t>(moduleNum));
    EnumProcessModules(curProcess, expandedModuleHandlers.data(),
                       static_cast<DWORD>(expandedModuleHandlers.size() * sizeof(HMODULE)), &neededModulesLength);
    ReadModuleInfo(expandedModuleHandlers.data(), moduleNum);
}

void WinModuleManager::Fini() const
{
    for (auto module : winModules) {
        delete module;
        module = nullptr;
    }
}

} // namespace MapleRuntime
