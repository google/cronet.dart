// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:cronet/cronet.dart';

/* Trying to re-impliment: https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/sample/main.cc */

void main(List<String> args) {
  final stopwatch = Stopwatch()..start();
  final client = HttpClient();
  // for (var i = 0; i < 3; i++) {
  // Demo - with concurrent requests
  client
      .postUrl(Uri.parse('https://jsonplaceholder.typicode.com/posts'))
      .then((HttpClientRequest request) {
    request.headers.set('Content-Type', 'application/json; charset=UTF-8');
    // if (i == 2) {
    //   client.close(); // We will shut down the client after 3 connections.
    // }
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
  // }
}
