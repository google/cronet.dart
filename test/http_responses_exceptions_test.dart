// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

void main() {
  late HttpClient client;
  late HttpServer server;
  setUp(() async {
    client = HttpClient();
    server = await HttpServer.bind(InternetAddress.anyIPv6, 5255);
    server.listen((HttpRequest request) {
      final paths = request.uri.pathSegments;
      request.response.statusCode = int.parse(paths[0]);
      request.response.close();
    });
  });

  test('Throws a HttpException: Not Found when status code is 404', () async {
    final request = await client.getUrl(Uri.parse('http://localhost:5255/404'));
    final resp = await request.close();
    expect(
        resp,
        emitsInOrder(<Matcher>[
          emitsError(isA<HttpException>().having(
              (exception) => exception.message, 'message', 'Not Found')),
          emitsDone
        ]));
  });

  test('Throws a HttpException: Unauthorized when status code is 401',
      () async {
    final request = await client.getUrl(Uri.parse('http://localhost:5255/401'));
    final resp = await request.close();
    expect(
        resp,
        emitsInOrder(<Matcher>[
          emitsError(isA<HttpException>().having(
              (exception) => exception.message, 'message', 'Unauthorized')),
          emitsDone
        ]));
  });

  test('Throws a HttpException: Service Unavailable when status code is 503',
      () async {
    final request = await client.getUrl(Uri.parse('http://localhost:5255/503'));
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

  tearDown(() {
    client.close();
    server.close();
  });
}
