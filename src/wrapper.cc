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
#include <unordered_map>

////////////////////////////////////////////////////////////////////////////////
// Globals

std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

Cronet_RESULT (*_Cronet_Engine_Shutdown)(Cronet_EnginePtr self);
void (*_Cronet_Engine_Destroy)(Cronet_EnginePtr self);
Cronet_BufferPtr (*_Cronet_Buffer_Create)(void);
void (*_Cronet_Buffer_InitWithAlloc)(Cronet_BufferPtr self, uint64_t size);
Cronet_UrlRequestCallbackPtr (*_Cronet_UrlRequestCallback_CreateWith)(
    Cronet_UrlRequestCallback_OnRedirectReceivedFunc OnRedirectReceivedFunc,
    Cronet_UrlRequestCallback_OnResponseStartedFunc OnResponseStartedFunc,
    Cronet_UrlRequestCallback_OnReadCompletedFunc OnReadCompletedFunc,
    Cronet_UrlRequestCallback_OnSucceededFunc OnSucceededFunc,
    Cronet_UrlRequestCallback_OnFailedFunc OnFailedFunc,
    Cronet_UrlRequestCallback_OnCanceledFunc OnCanceledFunc);
Cronet_RESULT (*_Cronet_UrlRequest_InitWithParams)(
    Cronet_UrlRequestPtr self, Cronet_EnginePtr engine, Cronet_String url,
    Cronet_UrlRequestParamsPtr params, Cronet_UrlRequestCallbackPtr callback,
    Cronet_ExecutorPtr executor);
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Initialize `dart_api_dl.h`
intptr_t InitDartApiDL(void *data) { return Dart_InitializeApiDL(data); }

////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Initialize required cronet functions
void InitCronetApi(void *shutdown, void *destroy, void *buffer_create,
                   void *buffer_InitWithAlloc,
                   void *UrlRequestCallback_CreateWith,
                   void *UrlRequest_InitWithParams) {
  if (!(shutdown && destroy && buffer_create && buffer_InitWithAlloc &&
        UrlRequestCallback_CreateWith && UrlRequest_InitWithParams)) {
    std::cerr << "Invalid pointer(s): null" << std::endl;
    return;
  }
  _Cronet_Engine_Shutdown =
      reinterpret_cast<Cronet_RESULT (*)(Cronet_EnginePtr)>(shutdown);
  _Cronet_Engine_Destroy =
      reinterpret_cast<void (*)(Cronet_EnginePtr)>(destroy);
  _Cronet_Buffer_Create =
      reinterpret_cast<Cronet_BufferPtr (*)()>(buffer_create);
  _Cronet_Buffer_InitWithAlloc =
      reinterpret_cast<void (*)(Cronet_BufferPtr, uint64_t)>(
          buffer_InitWithAlloc);
  _Cronet_UrlRequestCallback_CreateWith =
      reinterpret_cast<Cronet_UrlRequestCallbackPtr (*)(
          Cronet_UrlRequestCallback_OnRedirectReceivedFunc,
          Cronet_UrlRequestCallback_OnResponseStartedFunc,
          Cronet_UrlRequestCallback_OnReadCompletedFunc,
          Cronet_UrlRequestCallback_OnSucceededFunc,
          Cronet_UrlRequestCallback_OnFailedFunc,
          Cronet_UrlRequestCallback_OnCanceledFunc)>(
          UrlRequestCallback_CreateWith);
  _Cronet_UrlRequest_InitWithParams = reinterpret_cast<Cronet_RESULT (*)(
      Cronet_UrlRequestPtr, Cronet_EnginePtr, Cronet_String,
      Cronet_UrlRequestParamsPtr, Cronet_UrlRequestCallbackPtr,
      Cronet_ExecutorPtr)>(UrlRequest_InitWithParams);
}

////////////////////////////////////////////////////////////////////////////////

static void FreeFinalizer(void *, void *value) { free(value); }

/* Callback Helpers */

// Registers the Dart side's
// ReceievePort's NativePort component
//
// This is required to send the data
void registerCallbackHandler(Dart_Port send_port, Cronet_UrlRequestPtr rp) {
  requestNativePorts[rp] = send_port;
}

// This sends the callback name and the associated data with it to the Dart
// side via NativePort.
//
// Sent data is broken into 3 parts.
// message[0] is the method name, which is a string.
// message[1] contains all the data to pass to that method.
//
// Using this due to the lack of support for asynchronous callbacks in dart:ffi.
// See Issue: dart-lang/sdk#37022.
void dispatchCallback(const char *methodname, Cronet_UrlRequestPtr request,
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
Dart_CObject callbackArgBuilder(int num, ...) {
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
  c_request_data.value.as_external_typed_data.length =
      sizeof(uint64_t) * num; // 4 args to pass
  c_request_data.value.as_external_typed_data.data =
      static_cast<uint8_t *>(request_buffer);
  c_request_data.value.as_external_typed_data.peer = request_buffer;
  c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

  va_end(valist);

  return c_request_data;
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

void removeRequest(Cronet_UrlRequestPtr rp) { requestNativePorts.erase(rp); }

// Register our HttpClient object from dart side
void registerHttpClient(Dart_Handle h, Cronet_Engine *ce) {
  void *peer = ce;
  intptr_t size = 8;
  Dart_NewFinalizableHandle_DL(h, peer, size, HttpClientDestroy);
}

/* URL Callbacks Implementations */

void OnRedirectReceived(Cronet_UrlRequestCallbackPtr self,
                        Cronet_UrlRequestPtr request,
                        Cronet_UrlResponseInfoPtr info,
                        Cronet_String newLocationUrl) {
  dispatchCallback("OnRedirectReceived", request,
                   callbackArgBuilder(2, newLocationUrl, info));
}

void OnResponseStarted(Cronet_UrlRequestCallbackPtr self,
                       Cronet_UrlRequestPtr request,
                       Cronet_UrlResponseInfoPtr info) {

  // Create and allocate 32kb buffer.
  Cronet_BufferPtr buffer = _Cronet_Buffer_Create();
  _Cronet_Buffer_InitWithAlloc(buffer, 32 * 1024);

  dispatchCallback("OnResponseStarted", request,
                   callbackArgBuilder(2, info, buffer));

  // // Started reading the response.
  // _Cronet_UrlRequest_Read(request, buffer);
}

void OnReadCompleted(Cronet_UrlRequestCallbackPtr self,
                     Cronet_UrlRequestPtr request,
                     Cronet_UrlResponseInfoPtr info, Cronet_BufferPtr buffer,
                     uint64_t bytes_read) {
  dispatchCallback("OnReadCompleted", request,
                   callbackArgBuilder(4, request, info, buffer, bytes_read));
}

void OnSucceeded(Cronet_UrlRequestCallbackPtr self,
                 Cronet_UrlRequestPtr request, Cronet_UrlResponseInfoPtr info) {
  dispatchCallback("OnSucceeded", request, callbackArgBuilder(1, info));
}

void OnFailed(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
              Cronet_UrlResponseInfoPtr info, Cronet_ErrorPtr error) {
  dispatchCallback("OnFailed", request, callbackArgBuilder(1, error));
}

void OnCanceled(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request,
                Cronet_UrlResponseInfoPtr info) {
  dispatchCallback("OnCanceled", request, callbackArgBuilder(0));
}

ExecutorPtr Create_Executor() { return new SampleExecutor(); }

void Destroy_Executor(ExecutorPtr executor) {
  if (executor == nullptr) {
    std::cerr << "Invalid executor pointer: null." << std::endl;
    return;
  }
  delete reinterpret_cast<SampleExecutor *>(executor);
}

// NOTE: Changed from original cronet's api. executor & callback params aren't
// needed
Cronet_RESULT Cronet_UrlRequest_Init(Cronet_UrlRequestPtr self,
                                     Cronet_EnginePtr engine, Cronet_String url,
                                     Cronet_UrlRequestParamsPtr params,
                                     ExecutorPtr _executor) {
  SampleExecutor *executor = reinterpret_cast<SampleExecutor *>(_executor);
  if (executor == nullptr) {
    std::cerr << "Invalid executor pointer: null." << std::endl;
    return Cronet_RESULT_NULL_POINTER_EXECUTOR;
  }
  executor->Init();
  Cronet_UrlRequestCallbackPtr urCallback =
      _Cronet_UrlRequestCallback_CreateWith(OnRedirectReceived,
                                            OnResponseStarted, OnReadCompleted,
                                            OnSucceeded, OnFailed, OnCanceled);
  return _Cronet_UrlRequest_InitWithParams(self, engine, url, params,
                                           urCallback, executor->GetExecutor());
}
