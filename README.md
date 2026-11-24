# MMIX Linux From Scratch

This project builds an MMIX Linux system from source using the LFS 13.1-systemd package baseline, Clang, LLVM libc and the MMIX Linux kernel. The build targets the MMIX virtual machine in QEMU.

## Getting started

Run `make help` at the project root to list the available commands. Use a Linux host with Bash, GNU Make, flock (util-linux), a native C/C++ toolchain, Git, curl, CMake, Ninja, Meson, Python 3, GNU cpio and gzip. The kernel and QEMU also require their host build dependencies. For the offline QEMU build, provide setuptools >= 63.1 and wheel >= 0.41.2 for the host Python interpreter. A clean-host build has yet to be validated.

## Directory configuration

| Make variable | Default | Contents |
| --- | --- | --- |
| `BUILD_DIR` | `build/` | Private source checkouts under `sources/`, compiler outputs, installed tools and the production rootfs tree |
| `OUT_DIR` | `out/` | Kernel and rootfs images used by the launch command |
| `TMP_DIR` | `tmp/` | Temporary workspace, also exported to subprocesses as `TMPDIR` |
| `DOWNLOADS_DIR` | `downloads/` | Shared bare Git repositories keyed by source URL and verified archives grouped by checksum |

Set these variables on the Make command line or in `config/local.mk`. Relative directories resolve against the project root. To use a read-only checkout, store a copy of [the configuration example](config/local.mk.example) outside it, set all four directories to writable locations, and select it with `LOCAL_CONFIG`. Command-line assignments override values in the file.

```sh
make LOCAL_CONFIG=/work/mmix/build.mk fetch
make LOCAL_CONFIG=/work/mmix/build.mk tools
make LOCAL_CONFIG=/work/mmix/build.mk OUT_DIR=/work/images kernel
```

Give each build its own build, output and temporary directories. Projects can point to one download cache on a filesystem supporting advisory file locks and atomic renames. Fetching serializes each cache entry and checks out the manifest commit in the project's build directory. Older non-bare checkouts and flat archive caches are left in place. The first fetch using the new layout populates the keyed entries.

By default, the kernel, UAPI headers and LLVM SDK builds use the pinned Linux checkout at `$(BUILD_DIR)/sources/linux`. Use `LLVM_PREFIX`, `QEMU_PREFIX` and `LINUX_SOURCE` to consume existing read-only inputs. With an installed MMIX Linux SDK, set `LLVM_PREFIX` to its current location. Leave the variable at its default for a source build. `make llvm` invokes the pinned LLVM repository’s `llvm/utils/mmix/build-linux-toolchain.py` with `LINUX_SOURCE` and installs the relocatable SDK under `BUILD_DIR/install/llvm`. Subsequent runs reuse that installation. Use a fresh build directory when changing source revisions.

## Build commands

| Command | Purpose |
| --- | --- |
| `make fetch` | Download the pinned repositories, archives and QEMU Meson subprojects. Requires network access. |
| `make tools` | Prepare the LLVM SDK (including target libc) and build QEMU from cached sources. |
| `make qemu` | Build the MMIX system emulator and install it under `$(BUILD_DIR)/install/qemu`, the default prefix used by `make run`. |
| `make kernel` | Use the configured LLVM prefix and kernel checkout to create `$(OUT_DIR)/vmlinux`. |
| `make image` | Package a populated production tree at `$(BUILD_DIR)/rootfs/` as `$(OUT_DIR)/rootfs.cpio.gz`. |
| `make run` | Boot the two exported artifacts with the configured QEMU. |

These are initial build entry points. Package installation into the production tree and a complete root filesystem are still in development. Source revisions, runtime coverage and build status are documented in the [porting notes](docs/porting.md).
