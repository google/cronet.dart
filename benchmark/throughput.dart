// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:args/args.dart';
import 'package:cronet/cronet.dart';

abstract class ThroughputBenchmark {
  final String url;
  final int spawnThreshold;
  final Duration duration;

  Future<void> run();
  void setup();
  void teardown();
  Future<void> warmup();

  ThroughputBenchmark(this.url, this.spawnThreshold, this.duration);

  static Future<List<int>> measureFor(
      Future<void> Function() f, Duration duration, int maxSpawn) async {
    var durationInMicroseconds = duration.inMicroseconds;
    var inTimeReturns = 0;
    var lateReturns = 0;
    var watch = Stopwatch();
    final completer = Completer<List<int>>();
    watch.start();
    for (int i = 0; i < maxSpawn; i++) {
      f().then((_) {
        if (watch.elapsedMicroseconds < durationInMicroseconds) {
          inTimeReturns++;
        } else {
          watch.stop();
          lateReturns++;
        }
        if (inTimeReturns + lateReturns == maxSpawn) {
          completer.complete([maxSpawn, inTimeReturns]);
        }
      }).onError((error, stackTrace) {});
    }
    return completer.future;
  }

  Future<List<int>> measure(int spawns) async {
    setup();
    // Warmup. Not measured.
    await warmup();
    // Run the benchmark for [duration] with [spawns] number of parallel tasks.
    var result = await measureFor(run, duration, spawns);
    teardown();
    return result;
  }

  Future<List<int>> report() async {
    var maxReturn = 0;
    var throughput = [0, 0];
    // Run the benchmark for 1, 2, 4...spawnThreshold.
    for (int currentThreshold = 1;
        currentThreshold <= spawnThreshold;
        currentThreshold *= 2) {
      final res = await measure(currentThreshold);
      print('$runtimeType: Total Spawned: ${res[0]},'
          ' Returned in time: ${res[1]}.');
      if (res[1] > maxReturn) {
        maxReturn = res[1];
        throughput = res;
      }
    }
    // Return the result that has most returns.
    return throughput;
  }
}

class DartIOThroughputBenchmark extends ThroughputBenchmark {
  late io.HttpClient client;

  DartIOThroughputBenchmark(String url, int spawnThreshold, Duration duration)
      : super(url, spawnThreshold, duration);

  static Future<List<int>> main(
      String url, int spawnThreshold, Duration duration) async {
    return await DartIOThroughputBenchmark(url, spawnThreshold, duration)
        .report();
  }

  // The benchmark code.
  @override
  Future<void> run() async {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    await for (final _ in response) {}
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    client = io.HttpClient();
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    client.close();
  }

  @override
  Future<void> warmup() async {
    await run();
  }
}

class CronetThroughputBenchmark extends ThroughputBenchmark {
  late HttpClient client;

  CronetThroughputBenchmark(String url, int spawnThreshold, Duration duration)
      : super(url, spawnThreshold, duration);

  static Future<List<int>> main(
      String url, int spawnThreshold, Duration duration) async {
    return await CronetThroughputBenchmark(url, spawnThreshold, duration)
        .report();
  }

  // The benchmark code.
  @override
  Future<void> run() async {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    await for (final _ in response) {}
  }

  // Not measured setup code executed prior to the benchmark runs.
  @override
  void setup() {
    client = HttpClient();
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    client.close();
  }

  @override
  Future<void> warmup() async {
    await run();
  }
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
  final spawnThreshold =
      pow(2, int.parse(arguments['limit'] as String)).toInt();
  final duration = Duration(seconds: int.parse(arguments['time'] as String));
  // TODO: https://github.com/google/cronet.dart/issues/11
  await CronetThroughputBenchmark.main(url, spawnThreshold, duration);
  // Used as an delemeter while parsing output in run_all script.
  print('*****');
  await DartIOThroughputBenchmark.main(url, spawnThreshold, duration);
}
