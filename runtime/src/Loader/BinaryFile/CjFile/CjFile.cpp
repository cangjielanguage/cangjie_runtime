// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "CjFile.h"

#include "Base/Types.h"
#include "CjFileMeta.h"
#include "Common/TypeDef.h"
#include "Heap/Heap.h"
#include "Utils/Demangler.h"
namespace MapleRuntime {
void CJFile::RegisterFile() { LoadCJFileMeta(); }

void CJFile::UnregisterFile()
{
    // unregist gcroot
    Heap::GetHeap().UnregisterStaticRoots(cJFileMeta.gcRootsAddr, cJFileMeta.gcRootSize);
}

#if defined(_WIN64)
void CJFile::LoadWinCJFileMeta()
{
    Uptr begin = GetFileMetaAddr();
    CJFileHeader* header = reinterpret_cast<CJFileHeader*>(begin);
    // Init TablePtrs
    cJFileMetaEnd = cJFileMetaBegin + *header->cJFileSize;
    cJFileMeta.stackMapTbl.stackMapBasePtr = reinterpret_cast<void*>(*header->tables[STACK_MAP_TABLE].tableAddr);
    cJFileMeta.typeInfoTbl.typeInfoBasePtr = reinterpret_cast<TypeInfo*>(*header->tables[TYPE_INFO_TABLE].tableAddr);
    cJFileMeta.typeInfoTbl.typeInfoTotalSize = *header->tables[TYPE_INFO_TABLE].tableSize;
    cJFileMeta.funcDescTbl.funcDescBasePtr = reinterpret_cast<FuncDescRef>(*header->tables[FUNC_DESC_TABLE].tableAddr);
    cJFileMeta.globalInitFuncTbl.globalInitFuncTotalSize = *header->tables[GLOBAL_INIT_FUNC_TABLE].tableSize;
    cJFileMeta.globalInitFuncTbl.globalInitFuncBasePtr =
        reinterpret_cast<Uptr*>(*header->tables[GLOBAL_INIT_FUNC_TABLE].tableAddr);
    cJFileMeta.gcTibTbl.gcTibBasePtr = reinterpret_cast<void*>(*header->tables[GC_TIB_TABLE].tableAddr);
    cJFileMeta.extensionDataTbl.extensionDataTotalSize = *header->tables[EXTENSION_DATA_TABLE].tableSize;
    cJFileMeta.extensionDataTbl.extensionDataBasePtr =
        reinterpret_cast<ExtensionData*>(*header->tables[EXTENSION_DATA_TABLE].tableAddr);
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionTotalSize = *header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionBasePtr =
        reinterpret_cast<void*>(*header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableAddr);
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionTotalSize =
        *header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionBasePtr =
        reinterpret_cast<void*>(*header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableAddr);
    cJFileMeta.staticGITbl.staticGITotalSize = *header->tables[STATIC_GI_TABLE].tableSize;
    cJFileMeta.staticGITbl.staticGIBasePtr =
        reinterpret_cast<void*>(*header->tables[STATIC_GI_TABLE].tableAddr);
    cJFileMeta.gcFlagsTbl.withSafepoint =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->withSafepoint;
    cJFileMeta.gcFlagsTbl.withBarrier =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->withBarrier;
    cJFileMeta.gcFlagsTbl.hasStackPointerMap =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->hasStackPointerMap;
    cJFileMeta.gcRootsAddr = *header->tables[GC_ROOT_TABLE].tableAddr;
    cJFileMeta.gcRootSize = *header->tables[GC_ROOT_TABLE].tableSize / sizeof(U64);
    cJFileMeta.packageInfoTbl.packageInfoBasePtr = *header->tables[PACKINFO_TABLE].tableAddr;
    cJFileMeta.packageInfoTbl.packageInfoTotalSize = *header->tables[PACKINFO_TABLE].tableSize;
    cJFileMeta.typeExtTbl.typeExtBasePtr = reinterpret_cast<TypeExt*>(header->tables[TYPE_EXT_TABLE].tableAddr);
    cJFileMeta.typeExtTbl.typeExtTotalSize = *header->tables[TYPE_EXT_TABLE].tableSize;
    Heap::GetHeap().RegisterStaticRoots(cJFileMeta.gcRootsAddr, cJFileMeta.gcRootSize);
}
#elif defined(__APPLE__)
void CJFile::LoadMacCJFileMeta()
{
    Uptr begin = GetFileMetaAddr();
    CJFileHeader* header = reinterpret_cast<CJFileHeader*>(begin);
    // Init TablePtrs
    cJFileMetaEnd = cJFileMetaBegin + *header->cJFileSize;
    cJFileMeta.stackMapTbl.stackMapBasePtr = reinterpret_cast<void*>(*header->tables[STACK_MAP_TABLE].tableAddr);
    cJFileMeta.typeInfoTbl.typeInfoBasePtr = reinterpret_cast<TypeInfo*>(*header->tables[TYPE_INFO_TABLE].tableAddr);
    cJFileMeta.typeInfoTbl.typeInfoTotalSize = *header->tables[TYPE_INFO_TABLE].tableSize;
    cJFileMeta.funcDescTbl.funcDescBasePtr = reinterpret_cast<FuncDescRef>(*header->tables[FUNC_DESC_TABLE].tableAddr);
    cJFileMeta.globalInitFuncTbl.globalInitFuncTotalSize = *header->tables[GLOBAL_INIT_FUNC_TABLE].tableSize;
    cJFileMeta.globalInitFuncTbl.globalInitFuncBasePtr =
        reinterpret_cast<Uptr*>(*header->tables[GLOBAL_INIT_FUNC_TABLE].tableAddr);
    cJFileMeta.gcTibTbl.gcTibBasePtr = reinterpret_cast<void*>(*header->tables[GC_TIB_TABLE].tableAddr);
    cJFileMeta.extensionDataTbl.extensionDataTotalSize = *header->tables[EXTENSION_DATA_TABLE].tableSize;
    cJFileMeta.extensionDataTbl.extensionDataBasePtr =
        reinterpret_cast<ExtensionData*>(*header->tables[EXTENSION_DATA_TABLE].tableAddr);
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionTotalSize = *header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionBasePtr =
        reinterpret_cast<void*>(*header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableAddr);
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionTotalSize =
        *header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionBasePtr =
        reinterpret_cast<void*>(*header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableAddr);
    cJFileMeta.staticGITbl.staticGITotalSize = *header->tables[STATIC_GI_TABLE].tableSize;
    cJFileMeta.staticGITbl.staticGIBasePtr =
        reinterpret_cast<void*>(*header->tables[STATIC_GI_TABLE].tableAddr);
    cJFileMeta.gcFlagsTbl.withSafepoint =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->withSafepoint;
    cJFileMeta.gcFlagsTbl.withBarrier =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->withBarrier;
    cJFileMeta.gcFlagsTbl.hasStackPointerMap =
        reinterpret_cast<CJGCFlagsTable*>(*header->tables[GC_FLAGS_TABLE].tableAddr)->hasStackPointerMap;
    cJFileMeta.gcRootsAddr = *header->tables[GC_ROOT_TABLE].tableAddr;
    cJFileMeta.gcRootSize = *header->tables[GC_ROOT_TABLE].tableSize / sizeof(U64);
    cJFileMeta.packageInfoTbl.packageInfoBasePtr = *header->tables[PACKINFO_TABLE].tableAddr;
    cJFileMeta.packageInfoTbl.packageInfoTotalSize = *header->tables[PACKINFO_TABLE].tableSize;
    cJFileMeta.typeExtTbl.typeExtBasePtr = reinterpret_cast<TypeExt*>(*header->tables[TYPE_EXT_TABLE].tableAddr);
    cJFileMeta.typeExtTbl.typeExtTotalSize = *header->tables[TYPE_EXT_TABLE].tableSize;
    Heap::GetHeap().RegisterStaticRoots(cJFileMeta.gcRootsAddr, cJFileMeta.gcRootSize);
}
#else
void CJFile::LoadLinuxCJFileMeta()
{
    Uptr begin = GetFileMetaAddr();
    CJFileHeader* header = reinterpret_cast<CJFileHeader*>(begin);

    // Init TablePtrs
    cJFileMetaEnd = cJFileMetaBegin + header->cJFileSize;
    cJFileMeta.stackMapTbl.stackMapBasePtr =
        reinterpret_cast<void*>(begin + header->tables[STACK_MAP_TABLE].tableOffset);
    cJFileMeta.typeInfoTbl.typeInfoBasePtr =
        reinterpret_cast<TypeInfo*>(begin + header->tables[TYPE_INFO_TABLE].tableOffset);
    cJFileMeta.typeInfoTbl.typeInfoTotalSize = header->tables[TYPE_INFO_TABLE].tableSize;
    cJFileMeta.funcDescTbl.funcDescBasePtr =
        reinterpret_cast<FuncDescRef>(begin + header->tables[FUNC_DESC_TABLE].tableOffset);
    cJFileMeta.globalInitFuncTbl.globalInitFuncTotalSize = header->tables[GLOBAL_INIT_FUNC_TABLE].tableSize;
    cJFileMeta.globalInitFuncTbl.globalInitFuncBasePtr =
        reinterpret_cast<Uptr*>(begin + header->tables[GLOBAL_INIT_FUNC_TABLE].tableOffset);
    cJFileMeta.gcTibTbl.gcTibBasePtr = reinterpret_cast<void*>(begin + header->tables[GC_TIB_TABLE].tableOffset);
    cJFileMeta.extensionDataTbl.extensionDataTotalSize = header->tables[EXTENSION_DATA_TABLE].tableSize;
    cJFileMeta.extensionDataTbl.extensionDataBasePtr =
        reinterpret_cast<ExtensionData*>(begin + header->tables[EXTENSION_DATA_TABLE].tableOffset);
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionTotalSize = header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.innerTyExtensionTbl.innerTyExtensionBasePtr =
        reinterpret_cast<void*>(begin + header->tables[INNER_TYPE_EXTENSIONS_TABLE].tableOffset);
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionTotalSize =
        header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableSize;
    cJFileMeta.outerTyExtensionTbl.outerTyExtensionBasePtr =
        reinterpret_cast<void*>(begin + header->tables[OUTER_TYPE_EXTENSIONS_TABLE].tableOffset);
    cJFileMeta.staticGITbl.staticGITotalSize = header->tables[STATIC_GI_TABLE].tableSize;
    cJFileMeta.staticGITbl.staticGIBasePtr =
        reinterpret_cast<void*>(begin + header->tables[STATIC_GI_TABLE].tableOffset);
    cJFileMeta.gcFlagsTbl.withSafepoint =
        reinterpret_cast<CJGCFlagsTable*>(begin + header->tables[GC_FLAGS_TABLE].tableOffset)->withSafepoint;
    cJFileMeta.gcFlagsTbl.withBarrier =
        reinterpret_cast<CJGCFlagsTable*>(begin + header->tables[GC_FLAGS_TABLE].tableOffset)->withBarrier;
    cJFileMeta.gcFlagsTbl.hasStackPointerMap =
        reinterpret_cast<CJGCFlagsTable*>(begin + header->tables[GC_FLAGS_TABLE].tableOffset)->hasStackPointerMap;
    cJFileMeta.gcRootsAddr = begin + header->tables[GC_ROOT_TABLE].tableOffset;
    cJFileMeta.gcRootSize = header->tables[GC_ROOT_TABLE].tableSize / sizeof(ArchUInt);
    cJFileMeta.packageInfoTbl.packageInfoBasePtr = begin + header->tables[PACKINFO_TABLE].tableOffset;
    cJFileMeta.packageInfoTbl.packageInfoTotalSize = header->tables[PACKINFO_TABLE].tableSize;
    cJFileMeta.typeExtTbl.typeExtBasePtr =
        reinterpret_cast<TypeExt*>(begin + header->tables[TYPE_EXT_TABLE].tableOffset);
    cJFileMeta.typeExtTbl.typeExtTotalSize = header->tables[TYPE_EXT_TABLE].tableSize;
    Heap::GetHeap().RegisterStaticRoots(cJFileMeta.gcRootsAddr, cJFileMeta.gcRootSize);
}
#endif

void CJFile::LoadCJFileMeta()
{
#if defined(_WIN64)
    LoadWinCJFileMeta();
#elif defined(__APPLE__)
    LoadMacCJFileMeta();
#else
    LoadLinuxCJFileMeta();
#endif
    if (Heap::GetHeap().IsGCEnabled()) {
        if (cJFileMeta.gcFlagsTbl.withSafepoint != 1 || cJFileMeta.gcFlagsTbl.withBarrier != 1) {
            LOG(RTLOG_FATAL, "no safepoint or barrier defined in file %s \n", GetBaseName().Str());
        }
    }
    if (CangjieRuntime::stackGrowConfig == StackGrowConfig::UNDEF) {
        if (cJFileMeta.gcFlagsTbl.hasStackPointerMap == 0) {
            CangjieRuntime::stackGrowConfig = StackGrowConfig::STACK_GROW_OFF;
        } else {
            CangjieRuntime::stackGrowConfig = StackGrowConfig::STACK_GROW_ON;
        }
    } else {
        if ((cJFileMeta.gcFlagsTbl.hasStackPointerMap == 0 &&
                CangjieRuntime::stackGrowConfig != StackGrowConfig::STACK_GROW_OFF) ||
            (cJFileMeta.gcFlagsTbl.hasStackPointerMap == 1 &&
                CangjieRuntime::stackGrowConfig != StackGrowConfig::STACK_GROW_ON)) {
            LOG(RTLOG_FATAL,
                "The stackmap config is inconsistent for file %s: hasStackPointerMap: %u, runtime stackGrowConfig: %u",
                GetBaseName().Str(), static_cast<unsigned>(cJFileMeta.gcFlagsTbl.hasStackPointerMap),
                static_cast<unsigned>(CangjieRuntime::stackGrowConfig));
        }
    }
}

Uptr CJFile::GetFileMetaAddr() const { return cJFileMetaBegin; }

const CJFileMeta& CJFile::GetCJFileMeta() const { return cJFileMeta; }

bool CJFile::IsAddrInCJFile(Uptr addr) const { return cJFileMetaBegin <= addr && addr < cJFileMetaEnd; }

void CJFile::GetGlobalInitFunc(std::vector<Uptr> &globalInitFuncs) const
{
    CString globalInitFuncName = "_CGP";
    const CJFileMeta& cFileMeta = GetCJFileMeta();
    Uptr* globalInitPtr = cFileMeta.globalInitFuncTbl.globalInitFuncBasePtr;
    size_t sectionSize = cFileMeta.globalInitFuncTbl.globalInitFuncTotalSize;
#ifdef __APPLE__
    size_t offset = 0;
    while (offset < sectionSize) {
        uint8_t* funcPtrField = reinterpret_cast<uint8_t*>(globalInitPtr) + offset;
        offset += sizeof(void*);
        char* funcNamePtr = reinterpret_cast<char*>(globalInitPtr) + offset;
        offset += strlen(funcNamePtr) + 1; // 1: '\0\' takes one charactor length.
        offset = AlignUp(offset, static_cast<size_t>(8)); // 8: apple xcode needs aligment.
        CString funcName(funcNamePtr);
        if (funcName.Find(globalInitFuncName.Str()) != -1) {
            Uptr globalInitFunc = *reinterpret_cast<Uptr*>(funcPtrField);
            globalInitFuncs.emplace_back(globalInitFunc);
        }
    }
#else
    U32 cnt = sectionSize / sizeof(Uptr);
    for (U32 i = 0; i < cnt; ++i) {
        auto func = reinterpret_cast<Uptr>(*(globalInitPtr + i));
        CHECK_DETAIL(func != 0, "global init func could not be null");
        globalInitFuncs.emplace_back(func);
    }
#endif
}

Uptr CJFile::GetPackageInfoBase()
{
    return cJFileMeta.packageInfoTbl.packageInfoBasePtr;
}

U32 CJFile::GetPackageInfoTotalSize()
{
    return cJFileMeta.packageInfoTbl.packageInfoTotalSize;
}

Uptr CJFile::GetExtensionDataBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.extensionDataTbl.extensionDataBasePtr);
}

U32 CJFile::GetExtensionDataSize()
{
    return cJFileMeta.extensionDataTbl.extensionDataTotalSize;
}

Uptr CJFile::GetInnerTypeExtensionsBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.innerTyExtensionTbl.innerTyExtensionBasePtr);
}

U32 CJFile::GetInnerTypeExtensionsSize() { return cJFileMeta.innerTyExtensionTbl.innerTyExtensionTotalSize; }

Uptr CJFile::GetOuterTypeExtensionsBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.outerTyExtensionTbl.outerTyExtensionBasePtr);
}

U32 CJFile::GetOuterTypeExtensionsSize() { return cJFileMeta.outerTyExtensionTbl.outerTyExtensionTotalSize; }

Uptr CJFile::GetStaticGIBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.staticGITbl.staticGIBasePtr);
}

U32 CJFile::GetStaticGISize()
{
    return cJFileMeta.staticGITbl.staticGITotalSize;
}

Uptr CJFile::GetTypeInfoBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.typeInfoTbl.typeInfoBasePtr);
}

U32 CJFile::GetTypeInfoTotalSize()
{
    return cJFileMeta.typeInfoTbl.typeInfoTotalSize;
}

Uptr CJFile::GetTypeExtBase()
{
    return reinterpret_cast<Uptr>(cJFileMeta.typeExtTbl.typeExtBasePtr);
}

U32 CJFile::GetTypeExtTotalSize()
{
    return cJFileMeta.typeExtTbl.typeExtTotalSize;
}

CString CJFile::GetSDKVersion() const
{
    Uptr begin = GetFileMetaAddr();
    CJFileHeader* header = reinterpret_cast<CJFileHeader*>(begin);
#if defined(__APPLE__)
    return CString(reinterpret_cast<char*>(*reinterpret_cast<U64*>(*header->cJSDKVersionPtr)));
#elif defined(_WIN64)
    return CString(reinterpret_cast<char*>(*reinterpret_cast<U64*>(*header->cJSDKVersionPtr)));
#else
    return CString(reinterpret_cast<char*>(*reinterpret_cast<Uptr*>(begin + header->cJSDKVersionOffset)));
#endif
}
} // namespace MapleRuntime
