// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi';

import 'dylib_handler.dart';
import 'third_party/cronet/generated_bindings.dart';
import 'wrapper/generated_bindings.dart';

Wrapper loadAndInitWrapper() {
  final wrapper = Wrapper(loadWrapper());
  // Initialize Dart Native API dynamically.
  wrapper.InitDartApiDL(NativeApi.initializeApiDLData);
  // Registers few cronet functions that are required by the wrapper.
  // Casting because of https://github.com/dart-lang/ffigen/issues/22
  wrapper.InitCronetApi(
      cronet.addresses.Cronet_Engine_Shutdown.cast(),
      cronet.addresses.Cronet_Engine_Destroy.cast(),
      cronet.addresses.Cronet_Buffer_Create.cast(),
      cronet.addresses.Cronet_Buffer_InitWithAlloc.cast(),
      cronet.addresses.Cronet_UrlResponseInfo_http_status_code_get.cast(),
      cronet.addresses.Cronet_Error_message_get.cast(),
      cronet.addresses.Cronet_UrlResponseInfo_http_status_text_get.cast());
  // Registers few cronet functions that are required by the executor
  // run from the wrapper for executing network requests.
  // Casting because of https://github.com/dart-lang/ffigen/issues/22
  wrapper.InitCronetExecutorApi(
      cronet.addresses.Cronet_Executor_CreateWith.cast(),
      cronet.addresses.Cronet_Executor_SetClientContext.cast(),
      cronet.addresses.Cronet_Executor_GetClientContext.cast(),
      cronet.addresses.Cronet_Executor_Destroy.cast(),
      cronet.addresses.Cronet_Runnable_Run.cast(),
      cronet.addresses.Cronet_Runnable_Destroy.cast());
  return wrapper;
}

final _cronet = Cronet(loadCronet());
Cronet get cronet => _cronet;

final _wrapper = loadAndInitWrapper();
Wrapper get wrapper => _wrapper;
