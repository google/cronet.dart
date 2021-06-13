// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';

void main() {
  group('callback_api_response_test', () {
    late HttpClient client;
    late HttpServer server;
    final sentData = 'Hello, world!';
    setUp(() async {
      client = HttpClient();
      server = await HttpServer.bind(InternetAddress.anyIPv6, 5256);
      server.listen((HttpRequest request) {
        if (request.method == 'CUSTOM') {
          request.response.write(request.method);
        } else {
          request.response.write(sentData);
        }
        request.response.close();
      });
    });

    test('New API: Gets Hello, world response from server using getUrl',
        () async {
      String resp = '';
      final request = await client.getUrl(Uri.parse('http://localhost:5256'));
      await request.registerCallbacks((data, bytesRead, responseCode, next) {
        resp += utf8.decoder.convert(data);
        next();
      });
      expect(resp, equals(sentData));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
