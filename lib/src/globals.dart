// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dylib_handler.dart';
import 'third_party/cronet/generated_bindings.dart';
import 'wrapper/generated_bindings.dart';

final _cronet = Cronet(loadCronet());
Cronet get cronet => _cronet;

final _wrapper = Wrapper(loadWrapper());
Wrapper get wrapper => _wrapper;
