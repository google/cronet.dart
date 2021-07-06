import 'dart:convert';

import 'package:cronet/cronet.dart';

/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  for (var i = 0; i < 3; i++) {
    // Demo - with concurrent requests
    client
        .getUrl(Uri.parse('https://example.com'))
        .then((HttpClientRequest request) {
      if (i == 2) {
        client.close(); // We will shut down the client after 3 connections.
      }
      return request.close();
    }).then((HttpClientResponse response) {
      response.transform(utf8.decoder).listen((contents) {
        print(contents);
      }, onDone: () {
        print('cronet implemenation took: ${stopwatch.elapsedMilliseconds} ms');
      }, onError: (Object e) {
        print(e);
      });
    });
  }
}
