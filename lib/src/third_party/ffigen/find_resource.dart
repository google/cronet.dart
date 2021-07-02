// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io' show Directory, File, Platform;

import 'package:cronet/src/constants.dart';

/// Finds the root [Uri] of our package.
Uri findPackageRoot() {
  var root = Directory.current.uri;
  do {
    // Traverse up till .dart_tool/package_config.json is found.
    final file = File.fromUri(root.resolve('.dart_tool/package_config.json'));
    if (file.existsSync()) {
      // get package path from package_config.json.
      try {
        final packageMap =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        if (packageMap['configVersion'] == 2) {
          var packageRootUriString = (packageMap['packages'] as List<dynamic>)
                  .cast<Map<String, dynamic>>()
                  .firstWhere(
                      (element) => element['name'] == 'cronet')['rootUri']
              as String;
          packageRootUriString = packageRootUriString.endsWith('/')
              ? packageRootUriString
              : '$packageRootUriString/';
          return file.parent.uri.resolve(packageRootUriString);
        }
      } catch (e, s) {
        print(s);
        throw Exception("Cannot resolve package:cronet's rootUri");
      }
    }
  } while (root != (root = root.resolve('..')));
  print('Unable to fetch package location.'
      "Make sure you've added package:cronet as a dependency");
  throw Exception("Cannot resolve package:cronet's rootUri");
}

/// Gets the [wrapper]'s source code's path, throws [Exception] if not found.
String wrapperSourcePath() {
  final packagePath = findPackageRoot();
  final wrapperSource = packagePath.resolve('src');
  if (!Directory.fromUri(wrapperSource).existsSync()) {
    throw Exception('Cannot find wrapper source!');
  }
  return wrapperSource.toFilePath(windows: Platform.isWindows);
}

/// Checks if cronet binaries are already available in the project.
bool isCronetAvailable(String platform) {
  final cronetBinaries = File.fromUri(Directory.current.uri
          .resolve('.dart_tool/cronet/$platform/${getCronetName(platform)}'))
      .existsSync();
  final inRoot =
      File.fromUri(Directory.current.uri.resolve(getWrapperName(platform)))
              .existsSync() &&
          File.fromUri(Directory.current.uri.resolve(getCronetName(platform)))
              .existsSync();
  return cronetBinaries || inRoot;
}
