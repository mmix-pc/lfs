#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../paths.sh"
prefix="$BUILD_DIR/install/llvm"

if [[ $LLVM_PREFIX != "$prefix" || -e $prefix ]]; then
    if [[ ! -x $LLVM_PREFIX/bin/clang || ! -x $LLVM_PREFIX/bin/ld.lld ||
          ! -f $LLVM_PREFIX/sysroots/mmix-unknown-linux/usr/lib/libc.a ]]; then
        echo "Incomplete MMIX Linux toolchain at $LLVM_PREFIX" >&2
        exit 1
    fi
    printf 'Using installed MMIX Linux toolchain at %s\n' "$LLVM_PREFIX"
    exit 0
fi

builder="$BUILD_DIR/sources/llvm/llvm/utils/mmix/build-linux-toolchain.py"
mkdir -p "$BUILD_DIR/tools"
# The upstream builder requires an empty work directory for each attempt.
work=$(mktemp -d "$BUILD_DIR/tools/llvm-sdk.XXXXXX")
exec python3 "$builder" --linux-source "$LINUX_SOURCE" --build-dir "$work" \
    --prefix "$prefix" --jobs "${JOBS:-4}"
