#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.bootc.image"

sudo bcvk libvirt ssh "$BOOTC_VM_NAME" -- bootc upgrade --apply >/dev/stderr
sudo bcvk libvirt ssh "$BOOTC_VM_NAME" --timeout 600 true > /dev/stderr

redo-always
redo-stamp <<< "1"
