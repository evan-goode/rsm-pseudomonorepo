#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

if [[ $(git -C "$ROOT_DIR/$name" status -uno --porcelain) ]]; then
    echo "$name working tree is dirty, aborting" > /dev/stderr
    exit 1
fi

redo-always
(cd "$ROOT_DIR/$name" && git rev-parse HEAD) | redo-stamp
