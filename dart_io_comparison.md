# Comparing APIs with dart:io

## userAgent

### dart:io

    ```dart
    final client = HttpClient();
    client.userAgent = 'myUA/1.0'; // using custom UA string.
    print(client.userAgent); // Will print myUA/1.0.
    ```

### Cronet

    ```dart
    final client = HttpClient(userAgent: 'myUA/1.0'); // using custom UA string.
    print(client.userAgent); // Will print myUA/1.0.
    ```
