// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Defines the available http protocols supported by Cronet.
enum HttpProtocol {
  /// HTTP/2 with QUIC.
  quic,

  /// HTTP/2 without QUIC.
  http2,

  /// HTTP/1.1.
  http
}
