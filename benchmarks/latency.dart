// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cronet/cronet.dart';

class CronetBenchmark {
  final String url;
  late HttpClient client;

  CronetBenchmark(this.url);

  static Future<double> main([String url = 'https://example.com/']) async {
    return await CronetBenchmark(url).report();
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

  static Future<double> measureFor(Function f, Duration duration) async {
    var durationInMicroseconds = duration.inMicroseconds;
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < durationInMicroseconds) {
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
    // Run the benchmark for at least 2s.
    var result = await measureFor(run, const Duration(seconds: 2));
    teardown();
    return result;
  }

  Future<double> report() async {
    final runtime = await measure();
    print('Cronet(RunTime): $runtime us');
    return runtime;
  }
}

void main(List<String> args) async {
  // Run CronetBenchmark.
  // Accepts test url as optional cli parameter.
  if (args.length == 1) {
    await CronetBenchmark.main(args[0]);
  } else {
    await CronetBenchmark.main();
  }
}
