# Experimental Cronet Dart bindings

This package binds to Cronet's [native API](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/test_instructions.md) to expose them in Dart.

This is a [GSoC 2021 project](https://summerofcode.withgoogle.com/projects/#4757095741652992).

## Usage

1. Add package as a dependency in your `pubspec.yaml`.

2. Run this from the `root` of your project.

   **Dart CLI**

   ```bash
   dart pub get
   dart run cronet <platform> # Downloads the cronet binaries.
   ```

   **Flutter**

   ```bash
   flutter pub get
   flutter run cronet <platform> # Downloads the cronet binaries.
   ```

   Supported platforms: `linux64` and `windows64`.

3. Import

   ```dart
   import 'package:cronet/cronet.dart';
   ```

**Note:** Internet connection is required to download cronet binaries.

## Example

### `dart:io` style API

```dart
  final client = HttpClient();
  client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    return request.close();
  }).then((HttpClientResponse response) {
    response.transform(utf8.decoder).listen((contents) {
      print(contents);
    },
      onDone: () => print(
        'Done!'));
  });
```

### Alternate API

```dart
  final client = HttpClient();
  client
      .getUrl(Uri.parse('http://info.cern.ch/'))
      .then((HttpClientRequest request) {
    request.registerCallbacks((data, bytesRead, responseCode) {
      print(utf8.decoder.convert(data));
      print('Status: $responseCode');
    },
        onSuccess: (responseCode) =>
            print('Done with status: $responseCode')).catchError(
        (Object e) {print(e);});
  });
```

## Run Example

```bash
cd example_dart
dart run cronet <platform> # Downloads the cronet binaries.
dart run
```

Replace `<platform>` with `linux64` or `windows64`.

## Run Tests

```bash
dart pub get
dart run cronet <platform> # Downloads the cronet binaries.
dart test --platform vm
```

**Wrapper & Cronet binaries build guide**: [BUILD.md](lib/src/native/wrapper/BUILD.md)
