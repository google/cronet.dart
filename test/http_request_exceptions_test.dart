// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

const host = 'localhost';

void main() {
  group('Request exceptions', () {
    late HttpClient client;
    late int port;
    setUp(() async {
      client = HttpClient();
      final server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.close();
    });

    test('URL does not exist', () async {
      // Using non-existent url.
      final request =
          await client.openUrl('GET', Uri.parse('http://localghost:$port'));
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The port is wrong', () async {
      // This port is already closed by the server.
      final request =
          await client.openUrl('GET', Uri.parse('http://$host:$port'));
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The scheme is wrong', () async {
      final request =
          await client.openUrl('GET', Uri.parse('nonExistent://$host:$port'));
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    tearDown(() {
      client.close();
    });
  });
}
