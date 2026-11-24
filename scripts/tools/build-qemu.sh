#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../paths.sh"
mkdir -p "$BUILD_DIR/tools/qemu"
cd "$BUILD_DIR/tools/qemu"

"$BUILD_DIR/sources/qemu/configure" --target-list=mmix-softmmu \
    --prefix="$BUILD_DIR/install/qemu" --disable-download -Dfdt=internal

ninja -j "${JOBS:-4}"
ninja install
