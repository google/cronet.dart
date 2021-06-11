// This is same as cronet's header file except a few changes here and there.
#ifndef WRAPPER_H_
#define WRAPPER_H_

// #include "dart_api.h"
// #include "dart_native_api.h"

#include "../include/dart/dart_api_dl.h"


#include"wrapper_export.h"

#include<stdbool.h>

#ifdef __linux__
  #include <dlfcn.h>
  #define LIBTYPE void*
  #define OPENLIB(libname) dlopen((libname), RTLD_NOW)
  #define CLOSELIB(handle) dlclose((handle))
  #define CRONET_LIB_PREFIX "libcronet"
  #define CRONET_LIB_EXTENSION ".so"
#elif defined(_WIN32)
#include<windows.h>
  #define LIBTYPE HINSTANCE
  #define OPENLIB(libname) LoadLibrary(TEXT(libname))
  #define dlsym(lib, fn) (void *)GetProcAddress((lib), (fn))
  #define dlerror() GetLastError()
  #define CLOSELIB(handle) FreeLibrary((handle))
  #define CRONET_LIB_PREFIX "cronet"
  #define CRONET_LIB_EXTENSION ".dll"
#endif


#ifdef __cplusplus


extern "C" {
#endif

#include <stdint.h>


/* Wrapper Helpers */


DART_EXPORT void dispatchCallback(char* methodname);

DART_EXPORT intptr_t InitDartApiDL(void* data);
DART_EXPORT void unloadCronet();


typedef void* ExecutorPtr;

DART_EXPORT ExecutorPtr Create_Executor();
DART_EXPORT void Destroy_Executor(ExecutorPtr executor);

/* typedefs, enums & struct declaration from cronet. Derived from cronet.idl_c.h */

typedef const char* Cronet_String;
typedef void* Cronet_RawDataPtr;
typedef void* Cronet_ClientContext;

// Forward declare interfaces.
typedef struct Cronet_Buffer Cronet_Buffer;
typedef struct Cronet_Buffer* Cronet_BufferPtr;
typedef struct Cronet_BufferCallback Cronet_BufferCallback;
typedef struct Cronet_BufferCallback* Cronet_BufferCallbackPtr;
typedef struct Cronet_Runnable Cronet_Runnable;
typedef struct Cronet_Runnable* Cronet_RunnablePtr;
typedef struct Cronet_Executor Cronet_Executor;
typedef struct Cronet_Executor* Cronet_ExecutorPtr;
typedef struct Cronet_Engine Cronet_Engine;
typedef struct Cronet_Engine* Cronet_EnginePtr;
typedef struct Cronet_UrlRequestStatusListener Cronet_UrlRequestStatusListener;
typedef struct Cronet_UrlRequestStatusListener*
    Cronet_UrlRequestStatusListenerPtr;
typedef struct Cronet_UrlRequestCallback Cronet_UrlRequestCallback;
typedef struct Cronet_UrlRequestCallback* Cronet_UrlRequestCallbackPtr;
typedef struct Cronet_UploadDataSink Cronet_UploadDataSink;
typedef struct Cronet_UploadDataSink* Cronet_UploadDataSinkPtr;
typedef struct Cronet_UploadDataProvider Cronet_UploadDataProvider;
typedef struct Cronet_UploadDataProvider* Cronet_UploadDataProviderPtr;
typedef struct Cronet_UrlRequest Cronet_UrlRequest;
typedef struct Cronet_UrlRequest* Cronet_UrlRequestPtr;
typedef struct Cronet_RequestFinishedInfoListener
    Cronet_RequestFinishedInfoListener;
typedef struct Cronet_RequestFinishedInfoListener*
    Cronet_RequestFinishedInfoListenerPtr;

// Forward declare structs.
typedef struct Cronet_Error Cronet_Error;
typedef struct Cronet_Error* Cronet_ErrorPtr;
typedef struct Cronet_QuicHint Cronet_QuicHint;
typedef struct Cronet_QuicHint* Cronet_QuicHintPtr;
typedef struct Cronet_PublicKeyPins Cronet_PublicKeyPins;
typedef struct Cronet_PublicKeyPins* Cronet_PublicKeyPinsPtr;
typedef struct Cronet_EngineParams Cronet_EngineParams;
typedef struct Cronet_EngineParams* Cronet_EngineParamsPtr;
typedef struct Cronet_HttpHeader Cronet_HttpHeader;
typedef struct Cronet_HttpHeader* Cronet_HttpHeaderPtr;
typedef struct Cronet_UrlResponseInfo Cronet_UrlResponseInfo;
typedef struct Cronet_UrlResponseInfo* Cronet_UrlResponseInfoPtr;
typedef struct Cronet_UrlRequestParams Cronet_UrlRequestParams;
typedef struct Cronet_UrlRequestParams* Cronet_UrlRequestParamsPtr;
typedef struct Cronet_DateTime Cronet_DateTime;
typedef struct Cronet_DateTime* Cronet_DateTimePtr;
typedef struct Cronet_Metrics Cronet_Metrics;
typedef struct Cronet_Metrics* Cronet_MetricsPtr;
typedef struct Cronet_RequestFinishedInfo Cronet_RequestFinishedInfo;
typedef struct Cronet_RequestFinishedInfo* Cronet_RequestFinishedInfoPtr;

// Declare enums
typedef enum Cronet_RESULT {
  Cronet_RESULT_SUCCESS = 0,
  Cronet_RESULT_ILLEGAL_ARGUMENT = -100,
  Cronet_RESULT_ILLEGAL_ARGUMENT_STORAGE_PATH_MUST_EXIST = -101,
  Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_PIN = -102,
  Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HOSTNAME = -103,
  Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_METHOD = -104,
  Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_HEADER = -105,
  Cronet_RESULT_ILLEGAL_STATE = -200,
  Cronet_RESULT_ILLEGAL_STATE_STORAGE_PATH_IN_USE = -201,
  Cronet_RESULT_ILLEGAL_STATE_CANNOT_SHUTDOWN_ENGINE_FROM_NETWORK_THREAD = -202,
  Cronet_RESULT_ILLEGAL_STATE_ENGINE_ALREADY_STARTED = -203,
  Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_STARTED = -204,
  Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_INITIALIZED = -205,
  Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_INITIALIZED = -206,
  Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_STARTED = -207,
  Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_REDIRECT = -208,
  Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_READ = -209,
  Cronet_RESULT_ILLEGAL_STATE_READ_FAILED = -210,
  Cronet_RESULT_NULL_POINTER = -300,
  Cronet_RESULT_NULL_POINTER_HOSTNAME = -301,
  Cronet_RESULT_NULL_POINTER_SHA256_PINS = -302,
  Cronet_RESULT_NULL_POINTER_EXPIRATION_DATE = -303,
  Cronet_RESULT_NULL_POINTER_ENGINE = -304,
  Cronet_RESULT_NULL_POINTER_URL = -305,
  Cronet_RESULT_NULL_POINTER_CALLBACK = -306,
  Cronet_RESULT_NULL_POINTER_EXECUTOR = -307,
  Cronet_RESULT_NULL_POINTER_METHOD = -308,
  Cronet_RESULT_NULL_POINTER_HEADER_NAME = -309,
  Cronet_RESULT_NULL_POINTER_HEADER_VALUE = -310,
  Cronet_RESULT_NULL_POINTER_PARAMS = -311,
  Cronet_RESULT_NULL_POINTER_REQUEST_FINISHED_INFO_LISTENER_EXECUTOR = -312,
} Cronet_RESULT;

typedef enum Cronet_Error_ERROR_CODE {
  Cronet_Error_ERROR_CODE_ERROR_CALLBACK = 0,
  Cronet_Error_ERROR_CODE_ERROR_HOSTNAME_NOT_RESOLVED = 1,
  Cronet_Error_ERROR_CODE_ERROR_INTERNET_DISCONNECTED = 2,
  Cronet_Error_ERROR_CODE_ERROR_NETWORK_CHANGED = 3,
  Cronet_Error_ERROR_CODE_ERROR_TIMED_OUT = 4,
  Cronet_Error_ERROR_CODE_ERROR_CONNECTION_CLOSED = 5,
  Cronet_Error_ERROR_CODE_ERROR_CONNECTION_TIMED_OUT = 6,
  Cronet_Error_ERROR_CODE_ERROR_CONNECTION_REFUSED = 7,
  Cronet_Error_ERROR_CODE_ERROR_CONNECTION_RESET = 8,
  Cronet_Error_ERROR_CODE_ERROR_ADDRESS_UNREACHABLE = 9,
  Cronet_Error_ERROR_CODE_ERROR_QUIC_PROTOCOL_FAILED = 10,
  Cronet_Error_ERROR_CODE_ERROR_OTHER = 11,
} Cronet_Error_ERROR_CODE;

typedef enum Cronet_EngineParams_HTTP_CACHE_MODE {
  Cronet_EngineParams_HTTP_CACHE_MODE_DISABLED = 0,
  Cronet_EngineParams_HTTP_CACHE_MODE_IN_MEMORY = 1,
  Cronet_EngineParams_HTTP_CACHE_MODE_DISK_NO_HTTP = 2,
  Cronet_EngineParams_HTTP_CACHE_MODE_DISK = 3,
} Cronet_EngineParams_HTTP_CACHE_MODE;

typedef enum Cronet_UrlRequestParams_REQUEST_PRIORITY {
  Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_IDLE = 0,
  Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_LOWEST = 1,
  Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_LOW = 2,
  Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_MEDIUM = 3,
  Cronet_UrlRequestParams_REQUEST_PRIORITY_REQUEST_PRIORITY_HIGHEST = 4,
} Cronet_UrlRequestParams_REQUEST_PRIORITY;

typedef enum Cronet_UrlRequestParams_IDEMPOTENCY {
  Cronet_UrlRequestParams_IDEMPOTENCY_DEFAULT_IDEMPOTENCY = 0,
  Cronet_UrlRequestParams_IDEMPOTENCY_IDEMPOTENT = 1,
  Cronet_UrlRequestParams_IDEMPOTENCY_NOT_IDEMPOTENT = 2,
} Cronet_UrlRequestParams_IDEMPOTENCY;

typedef enum Cronet_RequestFinishedInfo_FINISHED_REASON {
  Cronet_RequestFinishedInfo_FINISHED_REASON_SUCCEEDED = 0,
  Cronet_RequestFinishedInfo_FINISHED_REASON_FAILED = 1,
  Cronet_RequestFinishedInfo_FINISHED_REASON_CANCELED = 2,
} Cronet_RequestFinishedInfo_FINISHED_REASON;

typedef enum Cronet_UrlRequestStatusListener_Status {
  Cronet_UrlRequestStatusListener_Status_INVALID = -1,
  Cronet_UrlRequestStatusListener_Status_IDLE = 0,
  Cronet_UrlRequestStatusListener_Status_WAITING_FOR_STALLED_SOCKET_POOL = 1,
  Cronet_UrlRequestStatusListener_Status_WAITING_FOR_AVAILABLE_SOCKET = 2,
  Cronet_UrlRequestStatusListener_Status_WAITING_FOR_DELEGATE = 3,
  Cronet_UrlRequestStatusListener_Status_WAITING_FOR_CACHE = 4,
  Cronet_UrlRequestStatusListener_Status_DOWNLOADING_PAC_FILE = 5,
  Cronet_UrlRequestStatusListener_Status_RESOLVING_PROXY_FOR_URL = 6,
  Cronet_UrlRequestStatusListener_Status_RESOLVING_HOST_IN_PAC_FILE = 7,
  Cronet_UrlRequestStatusListener_Status_ESTABLISHING_PROXY_TUNNEL = 8,
  Cronet_UrlRequestStatusListener_Status_RESOLVING_HOST = 9,
  Cronet_UrlRequestStatusListener_Status_CONNECTING = 10,
  Cronet_UrlRequestStatusListener_Status_SSL_HANDSHAKE = 11,
  Cronet_UrlRequestStatusListener_Status_SENDING_REQUEST = 12,
  Cronet_UrlRequestStatusListener_Status_WAITING_FOR_RESPONSE = 13,
  Cronet_UrlRequestStatusListener_Status_READING_RESPONSE = 14,
} Cronet_UrlRequestStatusListener_Status;


DART_EXPORT void registerHttpClient(Dart_Handle h, Cronet_EnginePtr ce);
DART_EXPORT void registerCallbackHandler(Dart_Port nativePort, Cronet_UrlRequestPtr rp);
DART_EXPORT void removeRequest(Cronet_UrlRequestPtr rp);
/* function signatures derived from cronet.idl_c.h. 
NOTE: Some are modified if required for wrapping */


///////////////////////
// Struct Cronet_QuicHint.
CRONET_EXPORT Cronet_QuicHintPtr Cronet_QuicHint_Create(void);
CRONET_EXPORT void Cronet_QuicHint_Destroy(Cronet_QuicHintPtr self);
// Cronet_QuicHint setters.
CRONET_EXPORT
void Cronet_QuicHint_host_set(Cronet_QuicHintPtr self,
                              const Cronet_String host);
CRONET_EXPORT
void Cronet_QuicHint_port_set(Cronet_QuicHintPtr self, const int32_t port);
CRONET_EXPORT
void Cronet_QuicHint_alternate_port_set(Cronet_QuicHintPtr self,
                                        const int32_t alternate_port);



CRONET_EXPORT Cronet_EnginePtr Cronet_Engine_Create(void);

CRONET_EXPORT Cronet_String Cronet_Engine_GetVersionString(Cronet_EnginePtr self);

CRONET_EXPORT Cronet_EngineParamsPtr Cronet_EngineParams_Create(void);
CRONET_EXPORT void Cronet_EngineParams_Destroy(Cronet_EngineParamsPtr self);

CRONET_EXPORT
void Cronet_EngineParams_user_agent_set(Cronet_EngineParamsPtr self,
                                        const Cronet_String user_agent);

CRONET_EXPORT
void Cronet_EngineParams_enable_quic_set(Cronet_EngineParamsPtr self,
                                         const bool enable_quic);

CRONET_EXPORT
void Cronet_EngineParams_quic_hints_add(Cronet_EngineParamsPtr self,
                                        const Cronet_QuicHintPtr element);

CRONET_EXPORT
void Cronet_EngineParams_accept_language_set(
    Cronet_EngineParamsPtr self,
    const Cronet_String accept_language);

CRONET_EXPORT
void Cronet_EngineParams_storage_path_set(Cronet_EngineParamsPtr self,
                                          const Cronet_String storage_path);

CRONET_EXPORT
void Cronet_EngineParams_enable_http2_set(Cronet_EngineParamsPtr self,
                                          const bool enable_http2);
CRONET_EXPORT
void Cronet_EngineParams_enable_brotli_set(Cronet_EngineParamsPtr self,
                                           const bool enable_brotli);
CRONET_EXPORT
void Cronet_EngineParams_http_cache_mode_set(
    Cronet_EngineParamsPtr self,
    const Cronet_EngineParams_HTTP_CACHE_MODE http_cache_mode);
CRONET_EXPORT
void Cronet_EngineParams_http_cache_max_size_set(
    Cronet_EngineParamsPtr self,
    const int64_t http_cache_max_size);
                                    
CRONET_EXPORT
Cronet_RESULT Cronet_Engine_StartWithParams(Cronet_EnginePtr self,
                                            Cronet_EngineParamsPtr params);
CRONET_EXPORT
Cronet_RESULT Cronet_Engine_Shutdown(Cronet_EnginePtr self);

typedef void (*Cronet_UrlRequestCallback_OnRedirectReceivedFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_String new_location_url);
typedef void (*Cronet_UrlRequestCallback_OnResponseStartedFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info);
typedef void (*Cronet_UrlRequestCallback_OnReadCompletedFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_BufferPtr buffer,
    uint64_t bytes_read);
typedef void (*Cronet_UrlRequestCallback_OnSucceededFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info);
typedef void (*Cronet_UrlRequestCallback_OnFailedFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info,
    Cronet_ErrorPtr error);
typedef void (*Cronet_UrlRequestCallback_OnCanceledFunc)(
    Cronet_UrlRequestCallbackPtr self,
    Cronet_UrlRequestPtr request,
    Cronet_UrlResponseInfoPtr info);


// Create an instance of Cronet_UrlRequest.
CRONET_EXPORT Cronet_UrlRequestPtr Cronet_UrlRequest_Create(void);
// Destroy an instance of Cronet_UrlRequest.
CRONET_EXPORT void Cronet_UrlRequest_Destroy(Cronet_UrlRequestPtr self);

CRONET_EXPORT void Cronet_UrlRequest_Cancel(Cronet_UrlRequestPtr self);
// Set and get app-specific Cronet_ClientContext.
CRONET_EXPORT void Cronet_UrlRequest_SetClientContext(
    Cronet_UrlRequestPtr self,
    Cronet_ClientContext client_context);
CRONET_EXPORT Cronet_ClientContext
Cronet_UrlRequest_GetClientContext(Cronet_UrlRequestPtr self);

// Struct Cronet_UrlRequestParams.
CRONET_EXPORT Cronet_UrlRequestParamsPtr Cronet_UrlRequestParams_Create(void);
// Cronet_UrlRequestParams setters.
CRONET_EXPORT
void Cronet_UrlRequestParams_http_method_set(Cronet_UrlRequestParamsPtr self,
                                             const Cronet_String http_method);

CRONET_EXPORT
void Cronet_UrlRequestParams_request_headers_add(
    Cronet_UrlRequestParamsPtr self,
    const Cronet_HttpHeaderPtr element);

CRONET_EXPORT
Cronet_RESULT Cronet_UrlRequest_Start(Cronet_UrlRequestPtr self);
CRONET_EXPORT
Cronet_RESULT Cronet_UrlRequest_FollowRedirect(Cronet_UrlRequestPtr self);
CRONET_EXPORT
Cronet_RESULT Cronet_UrlRequest_Read(Cronet_UrlRequestPtr self,
                                     Cronet_BufferPtr buffer);

DART_EXPORT Cronet_RESULT Cronet_UrlRequest_Init(Cronet_UrlRequestPtr self, Cronet_EnginePtr engine, Cronet_String url, Cronet_UrlRequestParamsPtr params, ExecutorPtr _executor);


CRONET_EXPORT Cronet_HttpHeaderPtr Cronet_HttpHeader_Create(void);
CRONET_EXPORT void Cronet_HttpHeader_Destroy(Cronet_HttpHeaderPtr self);
// Cronet_HttpHeader setters.
CRONET_EXPORT
void Cronet_HttpHeader_name_set(Cronet_HttpHeaderPtr self,
                                const Cronet_String name);
CRONET_EXPORT
void Cronet_HttpHeader_value_set(Cronet_HttpHeaderPtr self,
                                 const Cronet_String value);

CRONET_EXPORT
int32_t Cronet_UrlResponseInfo_http_status_code_get(
    const Cronet_UrlResponseInfoPtr self);
CRONET_EXPORT
Cronet_String Cronet_UrlResponseInfo_http_status_text_get(
    const Cronet_UrlResponseInfoPtr self);

// Create an instance of Cronet_Buffer.
// CRONET_EXPORT Cronet_BufferPtr Cronet_Buffer_Create(void);

// Destroy an instance of Cronet_Buffer.
// CRONET_EXPORT void Cronet_Buffer_Destroy(Cronet_BufferPtr self);

// CRONET_EXPORT void Cronet_Buffer_InitWithAlloc(Cronet_BufferPtr self, uint64_t size);

CRONET_EXPORT uint64_t Cronet_Buffer_GetSize(Cronet_BufferPtr self);
CRONET_EXPORT Cronet_RawDataPtr Cronet_Buffer_GetData(Cronet_BufferPtr self);

CRONET_EXPORT
bool Cronet_Engine_StartNetLogToFile(Cronet_EnginePtr self,
                                     Cronet_String file_name,
                                     bool log_all);
CRONET_EXPORT
void Cronet_Engine_StopNetLog(Cronet_EnginePtr self);

// CRONET_EXPORT
// Cronet_String Cronet_Error_message_get(const Cronet_ErrorPtr self);


/* executor only */

typedef void (*Cronet_Executor_ExecuteFunc)(Cronet_ExecutorPtr self, Cronet_RunnablePtr command);


#ifdef __cplusplus
}
#endif

#endif  // WRAPPER_H_