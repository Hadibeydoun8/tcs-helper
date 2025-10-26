# Quick Start Guide - ARM64 macOS Cross-Compilation

## What Was Fixed

### 1. **Devcontainer Configuration**
- ✅ Fixed misnamed `.devcontainer.json` → now correctly named `devcontainer.json`
- ✅ Fixed Docker build context to use workspace root (prevents lstat errors)
- ✅ Dockerfile path correctly points to `docker/Dockerfile` (relative to devcontainer.json)
- ✅ Configured automatic download of macOS 14.4 SDK (ARM64-compatible)
- ✅ Set `OSXCROSS_TARGET=darwin23` for Apple Silicon targets

### 2. **Build Scripts**
- ✅ Updated `setup-osxcross.sh` to build ARM64 cross-compilers
- ✅ Added automatic osxcross cloning if not present during image build
- ✅ Added curl retries and SHA256 checksum verification for SDK downloads
- ✅ Added verification of ARM64 compiler after build

### 3. **CMake Toolchain**
- ✅ Updated `macos_toolchain.cmake` to search for ARM64 compilers
- ✅ Looks for: `arm64-apple-darwin23-clang`, `aarch64-apple-darwin23-clang`, `oa64-clang`
- ✅ Sets `CMAKE_SYSTEM_PROCESSOR=aarch64` for ARM64 targets

### 4. **CMakeLists.txt**
- ✅ Made compiler selection conditional (works on both host Mac and in container)
- ✅ Only uses Homebrew LLVM when building on host macOS
- ✅ Respects toolchain file when cross-compiling in container
- ✅ **Fixed C++20 module scanning**: Uses `FILE_SET CXX_MODULES` for native builds, regular source files for cross-compilation
- ✅ Automatically disables module scanning when cross-compiling (CMAKE_CXX_SCAN_FOR_MODULES=OFF)
- ✅ Homebrew-specific include paths only applied on host

### 5. **Dockerfile**
- ✅ Added `ninja-build` for faster builds (required for C++20 module support)
- ✅ Added SSL, XML, and compression libraries needed by osxcross
- ✅ COPY command uses workspace-relative path (`.devcontainer/docker/setup-osxcross.sh`)

### 6. **Repository Structure**
- ✅ Added `.gitignore` to exclude build artifacts and IDE files
- ✅ All paths are portable - no hardcoded absolute paths

## How to Use

### Step 1: Reopen in Container
1. Open this project in VS Code
2. Press `Cmd+Shift+P` → "Dev Containers: Reopen in Container"
3. Wait for container to build and SDK to download (first time takes 5-10 minutes)

### Step 2: Verify Setup
Inside the container terminal:
```bash
# Check workspace files are mounted
ls -la /workspace
# Should see: main.cpp, lib/, CMakeLists.txt, .devcontainer/

# Check ARM64 compilers were built
ls -la /opt/osxcross/target/bin/
# Look for compilers like: arm64-apple-darwin23-clang or oa64-clang

# Check SDK is available
ls -la /opt/osxcross/target/SDK/
```

### Step 3: Build Your Project
```bash
cd /workspace
mkdir -p build && cd build
cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE=/workspace/.devcontainer/docker/macos_toolchain.cmake
cmake --build .
```

### Step 4: Verify ARM64 Binary
```bash
# Check architecture of built binary
file TCS_Helper
# Should show: Mach-O 64-bit arm64 executable

# Copy to host and run on your Mac
cp TCS_Helper /workspace/
# Then on your Mac host:
./TCS_Helper
```

## Your Code Structure
- ✅ `main.cpp` - Simple hello world with loop
- ✅ `lib/dataclasses.ixx` - C++20 module with SwimmingAthlete/SwimmingEvent structs
- ✅ `lib/meet_manager.ixx` - C++20 module importing dataclasses

## Building on Host macOS (Alternative)
If you want to build directly on your Mac without the container:
```bash
# Make sure you have Homebrew LLVM installed
brew install llvm

# Build normally (CMakeLists.txt will use Homebrew LLVM automatically)
mkdir -p build && cd build
cmake .. -G Ninja
cmake --build .
./TCS_Helper
```

## Troubleshooting

### Container won't start or SDK download fails
- Check internet connection
- Verify GitHub isn't blocked: `curl -I https://github.com`
- Check container logs in VS Code terminal

### osxcross build fails
- Ensure you have at least 4GB RAM allocated to Docker
- Check `/opt/osxcross/build.log` inside container for errors

### Compilers not found
```bash
# Inside container, manually verify:
ls -la /opt/osxcross/target/bin/
# If empty, SDK didn't build. Check:
ls -la /opt/osxcross/tarballs/
# Should see MacOSX14.4.sdk.tar.xz
```

### CMake can't find toolchain
Make sure you're passing the full path:
```bash
cmake .. -DCMAKE_TOOLCHAIN_FILE=/workspace/.devcontainer/docker/macos_toolchain.cmake
```

### CMake error about module dependency scanning
If you see an error like:
```
CMake Error: The target named "TCS_Helper" has C++ sources that may use modules,
but the compiler does not provide a way to discover the import graph dependencies.
```

This is now automatically handled! The CMakeLists.txt detects cross-compilation and:
- Disables CMAKE_CXX_SCAN_FOR_MODULES when cross-compiling
- Adds module files as regular sources instead of using FILE_SET CXX_MODULES
- Still uses proper module scanning for native builds

If you still see this error, ensure:
1. You're using Ninja generator: `cmake -G Ninja ...`
2. The toolchain file is properly loaded
3. You don't have a stale CMakeCache.txt (delete it: `rm CMakeCache.txt`)

### Module compilation errors
The container's clang must support C++20 modules. If you see module errors, check:
```bash
clang++ --version  # Should be clang 15+ with module support
```

## What's Cross-Compiled
When building in the container, you're creating **native ARM64 macOS binaries** that will run on Apple Silicon Macs (M1/M2/M3). The binary is built inside a Linux container but targets macOS ARM64.

## Next Steps
- Your code is ready to build!
- The devcontainer will auto-download the SDK
- All your source files (`main.cpp`, `lib/`) are automatically mounted at `/workspace`
- Just reopen in container and run the build commands above

