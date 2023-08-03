⚠️ This project has been superseeded by https://pub.dev/packages/cronet_http.

# Experimental Cronet Dart bindings

This package binds to Cronet's [native API](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/native/test_instructions.md) to expose them in Dart.

This is a [GSoC 2021 project](https://summerofcode.withgoogle.com/projects/#4757095741652992).

## Supported Platforms

Currently, Mobile and Desktop Platforms (Linux, Windows and MacOS<sup>\*</sup>) are supported.

<sup>\*</sup>MacOS is supported in `Dart CLI` platform only. Flutter compatible version coming soon.

## Requirements

1. Dart SDK 2.12.0 or above.
2. CMake 3.10 or above. (If on windows, Visual Studio 2019 with C++ tools)
3. C++ compiler. (g++/clang/msvc)
4. Android NDK if targeting Android.

## Usage

1. Add package as a dependency in your `pubspec.yaml`.

2. Run this from the `root` of your project.

   ```bash
   flutter pub get
   flutter pub run cronet:setup # Downloads the cronet binaries.
   ```

   We need to use `flutter pub` even if we want to use it with Dart CLI. See <https://github.com/dart-lang/pub/issues/2606> for further details.

   **Note for Android:** Remember to Add the following permissions in `AndroidManifest.xml` file.

   ```xml
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   ```

   Optionally, enable cleartext traffic by adding `android:usesCleartextTraffic="true"` to `AndroidManifest.xml` file.

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

### Flutter

```bash
cd example/flutter
flutter pub get
flutter pub run cronet:setup # Downloads the cronet binaries.
flutter run
```

### Dart CLI

```bash
cd example/cli
flutter pub get
flutter pub run cronet:setup # Downloads the cronet binaries.
dart run bin/example_dart.dart
```

## Run Tests

```bash
flutter pub get
flutter pub run cronet:setup # Downloads the cronet binaries.
flutter test
```

You can also verify your cronet binaries using `dart run cronet:setup verify`.
Make sure to have `cmake 3.10`.

## Benchmarking

See benchmark [summary](dart_io_comparison.md#performance-comparison) and [extensive reports](https://github.com/google/cronet.dart/issues/3) for comparison with `dart:io`.

```bash
flutter pub get
flutter pub run cronet:setup # Downloads the cronet binaries.
dart run benchmark/latency.dart # For sequential requests benchmark.
dart run benchmark/throughput.dart # For parallel requests benchmark.
dart run benchmark/run_all.dart # To run all the benchmarks and get reports.
```

Use `-h` to see available cli arguments and usage informations.

To know how to setup local test servers, read [benchmarking guide](benchmark/benchmarking.md).

Note: Test results may get affected by: <https://github.com/google/cronet.dart/issues/11>.

## Building Your Own

1. Make sure you've downloaded your custom version of cronet shared library and filename follows the pattern `cronet.86.0.4240.198.<extension>` with a prefix `lib` if on `linux`. Else, you can build cronet from [source](https://www.chromium.org/developers/how-tos/get-the-code) using the [provided instuctions](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md). Then copy the library to the designated folder. For linux, the files are under `.dart_tool/cronet/linux64`.

2. Run `dart run cronet:setup build` from the root of your project.

**Note for Windows:** Run `step 2` from `x64 Native Tools Command Prompt for VS 2019` shell.

**Note for Android:** Copy the produced jar files in `android/libs` and `.so` files in `android/src/main/jniLibs` subdirectory from the root of this package.
