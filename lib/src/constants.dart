// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

const validPlatforms = ['linux64', 'windows64'];
const tag = 'binaries-v0.0.1';
const cronetBinaryUrl =
    'https://github.com/google/cronet.dart/releases/download/$tag/';
const cronetVersion = "86.0.4240.198";

const binaryStorageDir = '.dart_tool/cronet/';

String getDylibName(String name, [String platform = '']) {
  var ext = '.so';
  var prefix = 'lib';

  if (Platform.isWindows || platform.startsWith('windows')) {
    prefix = '';
    ext = '.dll';
  } else if (Platform.isMacOS || platform.startsWith('macos')) {
    ext = '.dylib';
  } else if (!(Platform.isLinux || platform.startsWith('linux'))) {
    // If NOT even linux, then unsupported.
    throw Exception('Unsupported Platform.');
  }
  return prefix + name + ext;
}

String getWrapperName([String platform = '']) {
  return getDylibName('wrapper', platform);
}

String getCronetName([String platform = '']) {
  return getDylibName('cronet.$cronetVersion', platform);
}
