// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';
import 'generated_bindings.dart';
part 'http_client_response.dart';
part 'http_callback_handler.dart';

// Function signature for callbacks called on redirects.
typedef RedirectReceivedCallback = void Function(
    String newLocationUrl, int responseCode);
typedef ResponseStartedCallback = void Function(int responseCode);

/// Called when a chunk of data is received from the server.
typedef ReadDataCallback = void Function(
    List<int> data, int bytesRead, int responseCode);
typedef FailedCallabck = void Function(HttpException exception);
typedef CanceledCallabck = void Function();
typedef SuccessCallabck = void Function(int responseCode);

/// HTTP request for a client connection.
///
/// It handles all of the Http Requests made by [HttpClient].
/// Provides two ways to get data from the request.
/// [registerCallbacks] or a [HttpClientResponse] which is a [Stream<List<int>>].
/// Either of them can be used at a time.
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
class HttpClientRequest implements IOSink {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronetEngine;
  final _CallbackHandler _cbh;
  final Pointer<Cronet_UrlRequest> _request;

  /// Holds the function to clean up after the request is done (if nessesary).
  ///
  /// Implemented by: http_client.dart.
  final Function _clientCleanup;

  @override
  Encoding encoding;

  /// Initiates a [HttpClientRequest]. It is meant to be used by a [HttpClient].
  HttpClientRequest(this._uri, this._method, this._cronet, this._cronetEngine,
      this._clientCleanup,
      {this.encoding = utf8})
      : _cbh =
            _CallbackHandler(_cronet, _cronet.Create_Executor(), ReceivePort()),
        _request = _cronet.Cronet_UrlRequest_Create() {
    // Register the native port to C side.
    _cronet.registerCallbackHandler(
        _cbh.receivePort.sendPort.nativePort, _request);
  }

  // Starts the request.
  void _startRequest() {
    final requestParams = _cronet.Cronet_UrlRequestParams_Create();
    _cronet.Cronet_UrlRequestParams_http_method_set(
        requestParams, _method.toNativeUtf8().cast<Int8>());

    final res = _cronet.Cronet_UrlRequest_Init(
        _request,
        _cronetEngine,
        _uri.toString().toNativeUtf8().cast<Int8>(),
        requestParams,
        _cbh.executor);

    if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestException(res);
    }

    final res2 = _cronet.Cronet_UrlRequest_Start(_request);
    if (res2 != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw UrlRequestException(res2);
    }
    _cbh.listen(_request, () => _clientCleanup(this));
  }

  /// Registers callbacks for all network events.
  ///
  /// Throws [Exception] if callbacks are registered after listening to response [Stream].
  /// Resolves with `true` if request finished successfully and `false` otherwise.
  ///
  /// This is one of the methods to get data out of [HttpClientRequest].
  /// Accepted callbacks are [RedirectReceivedCallback], [ResponseStartedCallback],
  /// [ReadDataCallback], [FailedCallabck], [CanceledCallabck] and [SuccessCallabck].
  /// Callbacks will be called as per sequence of the events.
  Future<bool> registerCallbacks(ReadDataCallback onReadData,
      {RedirectReceivedCallback? onRedirectReceived,
      ResponseStartedCallback? onResponseStarted,
      FailedCallabck? onFailed,
      CanceledCallabck? onCanceled,
      SuccessCallabck? onSuccess}) {
    if (_cbh._isStreamClaimed) {
      return Future.error(ResponseListenerException());
    }
    final rc = _cbh.registerCallbacks(onReadData, onRedirectReceived,
        onResponseStarted, onFailed, onCanceled, onSuccess);
    _startRequest();
    return rc;
  }

  /// Returns [Future] of [HttpClientResponse] which can be listened for server response.
  ///
  /// Throws [Exception] if callback based api is in use.
  /// Throws [UrlRequestException] if request can't be initiated.
  /// Consumable similar to [HttpClientResponse].
  @override
  Future<HttpClientResponse> close() {
    return Future(() {
      // If callback based API is being used, throw Exception.
      if (_cbh._callBackCompleter != null) {
        throw ResponseListenerException();
      }
      _startRequest();
      return HttpClientResponse._(_cbh.stream);
    });
  }

  /// Done is same as [close]. A [HttpClientResponse] future that will complete once the response is available.
  ///
  /// If an error occurs before the response is available, this future will complete with an error.
  @override
  Future<HttpClientResponse> get done => close();

  /// Follow the redirects.
  bool get followRedirects => _cbh.followRedirects;
  set followRedirects(bool follow) {
    _cbh.followRedirects = follow;
  }

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  int get maxRedirects => _cbh.maxRedirects;
  set maxRedirects(int redirects) {
    _cbh.maxRedirects = redirects;
  }

  /// The uri of the request.
  Uri get uri => _uri;

  @override
  void add(List<int> data) {
    // TODO: implement add
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: implement addError
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: implement addStream
    throw UnimplementedError();
  }

  @override
  Future flush() {
    // TODO: implement flush
    throw UnimplementedError();
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
}
