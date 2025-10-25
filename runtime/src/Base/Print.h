// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#ifndef PRINT_H
#define PRINT_H
#if (defined(__OHOS__) && (__OHOS__ == 1))
#include "hilog/log.h"


#ifdef LOG_DOMAIN
#undef LOG_DOMAIN
#endif
#ifdef LOG_TAG
#undef LOG_TAG
#endif

#define BASE_DOMAIN 0
#define LOG_DOMAIN (BASE_DOMAIN + 8)
#define LOG_TAG "CANGJIE-RUNTIME"
#endif

#if defined(__ANDROID__)
#include "android/log.h"
#ifdef LOG_TAG
#undef LOG_TAG
#endif
#define LOG_TAG "CANGJIE-RUNTIME"
#endif

#if defined (__IOS__)
#include <os/log.h>
#ifdef LOG_SUBSYSTEM
#undef LOG_SUBSYSTEM
#endif
#define LOG_SUBSYSTEM "CANGJIE"
#ifdef LOG_CATEGORY
#undef LOG_CATEGORY
#endif
#define LOG_CATEGORY "RUNTIME"
#endif

namespace MapleRuntime {
#if defined(__OHOS__) && (__OHOS__ == 1)
#define PRINT_INFO(...)                                           \
if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_INFO)) {       \
    OH_LOG_INFO(LOG_APP, ##__VA_ARGS__);                    \
}

#define PRINT_ERROR(...)                                           \
if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_ERROR)) {       \
    OH_LOG_ERROR(LOG_APP, __VA_ARGS__);                    \
}
#define PRINT_FATAL(...)                                           \
if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_FATAL)) {       \
    OH_LOG_FATAL(LOG_APP, __VA_ARGS__);                    \
}
#define PRINT_DEBUG(...)                                           \
if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_DEBUG)) {       \
    OH_LOG_DEBUG(LOG_APP, __VA_ARGS__);                    \
}
#define PRINT_WARN(...)                                           \
if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_WARN)) {       \
    OH_LOG_WARN(LOG_APP, __VA_ARGS__);                    \
}

#define PRINT_FATAL_IF(conf, ...) \
    do { \
        if (conf) { \
            if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_FATAL)) {       \
                OH_LOG_FATAL(LOG_APP, __VA_ARGS__);                    \
            } \
        } \
    } while (0)

#define PRINT_ERROR_RETURN_IF(conf, retValue, ...) \
    do { \
        if (conf) { \
            if (OH_LOG_IsLoggable(LOG_DOMAIN, LOG_TAG, LOG_ERROR)) {       \
                OH_LOG_ERROR(LOG_APP, __VA_ARGS__);                    \
            } \
            return retValue; \
        } \
    } while (0)

#elif defined (__ANDROID__)
#define PRINT_DEBUG(...)  __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__)
#define PRINT_INFO(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, ##__VA_ARGS__)
#define PRINT_WARN(...)  __android_log_print(ANDROID_LOG_WARN, LOG_TAG, __VA_ARGS__)
#define PRINT_ERROR(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define PRINT_FATAL(...)  __android_log_print(ANDROID_LOG_FATAL, LOG_TAG, __VA_ARGS__)

#define PRINT_ERROR_RETURN_IF(conf, retValue, ...) \
    do { \
        if (conf) { \
            __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__); \
            return retValue; \
        } \
    } while (0)

#define PRINT_FATAL_IF(conf, ...) \
    do { \
        if (conf) { \
            __android_log_print(ANDROID_LOG_FATAL, LOG_TAG, __VA_ARGS__); \
        } \
    } while (0)

#elif defined (__IOS__)
inline os_log_t GetOsLogger() {
    static os_log_t logger = os_log_create(LOG_SUBSYSTEM, LOG_CATEGORY);
    return logger;
}

#define PRINT_DEBUG(...) os_log_debug(GetOsLogger(), __VA_ARGS__)
#define PRINT_INFO(...) os_log_info(GetOsLogger(), __VA_ARGS__)
#define PRINT_WARN(...) os_log(GetOsLogger(), __VA_ARGS__)
#define PRINT_ERROR(...) os_log_error(GetOsLogger(), __VA_ARGS__)
#define PRINT_FATAL(...) os_log_fault(GetOsLogger(), __VA_ARGS__)

#define PRINT_ERROR_RETURN_IF(conf, retValue, ...) \
    do { \
        if (conf) { \
            os_log(GetOsLogger(), __VA_ARGS__); \
            return retValue; \
        } \
    } while (0)

#define PRINT_FATAL_IF(conf, ...) \
    do { \
        if (conf) { \
            os_log_fault(GetOsLogger(), __VA_ARGS__); \
        } \
    } while (0)

#else
#define PRINT_INFO(format...) fprintf(stdout, format)

#define PRINT_ERROR(format...) fprintf(stderr, format)
#define PRINT_ERROR_RETURN_IF(conf, retValue, format...) \
    do { \
        if (conf) { \
            PRINT_ERROR(format); \
            return retValue; \
        } \
    } while (0)

#define PRINT_FATAL(format...) \
    do { \
        fprintf(stderr, format); \
        std::abort(); \
    } while (0)

#define PRINT_FATAL_IF(conf, format...) \
    do { \
        if (conf) { \
            PRINT_FATAL(format); \
        } \
    } while (0)

#endif
}

#endif