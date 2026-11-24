.DEFAULT_GOAL := help

LOCAL_CONFIG ?= config/local.mk
ifeq ($(LOCAL_CONFIG),config/local.mk)
-include config/local.mk
else
# Escape spaces so include treats LOCAL_CONFIG as a single filename.
empty :=
space := $(empty) $(empty)
include $(subst $(space),\$(space),$(LOCAL_CONFIG))
endif

BUILD_DIR ?= $(CURDIR)/build
OUT_DIR ?= $(CURDIR)/out
TMP_DIR ?= $(CURDIR)/tmp
DOWNLOADS_DIR ?= $(CURDIR)/downloads

LLVM_PREFIX ?= $(BUILD_DIR)/install/llvm
QEMU_PREFIX ?= $(BUILD_DIR)/install/qemu
LINUX_SOURCE ?= $(BUILD_DIR)/sources/linux
JOBS ?= 4

export BUILD_DIR OUT_DIR TMP_DIR DOWNLOADS_DIR
export LLVM_PREFIX QEMU_PREFIX LINUX_SOURCE JOBS

.PHONY: help fetch tools llvm qemu headers kernel image run

help:
	@echo 'Targets: fetch tools llvm qemu headers kernel image run'

fetch:
	bash scripts/fetch.sh

tools: llvm qemu

llvm:
	bash scripts/tools/build-llvm.sh

qemu:
	bash scripts/tools/build-qemu.sh

headers:
	bash recipes/linux.sh headers

kernel:
	bash recipes/linux.sh kernel

image:
	bash scripts/lfs/make-initramfs.sh

run:
	bash scripts/lfs/run-qemu.sh
