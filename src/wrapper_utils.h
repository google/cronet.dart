// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef WRAPPER_UTILS_H_
#define WRAPPER_UTILS_H_
#include "../third_party/cronet/cronet.idl_c.h"
#include "../third_party/dart-sdk/dart_api.h"
#include "../third_party/dart-sdk/dart_api_dl.h"
#include "../third_party/dart-sdk/dart_native_api.h"
#include "../third_party/dart-sdk/dart_tools_api.h"
#include <stdarg.h>
#include <stdlib.h>
#include <unordered_map>

void DispatchCallback(const char *methodname, Cronet_UrlRequestPtr request,
                      Dart_CObject args);
Dart_CObject CallbackArgBuilder(int num, ...);

#endif // WRAPPER_UTILS_H_
