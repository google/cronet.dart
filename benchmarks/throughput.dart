// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:cronet/cronet.dart';

class CronetBenchmark {
  final String url;
  late HttpClient client;

  CronetBenchmark(this.url);

  static Future<void> main([String url = 'https://example.com/']) async {
    await CronetBenchmark(url).report();
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

  Future<List<int>> measure([int spawns = 512]) async {
    setup();
    // Warmup. Not measured.
    await warmup();
    // Run the benchmark for 1s and run [spawns] number of parallel tasks.
    var result = await measureFor(run, const Duration(seconds: 1), spawns);
    teardown();
    return result;
  }

  Future<void> report() async {
    int maxSpawn = 1024;
    for (int currentThreshold = 1;
        currentThreshold <= maxSpawn;
        currentThreshold *= 2) {
      final res = await measure(currentThreshold);
      print('Cronet(Throughput): Total Spawned: ${res[0]},'
          ' In Time Returns: ${res[1]}.');
    }
  }
}

void main() async {
  // Run CronetBenchmark.
  // URL can be provided as a parameter to ping a specific server.
  await CronetBenchmark.main();
}
