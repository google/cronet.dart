// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

void main() async {
  final root =
      Directory.fromUri(Platform.script).parent.parent.uri.toFilePath();

  final generateCronet = Process.run('dart', [
    'run',
    'ffigen',
    '--config=$root/lib/src/third_party/cronet/ffigen.yaml',
  ]);

  final generateWrapper = Process.run('dart', [
    'run',
    'ffigen',
    '--config=$root/lib/src/wrapper/ffigen.yaml',
  ]);

  final result1 = await generateCronet;
  print(result1.stdout);
  print(result1.stderr);
  final result2 = await generateWrapper;
  print(result2.stdout);
  print(result2.stderr);
}
