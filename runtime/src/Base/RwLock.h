// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef MRT_RWLOCK_H
#define MRT_RWLOCK_H
#include <atomic>
#include <pthread.h>
#include "Log.h"

namespace MapleRuntime {
class RwLock {
public:
    void LockRead()
    {
        int count = lockCount.load(std::memory_order_acquire);
        do {
            while (count == WRITE_LOCKED) {
                sched_yield();
                count = lockCount.load(std::memory_order_acquire);
            }
        } while (!lockCount.compare_exchange_weak(count, count + 1, std::memory_order_acq_rel,
                                                 std::memory_order_relaxed));
    }

    void LockWrite()
    {
        for (int count = 0; !lockCount.compare_exchange_weak(count, WRITE_LOCKED, std::memory_order_acq_rel,
                                                             std::memory_order_relaxed);
             count = 0) {
            sched_yield();
        }
    }

    bool TryLockWrite()
    {
        int count = 0;
        if (lockCount.compare_exchange_weak(count, WRITE_LOCKED, std::memory_order_acq_rel,
                                            std::memory_order_relaxed)) {
            return true;
        }
        return false;
    }

    bool TryLockRead()
    {
        int count = lockCount.load(std::memory_order_acquire);
        do {
            if (count == WRITE_LOCKED) {
                return false;
            }
        } while (!lockCount.compare_exchange_weak(count, count + 1, std::memory_order_acq_rel,
                                                 std::memory_order_relaxed));
        return true;
    }

    void UnlockRead()
    {
        int count = lockCount.fetch_sub(1);
        if (count < 0) {
            std::abort();
        }
    }

    void UnlockWrite()
    {
        CHECK(lockCount.load() == WRITE_LOCKED);
        lockCount.store(0, std::memory_order_release);
    }

private:
    // 0: unlocked
    // -1: write locked
    // inc 1 for each read lock
    static constexpr int WRITE_LOCKED = -1;
    std::atomic<int> lockCount{ 0 };
};
} // namespace MapleRuntime
#endif // MRT_SPINLOCK_H
