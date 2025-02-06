#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

basename="$(basename "$2")"
name="${basename##*.}"
# This is a hack. We can't use redo "as intended" and simply do `redo-ifchanged
# centpkg/repo.HEAD` since centpkg may be a symlink outside the $ROOT_DIR, so
# traversing up the directory tree to find a default.do will fail.
repo_path="$(sed 's/\./\//g' <<< "$basename")"

if [[ $(git -C "$ROOT_DIR/$repo_path" status -uno --porcelain) ]]; then
    echo "$name working tree is dirty, aborting" > /dev/stderr
    exit 1
fi

redo-always
(cd "$ROOT_DIR/$repo_path" && git rev-parse HEAD) | redo-stamp
