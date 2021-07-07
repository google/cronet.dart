// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      await for (final _ in response) {}
    } catch (e) {
      print(e);
    }
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

  static Future<double> measureFor(Function f, int minimumMillis) async {
    var minimumMicros = minimumMillis * 1000;
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < minimumMicros) {
      await f();
      elapsed = watch.elapsedMicroseconds;
      iter++;
    }
    return elapsed / iter;
  }

  Future<double> measure() async {
    setup();
    // Warmup. Not measured.
    await warmup();
    // Run the benchmark for at least 2000ms.
    var result = await measureFor(run, 2000);
    teardown();
    return result;
  }

  Future<void> report() async {
    print('Cronet(RunTime): ${await measure()} us.');
  }
}

void main() async {
  // Run CronetBenchmark.
  // URL can be provided as a parameter to ping a specific server.
  await CronetBenchmark.main();
}
