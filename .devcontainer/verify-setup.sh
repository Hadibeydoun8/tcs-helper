#!/bin/bash
# Quick verification script for devcontainer setup
# Run this inside the devcontainer to verify everything is working

set -e

echo "==================================="
echo "Devcontainer Verification Script"
echo "==================================="
echo ""

echo "✓ Checking workspace mount..."
if [ -f "/workspace/main.cpp" ] && [ -d "/workspace/lib" ]; then
    echo "  ✅ Workspace files found: main.cpp, lib/"
else
    echo "  ❌ ERROR: Workspace files not found!"
    exit 1
fi

echo ""
echo "✓ Checking osxcross SDK..."
if [ -d "/opt/osxcross/target/SDK" ]; then
    echo "  ✅ SDK directory exists"
    ls -la /opt/osxcross/target/SDK/ | head -5
else
    echo "  ❌ ERROR: SDK not found!"
    exit 1
fi

echo ""
echo "✓ Checking ARM64 compilers..."
FOUND_COMPILER=0
for compiler in "arm64-apple-darwin23-clang" "aarch64-apple-darwin23-clang" "oa64-clang" "o64-clang"; do
    if [ -f "/opt/osxcross/target/bin/$compiler" ]; then
        echo "  ✅ Found: $compiler"
        FOUND_COMPILER=1
        break
    fi
done

if [ $FOUND_COMPILER -eq 0 ]; then
    echo "  ❌ ERROR: No ARM64 compiler found!"
    echo "  Available compilers:"
    ls -la /opt/osxcross/target/bin/ || echo "  No compilers in target/bin"
    exit 1
fi

echo ""
echo "✓ Checking CMake..."
if command -v cmake &> /dev/null; then
    CMAKE_VERSION=$(cmake --version | head -1)
    echo "  ✅ $CMAKE_VERSION"
else
    echo "  ❌ ERROR: CMake not found!"
    exit 1
fi

echo ""
echo "✓ Checking Ninja..."
if command -v ninja &> /dev/null; then
    NINJA_VERSION=$(ninja --version)
    echo "  ✅ Ninja $NINJA_VERSION"
else
    echo "  ❌ ERROR: Ninja not found!"
    exit 1
fi

echo ""
echo "==================================="
echo "All checks passed! ✅"
echo "==================================="
echo ""
echo "Ready to build. Run these commands:"
echo ""
echo "  cd /workspace"
echo "  mkdir -p build && cd build"
echo "  cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE=/workspace/.devcontainer/docker/macos_toolchain.cmake"
echo "  cmake --build ."
echo ""

