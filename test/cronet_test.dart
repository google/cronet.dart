// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

void main() {
  group('Cronet Initialization', () {
    late HttpClient client;
    setUp(() {
      client = HttpClient();
    });

    test('Validate static constants', () {
      expect(80, equals(HttpClient.defaultHttpPort));
      expect(443, equals(HttpClient.defaultHttpsPort));
    });

    test('Gets the version string', () {
      final exp = RegExp(r'^\d{2}.\d.\d{4}.\d{3}$');
      expect(true, exp.hasMatch(client.httpClientVersion));
    });

    test('Gets the user agent', () {
      expect(client.userAgent, equals('Dart/2.12'));
    });

    test('Loads another cronet engine with different config', () {
      final client2 = HttpClient(userAgent: 'Dart_Test/1.0');
      expect(client2, TypeMatcher<HttpClient>());
      expect(client2.userAgent, equals('Dart_Test/1.0'));
      client2.close();
    });

    tearDown(() {
      client.close();
    });
  });
}
