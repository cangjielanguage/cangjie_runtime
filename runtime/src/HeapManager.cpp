// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "HeapManager.h"

#include "Heap/Allocator/LocalObjectAllocator.h"
#include "Heap/Allocator/RegionSpace.h"
#include "Heap/Heap.h"
#include "ExceptionManager.inline.h"
#include "Mutator/Mutator.h"

namespace MapleRuntime {
RegionSpace* HeapManager::regionSpace = nullptr;
LocalObjectAllocator* HeapManager::localObjectAllocator = nullptr;

HeapManager::HeapManager() {}

MAddress HeapManager::Allocate(size_t allocSize, AllocType allocType)
{
    return Heap::GetHeap().Allocate(allocSize, allocType);
}

MAddress HeapManager::AllocateLocal(size_t allocSize)
{
    Mutator* mutator = Mutator::GetMutator();
    CHECK_DETAIL(regionSpace != nullptr && localObjectAllocator != nullptr && mutator != nullptr,
                 "cannot allocate local object: regionSpace %p, localObjectAllocator %p, mutator %p",
                 regionSpace, localObjectAllocator, mutator);

    size_t size = RegionSpace::ToAllocSize(allocSize);
    MAddress internalAddr = localObjectAllocator->Allocate(*mutator, size);
    if (UNLIKELY(internalAddr == 0) && !ExceptionManager::HasPendingException()) {
        ExceptionManager::OutOfMemory();
    }
    return internalAddr;
}

void HeapManager::Init(const HeapParam& param)
{
    Heap::GetHeap().Init(param);
    regionSpace = &reinterpret_cast<RegionSpace&>(Heap::GetHeap().GetAllocator());
    localObjectAllocator = &regionSpace->GetLocalObjectAllocator();
}

void HeapManager::Fini()
{
    localObjectAllocator = nullptr;
    regionSpace = nullptr;
    Heap::GetHeap().Fini();
}
} // namespace MapleRuntime
