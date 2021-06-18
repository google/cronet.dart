// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'prepare_cronet.dart';

void main(List<String> args) {
  if (args.contains('-h')) {
    print('build_cronet [cronet_version]');
  }
  final version = args.isEmpty ? null : args[0];
  if (Platform.isLinux) {
    buildWrapperLinux(version);
  } else if (Platform.isWindows) {
    buildWrapperWindows(version);
  } else {
    print("Unsupported platform.");
  }
}
