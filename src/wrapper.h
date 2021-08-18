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

typedef struct SampleExecutor *SampleExecutorPtr;
typedef struct UploadDataProvider *UploadDataProviderPtr;

WRAPPER_EXPORT const char *VersionString();

WRAPPER_EXPORT intptr_t InitDartApiDL(void *data);
WRAPPER_EXPORT void InitCronetApi(
    Cronet_RESULT (*Cronet_Engine_Shutdown)(Cronet_EnginePtr),
    void (*Cronet_Engine_Destroy)(Cronet_EnginePtr),
    Cronet_BufferPtr (*Cronet_Buffer_Create)(void),
    void (*Cronet_Buffer_InitWithAlloc)(Cronet_BufferPtr, uint64_t),
    int32_t (*Cronet_UrlResponseInfo_http_status_code_get)(
        const Cronet_UrlResponseInfoPtr),
    Cronet_String (*Cronet_Error_message_get)(const Cronet_ErrorPtr),
    Cronet_String (*Cronet_UrlResponseInfo_http_status_text_get)(
        const Cronet_UrlResponseInfoPtr),
    Cronet_ClientContext (*Cronet_UploadDataProvider_GetClientContext)(
        Cronet_UploadDataProviderPtr self));

/* Forward declaration. Implementation on sample_executor.cc */
WRAPPER_EXPORT void InitCronetExecutorApi(
    Cronet_ExecutorPtr (*Cronet_Executor_CreateWith)(
        Cronet_Executor_ExecuteFunc),
    void (*Cronet_Executor_SetClientContext)(Cronet_ExecutorPtr,
                                             Cronet_ClientContext),
    Cronet_ClientContext (*Cronet_Executor_GetClientContext)(
        Cronet_ExecutorPtr),
    void (*Cronet_Executor_Destroy)(Cronet_ExecutorPtr),
    void (*Cronet_Runnable_Run)(Cronet_RunnablePtr),
    void (*Cronet_Runnable_Destroy)(Cronet_RunnablePtr));

WRAPPER_EXPORT void RegisterHttpClient(Dart_Handle h, Cronet_Engine *ce);
WRAPPER_EXPORT void RegisterCallbackHandler(Dart_Port nativePort,
                                            Cronet_UrlRequest *rp);
WRAPPER_EXPORT void RemoveRequest(Cronet_UrlRequest *rp);

/* Callbacks. ISSUE: https://github.com/dart-lang/sdk/issues/37022 */

WRAPPER_EXPORT void OnRedirectReceived(Cronet_UrlRequestCallbackPtr self,
                                       Cronet_UrlRequestPtr request,
                                       Cronet_UrlResponseInfoPtr info,
                                       Cronet_String newLocationUrl);

WRAPPER_EXPORT void OnResponseStarted(Cronet_UrlRequestCallbackPtr self,
                                      Cronet_UrlRequestPtr request,
                                      Cronet_UrlResponseInfoPtr info);

WRAPPER_EXPORT void OnReadCompleted(Cronet_UrlRequestCallbackPtr self,
                                    Cronet_UrlRequestPtr request,
                                    Cronet_UrlResponseInfoPtr info,
                                    Cronet_BufferPtr buffer,
                                    uint64_t bytes_read);

WRAPPER_EXPORT void OnSucceeded(Cronet_UrlRequestCallbackPtr self,
                                Cronet_UrlRequestPtr request,
                                Cronet_UrlResponseInfoPtr info);

WRAPPER_EXPORT void OnFailed(Cronet_UrlRequestCallbackPtr self,
                             Cronet_UrlRequestPtr request,
                             Cronet_UrlResponseInfoPtr info,
                             Cronet_ErrorPtr error);

WRAPPER_EXPORT void OnCanceled(Cronet_UrlRequestCallbackPtr self,
                               Cronet_UrlRequestPtr request,
                               Cronet_UrlResponseInfoPtr info);

/* Sample Executor C APIs */

WRAPPER_EXPORT SampleExecutorPtr SampleExecutorCreate();
WRAPPER_EXPORT void SampleExecutorDestroy(SampleExecutorPtr executor);

WRAPPER_EXPORT void InitSampleExecutor(SampleExecutorPtr self);
WRAPPER_EXPORT Cronet_ExecutorPtr
SampleExecutor_Cronet_ExecutorPtr_get(SampleExecutorPtr self);

/* Upload Data Provider C APIs */
WRAPPER_EXPORT UploadDataProviderPtr UploadDataProviderCreate();
WRAPPER_EXPORT void
UploadDataProviderDestroy(UploadDataProviderPtr upload_data_provided);
WRAPPER_EXPORT void UploadDataProviderInit(UploadDataProviderPtr self,
                                           int64_t length,
                                           Cronet_UrlRequestPtr request);

WRAPPER_EXPORT int64_t
UploadDataProvider_GetLength(Cronet_UploadDataProviderPtr self);
WRAPPER_EXPORT void
UploadDataProvider_Read(Cronet_UploadDataProviderPtr self,
                        Cronet_UploadDataSinkPtr upload_data_sink,
                        Cronet_BufferPtr buffer);
WRAPPER_EXPORT void
UploadDataProvider_Rewind(Cronet_UploadDataProviderPtr self,
                          Cronet_UploadDataSinkPtr upload_data_sink);
WRAPPER_EXPORT void
UploadDataProvider_CloseFunc(Cronet_UploadDataProviderPtr self);
#ifdef __cplusplus
}
#endif

#endif // WRAPPER_H_
