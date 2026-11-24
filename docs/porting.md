# MMIX porting notes

Use [LFS 13.1-systemd](https://www.linuxfromscratch.org/lfs/view/13.1-systemd/) as the package baseline. Track each package's upstream version, source, local changes and observed build result when adding its recipe. The initial manifest covers Linux and Bash. The complete LFS inventory is pending.

| Component | MMIX selection | Status |
| --- | --- | --- |
| Compiler and libc | MMIX LLVM with Clang, LLD, compiler-rt and LLVM libc | The LLVM fork’s build-linux-toolchain.py packages the relocatable SDK, including libc and its sysroot. An existing SDK can be selected with LLVM_PREFIX. |
| QEMU | MMIX system emulator | Built and installed offline from the pinned commit with the internal libfdt. The installed emulator reported version 11.1.50 and answered a QMP status query on the MMIX virt machine. |
| Linux | MMIX fork supplying both installed UAPI headers and the kernel | The SDK builder exports its own UAPI headers from this same checkout. Kernel recipe selects the fork's userspace defconfig. |
| Bash | GNU Bash 5.3 | Archive recorded. Cross-build recipe and runtime compatibility pending. |

The Git pins in the manifests identify local fork checkout revisions at project creation. Remote availability and correspondence to existing installed binaries have yet to be verified. Archive rows use the upstream LFS MD5 value for download integrity. Patch files maintained here belong under `patches/<package>/`.

Image assembly consumes `$(BUILD_DIR)/rootfs/` only. Package recipes are responsible for populating that tree. Install reviewed static files from `rootfs-overlay/` individually. Use a separate staging tree and image for development fixtures.
