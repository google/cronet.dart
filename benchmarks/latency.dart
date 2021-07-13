// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:cronet/cronet.dart';

abstract class LatencyBenchmark {
  Future<void> run();
  void setup();
  void teardown();

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
    print('$runtimeType(RunTime): $runtime ms');
    return runtime;
  }
}

class DartIOLatencyBenchmark extends LatencyBenchmark {
  final String url;
  late io.HttpClient client;

  DartIOLatencyBenchmark(this.url);

  static Future<double> main(String url) async {
    return await DartIOLatencyBenchmark(url).report();
  }

  // The benchmark code.
  @override
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
  @override
  void setup() {
    client = io.HttpClient();
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    client.close();
  }
}

class CronetLatencyBenchmark extends LatencyBenchmark {
  final String url;
  late HttpClient client;

  CronetLatencyBenchmark(this.url);

  static Future<double> main(String url) async {
    return await CronetLatencyBenchmark(url).report();
  }

  // The benchmark code.
  @override
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
  @override
  void setup() {
    client = HttpClient();
  }

  // Not measured teardown code executed after the benchmark runs.
  @override
  void teardown() {
    client.close();
  }
}

void main(List<String> args) async {
  // Accepts test url as optional cli parameter.
  // Accepts -c flag to run `dart:io` benchmark also.
  final params = List<String>.from(args);
  var url = 'https://example.com';
  var benchmarkDartIO = params.remove('-c');
  if (params.isNotEmpty) {
    url = params[0];
  }
  // TODO: https://github.com/google/cronet.dart/issues/11
  await CronetLatencyBenchmark.main(url);
  if (benchmarkDartIO) {
    // Used as an delemeter while parsing output in run_all script.
    print('*****');
    await DartIOLatencyBenchmark.main(url);
  }
}
