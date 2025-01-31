#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

mock -r "$MOCK_CHROOT" --clean > /dev/stderr
redo-always
