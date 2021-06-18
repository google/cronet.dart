# Build Guide

Want to build your own?

For building cronet: <https://www.chromium.org/developers/how-tos/get-the-code> & <https://chromium.googlesource.com/chromium/src/+/master/components/cronet/build_instructions.md>

## For building wrapper

*Paths mentioned are relative to the repository root.*

### For Linux

```bash
cd src
./build.sh . '"86.0.4240.198"' # Replace version string with own
```

Copy the `wrapper` binary to your project's `root` folder.
Copy the cronet's binary to the `cronet_binaries/<platform><arch>` folder from project's `root` folder. (Except on Windows. There, everything will be on root dir only.)

*If you are in 64bit linux system, `cronet_binaries/<platform><arch>` will be `cronet_binaries/linux64`.*

### For Windows

Required: Visual Studio 2019 with C++ Desktop Development tools.

1. Make sure that you have `cmake` for Visual Studio 2019 is available in your command line. If not, you should open something like `x64 Native Tools Command Prompt for VS 2019` from your start menu which will open a command prompt with required path set.

2. In the command prompt do -

   ```dosbatch
   cd <path_to_repo>\src
   cmake CMakeLists.txt -B out
   cmake --build out
   ```

3. From there, go to `out\Debug` folder to get `wrapper.dll`.
