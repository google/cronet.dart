// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('client_close_test', () {
    late HttpServer server;
    late int port;
    setUp(() async {
      server = await HttpServer.bind(InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((HttpRequest request) {
        request.response.write(sentData);
        request.response.close();
      });
    });

    test('Opening new request afterwards throws exception', () async {
      final client = HttpClient();
      client.close();
      expect(
          () async =>
              await client.openUrl('GET', Uri.parse('http://$host:$port')),
          throwsException);
    });

    test('Keeps the previous connection alive, if closed afterwards', () async {
      final client = HttpClient();
      final request =
          await client.openUrl('GET', Uri.parse('http://$host:$port'));
      final resp = await request.close();
      client.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<dynamic>[equals(sentData), emitsDone]));
    });

    tearDown(() {
      server.close();
    });
  });
}
