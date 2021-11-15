## 0.0.7

* Added support for iOS devices.

## 0.0.6

* Added data upload feature for `POST`, `PUT` and similar requests.

## 0.0.5

* Added support for adding user specified headers in `HttpClientRequest`.

## 0.0.4+4

* Added support for 32 bit architecture.

## 0.0.4+3

* Fixed type casting issue between `Uint8List` and `Uint64List` while passing callback arguments from C side to Dart side.

Note the changes in behavior of `Dart_PostCObject` with `Dart_TypedData_kUint64` at <https://dart-review.googlesource.com/c/sdk/+/207865>.

## 0.0.4+2

* Added `HttpClient` force close feature.

## 0.0.4+1

* Fixed benchmarking instructions.

## 0.0.4

* Added support for Android and Flutter Desktops (Windows/Linux).

## 0.0.3

* Using `package:args` for handling CLI arguments.
* Dependency versions increased.
* Corrected wrong cli command suggestions in case of un-locateable dylibs.
* Fixed throughput benchmark's `RangeError` in case of 0 result.

## 0.0.2

* Added support for MacOS.

## 0.0.1+1

* `HttpClientResponse`'s `followRedirects` and `maxRedirects` are now modifiable.
* Fixed: utf8 decoding of newLocation in case of redirects.

## 0.0.1

* HttpClient with QUIC, HTTP2, brotli support.
* HttpClient with a customizable user agent string.
* HttpClient close method (without force close).
* Implemented open, openUrl & other associated methods.
* Response is consumable using 2 styles of APIs. dart:io style and callback based style.
* Different types of Exceptions are implemented.

**Breaking Changes:**

* Custom `SecurityContext` is no longer handled by the client. Users have to handle it in other ways. (To be documented later).
* `userAgent` property is now read-only. Custom userAgent should be passed as a constructor argument.
