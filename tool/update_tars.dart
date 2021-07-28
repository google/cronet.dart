// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Update github releases tarballs.
import 'dart:io';

import 'package:cronet/src/constants.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';
import 'package:path/path.dart';

void main() {
  Directory.current = Directory.current.uri.resolve('.dart_tool/cronet').path;
  for (final platform in desktopPlatforms) {
    if (File('$platform/${getCronetName(platform)}').existsSync()) {
      final result =
          Process.runSync('tar', ['-czvf', '$platform.tar.gz', platform]);
      print(result.stdout);
      print(result.stderr);
    } else {
      print(
          '${getCronetName(platform)} not found in .dart_tool/cronet/$platform');
    }
  }
  // Make tarball for android releases.
  final android =
      '${findPackageRoot().toFilePath(windows: Platform.isWindows)}/android';
  if (!Directory('$android/libs').existsSync()) return;
  Directory('android/libs').createSync(recursive: true);
  Directory('$android/libs/').listSync().forEach((jar) {
    if (jar is File) {
      print(jar);
      jar.copySync('android/libs/${basename(jar.path)}');
    }
  });
  Directory('android/jniLibs').createSync(recursive: true);
  Directory('$android/src/main/jniLibs/')
      .listSync(recursive: true)
      .forEach((cronet) {
    if (cronet is File) {
      print(cronet);
      Directory('android/jniLibs/${basename(cronet.parent.path)}').createSync();
      cronet.copySync('android/jniLibs/${basename(cronet.parent.path)}'
          '/${basename(cronet.path)}');
    }
  });
  final result = Process.runSync('tar', ['-czvf', 'android.tar.gz', 'android']);
  print(result.stdout);
  print(result.stderr);
}
