// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'globals.dart';
import 'third_party/cronet/generated_bindings.dart';

/// Headers for HTTP requests.
///
/// In some situations, headers are immutable:
/// [HttpClientRequest] have immutable headers from the moment the body is
/// written to. In this situation, the mutating methods throw exceptions.
///
/// For all operations on HTTP headers the header name is case-insensitive.
///
/// To set the value of a header use the `set()` method:
///
/// ```dart
/// request.headers.set('Content-Type',
///                    'application/json');
/// ```
abstract class HttpHeaders {
  /// Sets the header [name] to [value].
  void set(String name, Object value);
}

/// Implementation of [HttpHeaders].
class HttpHeadersImpl implements HttpHeaders {
  final Pointer<Cronet_UrlRequestParams> _requestParams;
  bool isImmutable = false;

  HttpHeadersImpl(this._requestParams);

  @override
  void set(String name, Object value) {
    if (isImmutable) {
      throw StateError('Can not write headers in immutable state.');
    }
    final header = cronet.Cronet_HttpHeader_Create();
    cronet.Cronet_HttpHeader_name_set(header, name.toNativeUtf8().cast());
    cronet.Cronet_HttpHeader_value_set(
        header, value.toString().toNativeUtf8().cast());
    cronet.Cronet_UrlRequestParams_request_headers_add(_requestParams, header);
    cronet.Cronet_HttpHeader_Destroy(header);
  }
}
