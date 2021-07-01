// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef WRAPPER_EXPORT_H_
#define WRAPPER_EXPORT_H_

#if defined(WIN32)
#define WRAPPER_EXPORT __declspec(dllexport)
#else
#define WRAPPER_EXPORT __attribute__((visibility("default")))
#endif

#endif  // WRAPPER_EXPORT_H_
