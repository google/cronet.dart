// Contains functions those are not exposed to dart but required to run this
// sample.

// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CRONET_IDL_EXTRA_SAMPLE_
#define CRONET_IDL_EXTRA_SAMPLE_

#include "../cronet/cronet_c.h"

#ifdef __cplusplus
extern "C" {
#endif
    Cronet_RESULT Cronet_UrlRequest_InitWithParams(
        Cronet_UrlRequestPtr self,
        Cronet_EnginePtr engine,
        Cronet_String url,
        Cronet_UrlRequestParamsPtr params,
        Cronet_UrlRequestCallbackPtr callback,
        Cronet_ExecutorPtr executor);

    void Cronet_Engine_Destroy(Cronet_EnginePtr self);

    Cronet_UrlRequestCallbackPtr Cronet_UrlRequestCallback_CreateWith(
        Cronet_UrlRequestCallback_OnRedirectReceivedFunc OnRedirectReceivedFunc,
        Cronet_UrlRequestCallback_OnResponseStartedFunc OnResponseStartedFunc,
        Cronet_UrlRequestCallback_OnReadCompletedFunc OnReadCompletedFunc,
        Cronet_UrlRequestCallback_OnSucceededFunc OnSucceededFunc,
        Cronet_UrlRequestCallback_OnFailedFunc OnFailedFunc,
        Cronet_UrlRequestCallback_OnCanceledFunc OnCanceledFunc);

    void Cronet_UrlRequestCallback_SetClientContext(
        Cronet_UrlRequestCallbackPtr self,
        Cronet_ClientContext client_context);

    void Cronet_UrlRequestCallback_Destroy(
        Cronet_UrlRequestCallbackPtr self);

    Cronet_BufferPtr Cronet_Buffer_Create(void);

    void Cronet_Buffer_InitWithAlloc(Cronet_BufferPtr self, uint64_t size);

    Cronet_String Cronet_Error_message_get(const Cronet_ErrorPtr self);

    Cronet_ClientContext Cronet_UrlRequestCallback_GetClientContext(Cronet_UrlRequestCallbackPtr self);

    ///////////////////////
    // Abstract interface Cronet_Executor is implemented by the app.

    // There is no method to create a concrete implementation.

    // Destroy an instance of Cronet_Executor.
    CRONET_EXPORT void Cronet_Executor_Destroy(Cronet_ExecutorPtr self);
    // Set and get app-specific Cronet_ClientContext.
    CRONET_EXPORT void Cronet_Executor_SetClientContext(
        Cronet_ExecutorPtr self,
        Cronet_ClientContext client_context);
    CRONET_EXPORT Cronet_ClientContext
    Cronet_Executor_GetClientContext(Cronet_ExecutorPtr self);
    // Abstract interface Cronet_Executor is implemented by the app.
    // The following concrete methods forward call to app implementation.
    // The app doesn't normally call them.
    CRONET_EXPORT
    void Cronet_Executor_Execute(Cronet_ExecutorPtr self,
                                Cronet_RunnablePtr command);
    // The app implements abstract interface Cronet_Executor by defining custom
    // functions for each method.
    typedef void (*Cronet_Executor_ExecuteFunc)(Cronet_ExecutorPtr self,
                                                Cronet_RunnablePtr command);
    // The app creates an instance of Cronet_Executor by providing custom functions
    // for each method.
    CRONET_EXPORT Cronet_ExecutorPtr
    Cronet_Executor_CreateWith(Cronet_Executor_ExecuteFunc ExecuteFunc);

    ///////////////////////
    // Abstract interface Cronet_Runnable is implemented by the app.

    // There is no method to create a concrete implementation.

    // Destroy an instance of Cronet_Runnable.
    CRONET_EXPORT void Cronet_Runnable_Destroy(Cronet_RunnablePtr self);
    // Set and get app-specific Cronet_ClientContext.
    CRONET_EXPORT void Cronet_Runnable_SetClientContext(
        Cronet_RunnablePtr self,
        Cronet_ClientContext client_context);
    CRONET_EXPORT Cronet_ClientContext
    Cronet_Runnable_GetClientContext(Cronet_RunnablePtr self);
    // Abstract interface Cronet_Runnable is implemented by the app.
    // The following concrete methods forward call to app implementation.
    // The app doesn't normally call them.
    CRONET_EXPORT
    void Cronet_Runnable_Run(Cronet_RunnablePtr self);
    // The app implements abstract interface Cronet_Runnable by defining custom
    // functions for each method.
    typedef void (*Cronet_Runnable_RunFunc)(Cronet_RunnablePtr self);
    // The app creates an instance of Cronet_Runnable by providing custom functions
    // for each method.
    CRONET_EXPORT Cronet_RunnablePtr
    Cronet_Runnable_CreateWith(Cronet_Runnable_RunFunc RunFunc);
#ifdef __cplusplus
}
#endif

#endif  // CRONET_IDL_EXTRA_SAMPLE_
