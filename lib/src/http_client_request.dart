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
import 'third_party/cronet/generated_bindings.dart';
import 'wrapper/generated_bindings.dart' as wrapper;
import 'http_client_response.dart';
import 'http_callback_handler.dart';

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
abstract class HttpClientRequest implements io.IOSink {
  /// Returns [Future] of [HttpClientResponse] which can be listened for server response.
  ///
  /// Throws [UrlRequestException] if request can't be initiated.
  @override
  Future<HttpClientResponse> close();

  /// This is same as [close]. A [HttpClientResponse] future that will complete
  /// once the request is successfully made.
  ///
  /// If any problems occurs before the response is available, this future will
  /// completes with an [UrlRequestException].
  @override
  Future<HttpClientResponse> get done;

  /// Follow the redirects.
  bool get followRedirects;

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  int get maxRedirects;

  /// The uri of the request.
  Uri get uri;
}

/// Implementation of [HttpClientRequest].
class HttpClientRequestImpl implements HttpClientRequest {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final wrapper.Wrapper _wrapper;
  final Pointer<Cronet_Engine> _cronetEngine;
  final CallbackHandler _cbh;
  final Pointer<Cronet_UrlRequest> _request;

  /// Holds the function to clean up after the request is done (if nessesary).
  ///
  /// Implemented by: http_client.dart.
  final Function _clientCleanup;

  @override
  Encoding encoding;

  /// Initiates a [HttpClientRequestImpl]. It is meant to be used by a [HttpClient].
  HttpClientRequestImpl(this._uri, this._method, this._cronet, this._wrapper,
      this._cronetEngine, this._clientCleanup,
      {this.encoding = utf8})
      : _cbh = CallbackHandler(
            _cronet, _wrapper, _wrapper.Create_Executor(), ReceivePort()),
        _request = _cronet.Cronet_UrlRequest_Create() {
    // Register the native port to C side.
    _wrapper.registerCallbackHandler(_cbh.receivePort.sendPort.nativePort,
        _request.cast<wrapper.Cronet_UrlRequest>());
  }

  // Starts the request.
  void _startRequest() {
    final requestParams = _cronet.Cronet_UrlRequestParams_Create();
    _cronet.Cronet_UrlRequestParams_http_method_set(
        requestParams, _method.toNativeUtf8().cast<Int8>());

    final res = _wrapper.Cronet_UrlRequest_Init(
        _request.cast<wrapper.Cronet_UrlRequest>(),
        _cronetEngine.cast<wrapper.Cronet_Engine>(),
        _uri.toString().toNativeUtf8().cast<Int8>(),
        requestParams.cast<wrapper.Cronet_UrlRequestParams>(),
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

  /// Returns [Future] of [HttpClientResponse] which can be listened for server response.
  ///
  /// Throws [UrlRequestException] if request can't be initiated.
  @override
  Future<HttpClientResponse> close() {
    return Future(() {
      _startRequest();
      return HttpClientResponseImpl(_cbh.stream);
    });
  }

  /// This is same as [close]. A [HttpClientResponse] future that will complete
  /// once the request is successfully made.
  ///
  /// If any problems occurs before the response is available, this future will
  /// completes with an [UrlRequestException].
  @override
  Future<HttpClientResponse> get done => close();

  /// Follow the redirects.
  @override
  bool get followRedirects => _cbh.followRedirects;
  set followRedirects(bool follow) {
    _cbh.followRedirects = follow;
  }

  /// Maximum numbers of redirects to follow.
  /// Have no effect if [followRedirects] is set to false.
  @override
  int get maxRedirects => _cbh.maxRedirects;
  set maxRedirects(int redirects) {
    _cbh.maxRedirects = redirects;
  }

  /// The uri of the request.
  @override
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
