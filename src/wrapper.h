// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef WRAPPER_H_
#define WRAPPER_H_

#include "../third_party/dart-sdk/dart_api_dl.h"
#include "../third_party/cronet/cronet.idl_c.h"

#include"wrapper_export.h"

#include<stdbool.h>

#ifdef __cplusplus


extern "C" {
#endif

#include <stdint.h>

DART_EXPORT void dispatchCallback(char* methodname);
DART_EXPORT intptr_t InitDartApiDL(void* data);
DART_EXPORT void InitCronetApi(void* shutdown, void *destroy, void *buffer_create, 
  void *buffer_InitWithAlloc, void *UrlRequestCallback_CreateWith, 
  void *UrlRequest_InitWithParams);
DART_EXPORT void InitCronetExecutorApi(void *executor_createWith, void *executor_setClientContext,
  void *executor_getClientContext,
  void *executor_destroy,
  void *runnable_run,
  void *runnable_destroy);
typedef void* ExecutorPtr;

DART_EXPORT ExecutorPtr Create_Executor();
DART_EXPORT void Destroy_Executor(ExecutorPtr executor);

DART_EXPORT void registerHttpClient(Dart_Handle h, Cronet_Engine* ce);
DART_EXPORT void registerCallbackHandler(Dart_Port nativePort, Cronet_UrlRequest* rp);
DART_EXPORT void removeRequest(Cronet_UrlRequest* rp);
DART_EXPORT Cronet_RESULT Cronet_UrlRequest_Init(Cronet_UrlRequest* self, Cronet_Engine* engine, Cronet_String url, Cronet_UrlRequestParams* params, ExecutorPtr _executor);

/* executor only */

typedef void (*Cronet_Executor_ExecuteFunc)(Cronet_Executor* self, Cronet_Runnable* command);


#ifdef __cplusplus
}
#endif

#endif  // WRAPPER_H_
