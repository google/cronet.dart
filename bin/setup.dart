// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:archive/archive.dart';
import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart' show Ansi, Logger;
import 'package:cronet/src/constants.dart';
import 'package:cronet/src/dylib_handler.dart';
import 'package:cronet/src/third_party/ffigen/find_resource.dart';
import 'package:cronet/src/wrapper/generated_bindings.dart';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart';

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

/// Places downloaded mobile binaries to proper location.
void placeMobileBinaries(String platform, String fileName) {
  Directory(androidPaths['cronet.jar']!).createSync(recursive: true);
  Directory(tempAndroidDownloadPath['cronet.jar']!).listSync().forEach((jar) {
    if (jar is File) {
      jar.renameSync(join(androidPaths['cronet.jar']!, basename(jar.path)));
    }
  });
  Directory(androidPaths['cronet.so']!).createSync(recursive: true);
  Directory(tempAndroidDownloadPath['cronet.so']!)
      .listSync(recursive: true)
      .forEach((cronet) {
    if (cronet is File) {
      Directory(join(androidPaths['cronet.so']!, basename(cronet.parent.path)))
          .createSync(recursive: true);
      cronet.renameSync(join(androidPaths['cronet.so']!,
          basename(cronet.parent.path), basename(cronet.path)));
    }
  });
}

/// Places downloaded binaries to proper location.
void placeBinaries(String platform, String fileName) {
  final logger = Logger.standard();
  final ansi = Ansi(Ansi.terminalSupportsAnsi);
  logger.stdout('${ansi.yellow}Extracting Cronet for $platform${ansi.none}');
  Directory(binaryStorageDir).createSync(recursive: true);
  extract(fileName, binaryStorageDir);
  if (mobilePlatforms.contains(platform)) {
    placeMobileBinaries(platform, fileName);
  }
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
    if (wrapperVersion !=
        Wrapper(loadWrapper()).VersionString().cast<Utf8>().toDartString()) {
      logger.stdout('${ansi.red}Wrapper is outdated for $platform.${ansi.none} '
          'Run: \nflutter pub run cronet:setup clean\n'
          'flutter pub run cronet:setup');
    } else {
      logger.stdout('${ansi.yellow}Cronet $platform is already available.'
          ' No need to download.${ansi.none}');
    }
  }
}

String _makeBuildOutputPath(String buildFolderPath, String fileName,
    {bool isDebug = false}) {
  if (Platform.isWindows) {
    return join(buildFolderPath, 'out', Platform.operatingSystem,
        isDebug ? 'Debug' : 'Release', fileName);
  } else if (Platform.isMacOS || Platform.isLinux) {
    return join(buildFolderPath, 'out', Platform.operatingSystem, fileName);
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
      join('out', Platform.operatingSystem),
      '-DCMAKE_BUILD_TYPE=Release'
    ]);
    print(result.stdout);
    print(result.stderr);
  } catch (error) {
    Directory.current = pwd;
    logger.stdout(error.toString());
    logger.stdout("${ansi.red}Build failed.${ansi.none}");
    if (Platform.isWindows) {
      logger.stdout(
          'Open ${ansi.yellow}x64 Native Tools Command Prompt for VS 2019.'
          '${ansi.none} Then run:\n'
          'cd ${pwd.path}\ndart run cronet:setup build');
    }
    return;
  }
  var result = Process.runSync('cmake', [
    '--build',
    join('out', Platform.operatingSystem),
    '--config',
    'Release'
  ]);
  print(result.stdout);
  print(result.stderr);
  if (result.exitCode != 0) exit(result.exitCode);
  Directory.current = pwd;
  final moveLocation = '$binaryStorageDir${Platform.operatingSystem}64';
  Directory(moveLocation).createSync(recursive: true);
  final buildOutputPath = _makeBuildOutputPath(wrapperPath, getWrapperName());
  File(buildOutputPath).copySync(join(moveLocation, getWrapperName()));
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
      .resolve(join('third_party', 'cronet_sample'))
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
    join(sampleSource, 'CMakeLists.txt'),
    '-B',
    join(sampleSource, 'out', Platform.operatingSystem)
  ], environment: {
    'CURRENTDIR': pwd.path
  });
  print(result.stdout);
  print(result.stderr);
  result = Process.runSync(
      'cmake', ['--build', join(sampleSource, 'out', Platform.operatingSystem)],
      environment: {'CURRENTDIR': pwd.path});
  print(result.stdout);
  print(result.stderr);
  final buildOutputPath =
      _makeBuildOutputPath(sampleSource, buildName, isDebug: true);

  logger.stdout('Copying...');
  final sample = File(buildOutputPath).copySync(
      join('.dart_tool', 'cronet', Platform.operatingSystem + '64', buildName));

  logger.stdout('Verifying...');
  result = Process.runSync(
      join('.dart_tool', 'cronet', Platform.operatingSystem + '64', buildName),
      []);
  if (result.exitCode == 0) {
    logger.stdout('${ansi.green}Verified! Cronet is working fine.${ansi.none}');
  } else {
    logger.stderr('${ansi.red}Verification failed!${ansi.none}');
  }
  sample.deleteSync();
}

// Available Commands.

class BuildCommand extends Command<void> {
  @override
  String get description => 'Builds the wrapper binaries. Requires cmake.';

  @override
  String get name => 'build';

  @override
  void run() {
    buildWrapper();
  }
}

class CleanCommand extends Command<void> {
  @override
  String get description => 'Cleans downloaded or built binaries.';

  @override
  String get name => 'clean';

  @override
  void run() {
    print('cleaning...');
    Directory(binaryStorageDir).deleteSync(recursive: true);
  }
}

class VerifyCommand extends Command<void> {
  @override
  String get description => 'Verifies the cronet binary.';

  @override
  String get name => 'verify';

  @override
  void run() {
    verifyCronetBinary();
  }
}

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<void>('setup', 'Downloads/Builds the cronet binaries.');
  runner
    ..addCommand(BuildCommand())
    ..addCommand(CleanCommand())
    ..addCommand(VerifyCommand());
  if (args.isEmpty) {
    // Targeting only 64bit OS. (At least for the time being.)
    if (validPlatforms.contains('${Platform.operatingSystem}64')) {
      await downloadCronetBinaries('${Platform.operatingSystem}64');
    }
    if (Directory('android').existsSync()) {
      await downloadCronetBinaries('android');
    }
  } else {
    await runner.run(args);
  }
}
