// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('request_HttpException_test', () {
    late HttpClient client;
    late int port;
    setUp(() async {
      client = HttpClient();
      final server = await HttpServer.bind(InternetAddress.anyIPv6, 0);
      port = server.port;
      server.close();
    });

    test('URL do not exist', () async {
      final request = await client.openUrl('GET',
          Uri.parse('http://localghost:$port')); // localghost shouln't exist :p
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The port is wrong', () async {
      final request = await client.openUrl('GET',
          Uri.parse('http://$host:$port')); // port 9999 should be close
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    test('The scheme is wrong', () async {
      final request =
          await client.openUrl('GET', Uri.parse('random://$host:$port'));
      final resp = await request.close();
      expect(resp,
          emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone]));
    });

    tearDown(() {
      client.close();
    });
  });
}
