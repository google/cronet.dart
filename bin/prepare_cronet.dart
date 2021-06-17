// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Contains the nessesary setup code only. Not meant to be exposed.

import 'dart:io' show Directory, File, Process, ProcessResult, ProcessStartMode;

import 'package:cronet/src/find_resource.dart';

import 'package:cronet/src/constants.dart';

/// Builds the [wrapper] shared library according to [build.sh] file.
void buildWrapper() {
  final wrapperPath = wrapperSourcePath();

  print('Building Wrapper...');
  Process.runSync('chmod', ['+x', '$wrapperPath/build.sh']);
  var result =
      Process.runSync('$wrapperPath/build.sh', [wrapperPath, cronetVersion]);
  print(result.stdout);
  print(result.stderr);
  print('Copying wrapper to project root...');
  result = Process.runSync('cp', ['$wrapperPath/wrapper.so', '.']);
  print(result.stdout);
  print(result.stderr);
}

/// Places downloaded binaries to proper location.
void placeBinaries(String platform, String fileName) {
  print('Extracting Cronet for $platform');
  ProcessResult res;
  // Process.runSync('mkdir', ['-p', 'cronet_binaries']);
  if (platform.startsWith('windows')) {
    res = Process.runSync('tar', ['-xvf', fileName]);
  } else {
    Directory('cronet_binaries').createSync();

    // Do we have tar extraction capability in dart's built-in libraries?
    res = Process.runSync('tar', ['-xvf', fileName, '-C', 'cronet_binaries']);
  }

  if (res.exitCode != 0) {
    throw Exception(
        "Can't unzip. Check if the downloaded file isn't corrupted");
  }
  print('Done! Cleaning up...');

  File(fileName).deleteSync();
  print('Done! Cronet support for $platform is now available!');
}

/// Download [cronet] library from Github Releases.
Future<void> downloadCronetBinaries(String platform) async {
  if (!isCronetAvailable(platform)) {
    final fileName = platform + (cBinExtMap[platform] ?? '');
    print('Downloading Cronet for $platform');
    final downloadUrl = cronetBinaryUrl + fileName;
    print(downloadUrl);
    final dProcess = await Process.start('curl', ['-OL', downloadUrl],
        mode: ProcessStartMode.inheritStdio);
    if (await dProcess.exitCode != 0) {
      throw Exception("Can't download. Check your network connection!");
    }
    placeBinaries(platform, fileName);
  } else {
    print("Cronet $platform is already available. No need to download.");
  }
}
