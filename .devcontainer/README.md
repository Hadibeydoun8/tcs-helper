Devcontainer usage and SDK download (ARM64/Apple Silicon)

This folder contains the devcontainer configuration for cross-compiling to macOS ARM64 (Apple Silicon) using osxcross.

Key files
- `devcontainer.json` - the devcontainer configuration for ARM64 macOS cross-compilation.
- `docker/Dockerfile` - image build that installs dependencies and provides a setup script.
- `docker/setup-osxcross.sh` - entrypoint script that downloads the macOS SDK and builds osxcross with ARM64 support at container start.
- `docker/macos_toolchain.cmake` - CMake toolchain file configured for ARM64 targets.

Configuration
The devcontainer is pre-configured to automatically download macOS SDK 14.4 (ARM64-compatible) at container startup.
No manual SDK setup required - just reopen in container and the SDK will be downloaded and osxcross will be built automatically.

How to make the container download the SDK automatically
1. Edit `.devcontainer/devcontainer.json` and set `containerEnv.OSXCROSS_SDK_URL` to a URL that points to a macOS SDK tarball you are legally allowed to download.
   - Optionally also set `containerEnv.OSXCROSS_SDK_SHA256` to the expected sha256sum to verify integrity.
   - Example (replace with a legal URL you own):
     {
       "containerEnv": {
         "OSXCROSS_SDK_URL": "https://example.com/MacOSX10.14.sdk.tar.xz",
         "OSXCROSS_SDK_SHA256": "<sha256sum>"
       }
     }

2. Reopen the folder in the devcontainer (VS Code: Command Palette → Remote-Containers: Reopen in Container).
   - The container's entrypoint script will run at start, download the SDK (if no local tarballs are present), copy it into `/opt/osxcross/tarballs`, and attempt to build osxcross.

Quick verification inside the running container
- Check the workspace and files are mounted:
  ls -la /workspace
- Check osxcross ARM64 tools (after setup finishes):
  ls -la /opt/osxcross/target/bin/
  # Look for compilers like: arm64-apple-darwin23-clang, aarch64-apple-darwin23-clang, or oa64-clang
- Build the project:
  mkdir -p build && cd build
  cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE=/workspace/.devcontainer/docker/macos_toolchain.cmake
  cmake --build .
- The resulting binary will be ARM64 macOS executable that runs on Apple Silicon Macs.

Notes & Legal
- You must have the legal right to download and use the macOS SDK you provide. This script does not include or distribute Apple SDKs.
- If you prefer not to download at runtime, you can place SDK tarballs under `.devcontainer/SDK/` in the repo and they'll be copied into the container at start.

If builds still fail, copy/paste the container-side build output here and I'll diagnose further.
