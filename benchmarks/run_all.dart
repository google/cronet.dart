// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';

import 'latency.dart';
import 'throughput.dart';

void main(List<String> args) async {
  var url = 'https://example.com';
  var throughputPrallelLimit = 10;
  switch (args.length) {
    case 1:
      url = args[0];
      break;
    case 2:
      url = args[0];
      throughputPrallelLimit = int.parse(args[1]).toInt();
      break;
    default:
  }
  print('Latency Test against: $url');
  print('JIT');
  final jitLatency = await CronetBenchmark.main(url);
  print('AOT');
  Process.runSync('dart', ['compile', 'exe', 'benchmarks/latency.dart']);
  final aotLatency = double.parse(
      Process.runSync('benchmarks/latency.exe', [url])
          .stdout
          .toString()
          .replaceAll(RegExp(r'[^0-9\\.]'), ''));
  print('Throughput Test against: $url with 2^$throughputPrallelLimit limit');
  print('JIT');
  final jitThroughput = await CronetThroughputBenchmark.main(
      url, pow(2, throughputPrallelLimit).toInt());
  print('AOT');
  Process.runSync('dart', ['compile', 'exe', 'benchmarks/throughput.dart']);
  final throughputStdout = Process.runSync(
          'benchmarks/throughput.exe', [url, throughputPrallelLimit.toString()])
      .stdout
      .toString();
  var aotThroughput = List<int>.filled(2, 0);
  throughputStdout.split('\n').forEach((line) {
    final match = RegExp(r'\d+').allMatches(line);
    if (match.length > 1) {
      if (int.parse(match.last.group(0)!) > aotThroughput[1]) {
        aotThroughput[0] = int.parse(match.first.group(0)!);
        aotThroughput[1] = int.parse(match.last.group(0)!);
      }
    }
  });

  print('Latency Test Results');
  print('| Mode          | package:cronet |');
  print('| :-----------: |:-------------: |');
  print('| JIT           | ${jitLatency.toStringAsFixed(4)} μs |');
  print('| AOT           | ${aotLatency.toStringAsFixed(4)} μs |');
  print('\n\nThroughput Test Results');
  print('| Mode          | package:cronet |');
  print('| :-----------: |:-------------: |');
  print('| JIT           | ${jitThroughput[1]} out of ${jitThroughput[0]} |');
  print('| AOT           | ${aotThroughput[1]} out of ${aotThroughput[0]} |');
}
