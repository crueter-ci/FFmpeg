# FFmpeg CI

Scripts and CI for debloated FFmpeg, containing only h264, vp8, vp9, and hwaccel support

- [**Releases**](https://github.com/crueter-ci/FFmpeg/releases)
- Shared libraries (`BUILD_SHARED_LIBS=ON`) are not supported.
- macOS is currently arm64-only.
- CMake target: `FFmpeg::FFmpeg`

## Building and Usage

See the [spec](https://github.com/crueter-ci/spec).

## Dependencies

All: GNU make, pkg-config, curl, zstd, unzip, bash, working compiler

- `amd64` only: nasm
- Linux, MinGW: amf-headers
- Linux, FreeBSD, MinGW: ffnvcodec-headers, vulkan-headers
- OpenBSD: vulkan-headers
- *Dependencies are handled automatically on MSVC*
