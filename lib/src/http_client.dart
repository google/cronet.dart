// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'enums.dart';
import 'exceptions.dart';
import 'globals.dart';
import 'http_client_request.dart';
import 'quic_hint.dart';
import 'third_party/cronet/generated_bindings.dart';

/// A client that receives content, such as web pages,
/// from a server using the HTTP, HTTPS, HTTP2, Quic etc. protocol.
///
/// HttpClient contains a number of methods to send an [HttpClientRequest] to an
/// Http server and receive an [HttpClientResponse] back which is a [Stream].
/// Alternatively, you can also register callbacks for different network events
/// including but not limited to receiving the raw bytes sent by the server.
/// For example, you can use the [get], [getUrl], [post], and [postUrl] methods
/// for GET and POST requests, respectively.
///
/// Example Usage:
/// ```dart
/// final client = HttpClient();
/// client.getUrl(Uri.parse('https://example.com/'))
///   .then((HttpClientRequest request) {
///   // See [HttpClientRequest] for more info
/// });
/// ```
class HttpClient {
  final String userAgent;
  final HttpProtocol protocol;
  final bool brotli;
  final String acceptLanguage;
  final List<QuicHint> quicHints;

  final Pointer<Cronet_Engine> _cronetEngine;
  // Keep all the request reference in a list so if the client is being
  // explicitly closed, we can clean up the requests.
  final _requests = List<HttpClientRequestImpl>.empty(growable: true);
  var _stop = false;

  static const int defaultHttpPort = 80;
  static const int defaultHttpsPort = 443;

  /// Initiates an [HttpClient] with the settings provided in the arguments.
  ///
  /// The settings control whether this client supports [brotli] and
  /// [HttpProtocol]s like  `quic`, `http2` and `http/1.1`. If `quic` is
  /// enabled, then [quicHints] can be provided. [userAgent] and
  /// [acceptLanguage] can also be provided.
  ///
  /// Throws [CronetNativeError] if [HttpClient] can't be created.
  HttpClient({
    this.userAgent = 'Dart/2.12',
    this.protocol = HttpProtocol.quic,
    this.quicHints = const [],
    this.brotli = true,
    this.acceptLanguage = 'en_US',
  }) : _cronetEngine = cronet.Cronet_Engine_Create() {
    if (_cronetEngine == nullptr) throw Error();
    wrapper.RegisterHttpClient(this, _cronetEngine.cast());
    // Starting the engine with parameters.
    final engineParams = cronet.Cronet_EngineParams_Create();
    if (engineParams == nullptr) throw Error();
    cronet.Cronet_EngineParams_user_agent_set(
        engineParams, userAgent.toNativeUtf8().cast<Int8>());

    switch (protocol) {
      case HttpProtocol.quic:
        cronet.Cronet_EngineParams_enable_quic_set(engineParams, true);
        break;
      case HttpProtocol.http2:
        cronet.Cronet_EngineParams_enable_http2_set(engineParams, true);
        cronet.Cronet_EngineParams_enable_quic_set(engineParams, false);
        break;
      case HttpProtocol.http:
        cronet.Cronet_EngineParams_enable_quic_set(engineParams, false);
        cronet.Cronet_EngineParams_enable_http2_set(engineParams, false);
        break;
      default:
        break;
    }
    if (protocol != HttpProtocol.quic && quicHints.isNotEmpty) {
      throw ArgumentError('Quic is not enabled but quic hints are provided.');
    }
    for (final quicHint in quicHints) {
      final hint = cronet.Cronet_QuicHint_Create();
      if (hint == nullptr) throw Error();
      cronet.Cronet_QuicHint_host_set(
          hint, quicHint.host.toNativeUtf8().cast<Int8>());
      cronet.Cronet_QuicHint_port_set(hint, quicHint.port);
      cronet.Cronet_QuicHint_alternate_port_set(hint, quicHint.alternatePort);
      cronet.Cronet_EngineParams_quic_hints_add(engineParams, hint);
      cronet.Cronet_QuicHint_Destroy(hint);
    }

    cronet.Cronet_EngineParams_enable_brotli_set(engineParams, brotli);
    cronet.Cronet_EngineParams_accept_language_set(
        engineParams, acceptLanguage.toNativeUtf8().cast<Int8>());

    final res =
        cronet.Cronet_Engine_StartWithParams(_cronetEngine, engineParams);
    if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
      throw CronetNativeError(res);
    }
    cronet.Cronet_EngineParams_Destroy(engineParams);
  }

  void _cleanUpRequests(HttpClientRequest hcr) {
    _requests.remove(hcr);
  }

  /// Shuts down the [HttpClient].
  ///
  /// The [HttpClient] will be kept alive until all active connections are done.
  /// If [force] is true any active connections will be closed to immediately
  /// release all resources. These closed connections will receive an error
  /// event to indicate that the client was shut down. Trying to establish a
  /// new connection after calling close, will throw an [Exception].
  void close({bool force = false}) {
    if (_stop) return;
    _stop = true;
    if (force) {
      // Deep copying the list because the original list may get modified
      // during the traversal as cronet sends onCancel callbacks.
      final requests = _requests.toList();
      for (final request in requests) {
        cronet.Cronet_UrlRequest_Cancel(request.requestPtr);
        request.callbackHandler.controller
            .addError(HttpException('HttpClient: Force Closed'));
      }
    }
  }

  /// Constructs [Uri] from [host], [port] & [path].
  Uri _getUri(String host, int port, String path) {
    final _host = Uri.parse(host);
    if (!_host.hasScheme) {
      final scheme = (port == defaultHttpsPort) ? 'https' : 'http';
      return Uri(scheme: scheme, host: host, port: port, path: path);
    } else {
      return Uri(
          scheme: _host.scheme, host: _host.host, port: port, path: path);
    }
  }

  /// Opens a [url] using a [method] like GET, PUT, POST, HEAD, PATCH, DELETE.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> openUrl(String method, Uri url) {
    return Future(() {
      if (_stop) {
        throw Exception("Client is closed. Can't open new connections");
      }
      _requests.add(
          HttpClientRequestImpl(url, method, _cronetEngine, _cleanUpRequests));
      return _requests.last;
    });
  }

  /// Opens a request on the basis of [method], [host], [port] and [path] using
  /// GET, PUT, POST, HEAD, PATCH, DELETE or any other method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> open(
      String method, String host, int port, String path) {
    return openUrl(method, _getUri(host, port, path));
  }

  /// Opens a [url] using GET method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> getUrl(Uri url) {
    return openUrl('GET', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using GET
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> get(String host, int port, String path) {
    return getUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using HEAD method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> headUrl(Uri url) {
    return openUrl('HEAD', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using HEAD
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> head(String host, int port, String path) {
    return headUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using PUT method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> putUrl(Uri url) {
    return openUrl('PUT', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using PUT
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> put(String host, int port, String path) {
    return putUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using POST method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> postUrl(Uri url) {
    return openUrl('POST', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using POST
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> post(String host, int port, String path) {
    return postUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using PATCH method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> patchUrl(Uri url) {
    return openUrl('PATCH', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using PATCH
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> patch(String host, int port, String path) {
    return patchUrl(_getUri(host, port, path));
  }

  /// Opens a [url] using DELETE method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> deleteUrl(Uri url) {
    return openUrl('DELETE', url);
  }

  /// Opens a request on the basis of [host], [port] and [path] using DELETE
  /// method.
  ///
  /// Returns a [Future] of [HttpClientRequest].
  Future<HttpClientRequest> delete(String host, int port, String path) {
    return deleteUrl(_getUri(host, port, path));
  }

  /// Version string of the Cronet Shared Library currently in use.
  String get httpClientVersion =>
      cronet.Cronet_Engine_GetVersionString(_cronetEngine)
          .cast<Utf8>()
          .toDartString();
}
