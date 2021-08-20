# Comparing with dart:io

This page covers the API differences and performance differences.

## API Comparison

We have `2` API differences between `dart:io` and `package:cronet`.

### SecurityContext

#### dart:io

```dart
HttpClient({SecurityContext? context})
```

#### package:cronet

`HttpClient` constructor doesn't take `SecurityContext` as a parameter. To use any custom/self-signed SSL certificate, it must be added to the system's trust store.

### userAgent

#### dart:io

```dart
final client = HttpClient();
client.userAgent = 'myUA/1.0'; // using custom UA string.
print(client.userAgent); // Will print myUA/1.0.
```

#### package:cronet

```dart
final client = HttpClient(userAgent: 'myUA/1.0'); // using custom UA string.
print(client.userAgent); // Will print myUA/1.0.
```

## Performance Comparison

Results may get affected by: <https://github.com/google/cronet.dart/issues/11>.

Here we present the result from a general purpose machine (Ryzen 5 2500U, 8GB RAM) with a `1.7MBPS` network connection running Ubuntu 20.04 against example.com.

### Latency (Sequential Requests)

| Mode          | package:cronet     | dart:io        |
| :-----------: |:-------------:     | :------------: |
| JIT           | **296.429 ms**     | 402.200 ms     |
| AOT           | **262.625 ms**     | 432.200 ms     |

### Throughput (Parallel Requests)

Throughput Test Results (Duration: 1s).
Considering the best appearing value only
| Mode | package:cronet               | dart:io                   |
| :--: |:-------------------------:   | :----------------------:  |
| JIT  | 225 (Parallel Requests: 128) | 5 (Parallel Requests: 32) |
| AOT  | 227 (Parallel Requests:  128)| 2 (Parallel Requests: 4)  |

## Size comparison

We can notice a size increment of `2MB` (on avg.) in Flutter (Android) apps if we use `package:cronet` instead of `dart:io`. We're working on reducing it. The progress can be tracked at <https://github.com/google/cronet.dart/issues/30>.
