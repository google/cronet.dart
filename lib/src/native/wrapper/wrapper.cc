// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "../include/dart/dart_api.h"
#include "../include/dart/dart_native_api.h"
#include "../include/dart/dart_tools_api.h"
// #include"dart_api_dl.c"
#include "wrapper.h"
#include "sample_executor.h"
#include <iostream>
#include <stdarg.h>
#include <unordered_map>

// Set CRONET_VERSION from build script

#ifdef CRONET_VERSION
  #define CRONET_LIB_NAME CRONET_LIB_PREFIX "." CRONET_VERSION CRONET_LIB_EXTENSION
#else
  #define CRONET_LIB_NAME CRONET_LIB_PREFIX ".86.0.4240.198" CRONET_LIB_EXTENSION
#endif

// cronet function loading and exposing macros
// use IMPORT for private use - accessable as func_name
// use P_IMPORT for those API who needs to be wrapped before exposing - accessable as _func_name

#define IMPORT(r_type, f_name, ...) r_type (* f_name) (__VA_ARGS__) = reinterpret_cast<r_type (*)(__VA_ARGS__)>(dlsym(handle, #f_name))

#define P_IMPORT(r_type, f_name, ...) r_type (* _ ## f_name) (__VA_ARGS__) = reinterpret_cast<r_type (*)(__VA_ARGS__)>(dlsym(handle, #f_name))

////////////////////////////////////////////////////////////////////////////////
// Initialize `dart_api_dl.h`
intptr_t InitDartApiDL(void* data) {
  printf("Initializing");
  return Dart_InitializeApiDL(data);
}

////////////////////////////////////////////////////////////////////////////////

// loading cronet
LIBTYPE handle = OPENLIB(CRONET_LIB_NAME);
std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

static void FreeFinalizer(void*, void* value) {
  free(value);
}


/* Callback Helpers */

// Registers the Dart side's
// ReceievePort's NativePort component
//
// This is required to send the data
void registerCallbackHandler(Dart_Port send_port, Cronet_UrlRequestPtr rp) {
  requestNativePorts[rp] = send_port;
}

// This sends the callback name and the associated data
// with it to the Dart side via NativePort
//
// Sent data is broken into 3 parts.
// message[0] is the method name, which is a string
// message[1] contains all the data to pass to that method
void dispatchCallback(const char* methodname, Cronet_UrlRequestPtr request, Dart_CObject args) {
  Dart_CObject c_method_name;
  c_method_name.type = Dart_CObject_kString;
  c_method_name.value.as_string = const_cast<char *>(methodname);

  Dart_CObject* c_request_arr[] = {&c_method_name, &args};
  Dart_CObject c_request;

  c_request.type = Dart_CObject_kArray;
  c_request.value.as_array.values = c_request_arr;
  c_request.value.as_array.length =
      sizeof(c_request_arr) / sizeof(c_request_arr[0]);
  
  Dart_PostCObject_DL(requestNativePorts[request], &c_request);
}

// Builds the arguments to pass to the Dart side
// as a parameter to the callbacks
// Data processed here are
// consumed as from message[2] if
// message is the name of the data
// receieved by the ReceievePort
Dart_CObject callbackArgBuilder(int num, ...) {
  Dart_CObject c_request_data;
  va_list valist;
  va_start(valist, num);
  void* request_buffer = malloc(sizeof(uint64_t) * num);
  uint64_t* buf =  reinterpret_cast<uint64_t*>(request_buffer);

  for(int i = 0; i < num; i++) {
    buf[i] = va_arg(valist,uint64_t);
  }

  c_request_data.type = Dart_CObject_kExternalTypedData;
  c_request_data.value.as_external_typed_data.type = Dart_TypedData_kUint64;
  c_request_data.value.as_external_typed_data.length = sizeof(uint64_t) * num;  // 4 args to pass
  c_request_data.value.as_external_typed_data.data = static_cast<uint8_t*>(request_buffer);
  c_request_data.value.as_external_typed_data.peer = request_buffer;
  c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

  va_end(valist);

  return c_request_data;
}


/* Getting Cronet's Functions */
P_IMPORT(Cronet_EnginePtr,Cronet_Engine_Create , void);
P_IMPORT(void, Cronet_Engine_Destroy, Cronet_EnginePtr);
P_IMPORT(Cronet_RESULT, Cronet_Engine_Shutdown, Cronet_EnginePtr);
P_IMPORT(Cronet_String, Cronet_Engine_GetVersionString, Cronet_EnginePtr);

P_IMPORT(Cronet_EngineParamsPtr, Cronet_EngineParams_Create, void);
P_IMPORT(void, Cronet_EngineParams_Destroy, Cronet_EngineParamsPtr);

P_IMPORT(Cronet_QuicHintPtr,Cronet_QuicHint_Create, void);
P_IMPORT(void, Cronet_QuicHint_Destroy, Cronet_QuicHintPtr);
P_IMPORT(void, Cronet_QuicHint_host_set, Cronet_QuicHintPtr self, const Cronet_String host);
P_IMPORT(void, Cronet_QuicHint_port_set, Cronet_QuicHintPtr self, const int32_t port);
P_IMPORT(void, Cronet_QuicHint_alternate_port_set, Cronet_QuicHintPtr self, const int32_t alternate_port);

P_IMPORT(void, Cronet_EngineParams_enable_check_result_set, Cronet_EngineParamsPtr, const bool);
P_IMPORT(void, Cronet_EngineParams_user_agent_set, Cronet_EngineParamsPtr, const Cronet_String);
P_IMPORT(void, Cronet_EngineParams_enable_quic_set, Cronet_EngineParamsPtr, const bool);
P_IMPORT(void, Cronet_EngineParams_quic_hints_add, Cronet_EngineParamsPtr self,const Cronet_QuicHintPtr element);
P_IMPORT(void, Cronet_EngineParams_enable_http2_set, Cronet_EngineParamsPtr, const bool);
P_IMPORT(void, Cronet_EngineParams_enable_brotli_set, Cronet_EngineParamsPtr, const bool);
P_IMPORT(void, Cronet_EngineParams_accept_language_set, Cronet_EngineParamsPtr, const Cronet_String);
P_IMPORT(void, Cronet_EngineParams_http_cache_mode_set, Cronet_EngineParamsPtr, const Cronet_EngineParams_HTTP_CACHE_MODE http_cache_mode);
P_IMPORT(void, Cronet_EngineParams_http_cache_max_size_set, Cronet_EngineParamsPtr, const int64_t http_cache_max_size);
P_IMPORT(void, Cronet_EngineParams_storage_path_set, Cronet_EngineParamsPtr, const Cronet_String storage_path);

P_IMPORT(Cronet_RESULT, Cronet_Engine_StartWithParams, Cronet_EnginePtr, Cronet_EngineParamsPtr);
P_IMPORT(Cronet_UrlRequestPtr, Cronet_UrlRequest_Create, void);
P_IMPORT(void, Cronet_UrlRequest_Destroy, Cronet_UrlRequestPtr);
P_IMPORT(void, Cronet_UrlRequest_Cancel, Cronet_UrlRequestPtr);
P_IMPORT(void, Cronet_UrlRequest_SetClientContext, Cronet_UrlRequestPtr, Cronet_ClientContext);
P_IMPORT(Cronet_ClientContext, Cronet_UrlRequest_GetClientContext, Cronet_UrlRequestPtr);
P_IMPORT(Cronet_UrlRequestParamsPtr, Cronet_UrlRequestParams_Create, void);
P_IMPORT(void, Cronet_UrlRequestParams_http_method_set, Cronet_UrlRequestParamsPtr, const Cronet_String);

P_IMPORT(void, Cronet_UrlRequestParams_request_headers_add, Cronet_UrlRequestParamsPtr,  const Cronet_HttpHeaderPtr);

void Cronet_UrlRequestParams_request_headers_add(
    Cronet_UrlRequestParamsPtr self,
    const Cronet_HttpHeaderPtr element) {return _Cronet_UrlRequestParams_request_headers_add(self, element);}

P_IMPORT(Cronet_HttpHeaderPtr, Cronet_HttpHeader_Create, void);
Cronet_HttpHeaderPtr Cronet_HttpHeader_Create(void) {return _Cronet_HttpHeader_Create();}

P_IMPORT(void,Cronet_HttpHeader_Destroy, Cronet_HttpHeaderPtr);
void Cronet_HttpHeader_Destroy(Cronet_HttpHeaderPtr self) {return _Cronet_HttpHeader_Destroy(self);}

P_IMPORT(void,Cronet_HttpHeader_name_set, Cronet_HttpHeaderPtr, const Cronet_String);

void Cronet_HttpHeader_name_set(Cronet_HttpHeaderPtr self,
                                const Cronet_String name) {return _Cronet_HttpHeader_name_set(self, name);}

P_IMPORT(void,Cronet_HttpHeader_value_set, Cronet_HttpHeaderPtr, const Cronet_String);
void Cronet_HttpHeader_value_set(Cronet_HttpHeaderPtr self,
                                 const Cronet_String value) {return _Cronet_HttpHeader_value_set(self, value);}

// Unexposed - see Cronet_UrlRequest_Init
P_IMPORT(Cronet_RESULT, Cronet_UrlRequest_InitWithParams, Cronet_UrlRequestPtr, Cronet_EnginePtr, Cronet_String, Cronet_UrlRequestParamsPtr, Cronet_UrlRequestCallbackPtr, Cronet_ExecutorPtr);

// Unexposed - see Cronet_UrlRequest_Init
P_IMPORT(Cronet_UrlRequestCallbackPtr, Cronet_UrlRequestCallback_CreateWith, 
  Cronet_UrlRequestCallback_OnRedirectReceivedFunc,
  Cronet_UrlRequestCallback_OnResponseStartedFunc,
  Cronet_UrlRequestCallback_OnReadCompletedFunc,
  Cronet_UrlRequestCallback_OnSucceededFunc,
  Cronet_UrlRequestCallback_OnFailedFunc,
  Cronet_UrlRequestCallback_OnCanceledFunc);

P_IMPORT(Cronet_RESULT, Cronet_UrlRequest_Start, Cronet_UrlRequestPtr);
P_IMPORT(Cronet_RESULT, Cronet_UrlRequest_FollowRedirect, Cronet_UrlRequestPtr);
P_IMPORT(Cronet_RESULT, Cronet_UrlRequest_Read, Cronet_UrlRequestPtr, Cronet_BufferPtr);
P_IMPORT(Cronet_BufferPtr, Cronet_Buffer_Create, void);
P_IMPORT(void, Cronet_Buffer_Destroy, Cronet_BufferPtr);
P_IMPORT(void, Cronet_Buffer_InitWithAlloc, Cronet_BufferPtr, uint64_t);
P_IMPORT(uint64_t, Cronet_Buffer_GetSize, Cronet_BufferPtr);
P_IMPORT(Cronet_RawDataPtr, Cronet_Buffer_GetData, Cronet_BufferPtr);
P_IMPORT(int64_t, Cronet_UrlResponseInfo_received_byte_count_get, Cronet_UrlResponseInfoPtr);
P_IMPORT(Cronet_String, Cronet_Error_message_get, const Cronet_ErrorPtr);

P_IMPORT(bool, Cronet_Engine_StartNetLogToFile, Cronet_EnginePtr self,Cronet_String file_name,bool log_all);
P_IMPORT(void, Cronet_Engine_StopNetLog,Cronet_EnginePtr self);

bool Cronet_Engine_StartNetLogToFile(Cronet_EnginePtr self,
                                     Cronet_String file_name,
                                     bool log_all) {
  return _Cronet_Engine_StartNetLogToFile(self, file_name, true);
}

void Cronet_Engine_StopNetLog(Cronet_EnginePtr self) {return _Cronet_Engine_StopNetLog(self);}

/* Engine Cleanup Tasks */
static void HttpClientDestroy(void* isolate_callback_data,
                         void* peer) {
  std::cout << "Engine Destroy" << std::endl;
  Cronet_EnginePtr ce = reinterpret_cast<Cronet_EnginePtr>(peer);
  _Cronet_Engine_Shutdown(ce);
  _Cronet_Engine_Destroy(ce);
}

void unloadCronet() {
  CLOSELIB(handle);
}

void removeRequest(Cronet_UrlRequestPtr rp) {
  requestNativePorts.erase(rp);
}

// Register our HttpClient object from dart side
void registerHttpClient(Dart_Handle h, Cronet_EnginePtr ce) {
  void* peer = ce;
  intptr_t size = 8;
  Dart_NewFinalizableHandle_DL(h, peer, size, HttpClientDestroy);
}



P_IMPORT(int32_t, Cronet_UrlResponseInfo_http_status_code_get, const Cronet_UrlResponseInfoPtr);
int32_t Cronet_UrlResponseInfo_http_status_code_get(const Cronet_UrlResponseInfoPtr self) {return _Cronet_UrlResponseInfo_http_status_code_get(self);}


P_IMPORT(Cronet_String, Cronet_UrlResponseInfo_http_status_text_get, const Cronet_UrlResponseInfoPtr);
Cronet_String Cronet_UrlResponseInfo_http_status_text_get(const Cronet_UrlResponseInfoPtr self) {return _Cronet_UrlResponseInfo_http_status_text_get(self);}


/* URL Callbacks Implementations */

void OnRedirectReceived(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_String newLocationUrl) {
    dispatchCallback("OnRedirectReceived",request, callbackArgBuilder(2, newLocationUrl, info));
}

void OnResponseStarted(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info) {
    
  // Create and allocate 32kb buffer.
  Cronet_BufferPtr buffer = _Cronet_Buffer_Create();
  _Cronet_Buffer_InitWithAlloc(buffer, 32 * 1024);

  dispatchCallback("OnResponseStarted",request, callbackArgBuilder(1, info));

  // Started reading the response.
  _Cronet_UrlRequest_Read(request, buffer);
   
}


void OnReadCompleted(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_BufferPtr buffer,
    uint64_t bytes_read) {
    dispatchCallback("OnReadCompleted",request, callbackArgBuilder(4, request, info, buffer, bytes_read));
}


void OnSucceeded(Cronet_UrlRequestCallbackPtr self, Cronet_UrlRequestPtr request, Cronet_UrlResponseInfoPtr info) {
  printf("OnSucceeded");
  std::cout << "OnSucceeded called." << std::endl;
  dispatchCallback("OnSucceeded",request, callbackArgBuilder(1, info));
}

void OnFailed(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_ErrorPtr error) {
      printf("OnFailed");
  dispatchCallback("OnFailed",request, callbackArgBuilder(1, _Cronet_Error_message_get(error)));
}

void OnCanceled(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info) {
      printf("OnCanceled");
      dispatchCallback("OnCanceled",request, callbackArgBuilder(0));
}


/* Interface */

Cronet_EnginePtr Cronet_Engine_Create() {
  printf("Cronet_Engine_Create");
  // Checks if cronet is loaded properly
  // As this is the first function to call,
  // if this succeeds, every subsequent use
  // of cronet [handle] should.
  if (!handle) {
    std::clog << dlerror() << std::endl;
    exit(EXIT_FAILURE);
  }
  return _Cronet_Engine_Create();
}

Cronet_RESULT Cronet_Engine_Shutdown(Cronet_EnginePtr self) { return _Cronet_Engine_Shutdown(self); }

// Mapping Cronet Function -> Wrapper function
// Most of them are unchanged, except some.
// Note: Can someone suggest a better way to
// map unchanged APIs?
Cronet_String Cronet_Engine_GetVersionString(Cronet_EnginePtr ce) {return _Cronet_Engine_GetVersionString(ce);}
Cronet_EngineParamsPtr Cronet_EngineParams_Create(void) {return _Cronet_EngineParams_Create();}
void Cronet_EngineParams_Destroy(Cronet_EngineParamsPtr self) {}
void Cronet_EngineParams_enable_check_result_set(
    Cronet_EngineParamsPtr self,
    const bool enable_check_result) {return _Cronet_EngineParams_enable_check_result_set(self,enable_check_result);}

Cronet_QuicHintPtr Cronet_QuicHint_Create(void) {
  return _Cronet_QuicHint_Create();
}

void Cronet_QuicHint_Destroy(Cronet_QuicHintPtr self) {
  return _Cronet_QuicHint_Destroy(self);
}

void Cronet_QuicHint_host_set(Cronet_QuicHintPtr self,
                              const Cronet_String host) {
  return _Cronet_QuicHint_host_set(self, host);
}

void Cronet_QuicHint_port_set(Cronet_QuicHintPtr self, const int32_t port) {
  return _Cronet_QuicHint_port_set(self, port);
}

void Cronet_QuicHint_alternate_port_set(Cronet_QuicHintPtr self,
                                        const int32_t alternate_port) {
  return _Cronet_QuicHint_alternate_port_set(self, alternate_port);
}

void Cronet_EngineParams_user_agent_set(Cronet_EngineParamsPtr self,
                                        const Cronet_String user_agent){_Cronet_EngineParams_user_agent_set(self, user_agent);}

void Cronet_EngineParams_enable_quic_set(Cronet_EngineParamsPtr self,
                                         const bool enable_quic){_Cronet_EngineParams_enable_quic_set(self,enable_quic);}

void Cronet_EngineParams_accept_language_set(
    Cronet_EngineParamsPtr self,
    const Cronet_String accept_language) {return _Cronet_EngineParams_accept_language_set(self, accept_language);}

void Cronet_EngineParams_storage_path_set(Cronet_EngineParamsPtr self,
                                          const Cronet_String storage_path) {
  return _Cronet_EngineParams_storage_path_set(self, storage_path);
}

void Cronet_EngineParams_enable_http2_set(Cronet_EngineParamsPtr self,
                                          const bool enable_http2) {
  return _Cronet_EngineParams_enable_http2_set(self, enable_http2);
}

void Cronet_EngineParams_quic_hints_add(Cronet_EngineParamsPtr self,
                                    const Cronet_QuicHintPtr element) {
  return _Cronet_EngineParams_quic_hints_add(self, element);

}

void Cronet_EngineParams_enable_brotli_set(Cronet_EngineParamsPtr self,
                                           const bool enable_brotli) {
  return _Cronet_EngineParams_enable_brotli_set(self, enable_brotli);
}

void Cronet_EngineParams_http_cache_mode_set(
    Cronet_EngineParamsPtr self,
    const Cronet_EngineParams_HTTP_CACHE_MODE http_cache_mode) {
      return _Cronet_EngineParams_http_cache_mode_set(self, http_cache_mode);
    }

void Cronet_EngineParams_http_cache_max_size_set(
    Cronet_EngineParamsPtr self,
    const int64_t http_cache_max_size) {
  return _Cronet_EngineParams_http_cache_max_size_set(self, http_cache_max_size);
}

Cronet_RESULT Cronet_Engine_StartWithParams(Cronet_EnginePtr self,
                                            Cronet_EngineParamsPtr params) {return _Cronet_Engine_StartWithParams(self, params);}

Cronet_UrlRequestPtr Cronet_UrlRequest_Create(void) {return _Cronet_UrlRequest_Create();}

void Cronet_UrlRequest_Destroy(Cronet_UrlRequestPtr self) {return _Cronet_UrlRequest_Destroy(self);}
void Cronet_UrlRequest_Cancel(Cronet_UrlRequestPtr self) {return _Cronet_UrlRequest_Cancel(self);}

void Cronet_UrlRequest_SetClientContext(Cronet_UrlRequestPtr self, Cronet_ClientContext client_context) {return _Cronet_UrlRequest_SetClientContext(self, client_context);}
Cronet_ClientContext Cronet_UrlRequest_GetClientContext(Cronet_UrlRequestPtr self) {return _Cronet_UrlRequest_GetClientContext(self);}

Cronet_UrlRequestParamsPtr Cronet_UrlRequestParams_Create(void) {return _Cronet_UrlRequestParams_Create();}

void Cronet_UrlRequestParams_http_method_set(Cronet_UrlRequestParamsPtr self, const Cronet_String http_method) {return _Cronet_UrlRequestParams_http_method_set(self, http_method);}

Cronet_RESULT Cronet_UrlRequest_Start(Cronet_UrlRequestPtr self) {return _Cronet_UrlRequest_Start(self);}
Cronet_RESULT Cronet_UrlRequest_FollowRedirect(Cronet_UrlRequestPtr self) {return _Cronet_UrlRequest_FollowRedirect(self);}
Cronet_RESULT Cronet_UrlRequest_Read(Cronet_UrlRequestPtr self, Cronet_BufferPtr buffer) {return _Cronet_UrlRequest_Read(self, buffer);}

Cronet_RawDataPtr Cronet_Buffer_GetData(Cronet_BufferPtr buffer) {return _Cronet_Buffer_GetData(buffer);}
uint64_t Cronet_Buffer_GetSize(Cronet_BufferPtr self) {return _Cronet_Buffer_GetSize(self);}


ExecutorPtr Create_Executor() {
  return new SampleExecutor();
}

void Destroy_Executor(ExecutorPtr executor) {
  delete reinterpret_cast<SampleExecutor*>(executor);
}


// NOTE: Changed from original cronet's api. executor & callback params aren't needed
Cronet_RESULT Cronet_UrlRequest_Init(Cronet_UrlRequestPtr self, Cronet_EnginePtr engine, Cronet_String url, Cronet_UrlRequestParamsPtr params, ExecutorPtr _executor) {
    SampleExecutor* executor = reinterpret_cast<SampleExecutor*>(_executor);
    executor->Init();
    Cronet_UrlRequestCallbackPtr urCallback = _Cronet_UrlRequestCallback_CreateWith(OnRedirectReceived, OnResponseStarted, OnReadCompleted,
        OnSucceeded, OnFailed, OnCanceled);
    return _Cronet_UrlRequest_InitWithParams(self, engine, url, params, urCallback, executor->GetExecutor());

} 

