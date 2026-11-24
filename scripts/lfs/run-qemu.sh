#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../paths.sh"

exec "$QEMU_PREFIX/bin/qemu-system-mmix" \
    -machine virt,elf-startup=platform,graphics=off -bios none -m 256M \
    -display none -serial stdio -monitor none -kernel "$OUT_DIR/vmlinux" \
    -initrd "$OUT_DIR/rootfs.cpio.gz" -append 'console=ttyS0,115200 rdinit=/init'
