// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:cronet/cronet.dart';

abstract class LatencyBenchmark {
  final String url;

  LatencyBenchmark(this.url);

  Future<void> run();
  void setup();
  void teardown();

  Future<void> warmup() async {
    await run();
  }

  Future<double> measureFor(Function f, Duration duration) async {
    var durationInMilliseconds = duration.inMilliseconds;
    var iter = 0;
    var watch = Stopwatch();
    watch.start();
    var elapsed = 0;
    while (elapsed < durationInMilliseconds) {
      await f();
      elapsed = watch.elapsedMilliseconds;
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
  late io.HttpClient client;

  DartIOLatencyBenchmark(String url) : super(url);

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
  late HttpClient client;

  CronetLatencyBenchmark(String url) : super(url);

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
  final parser = ArgParser();
  parser
    ..addOption('url',
        abbr: 'u',
        help: 'The server to ping for running this benchmark.',
        defaultsTo: 'https://example.com')
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
  // TODO: https://github.com/google/cronet.dart/issues/11
  await CronetLatencyBenchmark.main(url);
  // Used as an delemeter while parsing output in run_all script.
  print('*****');
  await DartIOLatencyBenchmark.main(url);
}
