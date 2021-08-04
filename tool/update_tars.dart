// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Update github releases tarballs.
import 'dart:io';

import 'package:cronet/src/constants.dart';
import 'package:path/path.dart';

void main() {
  final pwd = Directory.current;
  Directory.current =
      Directory.current.uri.resolve(join('.dart_tool', 'cronet')).path;
  for (final platform in desktopPlatforms) {
    if (File(join(platform, getCronetName(platform))).existsSync()) {
      final result =
          Process.runSync('tar', ['-czvf', '$platform.tar.gz', platform]);
      print(result.stdout);
      print(result.stderr);
    } else {
      print('${getCronetName(platform)} not found in' +
          join('.dart_tool', 'cronet', platform));
    }
  }
  // Make tarball for android releases.
  Directory.current = pwd;
  if (!Directory(androidPaths['cronet.jar']!).existsSync()) return;
  Directory(tempAndroidDownloadPath['cronet.jar']!).createSync(recursive: true);
  Directory(androidPaths['cronet.jar']!).listSync().forEach((jar) {
    if (jar is File) {
      jar.copySync(
          join(tempAndroidDownloadPath['cronet.jar']!, basename(jar.path)));
    }
  });
  Directory(tempAndroidDownloadPath['cronet.so']!).createSync(recursive: true);
  Directory(androidPaths['cronet.so']!)
      .listSync(recursive: true)
      .forEach((cronet) {
    if (cronet is File) {
      Directory(join(tempAndroidDownloadPath['cronet.so']!,
              basename(cronet.parent.path)))
          .createSync(recursive: true);
      cronet.copySync(join(tempAndroidDownloadPath['cronet.so']!,
          basename(cronet.parent.path), basename(cronet.path)));
    }
  });
  Directory.current =
      Directory.current.uri.resolve(join('.dart_tool', 'cronet')).path;
  final result = Process.runSync('tar', ['-czvf', 'android.tar.gz', 'android']);
  print(result.stdout);
  print(result.stderr);
}
