// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "wrapper.h"
#include "../third_party/cronet_impl/sample_executor.h"
#include "../third_party/dart-sdk/dart_api.h"
#include "../third_party/dart-sdk/dart_native_api.h"
#include "../third_party/dart-sdk/dart_tools_api.h"
#include <iostream>
#include <stdarg.h>
#include <string.h>
#include <unordered_map>

////////////////////////////////////////////////////////////////////////////////
// Globals

std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

Cronet_RESULT (*_Cronet_Engine_Shutdown)(Cronet_EnginePtr self);
void (*_Cronet_Engine_Destroy)(Cronet_EnginePtr self);
Cronet_BufferPtr (*_Cronet_Buffer_Create)(void);
void (*_Cronet_Buffer_InitWithAlloc)(Cronet_BufferPtr self, uint64_t size);
int32_t (*_Cronet_UrlResponseInfo_http_status_code_get)(
    const Cronet_UrlResponseInfoPtr self);
Cronet_String (*_Cronet_Error_message_get)(const Cronet_ErrorPtr self);
Cronet_String (*_Cronet_UrlResponseInfo_http_status_text_get)(
    const Cronet_UrlResponseInfoPtr self);
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
        const Cronet_UrlResponseInfoPtr)) {
  if (!(Cronet_Engine_Shutdown && Cronet_Engine_Destroy &&
        Cronet_Buffer_Create && Cronet_Buffer_InitWithAlloc &&
        Cronet_UrlResponseInfo_http_status_code_get &&
        Cronet_UrlResponseInfo_http_status_text_get)) {
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
}

////////////////////////////////////////////////////////////////////////////////

static void FreeFinalizer(void *, void *value) { free(value); }

/* Callback Helpers */

// Registers the Dart side's
// ReceievePort's NativePort component
//
// This is required to send the data
void RegisterCallbackHandler(Dart_Port send_port, Cronet_UrlRequestPtr rp) {
  requestNativePorts[rp] = send_port;
}

// This sends the callback name and the associated data with it to the Dart
// side via NativePort.
//
// Sent data is broken into 2 parts.
// message[0] is the method name, which is a string.
// message[1] contains all the data to pass to that method.
//
// Using this due to the lack of support for asynchronous callbacks in dart:ffi.
// See Issue: https://github.com/dart-lang/sdk/issues/37022.
void DispatchCallback(const char *methodname, Cronet_UrlRequestPtr request,
                      Dart_CObject args) {
  Dart_CObject c_method_name;
  c_method_name.type = Dart_CObject_kString;
  c_method_name.value.as_string = const_cast<char *>(methodname);

  Dart_CObject *c_request_arr[] = {&c_method_name, &args};
  Dart_CObject c_request;

  c_request.type = Dart_CObject_kArray;
  c_request.value.as_array.values = c_request_arr;
  c_request.value.as_array.length =
      sizeof(c_request_arr) / sizeof(c_request_arr[0]);

  Dart_PostCObject_DL(requestNativePorts[request], &c_request);
}

// Builds the arguments to pass to the Dart side as a parameter to the
// callbacks. [num] is the number of arguments to be passed and rest are the
// arguments.
Dart_CObject CallbackArgBuilder(int num, ...) {
  Dart_CObject c_request_data;
  va_list valist;
  va_start(valist, num);
  void *request_buffer = malloc(sizeof(uint64_t) * num);
  uint64_t *buf = reinterpret_cast<uint64_t *>(request_buffer);

  for (int i = 0; i < num; i++) {
    buf[i] = va_arg(valist, uint64_t);
  }

  c_request_data.type = Dart_CObject_kExternalTypedData;
  c_request_data.value.as_external_typed_data.type = Dart_TypedData_kUint64;
  c_request_data.value.as_external_typed_data.length = sizeof(uint64_t) * num;
  c_request_data.value.as_external_typed_data.data =
      static_cast<uint8_t *>(request_buffer);
  c_request_data.value.as_external_typed_data.peer = request_buffer;
  c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

  va_end(valist);

  return c_request_data;
}

/// Status Text is only returned to throw more meaningful HttpExceptions.
///
/// API is not exposed to the public.
char *statusText(Cronet_UrlResponseInfoPtr info, int statusCode, int lBound,
                 int uBound) {
  if (!(statusCode >= lBound && statusCode <= uBound)) {
    Cronet_String status = _Cronet_UrlResponseInfo_http_status_text_get(info);
    int statusLen = strlen(status);
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
  int len = strlen(newLocationUrl);
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
  int len = strlen(errStr);
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
