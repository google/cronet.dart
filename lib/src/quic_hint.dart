// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class QuicHint {
  final String host;
  final int port;
  final int alternatePort;

  QuicHint(this.host, this.port, this.alternatePort);
}