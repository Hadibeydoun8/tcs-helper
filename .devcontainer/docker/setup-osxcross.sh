#!/usr/bin/env bash
set -euo pipefail

# This script runs inside the devcontainer at container start.
# It copies any SDK tarballs from the mounted workspace to /opt/osxcross/tarballs
# and runs osxcross's build.sh if any tarballs are present. If no local
# tarballs exist but the environment variable OSXCROSS_SDK_URL is set, it will
# attempt to download the SDK from that URL. You must have legal rights to
# download/use the SDK you provide.

SDK_SRC_DIR="/workspace/.devcontainer/SDK"
OSXCROSS_TARBALLS_DIR="/opt/osxcross/tarballs"
OSXCROSS_DIR="/opt/osxcross"

# Helper: ensure tarballs dir exists
mkdir -p "$OSXCROSS_TARBALLS_DIR"

# 1) Copy SDK tarballs from the workspace SDK dir if it exists
if [ -d "$SDK_SRC_DIR" ]; then
  echo "Found SDK source dir: $SDK_SRC_DIR. Copying tarballs to $OSXCROSS_TARBALLS_DIR"
  shopt -s nullglob || true
  for f in "$SDK_SRC_DIR"/*; do
    echo "Copying $f -> $OSXCROSS_TARBALLS_DIR"
    cp -a "$f" "$OSXCROSS_TARBALLS_DIR/"
  done
  shopt -u nullglob || true
else
  echo "No SDK source dir found at $SDK_SRC_DIR"
fi

# 2) If no tarballs were copied and an SDK URL is provided, download it
if [ -z "$(ls -A "$OSXCROSS_TARBALLS_DIR" 2>/dev/null || true)" ]; then
  if [ -n "${OSXCROSS_SDK_URL:-}" ]; then
    echo "No local SDK tarballs found and OSXCROSS_SDK_URL is set. Downloading SDK from: $OSXCROSS_SDK_URL"
    filename="$(basename "$OSXCROSS_SDK_URL")"
    dest="$OSXCROSS_TARBALLS_DIR/$filename"
    echo "Downloading to $dest"
    # Use curl with fail + location and some retries
    curl -fSL --retry 3 --retry-delay 2 "$OSXCROSS_SDK_URL" -o "$dest"

    # Optional integrity check
    if [ -n "${OSXCROSS_SDK_SHA256:-}" ]; then
      echo "Verifying SHA256 checksum..."
      if command -v sha256sum >/dev/null 2>&1; then
        echo "$OSXCROSS_SDK_SHA256  $dest" | sha256sum -c -
      elif command -v shasum >/dev/null 2>&1; then
        echo "$OSXCROSS_SDK_SHA256  $dest" | shasum -a 256 -c -
      else
        echo "Warning: no sha256sum or shasum available to verify checksum. Skipping verification."
      fi
      echo "Checksum OK"
    fi
  else
    echo "No OSXCROSS_SDK_URL provided; skipping download"
  fi
else
  echo "SDK tarballs already present in $OSXCROSS_TARBALLS_DIR"
fi

# 3) Build osxcross if tarballs are present
if [ "$(ls -A "$OSXCROSS_TARBALLS_DIR" || true)" ]; then
  echo "SDK tarballs present in $OSXCROSS_TARBALLS_DIR. Building osxcross..."
  cd "$OSXCROSS_DIR"

  # Clone osxcross if it wasn't already done during image build
  if [ ! -f "./build.sh" ]; then
    echo "osxcross not found, cloning..."
    git clone https://github.com/tpoechtrager/osxcross.git .
  fi

  # Build for ARM64 targets (Apple Silicon)
  # Set TARGET_DIR and enable ARM64 support
  export ENABLE_ARM64=1

  # run build.sh unattended; build.sh will fail if prerequisites missing
  UNATTENDED=1 ./build.sh
  echo "osxcross build complete"

  # Verify ARM64 compiler was built
  if [ -f "./target/bin/arm64-apple-darwin23-clang" ] || [ -f "./target/bin/aarch64-apple-darwin23-clang" ]; then
    echo "ARM64 cross-compiler successfully built"
  else
    echo "Warning: ARM64 compiler not found, listing available compilers:"
    ls -la ./target/bin/ || true
  fi
else
  echo "No SDK tarballs in $OSXCROSS_TARBALLS_DIR — skipping osxcross build"
fi

# Drop to the requested command (so container behaves like normal shell)
exec "$@"
