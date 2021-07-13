// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cli_util/cli_logging.dart' show Ansi, Logger;
import 'package:cronet/src/constants.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';

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
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  logger.stdout('${ansi.yellow}Extracting Cronet for $platform${ansi.none}');
  Directory(binaryStorageDir).createSync(recursive: true);
  extract(fileName, binaryStorageDir);
  logger.stdout('Done! Cleaning up...');

  File(fileName).deleteSync();
}

/// Download `cronet` library from Github Releases.
Future<void> downloadCronetBinaries(String platform) async {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  if (!isCronetAvailable(platform)) {
    final fileName = platform + '.tar.gz';
    logger.stdout('Downloading Cronet for $platform');
    final downloadUrl = cronetBinaryUrl + fileName;
    logger.stdout(downloadUrl);
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(downloadUrl));
      final response = await request.close();
      final fileSink = File(fileName).openWrite();
      await response.pipe(fileSink);
      await fileSink.flush();
      await fileSink.close();
      httpClient.close();
    } catch (error) {
      Exception("Can't download. Check your network connection!");
    }
    placeBinaries(platform, fileName);
    buildWrapper();
    logger.stdout(
        '${ansi.green}Done! Cronet support for $platform is now available!'
        '${ansi.none}');
  } else {
    logger.stdout('${ansi.yellow}Cronet $platform is already available.'
        ' No need to download.${ansi.none}');
  }
}

String _makeBuildOutputPath(String buildFolderPath, String fileName,
    {bool isDebug = false}) {
  if (Platform.isWindows) {
    return '$buildFolderPath\\out\\${Platform.operatingSystem}\\${isDebug ? "Debug" : "Release"}\\$fileName';
  } else if (Platform.isMacOS || Platform.isLinux) {
    return '$buildFolderPath/out/${Platform.operatingSystem}/$fileName';
  } else {
    throw Exception('Unsupported Platform.');
  }
}

/// Builds wrapper from source for the current platform.
void buildWrapper() {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  final wrapperPath = wrapperSourcePath();
  final pwd = Directory.current;
  Directory.current = Directory(wrapperPath);
  logger.stdout('Building Wrapper...');
  try {
    final result = Process.runSync('cmake', [
      'CMakeLists.txt',
      '-B',
      'out/${Platform.operatingSystem}',
      '-DCMAKE_BUILD_TYPE=Release'
    ]);
    print(result.stdout);
    print(result.stderr);
  } catch (error) {
    Directory.current = pwd;
    logger.stdout("${ansi.red}Build failed.${ansi.none}");
    if (Platform.isWindows) {
      logger.stdout(
          'Open ${ansi.yellow}x64 Native Tools Command Prompt for VS 2019.'
          '${ansi.none} Then run:\n'
          'cd ${pwd.path}\ndart run cronet:setup build');
    }
    return;
  }
  var result = Process.runSync('cmake',
      ['--build', 'out/${Platform.operatingSystem}', '--config', 'Release']);
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) return;
  Directory.current = pwd;
  final moveLocation = '$binaryStorageDir${Platform.operatingSystem}64';
  Directory(moveLocation).createSync(recursive: true);
  final buildOutputPath = _makeBuildOutputPath(wrapperPath, getWrapperName());
  File(buildOutputPath).copySync('$moveLocation/${getWrapperName()}');
  logger.stdout(
      '${ansi.green}Wrapper moved to $moveLocation. Success!${ansi.none}');
  return;
}

String _getCronetSampleBuildName() {
  if (Platform.isWindows) {
    return 'cronet_sample.exe';
  } else if (Platform.isMacOS || Platform.isLinux) {
    return 'cronet_sample';
  } else {
    throw Exception('Unsupported Platform.');
  }
}

/// Verify if cronet binary is working correctly.
void verifyCronetBinary() {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  final sampleSource = findPackageRoot()
      .resolve('third_party/cronet_sample')
      .toFilePath(windows: Platform.isWindows);
  final buildName = _getCronetSampleBuildName();
  final pwd = Directory.current;
  if (!isCronetAvailable('${Platform.operatingSystem}64')) {
    logger.stderr('${ansi.red}Cronet binaries are not available.${ansi.none}');
    logger.stdout('Get the cronet binaries by running: dart run cronet:setup');
    return;
  }

  logger.stdout('Building Sample...');
  var result = Process.runSync('cmake', [
    '$sampleSource/CMakeLists.txt',
    '-B',
    '$sampleSource/out/${Platform.operatingSystem}'
  ], environment: {
    'CURRENTDIR': pwd.path
  });
  print(result.stdout);
  print(result.stderr);
  result = Process.runSync(
      'cmake', ['--build', '$sampleSource/out/${Platform.operatingSystem}'],
      environment: {'CURRENTDIR': pwd.path});
  print(result.stdout);
  print(result.stderr);
  final buildOutputPath =
      _makeBuildOutputPath(sampleSource, buildName, isDebug: true);

  logger.stdout('Copying...');
  final sample = File(buildOutputPath)
      .copySync('.dart_tool/cronet/${Platform.operatingSystem}64/$buildName');

  logger.stdout('Verifying...');
  result = Process.runSync(
      '.dart_tool/cronet/${Platform.operatingSystem}64/$buildName', []);
  if (result.exitCode == 0) {
    logger.stdout('${ansi.green}Verified! Cronet is working fine.${ansi.none}');
  } else {
    logger.stderr('${ansi.red}Verification failed!${ansi.none}');
  }
  sample.deleteSync();
}

Future<void> main(List<String> args) async {
  const docStr = """
dart run cronet:setup [option]
Downloads the cronet binaries.\n
clean\tClean downloaded or built binaries.
build\tBuilds the wrapper. Requires cmake.
verify\tVerifies the cronet binary.
  """;
  final logger = Logger.standard();
  if (args.length > 1) {
    logger.stderr('Expected 1 argument only.');
    logger.stdout(docStr);
  } else if (args.contains('-h')) {
    logger.stdout(docStr);
  } else if (args.contains('clean')) {
    logger.stdout('cleaning...');
    Directory(binaryStorageDir).deleteSync(recursive: true);
    logger.stdout('Done!');
  } else if (args.contains('build')) {
    buildWrapper();
  } else if (args.contains('verify')) {
    verifyCronetBinary();
  } else {
    // Targeting only 64bit OS. (At least for the time being.)
    if (validPlatforms.contains('${Platform.operatingSystem}64')) {
      await downloadCronetBinaries('${Platform.operatingSystem}64');
    }
  }
}
