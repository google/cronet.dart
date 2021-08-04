// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:cronet/cronet.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String data = '';
  bool _fetching = false;
  final client = HttpClient();
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    request();
  }

  void request() {
    setState(() {
      _fetching = true;
      data = '';
    });
    client
        .getUrl(Uri.parse('http://info.cern.ch/'))
        .then((HttpClientRequest request) {
      _stopwatch.reset();
      _stopwatch.start();
      return request.close();
    }).then((Stream<List<int>> response) {
      response.transform(utf8.decoder).listen((contents) {
        setState(() {
          data += contents;
        });
      }, onDone: () {
        _stopwatch.stop();
        setState(() {
          _fetching = false;
        });
      }, onError: (dynamic e) {
        setState(() {
          data = e.toString();
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cronet Flutter Example'),
        ),
        body: Center(
            child: Column(children: [
          Text('Cronet Version: ${client.httpClientVersion}'),
          _fetching
              ? CircularProgressIndicator()
              : Expanded(child: SingleChildScrollView(child: Text(data))),
          Text('Time taken: ${_stopwatch.elapsedMilliseconds} ms')
        ])),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Reload',
          child: Icon(Icons.replay_outlined),
          onPressed: () => request(),
        ),
      ),
    );
  }
}
