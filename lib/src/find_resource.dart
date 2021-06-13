// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Contains code related to asset path resolution only. Not meant to be exposed.
// This code is a modified version from ffigen package's old commit.

import 'dart:convert';
import 'dart:io' show File, Directory;

/// Finds the root [Uri] of our package.
Uri? findPackageRoot() {
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
  return null;
}

/// Gets the [wrapper]'s source code's path, throws [Exception] if not found.
String wrapperSourcePath() {
  final packagePath = findPackageRoot();
  if (packagePath == null) {
    throw Exception("Cannot resolve package:cronet's rootUri");
  }
  final wrapperSource = packagePath.resolve('lib/src/native/wrapper');
  if (!Directory.fromUri(wrapperSource).existsSync()) {
    throw Exception('Cannot find wrapper source!');
  }
  return wrapperSource.toFilePath();
}

/// Checks if cronet binaries are already available in the project.
bool isCronetAvailable(String platform) {
  final cronetDir = Directory.current.uri.resolve('cronet_binaries/$platform/');
  return Directory.fromUri(cronetDir).existsSync();
}
