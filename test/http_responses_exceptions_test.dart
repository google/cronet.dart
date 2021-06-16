// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('response_HttpException_test', () {
    late HttpClient client;
    late HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await HttpServer.bind(InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((HttpRequest request) {
        final paths = request.uri.pathSegments;
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
            emitsError(isA<HttpException>().having(
                (exception) => exception.message, 'message', 'Not Found')),
            emitsDone
          ]));
    });

    test('401, Unauthorized', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/401'));
      final resp = await request.close();
      expect(
          resp,
          emitsInOrder(<Matcher>[
            emitsError(isA<HttpException>().having(
                (exception) => exception.message, 'message', 'Unauthorized')),
            emitsDone
          ]));
    });

    test('503, Service Unavailable', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/503'));
      final resp = await request.close();
      expect(
          resp,
          emitsInOrder(<Matcher>[
            emitsError(isA<HttpException>().having(
                (exception) => exception.message,
                'message',
                'Service Unavailable')),
            emitsDone
          ]));
    });

    test('New API: 503, Service Unavailable', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/503'));
      final success = await request.registerCallbacks(
          (data, bytesRead, responseCode) {}, onFailed: (reason) {
        expect(
            reason,
            isA<HttpException>().having((exception) => exception.message,
                'message', 'Service Unavailable'));
      });
      expect(success, equals(false));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
