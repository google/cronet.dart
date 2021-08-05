// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

const host = 'localhost';
const sentData = 'Hello, world!';

void main() {
  group('HttpClient Close', () {
    late io.HttpServer server;
    late int port;
    setUp(() async {
      server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((io.HttpRequest request) {
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
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test(
        'Force closing after starting a request cancels previous connections'
        ' with error event', () async {
      final client = HttpClient();
      final request =
          await client.openUrl('GET', Uri.parse('http://$host:$port'));
      final resp = await request.close();
      client.close(force: true);
      final dataStream = resp.transform(utf8.decoder);
      expect(
          dataStream,
          emitsInAnyOrder(<Matcher>[
            mayEmit(isA<Stream<String>>()),
            emitsInOrder(<Matcher>[emitsError(isA<HttpException>()), emitsDone])
          ]));
    });

    tearDown(() {
      server.close();
    });
  });
}
