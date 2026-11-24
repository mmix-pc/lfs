# Shared by the executable build scripts. Resolve paths before any tool changes directory.
project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root" || return 1

BUILD_DIR=$(realpath -ms -- "${BUILD_DIR:-build}")
OUT_DIR=$(realpath -ms -- "${OUT_DIR:-out}")
TMP_DIR=$(realpath -ms -- "${TMP_DIR:-tmp}")
DOWNLOADS_DIR=$(realpath -ms -- "${DOWNLOADS_DIR:-downloads}")
LLVM_PREFIX=$(realpath -ms -- "${LLVM_PREFIX:-$BUILD_DIR/install/llvm}")
QEMU_PREFIX=$(realpath -ms -- "${QEMU_PREFIX:-$BUILD_DIR/install/qemu}")
LINUX_SOURCE=$(realpath -ms -- "${LINUX_SOURCE:-$BUILD_DIR/sources/linux}")

mkdir -p "$TMP_DIR"
export TMPDIR="$TMP_DIR"
