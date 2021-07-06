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
  group('Server Responses', () {
    late HttpClient client;
    late io.HttpServer server;
    late int port;
    setUp(() async {
      client = HttpClient();
      server = await io.HttpServer.bind(io.InternetAddress.anyIPv6, 0);
      port = server.port;
      server.listen((io.HttpRequest request) {
        if (request.method != 'GET' && request.method != 'POST') {
          request.response.write(request.method);
        } else if (request.uri.path == '/301') {
          request.response.headers.add('Location', '/');
          request.response.statusCode = 301;
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
      final request = await client.get(host, port, '/path');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Gets Hello, world response from server using openUrl method',
        () async {
      final request = await client.openUrl(
          'GET', Uri.parse('http://$host:$port/some/path'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Fetch Hello, world response from server using openUrl, custom method',
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

    test('Sending a HEAD request to server should send no body', () async {
      final request = await client.head(host, port, '/path');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[emitsDone]));
    });

    test('Do a PUT request to the server', () async {
      final request = await client.put(host, port, '/path');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals('PUT'), emitsDone]));
    });

    test('Do a PATCH request to the server', () async {
      final request = await client.patch(host, port, '/path');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals('PATCH'), emitsDone]));
    });

    test('Do a DELETE request to the server', () async {
      final request = await client.delete(host, port, '/path');
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals('DELETE'), emitsDone]));
    });

    test('Rediect to the root path and fetch Hello, world response', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/301'));
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[equals(sentData), emitsDone]));
    });

    test('Cancel request in case of redirects', () async {
      final request = await client.getUrl(Uri.parse('http://$host:$port/301'));
      request.followRedirects = false;
      final resp = await request.close();
      final dataStream = resp.transform(utf8.decoder);
      expect(dataStream, emitsInOrder(<Matcher>[emitsDone]));
    });

    tearDown(() {
      client.close();
      server.close();
    });
  });
}
