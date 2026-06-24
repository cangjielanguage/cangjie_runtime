/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#ifdef __android__
#include <sys/system_properties.h>
#endif
#ifdef __ohos__
#include <dlfcn.h>

#define TIMESERVICE_NDK "libtime_service_ndk.so"
#define NDK_NAME "OH_TimeService_GetTimeZone"
#endif

#define MAX_BUF_LENGTH 64

extern char* CJ_TIME_GetLocalTimeZoneProperty(void)
{
#ifdef __android__
    char buf[PROP_VALUE_MAX] = {0};
    int len = __system_property_get("persist.sys.timezone", buf);
    if (len <= 0) {
        return NULL;
    }
    return strdup(buf); // Need to free
#elif defined __ohos__
    void* timeNdk = dlopen(TIMESERVICE_NDK, RTLD_LAZY);
    if (timeNdk == NULL) {
        return NULL;
    }
    int (*getZoneFunc) (char*, uint32_t) = dlsym(timeNdk, NDK_NAME);
    if (getZoneFunc == NULL) {
        dlclose(timeNdk);
        return NULL;
    }
    char buf[MAX_BUF_LENGTH] = {0};
    int code = getZoneFunc(buf, MAX_BUF_LENGTH);
    dlclose(timeNdk);
    if (code != 0) {
        return NULL;
    }
    return strdup(buf);
#else
    return NULL;
#endif
}