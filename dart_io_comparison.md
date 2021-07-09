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

### Latency (Sequential Requests)

Server: HTTP/1.1 Local Flask Server
Payload: Lorem Ipsum Text

| Mode          | package:cronet | dart:io          |
| :-----------: |:-------------: | :--------------: |
| JIT           | 1807.8428 μs   | **1801.6621 μs** |
| AOT           | 1441.2866 μs   | **1049.1442 μs** |

Server: HTTP/2 Google Server
Payload: Google Chrome Debian Package

| Mode          | package:cronet | dart:io        |
| :-----------: |:-------------: |:--------------:|
| JIT           | 51.5 sec       | **47.02 sec**  |
| AOT           | **47.003 sec** | 47.75 sec      |

### Throughput (Parallel Requests)

_Contents written as, x concurrent requests succesfully completed out of y requests spawned within 1 second._

Server: HTTP/2 Local Caddy Server
Payload: example.org 's index.html page

| Mode          | package:cronet     | dart:io         |
| :-----------: |:------------------:| :--------------:|
| JIT           |**2982 out of 4096**| 512 out of 512  |
| AOT           |**2883 out of 4096**| 512 out of 512  |

*`dart:io`'s successful requests went down to 1 when more than 512 requests are spawned.*

Server: HTTP/2 example.com Server
Payload: example.com index.html page

| Mode          | package:cronet     | dart:io        |
| :-----------: |:------------------:| :-------------:|
| JIT           |**178 out of 512**  | 39 out of 128  |
| AOT           |**214 out of 512**  | 49 out of 128  |

*These are the best results. `dart:io`'s successful requests went down to rapidly to 0 as we reach 512 requests mark.*
