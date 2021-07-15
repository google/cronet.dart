// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show DynamicLibrary;
import 'dart:io' show Directory, File, Link, Platform;

import 'package:cli_util/cli_logging.dart' show Ansi, Logger;
import 'package:path/path.dart';

import 'constants.dart';

/// Checks if [File]/[Link] exists for an [uri].
bool _doesFileExist(Uri uri) {
  return File.fromUri(uri).existsSync() || Link.fromUri(uri).existsSync();
}

/// Resolves the absolute path of a resource (usually a dylib).
///
/// Checks if a dynamic library is located in -
///   1. Present Working Directory and it's .dart_tool.
///   2. Current script's/executable's directory and it's .dart_tool.
///   3. Current script's/executable's directory's parent and it's .dart_tool.
/// and returns the absolute path or [null] if can't be resolved.
String? _resolveLibUri(String name) {
  var libUri = Directory.current.uri.resolve(name);
  var dartTool = '.dart_tool/cronet/';

  // If lib is in Present Working Directory.
  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in Present Working Directory's .dart_tool folder.
  if (Platform.isWindows) {
    dartTool += 'windows64';
  } else if (Platform.isMacOS) {
    dartTool += 'macos64';
  } else {
    dartTool += 'linux64';
  }

  libUri = Directory.current.uri.resolve('$dartTool/$name');
  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's directory.
  libUri = Uri.directory(dirname(Platform.script.path)).resolve(name);

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's .dart_tool directory.
  libUri =
      Uri.directory(dirname(Platform.script.path)).resolve('$dartTool/$name');
  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's directory.
  libUri = Uri.directory(dirname(Platform.resolvedExecutable)).resolve(name);

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's .dart_tool directory.
  libUri = Uri.directory(dirname(Platform.resolvedExecutable))
      .resolve('$dartTool/$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's directory's parent.

  libUri = Uri.directory(dirname(Platform.script.path)).resolve('../$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's directory's parent's .dart_tool.

  libUri = Uri.directory(dirname(Platform.script.path))
      .resolve('../$dartTool/$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's directory's parent.

  libUri =
      Uri.directory(dirname(Platform.resolvedExecutable)).resolve('../$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's directory's parent's .dart_tool.
  libUri = Uri.directory(dirname(Platform.resolvedExecutable))
      .resolve('..../$dartTool/$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  return null;
}

/// Loads dynamic library depending on the platform.
///
/// Throws an [ArgumentError] if library can't be loaded.
DynamicLibrary loadDylib(String name) {
  // _resolveLibUri() will try to resolve wrapper's absolute path.
  // If it can't find it, try looking at search paths provided by the system.
  name = _resolveLibUri(name) ?? name;

  try {
    return Platform.isIOS
        ? DynamicLibrary.process()
        : DynamicLibrary.open(name);
  } catch (exception) {
    final logger = Logger.standard();
    final ansi = Ansi(Ansi.terminalSupportsAnsi);

    logger
        .stderr('${ansi.red}Failed to open the library. Make sure that required'
            ' binaries are in place.${ansi.none}');
    logger.stdout(
        'To download the binaries, please run the following from the root of'
        ' your project:');
    logger.stdout('${ansi.yellow}dart run cronet:setup${ansi.none}');
    logger.stdout('${ansi.green}Valid platforms are:');
    for (final platform in validPlatforms) {
      logger.stdout(platform);
    }
    logger.stdout(ansi.none);
    rethrow;
  }
}

/// Loads `wrapper` dynamic library depending on the platform.
DynamicLibrary loadWrapper() {
  return loadDylib(getWrapperName());
}

/// Loads `cronet` dynamic library depending on the platform.
DynamicLibrary loadCronet() {
  return loadDylib(getCronetName());
}
