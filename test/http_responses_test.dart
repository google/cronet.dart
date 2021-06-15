// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:cronet/cronet.dart';
import 'package:test/test.dart';
import 'test_utils.dart';

void main() {
  group('http_responses_test', () {
    late HttpClient client;
    late HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await HttpServer.bind(InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((HttpRequest request) {
        if (request.method == 'CUSTOM') {
          request.response.write(request.method);
        } else {
          request.response.write(sentData);
        }
        request.response.close();
      });
    });

    test('Gets Hello, world response from server using getUrl', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Gets Hello, world response from server using get method', () async {
      final request = await client.get(host, port, '/');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Gets Hello, world response from server using openUrl method',
        () async {
      final request =
          await client.openUrl('GET', Uri.parse('http://$host:$port'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test(
        'Fetch Hello, world response from server using openUrl, custom method method',
        () async {
      final request =
          await client.openUrl('CUSTOM', Uri.parse('http://$host:$port'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals('CUSTOM'), emitsDone]));
    });

    test('Fetch Hello, world response from server using POST request',
        () async {
      final request = await client.postUrl(Uri.parse('http://$host:$port'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('response.close after registering callbacks will throw error',
        () async {
      final request = await client.postUrl(Uri.parse('http://$host:$port'));
      request.registerCallbacks((data, bytesRead, responseCode) {});
      expect(request.close(), throwsA(isA<ResponseListenerException>()));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
