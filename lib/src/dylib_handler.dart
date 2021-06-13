// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:ffi' show DynamicLibrary;
import 'dart:io' show Directory, File, Link, Platform;

import 'package:path/path.dart';

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
  const fileName = 'wrapper';
  var ext = '.so';
  var prefix = '';

  // When gradle builds the wrapper, it automatically prepends lib.
  if (Platform.isAndroid) {
    prefix = 'lib';
  }

  if (Platform.isWindows) {
    ext = '.dll';
  } else if (Platform.isMacOS) {
    ext = '.dylib';
  }

  var wrapperName = prefix + fileName + ext;

  // _resolveLibUri() will try to resolve wrapper's absolute path.
  // If it can't find it, try looking at search paths provided by the system.
  wrapperName = _resolveLibUri(wrapperName) ?? wrapperName;

  return Platform.isIOS
      ? DynamicLibrary.process()
      : DynamicLibrary.open(wrapperName);
}
