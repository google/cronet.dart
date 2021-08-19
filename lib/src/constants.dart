// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:path/path.dart' as p;

import 'third_party/ffigen/find_resource.dart';

const desktopPlatforms = ['linux64', 'windows64', 'macos64'];
const mobilePlatforms = ['android'];
List<String> get validPlatforms => desktopPlatforms + mobilePlatforms;
const tag = 'binaries-v0.0.4';
const cronetBinaryUrl =
    'https://github.com/google/cronet.dart/releases/download/$tag/';
const cronetVersion = "86.0.4240.198";
const wrapperVersion = "2";

const binaryStorageDir = '.dart_tool/cronet/';

// Contains paths where downloaded binaries are stored temporarily.
final tempAndroidDownloadPath = {
  'cronet.jar': p.join(binaryStorageDir, 'android', 'libs'),
  'cronet.so': p.join(binaryStorageDir, 'android', 'jniLibs')
};

// Contains paths where downloaded binaries are located for Android.
final androidRoot = p.fromUri(findPackageRoot().resolve('android'));
final androidPaths = {
  'cronet.jar': p.join(androidRoot, 'libs'),
  'cronet.so': p.join(androidRoot, 'src', 'main', 'jniLibs')
};

String getDylibName(String name, [String platform = '']) {
  var ext = '.so';
  var prefix = 'lib';

  if (Platform.isWindows || platform.startsWith('windows')) {
    prefix = '';
    ext = '.dll';
  } else if (Platform.isMacOS || platform.startsWith('macos')) {
    ext = '.dylib';
  } else if (!(Platform.isLinux ||
      platform.startsWith('linux') ||
      Platform.isAndroid)) {
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
