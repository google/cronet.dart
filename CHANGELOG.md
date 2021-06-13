## 0.0.1

### Partially migrated from unsuitable001/dart_cronet_sample

* HttpClient with QUIC, HTTP2, brotli support.
* HttpClient with a customizable user agent string.
* HttpClient close method (without force close).
* Implemented open, openUrl & other associated methods.
* Response is consumable using 2 styles of APIs. dart:io style and callback based style.
* Different types of Exceptions are implemented.

**Breaking Changes:**

* Custom `SecurityContext` is no longer handled by the client. Users have to handle it in other ways. (To be documented later).
* `userAgent` property is now read-only. Custom userAgent should be passed as a constructor argument.

**Notes:**

If callback based API is used, `stream` based api (`dart:io` style) will be closed immediately.
