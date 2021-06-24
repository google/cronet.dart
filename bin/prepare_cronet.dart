// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Contains the nessesary setup code only. Not meant to be exposed.

import 'dart:io' show Directory, File, HttpClient, Process;

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';
import 'package:cronet/src/constants.dart';

import 'package:cli_util/cli_logging.dart' show Ansi, Logger;

/// Builds the `wrapper` shared library for linux.
bool buildWrapperLinux([String? version]) {
  final wrapperPath = wrapperSourcePath();
  final pwd = Directory.current;
  const compiler = 'g++';
  const cppV = '-std=c++11';
  const options = [
    '-fPIC',
    '-rdynamic',
    '-shared',
    '-W',
    '-ldl',
    '-DDART_SHARED_LIB',
    '-Wl,-z,origin',
    "-Wl,-rpath,\$ORIGIN",
    "-Wl,-rpath,\$ORIGIN/cronet_binaries/linux64/"
  ];
  const outputName = 'wrapper.so';
  const sources = [
    'wrapper.cc',
    '../third_party/cronet_impl/sample_executor.cc',
    '../third_party/dart-sdk/dart_api_dl.c',
  ];
  const includes = [
    '-I../third_party/cronet/',
    '-I../third_party/dart-sdk/',
  ];
  Directory.current = Directory(wrapperPath);
  print('Building Wrapper...');
  var result = Process.runSync(
      compiler,
      [cppV] +
          ['-DCRONET_VERSION="${version ?? cronetVersion}"'] +
          options +
          sources +
          ['-o', outputName] +
          includes);
  Directory.current = pwd;
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) return false;
  print('Copying wrapper to project root...');
  File('$wrapperPath/wrapper.so').copySync('wrapper.so');
  if (result.exitCode != 0) return false;
  return true;
}

/// Builds the `wrapper` shared library for windows.
bool buildWrapperWindows([String? version]) {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  final wrapperPath = wrapperSourcePath();
  final pwd = Directory.current;
  final environment = {
    'CL': '/DCRONET_VERSION="""${version ?? cronetVersion}"""'
  };
  Directory.current = Directory(wrapperPath);
  logger.stdout('Building Wrapper...');
  try {
    final result = Process.runSync('cmake', ['CMakeLists.txt', '-B', 'out'],
        environment: environment);
    print(result.stdout);
    print(result.stderr);
  } catch (error) {
    Directory.current = pwd;
    logger.stdout("${ansi.red}Build failed.${ansi.none}");
    logger.stdout(
        'Open ${ansi.yellow}x64 Native Tools Command Prompt for VS 2019.${ansi.none} Then run:\n');
    logger.stdout(
        'cd ${pwd.path}\ndart run cronet:build ${version ?? cronetVersion}');
    return false;
  }
  var result =
      Process.runSync('cmake', ['--build', 'out'], environment: environment);
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) return false;
  Directory.current = pwd;
  File('$wrapperPath\\out\\Debug\\wrapper.dll').copySync('wrapper.dll');
  return true;
}

// Extracts a tar.gz file.
void extract(String fileName, [String dir = '']) {
  final tarGzFile = File(fileName).readAsBytesSync();
  final archive = GZipDecoder().decodeBytes(tarGzFile, verify: true);
  final tarData = TarDecoder().decodeBytes(archive, verify: true);
  for (final file in tarData) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File(dir + filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(dir + filename).create(recursive: true);
    }
  }
}

/// Places downloaded binaries to proper location.
void placeBinaries(String platform, String fileName) {
  print('Extracting Cronet for $platform');

  if (platform.startsWith('windows')) {
    extract(fileName);
  } else {
    Directory('cronet_binaries').createSync();
    extract(fileName, 'cronet_binaries/');
  }
  print('Done! Cleaning up...');

  File(fileName).deleteSync();
  print('Done! Cronet support for $platform is now available!');
}

/// Download `cronet` library from Github Releases.
Future<void> downloadCronetBinaries(String platform) async {
  if (!isCronetAvailable(platform)) {
    final fileName = platform + '.tar.gz';
    print('Downloading Cronet for $platform');
    final downloadUrl = cronetBinaryUrl + fileName;
    print(downloadUrl);
    try {
      final request = await HttpClient().getUrl(Uri.parse(downloadUrl));
      final response = await request.close();
      final fileSink = File(fileName).openWrite();
      await response.pipe(fileSink);
      await fileSink.flush();
      await fileSink.close();
    } catch (error) {
      Exception("Can't download. Check your network connection!");
    }

    placeBinaries(platform, fileName);
  } else {
    print("Cronet $platform is already available. No need to download.");
  }
}
