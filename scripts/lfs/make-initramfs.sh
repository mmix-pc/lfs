#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../paths.sh"
[[ -x "$BUILD_DIR/rootfs/init" ]] || { echo "Stage the production /init in $BUILD_DIR/rootfs first." >&2; exit 1; }

mkdir -p "$OUT_DIR"
image=$(mktemp "$OUT_DIR/.rootfs.XXXXXX")
trap 'rm -f "$image"' EXIT

(cd "$BUILD_DIR/rootfs" && find . -print0 | LC_ALL=C sort -z | cpio --null -o -H newc --owner=0:0) | gzip -n > "$image"
mv "$image" "$OUT_DIR/rootfs.cpio.gz"
