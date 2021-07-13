// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
  var url = 'https://example.com';
  var throughputPrallelLimit = 10;
  var duration = const Duration(seconds: 1);
  if (args.isNotEmpty) {
    url = args[0];
  }
  if (args.length > 1) {
    throughputPrallelLimit = int.parse(args[1]).toInt();
  }
  if (args.length > 2) {
    duration = Duration(seconds: int.parse(args[2]));
  }
  print('Latency Test against: $url');
  print('JIT');
  final jitCronetLatency = await CronetLatencyBenchmark.main(url);
  final jitDartIOLatency = await DartIOLatencyBenchmark.main(url);

  print('AOT');
  print('Compiling...');
  Process.runSync('dart', ['compile', 'exe', 'benchmarks/latency.dart']);
  final aotLantencyProc = await Process.start('benchmarks/latency.exe', [url]);
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
  Process.runSync('dart', ['compile', 'exe', 'benchmarks/throughput.dart']);
  final aotThroughputProc = await Process.start('benchmarks/throughput.exe',
      [url, throughputPrallelLimit.toString(), duration.inSeconds.toString()]);
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
  print('\n\nThroughput Test Results (Duration ${duration.inSeconds}');
  print('| Mode          | package:cronet  | dart:io        |');
  print('| :-----------: |:--------------: | :-----------:  |');
  print('| JIT           | ${jitCronetThroughput[1]} out of'
      ' ${jitCronetThroughput[0]}  | ${jitDartIOThroughput[1]} out of'
      ' ${jitDartIOThroughput[0]}  |');
  print('| AOT           | ${aotCronetThroughput[1]} out of'
      ' ${aotCronetThroughput[0]} | ${aotDartIOThroughput[1]} out of'
      ' ${aotDartIOThroughput[0]} |');
}
