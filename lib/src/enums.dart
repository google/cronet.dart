// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'third_party/cronet/generated_bindings.dart';

/// Defines the available http protocols supported by Cronet.
enum HttpProtocol {
  /// HTTP/2 with QUIC.
  quic,

  /// HTTP/2 without QUIC.
  http2,

  /// HTTP/1.1.
  http
}

/// Cronet Error Enum to Error String bindings.
///
/// ISSUE: https://github.com/dart-lang/ffigen/issues/236
abstract class CronetResults extends Cronet_RESULT {
  // Supports having duplicate integers with the same key.
  static const Map<String, int> _nameToValue = {
    'Cronet_RESULT_SUCCESS': 0,
    'Cronet_RESULT_ILLEGAL_ARGUMENT': -100,
    'Cronet_RESULT_ILLEGAL_ARGUMENT_STORAGE_PATH_MUST_EXIST': -101,
    'Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_PIN': -102,
    'Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HOSTNAME': -103,
    'Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_METHOD': -104,
    'Cronet_RESULT_ILLEGAL_ARGUMENT_INVALID_HTTP_HEADER': -105,
    'Cronet_RESULT_ILLEGAL_STATE': -200,
    'Cronet_RESULT_ILLEGAL_STATE_STORAGE_PATH_IN_USE': -201,
    'Cronet_RESULT_ILLEGAL_STATE_CANNOT_SHUTDOWN_ENGINE_FROM_NETWORK_THREAD':
        -202,
    'Cronet_RESULT_ILLEGAL_STATE_ENGINE_ALREADY_STARTED': -203,
    'Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_STARTED': -204,
    'Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_INITIALIZED': -205,
    'Cronet_RESULT_ILLEGAL_STATE_REQUEST_ALREADY_INITIALIZED': -206,
    'Cronet_RESULT_ILLEGAL_STATE_REQUEST_NOT_STARTED': -207,
    'Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_REDIRECT': -208,
    'Cronet_RESULT_ILLEGAL_STATE_UNEXPECTED_READ': -209,
    'Cronet_RESULT_ILLEGAL_STATE_READ_FAILED': -210,
    'Cronet_RESULT_NULL_POINTER': -300,
    'Cronet_RESULT_NULL_POINTER_HOSTNAME': -301,
    'Cronet_RESULT_NULL_POINTER_SHA256_PINS': -302,
    'Cronet_RESULT_NULL_POINTER_EXPIRATION_DATE': -303,
    'Cronet_RESULT_NULL_POINTER_ENGINE': -304,
    'Cronet_RESULT_NULL_POINTER_URL': -305,
    'Cronet_RESULT_NULL_POINTER_CALLBACK': -306,
    'Cronet_RESULT_NULL_POINTER_EXECUTOR': -307,
    'Cronet_RESULT_NULL_POINTER_METHOD': -308,
    'Cronet_RESULT_NULL_POINTER_HEADER_NAME': -309,
    'Cronet_RESULT_NULL_POINTER_HEADER_VALUE': -310,
    'Cronet_RESULT_NULL_POINTER_PARAMS': -311,
    'Cronet_RESULT_NULL_POINTER_REQUEST_FINISHED_INFO_LISTENER_EXECUTOR': -312,
  };

  // Does not support having duplicate integers with the same key, picks the
  // (first? last?) name.
  static final Map<int, String> _valueToName = Map.fromEntries(
      _nameToValue.entries.map((e) => MapEntry(e.value, e.key)));

  /// A string representation of an enum value.
  static String toEnumName(int enumValue) {
    return _valueToName[enumValue]!;
  }

  /// An int representation of an enum name.
  static int toEnumValue(String enumName) {
    return _nameToValue[enumName]!;
  }
}
