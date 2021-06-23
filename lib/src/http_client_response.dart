// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of '../src/http_client_request.dart';

/// Represents the server's response to a request.
///
/// The body of a [HttpClientResponse] object is a [Stream] of data from the server.
/// Listen to the body to handle the data and be notified when the entire body
/// is received.
abstract class HttpClientResponse extends Stream<List<int>> {
  HttpClientResponse();

  factory HttpClientResponse._(Stream<List<int>> cbhStream) {
    return _HttpClientResponse(cbhStream);
  }
}

/// Implementation of [HttpClientResponse].
///
/// Takes instance of callback handler and registers [listen] callbacks to the stream.
class _HttpClientResponse extends HttpClientResponse {
  final Stream<List<int>> cbhStream;
  _HttpClientResponse(this.cbhStream);

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return cbhStream.listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}
