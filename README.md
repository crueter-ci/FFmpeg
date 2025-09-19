# CI Template

Template for scripts and CI for CMake-compatible software on Windows (amd64, arm64), UNIX (amd64, Solaris, FreeBSD, Linux) and Android (aarch64).

<!-- [**Releases**](https://github.com/crueter/OpenSSL-CI/releases) -->

Change any necessary links, names, and variables here:

## Usage

CMake is recommended. You can include it through `FetchContent`:

```cmake
if (ANDROID)
    FetchContent_Declare(
      OpenSSL
      DOWNLOAD_EXTRACT_TIMESTAMP true
      URL https://github.com/crueter/OpenSSL-CI/releases/download/v3.5.2/openssl-android-3.5.2.tar.zst
    )
    FetchContent_MakeAvailable(OpenSSL)
    include(${OpenSSL_SOURCE_DIR}/openssl.cmake)
endif()
```

...or [`CPM`](https://github.com/cpm-cmake/CPM.cmake):

```cmake
if (MSVC)
  CPMAddPackage(
    NAME OpenSSL
    URL https://github.com/crueter/OpenSSL-CI/releases/download/v3.5.2/openssl-windows-3.5.2.tar.zst
  )
  include(${OpenSSL_SOURCE_DIR}/openssl.cmake)
endif()
```

You may additionally specify a `URL_HASH` with sha1, sha256, or sha512. Downloads containing the file's sums are included in each release and can be fetched programmatically.

## Building

### Common

Build scripts are located at `build.sh` in their relevant directory, e.g. `android` and `windows`. All scripts are POSIX-compliant and have the following options as environment variables:

- `VERSION` (default `3.5.2`): OpenSSL version to build
- `BUILD_DIR` (default `<PWD>/build`): The build directory to use
- `OUT_DIR` (default `<PWD>/out`): The directory to output the include directory and built libraries
- `ARCH` (default: amd64 on Windows/UNIX, arm64 on Android): The architecture to build for

### Android

Android building is only tested on Linux and macOS. Windows support is not currently planned. Note that while other targets can be built, only arm64 is "officially" supported or distributed.

Environment variables:

- `ANDROID_API` (default `23`): What API to target. Usually you should keep this as-is
- `ANDROID_NDK_ROOT` (required): The root of your NDK, e.g. `/home/crueter/Android/Sdk/ndk/26.11...`

Android builds both shared and static libraries by default. You can control this with the `BUILD_SHARED_LIBS` CMake variable.

### Windows

Windows building is only tested on MSVC and on Windows only. MSYS2 and MinGW support is planned. Only amd64 is officially supported or distributed for the time being.

Windows only builds static libraries, and will always be linked as such.

### Unix

Unix builds are tested on Linux, FreeBSD, and Solaris (gcc64), and should "just work" out of the box. To change your platform (only affects the artifact name), set the `PLATFORM` environment variable.

Unix builds both shared and static libraries by default. You can control this with the `BUILD_SHARED_LIBS` CMake variable.