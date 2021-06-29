// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Contains the nessesary setup code only. Not meant to be exposed.

import 'dart:io' show Directory, File, HttpClient, Process;

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:cli_util/cli_logging.dart' show Ansi, Logger;
import 'package:cronet/src/constants.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';

/// Builds the `wrapper` shared library for linux.
bool buildWrapperLinux() {
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
    '-DDART_SHARED_LIB'
  ];
  const outputName = 'libwrapper.so';
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
      compiler, [cppV] + options + sources + ['-o', outputName] + includes);
  Directory.current = pwd;
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) return false;
  print("Copying wrapper to project's .dart_tool...");
  Directory('.dart_tool/cronet/linux64').createSync(recursive: true);
  File('$wrapperPath/$outputName')
      .copySync('.dart_tool/cronet/linux64/$outputName');
  if (result.exitCode != 0) return false;
  return true;
}

/// Builds the `wrapper` shared library for windows.
bool buildWrapperWindows() {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  final wrapperPath = wrapperSourcePath();
  final pwd = Directory.current;
  Directory.current = Directory(wrapperPath);
  logger.stdout('Building Wrapper...');
  try {
    final result = Process.runSync('cmake', ['CMakeLists.txt', '-B', 'out']);
    print(result.stdout);
    print(result.stderr);
  } catch (error) {
    Directory.current = pwd;
    logger.stdout("${ansi.red}Build failed.${ansi.none}");
    logger.stdout(
        'Open ${ansi.yellow}x64 Native Tools Command Prompt for VS 2019.${ansi.none} Then run:\n');
    logger.stdout('cd ${pwd.path}\ndart run cronet:build');
    return false;
  }
  var result = Process.runSync('cmake', ['--build', 'out']);
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) return false;
  Directory.current = pwd;
  Directory('.dart_tool\\cronet\\windows64').createSync(recursive: true);
  File('$wrapperPath\\out\\Debug\\wrapper.dll')
      .copySync('.dart_tool\\cronet\\windows64\\wrapper.dll');
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
      Directory(dir + filename).createSync(recursive: true);
    }
  }
}

/// Places downloaded binaries to proper location.
void placeBinaries(String platform, String fileName) {
  print('Extracting Cronet for $platform');
  Directory('.dart_tool/cronet').createSync(recursive: true);
  extract(fileName, '.dart_tool/cronet/');
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
