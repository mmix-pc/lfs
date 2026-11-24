#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../scripts/paths.sh"
src=$LINUX_SOURCE
prefix=$LLVM_PREFIX

case "${1:-}" in
    headers)
        make -C "$src" ARCH=mmix O="$BUILD_DIR/lfs/linux-headers" \
            INSTALL_HDR_PATH="$BUILD_DIR/lfs/uapi/usr" headers_install
        ;;

    kernel)
        args=(-C "$src" ARCH=mmix O="$BUILD_DIR/lfs/linux" LLVM="$prefix/bin/" HOSTCC=cc HOSTCXX=c++ CROSS_COMPILE=mmix-unknown-linux-)
        make "${args[@]}" mmix_userspace_defconfig
        make "${args[@]}" -j "${JOBS:-4}" vmlinux

        install -D -m 0644 "$BUILD_DIR/lfs/linux/vmlinux" "$OUT_DIR/vmlinux"
        ;;

    *) echo 'Expected headers or kernel' >&2; exit 2 ;;
esac
