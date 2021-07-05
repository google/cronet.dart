// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

const host = 'localhost';

void main() {
  group('Server Response Exceptions', () {
    late HttpClient client;
    late io.HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((io.HttpRequest request) {
        final paths = request.uri.pathSegments;
        assert(paths.isNotEmpty);
        request.response.statusCode = int.parse(paths[0]);
        request.response.close();
      });
    });

    test('404, Not Found', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/404'));
      final resp = await request.close();
      expect(
          resp,
          emitsInOrder(<Matcher>[
            emitsError(isA<HttpException>()
                .having((exception) => exception.message, 'message', '404')),
            emitsDone
          ]));
    });

    test('401, Unauthorized', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/401'));
      final resp = await request.close();
      expect(
          resp,
          emitsInOrder(<Matcher>[
            emitsError(isA<HttpException>()
                .having((exception) => exception.message, 'message', '401')),
            emitsDone
          ]));
    });

    test('503, Service Unavailable', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/503'));
      final resp = await request.close();
      expect(
          resp,
          emitsInOrder(<Matcher>[
            emitsError(isA<HttpException>()
                .having((exception) => exception.message, 'message', '503')),
            emitsDone
          ]));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
