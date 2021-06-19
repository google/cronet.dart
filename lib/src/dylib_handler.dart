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
///   1. Present Working Directory
///   2. Current script's/executable's directory
///   3. Current script's/executable's directory's parent
/// and returns the absolute path or [null] if can't be resolved.
String? _resolveLibUri(String name) {
  var libUri = Directory.current.uri.resolve(name);

  // If lib is in Present Working Directory.
  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's directory.
  libUri = Uri.directory(dirname(Platform.script.path)).resolve(name);

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's directory.
  libUri = Uri.directory(dirname(Platform.resolvedExecutable)).resolve(name);

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in script's directory's parent.

  libUri = Uri.directory(dirname(Platform.script.path)).resolve('../$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  // If lib is in executable's directory's parent.

  libUri =
      Uri.directory(dirname(Platform.resolvedExecutable)).resolve('../$name');

  if (_doesFileExist(libUri)) {
    return libUri.toFilePath(windows: Platform.isWindows);
  }

  return null;
}

/// Loads [wrapper] dynamic library depending on the platform.
///
/// This loaded [wrapper] will then load [cronet].
/// Throws an [ArgumentError] if library can't be loaded.
DynamicLibrary loadWrapper() {
  var wrapperName = getWrapperName();

  // _resolveLibUri() will try to resolve wrapper's absolute path.
  // If it can't find it, try looking at search paths provided by the system.
  wrapperName = _resolveLibUri(wrapperName) ?? wrapperName;

  try {
    return Platform.isIOS
        ? DynamicLibrary.process()
        : DynamicLibrary.open(wrapperName);
  } catch (exception) {
    final logger = Logger.standard();
    final ansi = Ansi(Ansi.terminalSupportsAnsi);

    logger.stderr(
        '${ansi.red}Failed to open the library. Make sure that required binaries are in place.${ansi.none}');
    logger.stdout(
        'To download the binaries, please run the following from the root of your project:');
    logger.stdout('${ansi.yellow}dart run cronet <platform>${ansi.none}');
    logger.stdout('${ansi.green}Valid platforms are:');
    for (final platform in validPlatforms) {
      logger.stdout(platform);
    }
    logger.stdout(ansi.none);
    rethrow;
  }
}
