// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cli_util/cli_logging.dart' show Ansi, Logger;
import 'package:cronet/src/constants.dart';

import 'prepare_cronet.dart';

Future<void> main(List<String> platforms) async {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  if (platforms.isEmpty || platforms.contains('-h')) {
    logger.stdout(
        'Please run: dart run cronet ${ansi.red}<platform>.${ansi.none}');
    return;
  }
  for (final platform in platforms) {
    if (!validPlatforms.contains(platform)) {
      logger
          .stderr('${ansi.red}$platform is not a valid platform.${ansi.none}');
      logger.stdout('Valid platfroms are:${ansi.yellow}');
      for (final valid in validPlatforms) {
        logger.stdout(valid);
      }
      logger.stdout(ansi.none);
      return;
    }

    if (platform.startsWith('linux')) {
      if (!buildWrapperLinux()) return;
    }
    await downloadCronetBinaries(platform);
  }
}
