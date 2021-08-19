// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io' as io;
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';
import 'globals.dart';
import 'http_callback_handler.dart';
import 'http_client_response.dart';
import 'http_headers.dart';
import 'third_party/cronet/generated_bindings.dart';

/// HTTP request for a client connection.
///
/// It handles all of the Http Requests made by [HttpClient].
/// Provides two ways to get data from the request.
/// [registerCallbacks] or a [HttpClientResponse] which is a
/// [Stream<List<int>>]. Either of them can be used at a time.
///
/// Example Usage:
/// ```dart
/// final client = HttpClient();
/// client.getUrl(Uri.parse('https://example.com/'))
///   .then((HttpClientRequest request) {
///   return request.close();
/// }).then((HttpClientResponse response) {
///   // Here you got the raw data.
///   // Use it as you like.
/// });
/// ```
abstract class HttpClientRequest implements io.IOSink {
  /// Returns [Future] of [HttpClientResponse] which can be listened for server
  /// response.
  ///
  /// Throws [UrlRequestError] if request can't be initiated.
  @override
  Future<HttpClientResponse> close();

  /// This is same as [close]. A [HttpClientResponse] future that will complete
  /// once the request is successfully made.
  ///
  /// If any problems occurs before the response is available, this future will
  /// completes with an [UrlRequestError].
  @override
  Future<HttpClientResponse> get done;

  /// Follow the redirects.
  bool get followRedirects;
  set followRedirects(bool follow);

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  int get maxRedirects;
  set maxRedirects(int redirects);

  /// The uri of the request.
  Uri get uri;

  /// The [Encoding] used when writing strings.
  @override
  late Encoding encoding;

  /// Returns the client request headers.
  HttpHeaders get headers;
}

/// Implementation of [HttpClientRequest].
class HttpClientRequestImpl implements HttpClientRequest {
  final Uri _uri;
  final String _method;
  final Pointer<Cronet_Engine> _cronetEngine;
  final CallbackHandler _callbackHandler;
  final Pointer<Cronet_UrlRequest> _request;
  final _requestParams = cronet.Cronet_UrlRequestParams_Create();
  late final HttpHeadersImpl _headers;
  final io.BytesBuilder _dataToUpload = io.BytesBuilder();
  bool isImmutable = false;

  /// Holds the function to clean up after the request is done (if nessesary).
  ///
  /// Implemented by: http_client.dart.
  final void Function(HttpClientRequest) _clientCleanup;

  /// Pointer associated with [this] request.
  ///
  /// This is not a part of public api.
  Pointer<Cronet_UrlRequest> get requestPtr => _request;

  /// [CallbackHandler] handling this request.
  ///
  /// This is not a part of public api.
  CallbackHandler get callbackHandler => _callbackHandler;

  @override
  Encoding encoding;

  /// Initiates a [HttpClientRequestImpl]. It is meant to be used by a
  /// [HttpClient].
  HttpClientRequestImpl(
      this._uri, this._method, this._cronetEngine, this._clientCleanup,
      {this.encoding = utf8})
      : _callbackHandler =
            CallbackHandler(wrapper.SampleExecutorCreate(), ReceivePort()),
        _request = cronet.Cronet_UrlRequest_Create() {
    _headers = HttpHeadersImpl(_requestParams);
    // Register the native port to C side.
    wrapper.RegisterCallbackHandler(
        _callbackHandler.receivePort.sendPort.nativePort, _request.cast());
  }

  // Starts the request.
  void _startRequest() {
    if (_requestParams == nullptr) throw Error();
    // TODO: ISSUE https://github.com/dart-lang/ffigen/issues/22
    cronet.Cronet_UrlRequestParams_http_method_set(
        _requestParams, _method.toNativeUtf8().cast<Int8>());
    wrapper.InitSampleExecutor(_callbackHandler.executor);
    final cronetCallbacks = cronet.Cronet_UrlRequestCallback_CreateWith(
      wrapper.addresses.OnRedirectReceived.cast(),
      wrapper.addresses.OnResponseStarted.cast(),
      wrapper.addresses.OnReadCompleted.cast(),
      wrapper.addresses.OnSucceeded.cast(),
      wrapper.addresses.OnFailed.cast(),
      wrapper.addresses.OnCanceled.cast(),
    );

    if (_dataToUpload.isNotEmpty) {
      /// Data upload provider with registered callbacks (from cronet side).
      final cronetUploadProvider = cronet.Cronet_UploadDataProvider_CreateWith(
          wrapper.addresses.UploadDataProvider_GetLength.cast(),
          wrapper.addresses.UploadDataProvider_Read.cast(),
          wrapper.addresses.UploadDataProvider_Rewind.cast(),
          wrapper.addresses.UploadDataProvider_CloseFunc.cast());

      /// Data upload provider implementation (wrapper).
      final wrapperUploadProvider = wrapper.UploadDataProviderCreate();
      cronet.Cronet_UploadDataProvider_SetClientContext(
          cronetUploadProvider, wrapperUploadProvider.cast());
      wrapper.UploadDataProviderInit(
          wrapperUploadProvider, _dataToUpload.length, _request.cast());
      cronet.Cronet_UrlRequestParams_upload_data_provider_set(
          _requestParams, cronetUploadProvider);
    }

    final res = cronet.Cronet_UrlRequest_InitWithParams(
        _request,
        _cronetEngine,
        _uri.toString().toNativeUtf8().cast<Int8>(),
        _requestParams,
        cronetCallbacks,
        wrapper.SampleExecutor_Cronet_ExecutorPtr_get(_callbackHandler.executor)
            .cast());

    if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestError(res);
    }

    final res2 = cronet.Cronet_UrlRequest_Start(_request);
    if (res2 != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestError(res2);
    }
    _callbackHandler.listen(
        _request, () => _clientCleanup(this), _dataToUpload.takeBytes());
  }

  /// Closes the request for input.
  ///
  /// Returns [Future] of [HttpClientResponse] which can be listened to the
  /// server response. Throws [UrlRequestError] if request can't be initiated.
  @override
  Future<HttpClientResponse> close() {
    return Future(() {
      _headers.isImmutable = isImmutable = true;
      _startRequest();
      return HttpClientResponseImpl(_callbackHandler.stream);
    });
  }

  /// This is same as [close]. A [HttpClientResponse] future that will complete
  /// once the request is successfully made.
  ///
  /// If any problems occurs before the response is available, this future will
  /// completes with an [UrlRequestError].
  @override
  Future<HttpClientResponse> get done => close();

  /// Follow the redirects.
  @override
  bool get followRedirects => _callbackHandler.followRedirects;
  @override
  set followRedirects(bool follow) {
    _callbackHandler.followRedirects = follow;
  }

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  @override
  int get maxRedirects => _callbackHandler.maxRedirects;
  @override
  set maxRedirects(int redirects) {
    _callbackHandler.maxRedirects = redirects;
  }

  /// The uri of the request.
  @override
  Uri get uri => _uri;

  @override
  void add(List<int> data) {
    if (isImmutable) throw StateError('Can not mutate the request body');
    _dataToUpload.add(data);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // StackTrace is ignored due to https://github.com/dart-lang/sdk/issues/30741.
    throw error;
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    return stream.forEach((bytes) {
      _dataToUpload.add(bytes);
    });
  }

  @override
  Future flush() {
    return Future<void>(() => _dataToUpload.clear());
  }

  @override
  void write(Object? object) {
    final string = '$object';
    if (string.isEmpty) return;
    add(encoding.encode(string));
  }

  @override
  void writeAll(Iterable objects, [String separator = '']) {
    final iterator = objects.iterator;
    if (!iterator.moveNext()) return;
    if (separator.isEmpty) {
      do {
        write(iterator.current);
      } while (iterator.moveNext());
    } else {
      write(iterator.current);
      while (iterator.moveNext()) {
        write(separator);
        write(iterator.current);
      }
    }
  }

  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }

  @override
  HttpHeaders get headers => _headers;
}
