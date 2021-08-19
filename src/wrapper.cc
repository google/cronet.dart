// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "wrapper.h"
#include "../third_party/cronet_impl/sample_executor.h"
#include "upload_data_provider.h"
#include "wrapper_utils.h"
#include <iostream>
#include <stdlib.h>
#include <string.h>
#include <unordered_map>

////////////////////////////////////////////////////////////////////////////////
// Versioning
#define STRINGIFY_(x) #x
#define STRINGIFY(x) STRINGIFY_(x)

#define WRAPPER_VERSION 2

#define WRAPPER_VERSTR STRINGIFY(WRAPPER_VERSION)

const char *VersionString() { return WRAPPER_VERSTR; }

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Globals

extern std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

Cronet_RESULT (*_Cronet_Engine_Shutdown)(Cronet_EnginePtr self);
void (*_Cronet_Engine_Destroy)(Cronet_EnginePtr self);
Cronet_BufferPtr (*_Cronet_Buffer_Create)(void);
void (*_Cronet_Buffer_InitWithAlloc)(Cronet_BufferPtr self, uint64_t size);
int32_t (*_Cronet_UrlResponseInfo_http_status_code_get)(
    const Cronet_UrlResponseInfoPtr self);
Cronet_String (*_Cronet_Error_message_get)(const Cronet_ErrorPtr self);
Cronet_String (*_Cronet_UrlResponseInfo_http_status_text_get)(
    const Cronet_UrlResponseInfoPtr self);
Cronet_ClientContext (*_Cronet_UploadDataProvider_GetClientContext)(
    Cronet_UploadDataProviderPtr self);
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Initialize `dart_api_dl.h`
intptr_t InitDartApiDL(void *data) { return Dart_InitializeApiDL(data); }

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Initialize required cronet functions
void InitCronetApi(
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
        Cronet_UploadDataProviderPtr self)) {
  if (!(Cronet_Engine_Shutdown && Cronet_Engine_Destroy &&
        Cronet_Buffer_Create && Cronet_Buffer_InitWithAlloc &&
        Cronet_UrlResponseInfo_http_status_code_get &&
        Cronet_UrlResponseInfo_http_status_text_get &&
        Cronet_UploadDataProvider_GetClientContext)) {
    std::cerr << "Invalid pointer(s): null" << std::endl;
    return;
  }
  _Cronet_Engine_Shutdown = Cronet_Engine_Shutdown;
  _Cronet_Engine_Destroy = Cronet_Engine_Destroy;
  _Cronet_Buffer_Create = Cronet_Buffer_Create;
  _Cronet_Buffer_InitWithAlloc = Cronet_Buffer_InitWithAlloc;
  _Cronet_UrlResponseInfo_http_status_code_get =
      Cronet_UrlResponseInfo_http_status_code_get;
  _Cronet_Error_message_get = Cronet_Error_message_get;
  _Cronet_UrlResponseInfo_http_status_text_get =
      Cronet_UrlResponseInfo_http_status_text_get;
  _Cronet_UploadDataProvider_GetClientContext =
      Cronet_UploadDataProvider_GetClientContext;
}

////////////////////////////////////////////////////////////////////////////////

/* Callback Helpers */

// Registers the Dart side's
// ReceievePort's NativePort component
//
// This is required to send the data
void RegisterCallbackHandler(Dart_Port send_port, Cronet_UrlRequestPtr rp) {
  requestNativePorts[rp] = send_port;
}

/// Status Text is only returned to throw more meaningful HttpExceptions.
///
/// API is not exposed to the public.
char *statusText(Cronet_UrlResponseInfoPtr info, int statusCode, int lBound,
                 int uBound) {
  if (!(statusCode >= lBound && statusCode <= uBound)) {
    Cronet_String status = _Cronet_UrlResponseInfo_http_status_text_get(info);
    size_t statusLen = strlen(status);
    char *statusDup = (char *)malloc(statusLen + 1);
    memcpy(statusDup, status, statusLen + 1);
    return statusDup;
  }
  return NULL;
}

/* Engine Cleanup Tasks */
static void HttpClientDestroy(void *isolate_callback_data, void *peer) {
  Cronet_EnginePtr ce = reinterpret_cast<Cronet_EnginePtr>(peer);
  if (_Cronet_Engine_Shutdown(ce) != Cronet_RESULT_SUCCESS) {
    std::cerr << "Failed to shut down the cronet engine." << std::endl;
    return;
  }
  _Cronet_Engine_Destroy(ce);
}

void RemoveRequest(Cronet_UrlRequestPtr rp) { requestNativePorts.erase(rp); }

// Register our HttpClient object from dart side
void RegisterHttpClient(Dart_Handle h, Cronet_Engine *ce) {
  void *peer = ce;
  intptr_t size = 8;
  Dart_NewFinalizableHandle_DL(h, peer, size, HttpClientDestroy);
}

/* URL Callbacks Implementations
ISSUE: https://github.com/dart-lang/sdk/issues/37022
*/

void OnRedirectReceived(Cronet_UrlRequestCallbackPtr self,
                        Cronet_UrlRequestPtr request,
                        Cronet_UrlResponseInfoPtr info,
                        Cronet_String newLocationUrl) {
  size_t len = strlen(newLocationUrl);
  char *newLoc = (char *)malloc(len + 1);
  memcpy(newLoc, newLocationUrl, len + 1);
  int statusCode = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 3XX status code.
  DispatchCallback("OnRedirectReceived", request,
                   CallbackArgBuilder(3, newLoc, statusCode,
                                      statusText(info, statusCode, 300, 399)));
}

void OnResponseStarted(Cronet_UrlRequestCallbackPtr self,
                       Cronet_UrlRequestPtr request,
                       Cronet_UrlResponseInfoPtr info) {

  // Create and allocate 32kb buffer.
  Cronet_BufferPtr buffer = _Cronet_Buffer_Create();
  _Cronet_Buffer_InitWithAlloc(buffer, 32 * 1024);
  int statusCode = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 1XX or 2XX status code.
  DispatchCallback("OnResponseStarted", request,
                   CallbackArgBuilder(3, statusCode, buffer,
                                      statusText(info, statusCode, 100, 299)));
}

void OnReadCompleted(Cronet_UrlRequestCallbackPtr self,
                     Cronet_UrlRequestPtr request,
                     Cronet_UrlResponseInfoPtr info, Cronet_BufferPtr buffer,
                     uint64_t bytes_read) {
  int statusCode = _Cronet_UrlResponseInfo_http_status_code_get(info);
  // If NOT a 1XX or 2XX status code.
  DispatchCallback("OnReadCompleted", request,
                   CallbackArgBuilder(5, request, statusCode, buffer,
                                      bytes_read,
                                      statusText(info, statusCode, 100, 299)));
}

void OnSucceeded(Cronet_UrlRequestCallbackPtr self,
                 Cronet_UrlRequestPtr request, Cronet_UrlResponseInfoPtr info) {
  int statusCode = _Cronet_UrlResponseInfo_http_status_code_get(info);
  DispatchCallback("OnSucceeded", request, CallbackArgBuilder(1, statusCode));
}

void OnFailed(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
              Cronet_UrlResponseInfoPtr info, Cronet_ErrorPtr error) {
  Cronet_String errStr = _Cronet_Error_message_get(error);
  size_t len = strlen(errStr);
  char *dupStr = (char *)malloc(len + 1);
  memcpy(dupStr, errStr, len + 1);
  DispatchCallback("OnFailed", request, CallbackArgBuilder(1, dupStr));
}

void OnCanceled(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
                Cronet_UrlResponseInfoPtr info) {
  DispatchCallback("OnCanceled", request, CallbackArgBuilder(0));
}

// Creates a SampleExecutor Object.
SampleExecutorPtr SampleExecutorCreate() { return new SampleExecutor(); }

// Destroys a SampleExecutor Object.
void SampleExecutorDestroy(SampleExecutorPtr executor) {
  if (executor == nullptr) {
    std::cerr << "Invalid executor pointer: null." << std::endl;
    return;
  }
  delete executor;
}

// Initializes a SampleExecutor.
void InitSampleExecutor(SampleExecutorPtr self) { return self->Init(); }

// Cronet_ExecutorPtr of the provided SampleExecutor.
Cronet_ExecutorPtr
SampleExecutor_Cronet_ExecutorPtr_get(SampleExecutorPtr self) {
  return self->GetExecutor();
}

/* Upload Data Provider C APIs */
UploadDataProviderPtr UploadDataProviderCreate() {
  return new UploadDataProvider();
}

void UploadDataProviderDestroy(UploadDataProviderPtr upload_data_provider) {
  delete upload_data_provider;
}

void UploadDataProviderInit(UploadDataProviderPtr self, int64_t length,
                            Cronet_UrlRequestPtr request) {
  self->Init(length, request);
}

int64_t UploadDataProvider_GetLength(Cronet_UploadDataProviderPtr self) {
  UploadDataProvider *instance = static_cast<UploadDataProvider *>(
      _Cronet_UploadDataProvider_GetClientContext(self));
  return instance->GetLength();
}
void UploadDataProvider_Read(Cronet_UploadDataProviderPtr self,
                             Cronet_UploadDataSinkPtr upload_data_sink,
                             Cronet_BufferPtr buffer) {
  UploadDataProvider *instance = static_cast<UploadDataProvider *>(
      _Cronet_UploadDataProvider_GetClientContext(self));
  instance->ReadFunc(upload_data_sink, buffer);
}
void UploadDataProvider_Rewind(Cronet_UploadDataProviderPtr self,
                               Cronet_UploadDataSinkPtr upload_data_sink) {
  UploadDataProvider *instance = static_cast<UploadDataProvider *>(
      _Cronet_UploadDataProvider_GetClientContext(self));
  instance->RewindFunc(upload_data_sink);
}
void UploadDataProvider_CloseFunc(Cronet_UploadDataProviderPtr self) {
  UploadDataProvider *instance = static_cast<UploadDataProvider *>(
      _Cronet_UploadDataProvider_GetClientContext(self));
  instance->CloseFunc();
}
