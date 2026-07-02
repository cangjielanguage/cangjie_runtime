// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.

#ifndef MRT_SCHEDULE_BASE_H
#define MRT_SCHEDULE_BASE_H

#ifdef MRT_MACOS
#include <dispatch/dispatch.h>

struct Semaphore {
    dispatch_semaphore_t sem;
};

static inline int SemaphoreInit(struct Semaphore *sem, int pshared, unsigned value)
{
    (void)pshared;
    sem->sem = dispatch_semaphore_create(value);
    if (sem->sem == NULL) {
        return -1;
    }
    return 0;
}

static inline int SemaphoreWait(struct Semaphore *sem)
{
    dispatch_semaphore_wait(sem->sem, DISPATCH_TIME_FOREVER); // always succuess
    return 0;
}

static inline int SemaphoreWaitNoIntr(struct Semaphore *sem)
{
    dispatch_semaphore_wait(sem->sem, DISPATCH_TIME_FOREVER); // always succuess
    return 0;
}

static inline int SemaphorePost(struct Semaphore *sem)
{
    dispatch_semaphore_signal(sem->sem); // always succuess
    return 0;
}

/* Attention:Different from sem_destroy, dispatch_release can be released only when the number
 * of wait and post times is balanced. That is, no object is allowed to use it when it is
 * destroyed.
 **/
static inline int SemaphoreDestroy(struct Semaphore *sem)
{
    dispatch_release(sem->sem); // always succuess
    return 0;
}

struct CJthreadSpinLock {
    pthread_mutex_t lock;
};

static inline int PthreadSpinInit(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_init(&lock->lock, nullptr);
}

static inline int PthreadSpinLock(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_lock(&lock->lock);
}

static inline int PthreadSpinUnlock(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_unlock(&lock->lock);
}

static inline int PthreadSpinDestroy(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_destroy(&lock->lock);
}

#else
#include <semaphore.h>

struct Semaphore {
    sem_t sem;
};

static inline int SemaphoreInit(struct Semaphore *sem, int pshared, unsigned value)
{
    return sem_init(&sem->sem, pshared, value);
}

static inline int SemaphoreWait(struct Semaphore *sem)
{
    return sem_wait(&sem->sem);
}

static inline int SemaphoreWaitNoIntr(struct Semaphore *sem)
{
    int error;
    do {
        error = sem_wait(&(sem->sem));
    } while (error != 0 && errno == EINTR);
    return error;
}

static inline int SemaphorePost(struct Semaphore *sem)
{
    return sem_post(&sem->sem);
}

static inline int SemaphoreDestroy(struct Semaphore *sem)
{
    return sem_destroy(&sem->sem);
}

// Bionic's pthread_spin_init/lock/unlock/destroy/trylock are __INTRODUCED_IN(24)
// (Android 7.0 Nougat). API < 24 (e.g. API 23 = Android 6.0) lacks these symbols,
// so fall back to pthread_mutex_t to avoid link/load failure on low-API devices.
#if defined (__ANDROID__) && (!defined(__ANDROID_API__) || __ANDROID_API__ < 24)
struct CJthreadSpinLock {
    pthread_mutex_t lock;
};

static inline int PthreadSpinInit(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_init(&lock->lock, nullptr);
}

static inline int PthreadSpinLock(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_lock(&lock->lock);
}

static inline int PthreadSpinUnlock(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_unlock(&lock->lock);
}

static inline int PthreadSpinDestroy(struct CJthreadSpinLock *lock)
{
    return pthread_mutex_destroy(&lock->lock);
}
#else
struct CJthreadSpinLock {
    pthread_spinlock_t lock;
};

static inline int PthreadSpinInit(struct CJthreadSpinLock *lock)
{
    return pthread_spin_init(&lock->lock, PTHREAD_PROCESS_PRIVATE);
}

static inline int PthreadSpinLock(struct CJthreadSpinLock *lock)
{
    return pthread_spin_lock(&lock->lock);
}

static inline int PthreadSpinUnlock(struct CJthreadSpinLock *lock)
{
    return pthread_spin_unlock(&lock->lock);
}

static inline int PthreadSpinDestroy(struct CJthreadSpinLock *lock)
{
    return pthread_spin_destroy(&lock->lock);
}

#endif
#endif
#endif
