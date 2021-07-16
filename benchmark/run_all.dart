// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';

import 'latency.dart';
import 'throughput.dart';

List<int> throughputParserHelper(String aotThroughputStdout) {
  var aotThroughput = List<int>.filled(2, 0);
  aotThroughputStdout.split('\n').forEach((line) {
    final match = RegExp(r'\d+').allMatches(line);
    if (match.length > 1) {
      if (int.parse(match.last.group(0)!) > aotThroughput[1]) {
        aotThroughput[0] = int.parse(match.first.group(0)!);
        aotThroughput[1] = int.parse(match.last.group(0)!);
      }
    }
  });
  return aotThroughput;
}

void main(List<String> args) async {
  final parser = ArgParser();
  parser
    ..addOption('url',
        abbr: 'u',
        help: 'The server to ping for running this benchmark.',
        defaultsTo: 'https://example.com')
    ..addOption('limit',
        abbr: 'l',
        help: 'Limits the maximum number of parallel requests to 2^N where N'
            ' is provided through this option.',
        defaultsTo: '10')
    ..addOption('time',
        abbr: 't',
        help: 'Maximum second(s) the benchmark should wait for each request.',
        defaultsTo: '1')
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Print this usage information.');
  final arguments = parser.parse(args);
  if (arguments.wasParsed('help')) {
    print(parser.usage);
    return;
  }
  if (arguments.rest.isNotEmpty) {
    print(parser.usage);
    throw ArgumentError();
  }
  final url = arguments['url'] as String;
  final throughputPrallelLimit = int.parse(arguments['limit'] as String);
  final duration = Duration(seconds: int.parse(arguments['time'] as String));

  print('Latency Test against: $url');
  print('JIT');
  final jitCronetLatency = await CronetLatencyBenchmark.main(url);
  final jitDartIOLatency = await DartIOLatencyBenchmark.main(url);

  print('AOT');
  print('Compiling...');
  Process.runSync('dart', ['compile', 'exe', 'benchmark/latency.dart']);
  final aotLantencyProc =
      await Process.start('benchmark/latency.exe', ['-u', url]);
  stderr.addStream(aotLantencyProc.stderr);
  var latencyStdout = '';
  await for (final chunk in aotLantencyProc.stdout.transform(utf8.decoder)) {
    latencyStdout += chunk;
    stdout.write(chunk);
  }
  // Delemeter to seperate Cronet and dart:io output.
  final rawAotLatency = latencyStdout.split('*****');
  final aotCronetLatency =
      double.parse(rawAotLatency[0].replaceAll(RegExp(r'[^0-9\\.]'), ''));
  final aotDartIOLatency =
      double.parse(rawAotLatency[1].replaceAll(RegExp(r'[^0-9\\.]'), ''));

  print('Throughput Test against: $url with 2^$throughputPrallelLimit limit');
  print('JIT');
  final jitCronetThroughput = await CronetThroughputBenchmark.main(
      url, pow(2, throughputPrallelLimit).toInt(), duration);
  final jitDartIOThroughput = await DartIOThroughputBenchmark.main(
      url, pow(2, throughputPrallelLimit).toInt(), duration);

  print('AOT');
  print('Compiling...');
  Process.runSync('dart', ['compile', 'exe', 'benchmark/throughput.dart']);
  final aotThroughputProc = await Process.start('benchmark/throughput.exe', [
    '-u',
    url,
    '-l',
    throughputPrallelLimit.toString(),
    '-t',
    duration.inSeconds.toString()
  ]);
  stderr.addStream(aotThroughputProc.stderr);
  var throughputStdout = '';
  await for (final chunk in aotThroughputProc.stdout.transform(utf8.decoder)) {
    throughputStdout += chunk;
    stdout.write(chunk);
  }
  // Delemeter to seperate Cronet and dart:io output.
  final rawAotThroughput = throughputStdout.split('*****');
  final aotCronetThroughput = throughputParserHelper(rawAotThroughput[0]);
  final aotDartIOThroughput = throughputParserHelper(rawAotThroughput[1]);

  print(
      'Test results may get affected by: https://github.com/google/cronet.dart/issues/11');
  print('Latency Test Results');
  print('| Mode          | package:cronet | dart:io        |');
  print('| :-----------: |:-------------: | :------------: |');
  print('| JIT           | ${jitCronetLatency.toStringAsFixed(3)} ms   |'
      ' ${jitDartIOLatency.toStringAsFixed(3)} ms   |');
  print('| AOT           | ${aotCronetLatency.toStringAsFixed(3)} ms   |'
      ' ${aotDartIOLatency.toStringAsFixed(3)} ms   |');
  print('\nThroughput Test Results (Duration: ${duration.inSeconds}s)');
  print('| Mode          | package:cronet  | dart:io        |');
  print('| :-----------: |:--------------: | :-----------:  |');
  print('| JIT           | ${jitCronetThroughput[1]} out of'
      ' ${jitCronetThroughput[0]}  | ${jitDartIOThroughput[1]} out of'
      ' ${jitDartIOThroughput[0]}  |');
  print('| AOT           | ${aotCronetThroughput[1]} out of'
      ' ${aotCronetThroughput[0]} | ${aotDartIOThroughput[1]} out of'
      ' ${aotDartIOThroughput[0]} |');
}
