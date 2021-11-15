// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'enums.dart';

class LoggingException implements Exception {
  const LoggingException();
}

class HttpException implements IOException {
  final String message;
  final Uri? uri;

  const HttpException(this.message, {this.uri});

  @override
  String toString() {
    final b = StringBuffer()
      ..write('HttpException: ')
      ..write(message);
    final uri = this.uri;
    if (uri != null) {
      b.write(', uri = $uri');
    }
    return b.toString();
  }
}

/// Errors from Cronet Native Library.
class CronetNativeError implements Error {
  final int val;
  const CronetNativeError(this.val);
  @override
  String toString() {
    final b = StringBuffer()
      ..write('CronetNativeError: Cronet Result: ')
      ..write(val)
      ..write(' : ${CronetResults.toEnumName(val)}');
    return b.toString();
  }

  @override
  StackTrace? get stackTrace => StackTrace.current;
}

/// Error occured while performing a request.
///
/// Failing to start a request or failing to complete
/// with a proper server response will throw this exception.
class UrlRequestError extends CronetNativeError {
  const UrlRequestError(int val) : super(val);
}
