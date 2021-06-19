// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

const validPlatforms = ['linux64', 'windows64'];
const release = '0.0.1';
// TODO: Change URL and Version
const cronetBinaryUrl =
    'https://github.com/unsuitable001/cronet.dart/releases/download/$release/';
const cronetVersion = "86.0.4240.198";

String getDylibName(String name, [String platform = '']) {
  var ext = '.so';
  var prefix = '';

  // When gradle builds the wrapper, it automatically prepends lib.
  if (Platform.isAndroid || platform.startsWith('android')) {
    prefix = 'lib';
  } else if (Platform.isWindows || platform.startsWith('windows')) {
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
