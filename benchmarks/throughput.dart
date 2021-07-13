// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;
import 'dart:math';

import 'package:cronet/cronet.dart';

abstract class ThroughputBenchmark {
  final int spawnThreshold;

  Future<void> run();
  void setup();
  void teardown();
  Future<void> warmup();

  ThroughputBenchmark(this.spawnThreshold);

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
    // Run the benchmark for 1s and run [spawns] number of parallel tasks.
    var result = await measureFor(run, const Duration(seconds: 1), spawns);
    teardown();
    return result;
  }

  Future<List<int>> report() async {
    var maxReturn = 0;
    var throughput = List<int>.empty();
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
  final String url;
  late io.HttpClient client;

  DartIOThroughputBenchmark(this.url, int spawnThreshold)
      : super(spawnThreshold);

  static Future<List<int>> main(String url, int spawnThreshold) async {
    return await DartIOThroughputBenchmark(url, spawnThreshold).report();
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
  final String url;
  late HttpClient client;

  CronetThroughputBenchmark(this.url, int spawnThreshold)
      : super(spawnThreshold);

  static Future<List<int>> main(String url, int spawnThreshold) async {
    return await CronetThroughputBenchmark(url, spawnThreshold).report();
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
  // Accepts test url & parallel request threshold as optional cli parameter.
  // Accepts -c flag to run `dart:io` benchmark also.
  final params = List<String>.from(args);
  var url = 'https://example.com';
  var spawnThreshold = 1024;
  var benchmarkDartIO = params.remove('-c');
  if (params.length == 1) {
    url = params[0];
  }
  if (params.length == 2) {
    spawnThreshold = pow(2, int.parse(params[1])).toInt();
  }
  // TODO: https://github.com/google/cronet.dart/issues/11
  await CronetThroughputBenchmark.main(url, spawnThreshold);
  if (benchmarkDartIO) {
    // Used as an delemeter while parsing output in run_all script.
    print('*****');
    await DartIOThroughputBenchmark.main(url, spawnThreshold);
  }
}
