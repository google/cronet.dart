// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Update github releases tarballs.
import 'dart:io';

import 'package:cronet/src/constants.dart';

void main() {
  Directory.current = Directory.current.uri.resolve('.dart_tool/cronet').path;
  for (final platform in validPlatforms) {
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
}
