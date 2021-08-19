// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings to Wrapper for Cronet
class Wrapper {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  Wrapper(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  Wrapper.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  ffi.Pointer<ffi.Int8> VersionString() {
    return _VersionString();
  }

  late final _VersionString_ptr =
      _lookup<ffi.NativeFunction<_c_VersionString>>('VersionString');
  late final _dart_VersionString _VersionString =
      _VersionString_ptr.asFunction<_dart_VersionString>();

  int InitDartApiDL(
    ffi.Pointer<ffi.Void> data,
  ) {
    return _InitDartApiDL(
      data,
    );
  }

  late final _InitDartApiDL_ptr =
      _lookup<ffi.NativeFunction<_c_InitDartApiDL>>('InitDartApiDL');
  late final _dart_InitDartApiDL _InitDartApiDL =
      _InitDartApiDL_ptr.asFunction<_dart_InitDartApiDL>();

  void InitCronetApi(
    ffi.Pointer<ffi.NativeFunction<_typedefC_1>> Cronet_Engine_Shutdown,
    ffi.Pointer<ffi.NativeFunction<_typedefC_2>> Cronet_Engine_Destroy,
    ffi.Pointer<ffi.NativeFunction<_typedefC_3>> Cronet_Buffer_Create,
    ffi.Pointer<ffi.NativeFunction<_typedefC_4>> Cronet_Buffer_InitWithAlloc,
    ffi.Pointer<ffi.NativeFunction<_typedefC_5>>
        Cronet_UrlResponseInfo_http_status_code_get,
    ffi.Pointer<ffi.NativeFunction<_typedefC_6>> Cronet_Error_message_get,
    ffi.Pointer<ffi.NativeFunction<_typedefC_7>>
        Cronet_UrlResponseInfo_http_status_text_get,
    ffi.Pointer<ffi.NativeFunction<_typedefC_8>>
        Cronet_UploadDataProvider_GetClientContext,
  ) {
    return _InitCronetApi(
      Cronet_Engine_Shutdown,
      Cronet_Engine_Destroy,
      Cronet_Buffer_Create,
      Cronet_Buffer_InitWithAlloc,
      Cronet_UrlResponseInfo_http_status_code_get,
      Cronet_Error_message_get,
      Cronet_UrlResponseInfo_http_status_text_get,
      Cronet_UploadDataProvider_GetClientContext,
    );
  }

  late final _InitCronetApi_ptr =
      _lookup<ffi.NativeFunction<_c_InitCronetApi>>('InitCronetApi');
  late final _dart_InitCronetApi _InitCronetApi =
      _InitCronetApi_ptr.asFunction<_dart_InitCronetApi>();

  /// Forward declaration. Implementation on sample_executor.cc
  void InitCronetExecutorApi(
    ffi.Pointer<ffi.NativeFunction<_typedefC_9>> Cronet_Executor_CreateWith,
    ffi.Pointer<ffi.NativeFunction<_typedefC_10>>
        Cronet_Executor_SetClientContext,
    ffi.Pointer<ffi.NativeFunction<_typedefC_11>>
        Cronet_Executor_GetClientContext,
    ffi.Pointer<ffi.NativeFunction<_typedefC_12>> Cronet_Executor_Destroy,
    ffi.Pointer<ffi.NativeFunction<_typedefC_13>> Cronet_Runnable_Run,
    ffi.Pointer<ffi.NativeFunction<_typedefC_14>> Cronet_Runnable_Destroy,
  ) {
    return _InitCronetExecutorApi(
      Cronet_Executor_CreateWith,
      Cronet_Executor_SetClientContext,
      Cronet_Executor_GetClientContext,
      Cronet_Executor_Destroy,
      Cronet_Runnable_Run,
      Cronet_Runnable_Destroy,
    );
  }

  late final _InitCronetExecutorApi_ptr =
      _lookup<ffi.NativeFunction<_c_InitCronetExecutorApi>>(
          'InitCronetExecutorApi');
  late final _dart_InitCronetExecutorApi _InitCronetExecutorApi =
      _InitCronetExecutorApi_ptr.asFunction<_dart_InitCronetExecutorApi>();

  void RegisterHttpClient(
    Object h,
    ffi.Pointer<Cronet_EnginePtr> ce,
  ) {
    return _RegisterHttpClient(
      h,
      ce,
    );
  }

  late final _RegisterHttpClient_ptr =
      _lookup<ffi.NativeFunction<_c_RegisterHttpClient>>('RegisterHttpClient');
  late final _dart_RegisterHttpClient _RegisterHttpClient =
      _RegisterHttpClient_ptr.asFunction<_dart_RegisterHttpClient>();

  void RegisterCallbackHandler(
    int nativePort,
    ffi.Pointer<Cronet_UrlRequest> rp,
  ) {
    return _RegisterCallbackHandler(
      nativePort,
      rp,
    );
  }

  late final _RegisterCallbackHandler_ptr =
      _lookup<ffi.NativeFunction<_c_RegisterCallbackHandler>>(
          'RegisterCallbackHandler');
  late final _dart_RegisterCallbackHandler _RegisterCallbackHandler =
      _RegisterCallbackHandler_ptr.asFunction<_dart_RegisterCallbackHandler>();

  void RemoveRequest(
    ffi.Pointer<Cronet_UrlRequest> rp,
  ) {
    return _RemoveRequest(
      rp,
    );
  }

  late final _RemoveRequest_ptr =
      _lookup<ffi.NativeFunction<_c_RemoveRequest>>('RemoveRequest');
  late final _dart_RemoveRequest _RemoveRequest =
      _RemoveRequest_ptr.asFunction<_dart_RemoveRequest>();

  /// Callbacks. ISSUE: https://github.com/dart-lang/sdk/issues/37022
  void OnRedirectReceived(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
    ffi.Pointer<ffi.Int8> newLocationUrl,
  ) {
    return _OnRedirectReceived(
      self,
      request,
      info,
      newLocationUrl,
    );
  }

  late final _OnRedirectReceived_ptr =
      _lookup<ffi.NativeFunction<Native_OnRedirectReceived>>(
          'OnRedirectReceived');
  late final _dart_OnRedirectReceived _OnRedirectReceived =
      _OnRedirectReceived_ptr.asFunction<_dart_OnRedirectReceived>();

  void OnResponseStarted(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ) {
    return _OnResponseStarted(
      self,
      request,
      info,
    );
  }

  late final _OnResponseStarted_ptr =
      _lookup<ffi.NativeFunction<Native_OnResponseStarted>>(
          'OnResponseStarted');
  late final _dart_OnResponseStarted _OnResponseStarted =
      _OnResponseStarted_ptr.asFunction<_dart_OnResponseStarted>();

  void OnReadCompleted(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
    ffi.Pointer<Cronet_BufferPtr> buffer,
    int bytes_read,
  ) {
    return _OnReadCompleted(
      self,
      request,
      info,
      buffer,
      bytes_read,
    );
  }

  late final _OnReadCompleted_ptr =
      _lookup<ffi.NativeFunction<Native_OnReadCompleted>>('OnReadCompleted');
  late final _dart_OnReadCompleted _OnReadCompleted =
      _OnReadCompleted_ptr.asFunction<_dart_OnReadCompleted>();

  void OnSucceeded(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ) {
    return _OnSucceeded(
      self,
      request,
      info,
    );
  }

  late final _OnSucceeded_ptr =
      _lookup<ffi.NativeFunction<Native_OnSucceeded>>('OnSucceeded');
  late final _dart_OnSucceeded _OnSucceeded =
      _OnSucceeded_ptr.asFunction<_dart_OnSucceeded>();

  void OnFailed(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
    ffi.Pointer<Cronet_ErrorPtr> error,
  ) {
    return _OnFailed(
      self,
      request,
      info,
      error,
    );
  }

  late final _OnFailed_ptr =
      _lookup<ffi.NativeFunction<Native_OnFailed>>('OnFailed');
  late final _dart_OnFailed _OnFailed =
      _OnFailed_ptr.asFunction<_dart_OnFailed>();

  void OnCanceled(
    ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
    ffi.Pointer<Cronet_UrlRequest> request,
    ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ) {
    return _OnCanceled(
      self,
      request,
      info,
    );
  }

  late final _OnCanceled_ptr =
      _lookup<ffi.NativeFunction<Native_OnCanceled>>('OnCanceled');
  late final _dart_OnCanceled _OnCanceled =
      _OnCanceled_ptr.asFunction<_dart_OnCanceled>();

  /// Sample Executor C APIs
  ffi.Pointer<SampleExecutor> SampleExecutorCreate() {
    return _SampleExecutorCreate();
  }

  late final _SampleExecutorCreate_ptr =
      _lookup<ffi.NativeFunction<_c_SampleExecutorCreate>>(
          'SampleExecutorCreate');
  late final _dart_SampleExecutorCreate _SampleExecutorCreate =
      _SampleExecutorCreate_ptr.asFunction<_dart_SampleExecutorCreate>();

  void SampleExecutorDestroy(
    ffi.Pointer<SampleExecutor> executor,
  ) {
    return _SampleExecutorDestroy(
      executor,
    );
  }

  late final _SampleExecutorDestroy_ptr =
      _lookup<ffi.NativeFunction<_c_SampleExecutorDestroy>>(
          'SampleExecutorDestroy');
  late final _dart_SampleExecutorDestroy _SampleExecutorDestroy =
      _SampleExecutorDestroy_ptr.asFunction<_dart_SampleExecutorDestroy>();

  void InitSampleExecutor(
    ffi.Pointer<SampleExecutor> self,
  ) {
    return _InitSampleExecutor(
      self,
    );
  }

  late final _InitSampleExecutor_ptr =
      _lookup<ffi.NativeFunction<_c_InitSampleExecutor>>('InitSampleExecutor');
  late final _dart_InitSampleExecutor _InitSampleExecutor =
      _InitSampleExecutor_ptr.asFunction<_dart_InitSampleExecutor>();

  ffi.Pointer<Cronet_ExecutorPtr> SampleExecutor_Cronet_ExecutorPtr_get(
    ffi.Pointer<SampleExecutor> self,
  ) {
    return _SampleExecutor_Cronet_ExecutorPtr_get(
      self,
    );
  }

  late final _SampleExecutor_Cronet_ExecutorPtr_get_ptr =
      _lookup<ffi.NativeFunction<_c_SampleExecutor_Cronet_ExecutorPtr_get>>(
          'SampleExecutor_Cronet_ExecutorPtr_get');
  late final _dart_SampleExecutor_Cronet_ExecutorPtr_get
      _SampleExecutor_Cronet_ExecutorPtr_get =
      _SampleExecutor_Cronet_ExecutorPtr_get_ptr.asFunction<
          _dart_SampleExecutor_Cronet_ExecutorPtr_get>();

  /// Upload Data Provider C APIs
  ffi.Pointer<UploadDataProvider> UploadDataProviderCreate() {
    return _UploadDataProviderCreate();
  }

  late final _UploadDataProviderCreate_ptr =
      _lookup<ffi.NativeFunction<_c_UploadDataProviderCreate>>(
          'UploadDataProviderCreate');
  late final _dart_UploadDataProviderCreate _UploadDataProviderCreate =
      _UploadDataProviderCreate_ptr.asFunction<
          _dart_UploadDataProviderCreate>();

  void UploadDataProviderDestroy(
    ffi.Pointer<UploadDataProvider> upload_data_provided,
  ) {
    return _UploadDataProviderDestroy(
      upload_data_provided,
    );
  }

  late final _UploadDataProviderDestroy_ptr =
      _lookup<ffi.NativeFunction<_c_UploadDataProviderDestroy>>(
          'UploadDataProviderDestroy');
  late final _dart_UploadDataProviderDestroy _UploadDataProviderDestroy =
      _UploadDataProviderDestroy_ptr.asFunction<
          _dart_UploadDataProviderDestroy>();

  void UploadDataProviderInit(
    ffi.Pointer<UploadDataProvider> self,
    int length,
    ffi.Pointer<Cronet_UrlRequest> request,
  ) {
    return _UploadDataProviderInit(
      self,
      length,
      request,
    );
  }

  late final _UploadDataProviderInit_ptr =
      _lookup<ffi.NativeFunction<_c_UploadDataProviderInit>>(
          'UploadDataProviderInit');
  late final _dart_UploadDataProviderInit _UploadDataProviderInit =
      _UploadDataProviderInit_ptr.asFunction<_dart_UploadDataProviderInit>();

  int UploadDataProvider_GetLength(
    ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ) {
    return _UploadDataProvider_GetLength(
      self,
    );
  }

  late final _UploadDataProvider_GetLength_ptr =
      _lookup<ffi.NativeFunction<Native_UploadDataProvider_GetLength>>(
          'UploadDataProvider_GetLength');
  late final _dart_UploadDataProvider_GetLength _UploadDataProvider_GetLength =
      _UploadDataProvider_GetLength_ptr.asFunction<
          _dart_UploadDataProvider_GetLength>();

  void UploadDataProvider_Read(
    ffi.Pointer<Cronet_UploadDataProviderPtr> self,
    ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
    ffi.Pointer<Cronet_BufferPtr> buffer,
  ) {
    return _UploadDataProvider_Read(
      self,
      upload_data_sink,
      buffer,
    );
  }

  late final _UploadDataProvider_Read_ptr =
      _lookup<ffi.NativeFunction<Native_UploadDataProvider_Read>>(
          'UploadDataProvider_Read');
  late final _dart_UploadDataProvider_Read _UploadDataProvider_Read =
      _UploadDataProvider_Read_ptr.asFunction<_dart_UploadDataProvider_Read>();

  void UploadDataProvider_Rewind(
    ffi.Pointer<Cronet_UploadDataProviderPtr> self,
    ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
  ) {
    return _UploadDataProvider_Rewind(
      self,
      upload_data_sink,
    );
  }

  late final _UploadDataProvider_Rewind_ptr =
      _lookup<ffi.NativeFunction<Native_UploadDataProvider_Rewind>>(
          'UploadDataProvider_Rewind');
  late final _dart_UploadDataProvider_Rewind _UploadDataProvider_Rewind =
      _UploadDataProvider_Rewind_ptr.asFunction<
          _dart_UploadDataProvider_Rewind>();

  void UploadDataProvider_CloseFunc(
    ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ) {
    return _UploadDataProvider_CloseFunc(
      self,
    );
  }

  late final _UploadDataProvider_CloseFunc_ptr =
      _lookup<ffi.NativeFunction<Native_UploadDataProvider_CloseFunc>>(
          'UploadDataProvider_CloseFunc');
  late final _dart_UploadDataProvider_CloseFunc _UploadDataProvider_CloseFunc =
      _UploadDataProvider_CloseFunc_ptr.asFunction<
          _dart_UploadDataProvider_CloseFunc>();

  late final addresses = _SymbolAddresses(this);
}

class _SymbolAddresses {
  final Wrapper _library;
  _SymbolAddresses(this._library);
  ffi.Pointer<ffi.NativeFunction<Native_OnRedirectReceived>>
      get OnRedirectReceived => _library._OnRedirectReceived_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_OnResponseStarted>>
      get OnResponseStarted => _library._OnResponseStarted_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_OnReadCompleted>> get OnReadCompleted =>
      _library._OnReadCompleted_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_OnSucceeded>> get OnSucceeded =>
      _library._OnSucceeded_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_OnFailed>> get OnFailed =>
      _library._OnFailed_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_OnCanceled>> get OnCanceled =>
      _library._OnCanceled_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_UploadDataProvider_GetLength>>
      get UploadDataProvider_GetLength =>
          _library._UploadDataProvider_GetLength_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_UploadDataProvider_Read>>
      get UploadDataProvider_Read => _library._UploadDataProvider_Read_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_UploadDataProvider_Rewind>>
      get UploadDataProvider_Rewind => _library._UploadDataProvider_Rewind_ptr;
  ffi.Pointer<ffi.NativeFunction<Native_UploadDataProvider_CloseFunc>>
      get UploadDataProvider_CloseFunc =>
          _library._UploadDataProvider_CloseFunc_ptr;
}

class SampleExecutor extends ffi.Opaque {}

class UploadDataProvider extends ffi.Opaque {}

class Cronet_EnginePtr extends ffi.Opaque {}

class Cronet_BufferPtr extends ffi.Opaque {}

class Cronet_UrlResponseInfoPtr extends ffi.Opaque {}

class Cronet_ErrorPtr extends ffi.Opaque {}

class Cronet_UploadDataProviderPtr extends ffi.Opaque {}

class Cronet_ExecutorPtr extends ffi.Opaque {}

class Cronet_RunnablePtr extends ffi.Opaque {}

class Cronet_UrlRequest extends ffi.Opaque {}

class Cronet_UrlRequestCallbackPtr extends ffi.Opaque {}

class Cronet_UploadDataSinkPtr extends ffi.Opaque {}

typedef _c_VersionString = ffi.Pointer<ffi.Int8> Function();

typedef _dart_VersionString = ffi.Pointer<ffi.Int8> Function();

typedef _c_InitDartApiDL = ffi.IntPtr Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _dart_InitDartApiDL = int Function(
  ffi.Pointer<ffi.Void> data,
);

typedef _typedefC_1 = ffi.Int32 Function(
  ffi.Pointer<Cronet_EnginePtr>,
);

typedef _typedefC_2 = ffi.Void Function(
  ffi.Pointer<Cronet_EnginePtr>,
);

typedef _typedefC_3 = ffi.Pointer<Cronet_BufferPtr> Function();

typedef _typedefC_4 = ffi.Void Function(
  ffi.Pointer<Cronet_BufferPtr>,
  ffi.Uint64,
);

typedef _typedefC_5 = ffi.Int32 Function(
  ffi.Pointer<Cronet_UrlResponseInfoPtr>,
);

typedef _typedefC_6 = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<Cronet_ErrorPtr>,
);

typedef _typedefC_7 = ffi.Pointer<ffi.Int8> Function(
  ffi.Pointer<Cronet_UrlResponseInfoPtr>,
);

typedef _typedefC_8 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr>,
);

typedef _c_InitCronetApi = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> Cronet_Engine_Shutdown,
  ffi.Pointer<ffi.NativeFunction<_typedefC_2>> Cronet_Engine_Destroy,
  ffi.Pointer<ffi.NativeFunction<_typedefC_3>> Cronet_Buffer_Create,
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> Cronet_Buffer_InitWithAlloc,
  ffi.Pointer<ffi.NativeFunction<_typedefC_5>>
      Cronet_UrlResponseInfo_http_status_code_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_6>> Cronet_Error_message_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_7>>
      Cronet_UrlResponseInfo_http_status_text_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_8>>
      Cronet_UploadDataProvider_GetClientContext,
);

typedef _dart_InitCronetApi = void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> Cronet_Engine_Shutdown,
  ffi.Pointer<ffi.NativeFunction<_typedefC_2>> Cronet_Engine_Destroy,
  ffi.Pointer<ffi.NativeFunction<_typedefC_3>> Cronet_Buffer_Create,
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> Cronet_Buffer_InitWithAlloc,
  ffi.Pointer<ffi.NativeFunction<_typedefC_5>>
      Cronet_UrlResponseInfo_http_status_code_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_6>> Cronet_Error_message_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_7>>
      Cronet_UrlResponseInfo_http_status_text_get,
  ffi.Pointer<ffi.NativeFunction<_typedefC_8>>
      Cronet_UploadDataProvider_GetClientContext,
);

typedef Cronet_Executor_ExecuteFunc = ffi.Void Function(
  ffi.Pointer<Cronet_ExecutorPtr>,
  ffi.Pointer<Cronet_RunnablePtr>,
);

typedef _typedefC_9 = ffi.Pointer<Cronet_ExecutorPtr> Function(
  ffi.Pointer<ffi.NativeFunction<Cronet_Executor_ExecuteFunc>>,
);

typedef _typedefC_10 = ffi.Void Function(
  ffi.Pointer<Cronet_ExecutorPtr>,
  ffi.Pointer<ffi.Void>,
);

typedef _typedefC_11 = ffi.Pointer<ffi.Void> Function(
  ffi.Pointer<Cronet_ExecutorPtr>,
);

typedef _typedefC_12 = ffi.Void Function(
  ffi.Pointer<Cronet_ExecutorPtr>,
);

typedef _typedefC_13 = ffi.Void Function(
  ffi.Pointer<Cronet_RunnablePtr>,
);

typedef _typedefC_14 = ffi.Void Function(
  ffi.Pointer<Cronet_RunnablePtr>,
);

typedef _c_InitCronetExecutorApi = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_9>> Cronet_Executor_CreateWith,
  ffi.Pointer<ffi.NativeFunction<_typedefC_10>>
      Cronet_Executor_SetClientContext,
  ffi.Pointer<ffi.NativeFunction<_typedefC_11>>
      Cronet_Executor_GetClientContext,
  ffi.Pointer<ffi.NativeFunction<_typedefC_12>> Cronet_Executor_Destroy,
  ffi.Pointer<ffi.NativeFunction<_typedefC_13>> Cronet_Runnable_Run,
  ffi.Pointer<ffi.NativeFunction<_typedefC_14>> Cronet_Runnable_Destroy,
);

typedef _dart_InitCronetExecutorApi = void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_9>> Cronet_Executor_CreateWith,
  ffi.Pointer<ffi.NativeFunction<_typedefC_10>>
      Cronet_Executor_SetClientContext,
  ffi.Pointer<ffi.NativeFunction<_typedefC_11>>
      Cronet_Executor_GetClientContext,
  ffi.Pointer<ffi.NativeFunction<_typedefC_12>> Cronet_Executor_Destroy,
  ffi.Pointer<ffi.NativeFunction<_typedefC_13>> Cronet_Runnable_Run,
  ffi.Pointer<ffi.NativeFunction<_typedefC_14>> Cronet_Runnable_Destroy,
);

typedef _c_RegisterHttpClient = ffi.Void Function(
  ffi.Handle h,
  ffi.Pointer<Cronet_EnginePtr> ce,
);

typedef _dart_RegisterHttpClient = void Function(
  Object h,
  ffi.Pointer<Cronet_EnginePtr> ce,
);

typedef _c_RegisterCallbackHandler = ffi.Void Function(
  ffi.Int64 nativePort,
  ffi.Pointer<Cronet_UrlRequest> rp,
);

typedef _dart_RegisterCallbackHandler = void Function(
  int nativePort,
  ffi.Pointer<Cronet_UrlRequest> rp,
);

typedef _c_RemoveRequest = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequest> rp,
);

typedef _dart_RemoveRequest = void Function(
  ffi.Pointer<Cronet_UrlRequest> rp,
);

typedef Native_OnRedirectReceived = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<ffi.Int8> newLocationUrl,
);

typedef _dart_OnRedirectReceived = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<ffi.Int8> newLocationUrl,
);

typedef Native_OnResponseStarted = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef _dart_OnResponseStarted = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef Native_OnReadCompleted = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<Cronet_BufferPtr> buffer,
  ffi.Uint64 bytes_read,
);

typedef _dart_OnReadCompleted = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<Cronet_BufferPtr> buffer,
  int bytes_read,
);

typedef Native_OnSucceeded = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef _dart_OnSucceeded = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef Native_OnFailed = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<Cronet_ErrorPtr> error,
);

typedef _dart_OnFailed = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
  ffi.Pointer<Cronet_ErrorPtr> error,
);

typedef Native_OnCanceled = ffi.Void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef _dart_OnCanceled = void Function(
  ffi.Pointer<Cronet_UrlRequestCallbackPtr> self,
  ffi.Pointer<Cronet_UrlRequest> request,
  ffi.Pointer<Cronet_UrlResponseInfoPtr> info,
);

typedef _c_SampleExecutorCreate = ffi.Pointer<SampleExecutor> Function();

typedef _dart_SampleExecutorCreate = ffi.Pointer<SampleExecutor> Function();

typedef _c_SampleExecutorDestroy = ffi.Void Function(
  ffi.Pointer<SampleExecutor> executor,
);

typedef _dart_SampleExecutorDestroy = void Function(
  ffi.Pointer<SampleExecutor> executor,
);

typedef _c_InitSampleExecutor = ffi.Void Function(
  ffi.Pointer<SampleExecutor> self,
);

typedef _dart_InitSampleExecutor = void Function(
  ffi.Pointer<SampleExecutor> self,
);

typedef _c_SampleExecutor_Cronet_ExecutorPtr_get
    = ffi.Pointer<Cronet_ExecutorPtr> Function(
  ffi.Pointer<SampleExecutor> self,
);

typedef _dart_SampleExecutor_Cronet_ExecutorPtr_get
    = ffi.Pointer<Cronet_ExecutorPtr> Function(
  ffi.Pointer<SampleExecutor> self,
);

typedef _c_UploadDataProviderCreate = ffi.Pointer<UploadDataProvider>
    Function();

typedef _dart_UploadDataProviderCreate = ffi.Pointer<UploadDataProvider>
    Function();

typedef _c_UploadDataProviderDestroy = ffi.Void Function(
  ffi.Pointer<UploadDataProvider> upload_data_provided,
);

typedef _dart_UploadDataProviderDestroy = void Function(
  ffi.Pointer<UploadDataProvider> upload_data_provided,
);

typedef _c_UploadDataProviderInit = ffi.Void Function(
  ffi.Pointer<UploadDataProvider> self,
  ffi.Int64 length,
  ffi.Pointer<Cronet_UrlRequest> request,
);

typedef _dart_UploadDataProviderInit = void Function(
  ffi.Pointer<UploadDataProvider> self,
  int length,
  ffi.Pointer<Cronet_UrlRequest> request,
);

typedef Native_UploadDataProvider_GetLength = ffi.Int64 Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
);

typedef _dart_UploadDataProvider_GetLength = int Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
);

typedef Native_UploadDataProvider_Read = ffi.Void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
  ffi.Pointer<Cronet_BufferPtr> buffer,
);

typedef _dart_UploadDataProvider_Read = void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
  ffi.Pointer<Cronet_BufferPtr> buffer,
);

typedef Native_UploadDataProvider_Rewind = ffi.Void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
);

typedef _dart_UploadDataProvider_Rewind = void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
  ffi.Pointer<Cronet_UploadDataSinkPtr> upload_data_sink,
);

typedef Native_UploadDataProvider_CloseFunc = ffi.Void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
);

typedef _dart_UploadDataProvider_CloseFunc = void Function(
  ffi.Pointer<Cronet_UploadDataProviderPtr> self,
);
