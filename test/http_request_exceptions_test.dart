// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

void main() {
  group('request_HttpException_test', () {
    late HttpClient client;
    setUp(() async {
      client = HttpClient();
    });

    test('URL do not exist', () async {
      final request = await client.openUrl('GET',
          Uri.parse('http://localghost:9999')); // localghost shouln't exist :p
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The port is wrong', () async {
      final request = await client.openUrl('GET',
          Uri.parse('http://localhost:9999')); // port 9999 should be close
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The scheme is wrong', () async {
      final request =
          await client.openUrl('GET', Uri.parse('random://localhost:5253'));
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    tearDown(() {
      client.close();
    });
  });
}
