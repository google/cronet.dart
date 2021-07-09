// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:cronet/cronet.dart';

class CronetThroughputBenchmark {
  final String url;
  final int spawnThreshold;
  late HttpClient client;

  CronetThroughputBenchmark(this.url, this.spawnThreshold);

  static Future<List<int>> main(
      [String url = 'https://example.com/', int spawnThreshold = 1024]) async {
    return await CronetThroughputBenchmark(url, spawnThreshold).report();
  }

  // The benchmark code.
  Future<void> run() async {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    await for (final _ in response) {}
  }

  // Not measured setup code executed prior to the benchmark runs.
  void setup() {
    client = HttpClient();
  }

  // Not measured teardown code executed after the benchmark runs.
  void teardown() {
    client.close();
  }

  Future<void> warmup() async {
    await run();
  }

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
      print('Cronet(Throughput): Total Spawned: ${res[0]},'
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

void main(List<String> args) async {
  // Run CronetThroughputBenchmark.
  // Accepts test url & parallel request threshold as optional cli parameter.
  if (args.length == 1) {
    await CronetThroughputBenchmark.main(args[0]);
  } else if (args.length == 2) {
    // Parallel request limit is determined as 2^N. N is taken from cli args.
    await CronetThroughputBenchmark.main(
        args[0], pow(2, int.parse(args[1])).toInt());
  } else {
    await CronetThroughputBenchmark.main();
  }
}
