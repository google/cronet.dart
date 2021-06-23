// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

class LoggingException implements Exception {
  const LoggingException();
}

class HttpException implements IOException {
  final String message;
  final Uri? uri;

  const HttpException(this.message, {this.uri});

  @override
  String toString() {
    final b = StringBuffer()..write('HttpException: ')..write(message);
    final uri = this.uri;
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}

/// Errors/Exceptions from Cronet Native Library.
class CronetNativeException implements Exception {
  final int val;
  const CronetNativeException(this.val);

  @override
  String toString() {
    final b = StringBuffer()
      ..write('CronetNativeException: Cronet Result: ')
      ..write(val);
    return b.toString();
  }
}

/// Exceptions occured while performing a request.
///
/// Failing to start a request or failing to complete
/// with a proper server response will throw this exception.
class UrlRequestException extends CronetNativeException {
  const UrlRequestException(int val) : super(val);
}

class ResponseListenerException implements Exception {
  ResponseListenerException();
}
