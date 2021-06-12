// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef WRAPPER_H_
#define WRAPPER_H_

#include "../include/dart/dart_api_dl.h"
#include "../include/cronet/cronet.idl_c.h"


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

DART_EXPORT void dispatchCallback(char* methodname);
DART_EXPORT intptr_t InitDartApiDL(void* data);
DART_EXPORT void unloadCronet();
typedef void* ExecutorPtr;

DART_EXPORT ExecutorPtr Create_Executor();
DART_EXPORT void Destroy_Executor(ExecutorPtr executor);

DART_EXPORT void registerHttpClient(Dart_Handle h, Cronet_EnginePtr ce);
DART_EXPORT void registerCallbackHandler(Dart_Port nativePort, Cronet_UrlRequestPtr rp);
DART_EXPORT void removeRequest(Cronet_UrlRequestPtr rp);
DART_EXPORT Cronet_RESULT Cronet_UrlRequest_Init(Cronet_UrlRequestPtr self, Cronet_EnginePtr engine, Cronet_String url, Cronet_UrlRequestParamsPtr params, ExecutorPtr _executor);

/* executor only */

typedef void (*Cronet_Executor_ExecuteFunc)(Cronet_ExecutorPtr self, Cronet_RunnablePtr command);


#ifdef __cplusplus
}
#endif

#endif  // WRAPPER_H_
