// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
// import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';

import 'generated_bindings.dart';

// TODO: Enable these when Headers are implemented
// part '../third_party/http_headers.dart';
// part '../third_party/http_date.dart';
part 'http_client_response.dart';
part 'http_callback_handler.dart';

// Type definitions for various callbacks

/// Called when a redirect is received. Gets new location and response code as
/// arguments.
typedef RedirectReceivedCallback = void Function(
    String newLocationUrl, int responseCode);

/// Called when server sends a response for the first time. Gets the response code
/// as an argument.
typedef ResponseStartedCallback = void Function(int responseCode);

/// Called when a chunk of data is received from the server. Gets raw bytes as
/// [List<int>], number of bytes read and response code as arguments.
typedef ReadDataCallback = void Function(List<int> data, int bytesRead,
    int responseCode); // onReadComplete may confuse people.

/// Called when request is failed due to some reason. Gets [HttpException] as
/// an argument which also contains the reason of failure.
typedef FailedCallabck = void Function(HttpException exception);

/// Called when a request is cancelled.
typedef CanceledCallabck = void Function();

/// Called when a request is finished with success. Gets the response code as
/// an argument.
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
// TODO: Implement other functions
class HttpClientRequest implements IOSink {
  final Uri _uri;
  final String _method;
  final Cronet _cronet;
  final Pointer<Cronet_Engine> _cronetEngine;
  final _CallbackHandler _cbh;
  final Pointer<Cronet_UrlRequest> _request;
  final Function _clientCleanup; // Holds the function to clean up after
  //                                // the request is done (if nessesary).
  //                                // implemented in: http_client.dart
  // TODO: Enable with abort API
  // bool _isAborted = false;

  // TODO: See how that affects and do we need to change
  // Negotiated protocol info is only available via Cronet_UrlResponseInfo
  // final _headers = _HttpHeaders('1.1'); // Setting it to HTTP/1.1

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
    // TODO: Enable with abort API
    // if (_isAborted) {
    //   throw Exception('Request is already aborted');
    // }
    // _headers._finalize(); // making headers immutable
    final requestParams = _cronet.Cronet_UrlRequestParams_Create();
    _cronet.Cronet_UrlRequestParams_http_method_set(
        requestParams, _method.toNativeUtf8().cast<Int8>());

    // TODO: Setting headers go here

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

  /// Aborts the client connection.
  ///
  /// If the connection has not yet completed, the request is aborted
  /// and closes the [Stream] with onDone callback you may have
  /// registered. The [Exception] passed to it is thrown and
  /// [StackTrace] is printed. If there is no [StackTrace] provided,
  /// [StackTrace.empty] will be shown. If no [Exception] is provided,
  /// no exception is thrown.
  /// If the [Stream] is closed, aborting has no effect.
  void abort([Object? exception, StackTrace? stackTrace]) {
    // TODO: Migrate abort code
    throw UnimplementedError();
  }

  /// Done is same as [close]. A [HttpClientResponse] future that will complete once the response is available.
  ///
  /// If an error occurs before the response is available, this future will complete with an error.
  @override
  Future<HttpClientResponse> get done => close();

  @override
  void add(List<int> data) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  @override
  Future flush() {
    // TODO: Implement this with POST request
    throw UnimplementedError();
  }

  // Implementation taken from `dart:io`.
  @override
  void write(Object? object) {
    final string = '$object';
    if (string.isEmpty) return;
    add(encoding.encode(string));
  }

  // Implementation taken from `dart:io`.
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

  // Implementation taken from `dart:io`.
  @override
  void writeCharCode(int charCode) {
    write(String.fromCharCode(charCode));
  }

  // Implementation taken from `dart:io`.
  @override
  void writeln([Object? object = '']) {
    write(object);
    write('\n');
  }

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

  // HttpHeaders get headers => _headers;
}
