// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "wrapper_utils.h"

std::unordered_map<Cronet_UrlRequestPtr, Dart_Port> requestNativePorts;

static void FreeFinalizer(void *, void *value) { free(value); }

// This sends the callback name and the associated data with it to the Dart
// side via NativePort.
//
// Sent data is broken into 2 parts.
// message[0] is the method name, which is a string.
// message[1] contains all the data to pass to that method.
//
// Using this due to the lack of support for asynchronous callbacks in dart:ffi.
// See Issue: https://github.com/dart-lang/sdk/issues/37022.
void DispatchCallback(const char *methodname, Cronet_UrlRequestPtr request,
                      Dart_CObject args) {
  Dart_CObject c_method_name;
  c_method_name.type = Dart_CObject_kString;
  c_method_name.value.as_string = const_cast<char *>(methodname);

  Dart_CObject *c_request_arr[] = {&c_method_name, &args};
  Dart_CObject c_request;

  c_request.type = Dart_CObject_kArray;
  c_request.value.as_array.values = c_request_arr;
  c_request.value.as_array.length =
      sizeof(c_request_arr) / sizeof(c_request_arr[0]);

  Dart_PostCObject_DL(requestNativePorts[request], &c_request);
}

// Builds the arguments to pass to the Dart side as a parameter to the
// callbacks. [num] is the number of arguments to be passed and rest are the
// arguments.
Dart_CObject CallbackArgBuilder(int num, ...) {
  Dart_CObject c_request_data;
  va_list valist;
  va_start(valist, num);
  void *request_buffer = malloc(sizeof(uint64_t) * num);
  uint64_t *buf = reinterpret_cast<uint64_t *>(request_buffer);

  // uintptr_r will get implicitly casted to uint64_t. So, when the code is
  // executed in 32 bit mode, the upper 32 bit of buf[i] will be 0 extended
  // automatically. This is required because, on the Dart side these addresses
  // are viewed as 64 bit integers.
  for (int i = 0; i < num; i++) {
    buf[i] = va_arg(valist, uintptr_t);
  }

  c_request_data.type = Dart_CObject_kExternalTypedData;
  c_request_data.value.as_external_typed_data.type = Dart_TypedData_kUint8;
  c_request_data.value.as_external_typed_data.length = sizeof(uint64_t) * num;
  c_request_data.value.as_external_typed_data.data =
      static_cast<uint8_t *>(request_buffer);
  c_request_data.value.as_external_typed_data.peer = request_buffer;
  c_request_data.value.as_external_typed_data.callback = FreeFinalizer;

  va_end(valist);

  return c_request_data;
}
