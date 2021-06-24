// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cli_util/cli_logging.dart' show Ansi, Logger;

import 'package:cronet/src/constants.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';

import 'prepare_cronet.dart';

void main(List<String> args) {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);

  if (args.contains('-h')) {
    print('dart run cronet:build [cronet_version]');
  }
  final version = args.isEmpty ? cronetVersion : args[0];
  if (Platform.isLinux) {
    buildWrapperLinux(version);
  } else if (Platform.isWindows) {
    buildWrapperWindows(version);
  } else {
    logger.stderr('${ansi.red}Unsupported platform.${ansi.none}');
    return;
  }
  final cronetName = getDylibName('cronet.$version');
  if (!isCronetAvailable(Platform.isLinux ? 'linux64' : 'windows64')) {
    logger.stderr('${ansi.yellow}Make sure that your cronet shared library'
        ' is named as $cronetName and either placed in ${Directory.current.path}'
        ' or, available in your system\'s shared library search path.${ansi.none}');

    logger.stdout('For more info and build instructions, go to: '
        'https://github.com/google/cronet.dart/#building-your-own');
  }
}
