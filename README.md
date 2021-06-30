# Experimental Cronet Dart bindings

This package binds to Cronet's [native API](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/test_instructions.md) to expose them in Dart.

This is a [GSoC 2021 project](https://summerofcode.withgoogle.com/projects/#4757095741652992).

## Usage

1. Add package as a dependency in your `pubspec.yaml`.

2. Run this from the `root` of your project.

   **Dart CLI**

   ```bash
   dart pub get
   dart run cronet:setup # Downloads the cronet binaries.
   ```

3. Import

   ```dart
   import 'package:cronet/cronet.dart';
   ```

**Note:** Internet connection is required to download cronet binaries.

## Example

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

[See the API comparison with `dart:io`.](dart_io_comparison.md)

## Run Example

```bash
cd example_dart
dart run cronet:setup # Downloads the cronet binaries.
dart run
```

## Run Tests

```bash
dart pub get
dart run cronet <platform> # Downloads the cronet binaries.
dart test --platform vm
```

You can also verify your cronet binaries using `dart run cronet:setup verify`.
Make sure to have `cmake 3.15`.

## Building Your Own

1. Make sure you've downloaded your custom version of cronet shared library and filename follows the pattern `cronet.86.0.4240.198.<extension>` with a prefix `lib` if on `linux`. Else, you can build cronet from [source](https://www.chromium.org/developers/how-tos/get-the-code) using the [provided instuctions](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md). Then copy the library to the designated folder. For linux, the files are under `.dart_tool/cronet/linux64`.

2. Run `dart run cronet:setup build` from the root of your project.

**Note for Windows:** Run `step 3` from `x64 Native Tools Command Prompt for VS 2019` shell.
