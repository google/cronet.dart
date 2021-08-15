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
  group('Header Tests', () {
    late HttpClient client;
    late io.HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((io.HttpRequest request) {
        request.response.write(request.headers.value('test-header'));
        request.response.close();
      });
    });

    test('Send an arbitrary http header to the server', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/'));
      request.headers.set('test-header', sentData);
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Mutating headers after request.close throws error', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/'));
      await request.close();
      expect(
          () => request.headers.set('test-header', sentData), throwsStateError);
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
