// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math' as m;
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'exceptions.dart';
import 'globals.dart';
import 'third_party/cronet/generated_bindings.dart';
import 'wrapper/generated_bindings.dart' as wrpr;

/// Deserializes the message sent by cronet and it's wrapper.
class _CallbackRequestMessage {
  final String method;
  final Uint8List data;

  /// Constructs [method] and [data] from [message].
  factory _CallbackRequestMessage.fromCppMessage(List<dynamic> message) {
    return _CallbackRequestMessage._(
        message[0] as String, message[1] as Uint8List);
  }

  _CallbackRequestMessage._(this.method, this.data);

  @override
  String toString() => 'CppRequest(method: $method)';
}

/// Handles every kind of callbacks that are invoked by messages and
/// data that are sent by [NativePort] from native cronet library.
class CallbackHandler {
  final ReceivePort receivePort;
  final Pointer<wrpr.SampleExecutor> executor;

  // These are a part of HttpClientRequest Public API.
  bool followRedirects = true;
  int maxRedirects = 5;

  /// Stream controller to allow consumption of data like [HttpClientResponse].
  final _controller = StreamController<List<int>>();

  /// Registers the [NativePort] to the cronet side.
  CallbackHandler(this.executor, this.receivePort);

  /// [Stream] for [HttpClientResponse].
  Stream<List<int>> get stream {
    return _controller.stream;
  }

  /// [Stream] controller for [HttpClientResponse].
  StreamController<List<int>> get controller => _controller;

  // Clean up tasks for a request.
  //
  // We need to call this then whenever we are done with the request.
  void cleanUpRequest(
      Pointer<Cronet_UrlRequest> reqPtr, void Function() cleanUpClient) {
    receivePort.close();
    wrapper.RemoveRequest(reqPtr.cast());
    cleanUpClient();
  }

  /// Checks status of an URL response.
  bool statusChecker(int respCode, Pointer<Utf8> status, int lBound, int uBound,
      void Function() callback) {
    if (!(respCode >= lBound && respCode <= uBound)) {
      // If NOT in range.
      if (status == nullptr) {
        _controller.addError(HttpException('$respCode'));
      } else {
        final statusStr = status.toDartString();
        _controller.addError(
            HttpException(statusStr.isNotEmpty ? statusStr : '$respCode'));
        malloc.free(status);
      }
      callback();
      return false;
    }
    return true;
  }

  /// This listens to the messages sent by native cronet library.
  ///
  /// This also invokes the appropriate callbacks that are registered,
  /// according to the network events sent from cronet side.
  void listen(Pointer<Cronet_UrlRequest> reqPtr, void Function() cleanUpClient,
      Uint8List dataToUpload) {
    // Registers the listener on the receivePort.
    //
    // The message parameter contains both the name of the event and
    // the data associated with it.
    receivePort.listen((dynamic message) {
      final reqMessage =
          _CallbackRequestMessage.fromCppMessage(message as List);
      final args = reqMessage.data.buffer.asUint64List();

      /// Count of how many bytes has been uploaded to the server.
      int bytesSent = 0;

      switch (reqMessage.method) {
        case 'OnRedirectReceived':
          {
            final newUrlPtr = Pointer.fromAddress(args[0]).cast<Utf8>();
            log('New Location: '
                '${newUrlPtr.toDartString()}');
            malloc.free(newUrlPtr);
            // If NOT a 3XX status code, throw Exception.
            final status = statusChecker(args[1], Pointer.fromAddress(args[2]),
                300, 399, () => cronet.Cronet_UrlRequest_Cancel(reqPtr));
            if (!status) {
              break;
            }
            if (followRedirects && maxRedirects > 0) {
              final res = cronet.Cronet_UrlRequest_FollowRedirect(reqPtr);
              if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
                cleanUpRequest(reqPtr, cleanUpClient);
                throw UrlRequestError(res);
              }
              maxRedirects--;
            } else {
              cronet.Cronet_UrlRequest_Cancel(reqPtr);
            }
          }
          break;

        // When server has sent the initial response.
        case 'OnResponseStarted':
          {
            // If NOT a 1XX or 2XX status code, throw Exception.
            final status = statusChecker(args[0], Pointer.fromAddress(args[2]),
                100, 299, () => cronet.Cronet_UrlRequest_Cancel(reqPtr));
            log('Response started');
            if (!status) {
              break;
            }
            final res = cronet.Cronet_UrlRequest_Read(
                reqPtr, Pointer.fromAddress(args[1]).cast<Cronet_Buffer>());
            if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
              throw UrlRequestError(res);
            }
          }
          break;
        // Read a chunk of data.
        //
        // This is where we actually read the response from the server. Data
        // gets added to the stream here. ReadDataCallback is invoked here with
        // data received and no of bytes read.
        case 'OnReadCompleted':
          {
            final request = Pointer<Cronet_UrlRequest>.fromAddress(args[0]);
            final buffer = Pointer<Cronet_Buffer>.fromAddress(args[2]);
            final bytesRead = args[3];

            log('Recieved: $bytesRead');
            // If NOT a 1XX or 2XX status code, throw Exception.
            final status = statusChecker(args[1], Pointer.fromAddress(args[4]),
                100, 299, () => cronet.Cronet_UrlRequest_Cancel(reqPtr));
            if (!status) {
              break;
            }
            final data = cronet.Cronet_Buffer_GetData(buffer)
                .cast<Uint8>()
                .asTypedList(bytesRead);
            _controller.sink.add(data.toList(growable: false));
            final res = cronet.Cronet_UrlRequest_Read(request, buffer);
            if (res != Cronet_RESULT.Cronet_RESULT_SUCCESS) {
              cleanUpRequest(reqPtr, cleanUpClient);
              _controller.addError(UrlRequestError(res));
              _controller.close();
            }
          }
          break;
        // In case of network error, we will shut down everything.
        case 'OnFailed':
          {
            final errorStrPtr = Pointer.fromAddress(args[0]).cast<Utf8>();
            final error = errorStrPtr.toDartString();
            malloc.free(errorStrPtr);
            cleanUpRequest(reqPtr, cleanUpClient);
            _controller.addError(HttpException(error));
            _controller.close();
            cronet.Cronet_UrlRequest_Destroy(reqPtr);
          }
          break;
        // When the request is cancelled, we will shut down everything.
        case 'OnCanceled':
          {
            cleanUpRequest(reqPtr, cleanUpClient);
            _controller.close();
            cronet.Cronet_UrlRequest_Destroy(reqPtr);
          }
          break;
        // When the request is succesfully done, we will shut down everything.
        case 'OnSucceeded':
          {
            cleanUpRequest(reqPtr, cleanUpClient);
            _controller.close();
            cronet.Cronet_UrlRequest_Destroy(reqPtr);
          }
          break;
        case 'ReadFunc':
          {
            final size =
                cronet.Cronet_Buffer_GetSize(Pointer.fromAddress(args[1]));
            final remainintBytes = dataToUpload.length - bytesSent;
            final chunkSize = m.min(size, remainintBytes);
            final buff =
                cronet.Cronet_Buffer_GetData(Pointer.fromAddress(args[1]))
                    .cast<Uint8>();
            int i = 0;
            // memcopy from our buffer to cronet buffer.
            for (final byte in dataToUpload.getRange(bytesSent, chunkSize)) {
              buff[i] = byte;
              i++;
            }
            bytesSent += chunkSize;
            cronet.Cronet_UploadDataSink_OnReadSucceeded(
                Pointer.fromAddress(args[0]).cast(), chunkSize, false);
            break;
          }
        case 'RewindFunc':
          {
            bytesSent = 0;
            cronet.Cronet_UploadDataSink_OnRewindSucceeded(
                Pointer.fromAddress(args[0]));
            break;
          }
        case 'CloseFunc':
          {
            wrapper.UploadDataProviderDestroy(Pointer.fromAddress(args[0]));
            break;
          }
        default:
          {
            break;
          }
      }
    }, onError: (Object error) {
      log(error.toString());
    });
  }
}
