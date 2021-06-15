// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('callback_api_response_test New API', () {
    late HttpClient client;
    late HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await HttpServer.bind(InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((HttpRequest request) {
        if (request.uri.pathSegments.isNotEmpty &&
            request.uri.pathSegments[0] == '301') {
          request.response.statusCode = 301;
          request.response.headers.set('Location', '/');
        } else {
          request.response.write(sentData);
        }
        request.response.close();
      });
    });

    test('Gets Hello, world response from server using getUrl', () async {
      String resp = '';
      final request = await client.getUrl(Uri.parse('http://$host:$port'));
      final success =
          await request.registerCallbacks((data, bytesRead, responseCode) {
        resp += utf8.decoder.convert(data);
      }, onSuccess: (responseCode) {
        expect(responseCode, equals(200));
      });
      expect(resp, equals(sentData));
      expect(success, equals(true));
    });

    test('Invalid URLs calls onFailed and returns false', () async {
      String resp = '';
      final request = await client.getUrl(
          Uri.parse('http://localghost:$port')); // localghost shouldn't exist
      final success =
          await request.registerCallbacks((data, bytesRead, responseCode) {
        resp += utf8.decoder.convert(data);
      }, onFailed: (HttpException reason) {
        expect(reason, isA<HttpException>());
      });
      expect(resp, equals(''));
      expect(success, equals(false));
    });

    test('URL redirect on 301 and fetch data', () async {
      String resp = '';
      final request =
          await client.getUrl(Uri.parse('http://$host:$port'));
      final success =
          await request.registerCallbacks((data, bytesRead, responseCode) {
        resp += utf8.decoder.convert(data);
      }, onRedirectReceived: (location, responseCode) {
        expect(responseCode, equals(301));
        expect(location, equals('http://$host:$port'));
      });
      expect(resp, equals(sentData));
      expect(success, equals(true));
    });

    test('registering callbacks after response.close will throw error',
        () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port'));
      await request.close();
      expect(request.registerCallbacks((data, bytesRead, responseCode) {}),
          throwsA(isA<ResponseListenerException>()));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
