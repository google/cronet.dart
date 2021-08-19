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
  group('HttpClientRequest Upload Test', () {
    late HttpClient client;
    late io.HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((io.HttpRequest request) async {
        await request.forEach((data) {
          request.response.add(data);
        });
        request.response.close();
      });
    });

    test('Sending text a request body using POST method', () async {
      final request = await client.postUrl(Uri.parse('http://$host:$port/'));
      request.headers.set('Content-Type', 'text/plain');
      request.write(sentData);
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Mutating request body after request.close throws error', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/'));
      await request.close();
      expect(() => request.write(sentData), throwsStateError);
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
