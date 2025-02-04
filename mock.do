#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

mock -r "$MOCK_CHROOT" --clean > /dev/stderr
redo-always

# Stamp a constant, dependents should never be rebuilt just because mock chroot
# was cleaned
redo-stamp <<< "1"
