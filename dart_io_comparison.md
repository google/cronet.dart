# Comparing with dart:io

## API Comparison

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

### Latency (Sequential Requests)

Server: HTTP/1.1 Local Flask Server
Payload: Lorem Ipsum Text

| Mode          | package:cronet | dart:io        |
| :-----------: |:-------------: | :-------------:|
| JIT           | 1.807 ms       | **1.801 ms**   |
| AOT           | 1.441 ms       | **1.049 ms**   |

Server: HTTP/2 example.com Server
Payload: example.com index.html page

| Mode          | package:cronet | dart:io        |
| :-----------: |:-------------: | :------------: |
| JIT           | **90.696 ms**  | 104.150 ms     |
| AOT           | **89.348 ms**  | 104.050 ms     |

Server: HTTP/2 Google Server
Payload: Google Chrome Debian Package

| Mode          | package:cronet | dart:io        |
| :-----------: |:-------------: |:--------------:|
| JIT           | 51.5 sec       | **47.02 sec**  |
| AOT           | **47.003 sec** | 47.75 sec      |

### Throughput (Parallel Requests)

Server: HTTP/2 example.com Server
Payload: example.com index.html page

Considering the best appearing value only
| Mode | package:cronet               | dart:io                      |
| :--: |:-------------------------:   | :----------------------:     |
| JIT  | 855 (Parallel Requests: 256) | 1078 (Parallel Requests: 256)|
| AOT  | 789 (Parallel Requests: 128) | 1306 (Parallel Requests: 512)|
