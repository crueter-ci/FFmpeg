# FFmpeg CI

Template for scripts and CI for CMake-compatible FFmpeg on Windows (amd64, arm64), UNIX (amd64, Linux) and Android (aarch64). Note that this is purpose-built for Eden, containing only h264, VP8, and VP9 decoders.

[**Releases**](https://github.com/crueter-ci/FFmpeg/releases)

Change any necessary links, names, and variables here:

## Usage

CMake is recommended. You can include it through `FetchContent`:

```cmake
if (ANDROID)
    FetchContent_Declare(
      FFmpeg
      DOWNLOAD_EXTRACT_TIMESTAMP true
      URL https://github.com/crueter-ci/FFmpeg/releases/download/v8.0/ffmpeg-android-8.0.tar.zst
    )
    FetchContent_MakeAvailable(FFmpeg)
    include(${FFmpeg_SOURCE_DIR}/ffmpeg.cmake)
endif()
```

...or [`CPM`](https://github.com/cpm-cmake/CPM.cmake):

```cmake
if (MSVC)
  CPMAddPackage(
    NAME FFmpeg
    URL https://github.com/crueter-ci/FFmpeg/releases/download/v8.0/ffmpeg-windows-8.0.tar.zst
  )
  include(${FFmpeg_SOURCE_DIR}/ffmpeg.cmake)
endif()
```

You may additionally specify a `URL_HASH` with sha1, sha256, or sha512. Downloads containing the file's sums are included in each release and can be fetched programmatically.

To link your project to FFmpeg, simply link to the `FFmpeg::FFmpeg` INTERFACE target.

## Building

### Common

Build scripts are located at `build.sh` in their relevant directory, e.g. `android` and `windows`. All scripts are POSIX-compliant and have the following options as environment variables:

- `VERSION` (default `8.0`): FFmpeg version to build
- `BUILD_DIR` (default `<PWD>/build`): The build directory to use
- `OUT_DIR` (default `<PWD>/out`): The directory to output the include directory and built libraries
- `ARCH` (default: amd64 on Windows/UNIX, arm64 on Android): The architecture to build for

All builds make both shared and static libraries by default. You can control this with the `BUILD_SHARED_LIBS` CMake variable.

### Android

Android building is only tested on Linux and macOS. Windows is untested. Note that while other targets can be built, only arm64 is "officially" supported or distributed.

Environment variables:

- `ANDROID_NDK_ROOT` (required): The root of your NDK, e.g. `/home/crueter/Android/Sdk/ndk/25...`
  * NB: This must be version 25 or earlier
- `ANDROID_SDK_ROOT` (required): The root of your SDK, e.g. `/home/crueter/Android/Sdk`

### Windows

Windows building is only available via cross-compilation with MinGW on Linux. See `unix/linux-deps.sh` to see necessary tools and instructions for Ubuntu/Debian. Other distros have similar steps, but may have e.g. the `nvidia-cuda-toolkit` available in their repositories. Ensure to modify `windows/build.sh` to match your paths for Vulkan, AMF, CUDA, etc.

### Unix

Unix builds are tested on Linux, and should "just work" out of the box. To change your platform (only affects the artifact name), set the `PLATFORM` environment variable.
