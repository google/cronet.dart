# Build Cronet Sample

Source: [Chromium Cronet Sample](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/components/cronet/native/sample).

**Note:** Code here aren't used by the Dart code by any means. It is only to test if the downloaded/built cronet library is working and major apis are compatible with this package.

## Compilation Instruction

```bash
g++ -std=c++11 main.cc sample_executor.cc sample_url_request_callback.cc -o sample.out -ldl -lpthread -L. -l:libcronet.86.0.4240.198.so -Wl,-z,origin -Wl,-rpath,'$ORIGIN'
```

Put the compiled `sample.out` and `libcronet.86.0.4240.198.so` in the same folder and execute `./sample.out`.

Replace `libcronet.86.0.4240.198.so` with your cronet dylib's name.
