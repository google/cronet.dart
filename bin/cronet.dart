// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cronet/src/prepare_cronet.dart';

Future<void> main(List<String> platforms) async {
  for (final platform in platforms) {
    if (platform.startsWith('linux')) {
      buildWrapper();
    }
    await downloadCronetBinaries(platform);
  }
}
