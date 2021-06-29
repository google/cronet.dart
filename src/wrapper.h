// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef WRAPPER_H_
#define WRAPPER_H_

#include "../third_party/cronet/cronet.idl_c.h"
#include "../third_party/dart-sdk/dart_api_dl.h"

#include "wrapper_export.h"

#include <stdbool.h>

#ifdef __cplusplus

extern "C" {
#endif

#include <stdint.h>

DART_EXPORT intptr_t InitDartApiDL(void *data);
DART_EXPORT void InitCronetApi(
    Cronet_RESULT (*Cronet_Engine_Shutdown)(Cronet_EnginePtr),
    void (*Cronet_Engine_Destroy)(Cronet_EnginePtr),
    Cronet_BufferPtr (*Cronet_Buffer_Create)(void),
    void (*Cronet_Buffer_InitWithAlloc)(Cronet_BufferPtr, uint64_t),
    Cronet_UrlRequestCallbackPtr (*Cronet_UrlRequestCallback_CreateWith)(
        Cronet_UrlRequestCallback_OnRedirectReceivedFunc,
        Cronet_UrlRequestCallback_OnResponseStartedFunc,
        Cronet_UrlRequestCallback_OnReadCompletedFunc,
        Cronet_UrlRequestCallback_OnSucceededFunc,
        Cronet_UrlRequestCallback_OnFailedFunc,
        Cronet_UrlRequestCallback_OnCanceledFunc),
    Cronet_RESULT (*Cronet_UrlRequest_InitWithParams)(
        Cronet_UrlRequestPtr, Cronet_EnginePtr, Cronet_String,
        Cronet_UrlRequestParamsPtr, Cronet_UrlRequestCallbackPtr,
        Cronet_ExecutorPtr));

DART_EXPORT void InitCronetExecutorApi(
    Cronet_ExecutorPtr (*Cronet_Executor_CreateWith)(
        Cronet_Executor_ExecuteFunc),
    void (*Cronet_Executor_SetClientContext)(Cronet_ExecutorPtr,
                                             Cronet_ClientContext),
    Cronet_ClientContext (*Cronet_Executor_GetClientContext)(
        Cronet_ExecutorPtr),
    void (*Cronet_Executor_Destroy)(Cronet_ExecutorPtr),
    void (*Cronet_Runnable_Run)(Cronet_RunnablePtr),
    void (*Cronet_Runnable_Destroy)(Cronet_RunnablePtr));

typedef void *ExecutorPtr;

DART_EXPORT ExecutorPtr Create_Executor();
DART_EXPORT void Destroy_Executor(ExecutorPtr executor);

DART_EXPORT void RegisterHttpClient(Dart_Handle h, Cronet_Engine *ce);
DART_EXPORT void RegisterCallbackHandler(Dart_Port nativePort,
                                         Cronet_UrlRequest *rp);
DART_EXPORT void RemoveRequest(Cronet_UrlRequest *rp);
DART_EXPORT Cronet_RESULT Cronet_UrlRequest_Init(
    Cronet_UrlRequest *self, Cronet_Engine *engine, Cronet_String url,
    Cronet_UrlRequestParams *params, ExecutorPtr _executor);
#ifdef __cplusplus
}
#endif

#endif // WRAPPER_H_
