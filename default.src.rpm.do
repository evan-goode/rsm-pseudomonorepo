#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

srpm_tmp_path="$(cd "$ROOT_DIR/$name" && tito build --test --srpm --output "$BUILD_DIR" | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //')"
mv "$srpm_tmp_path" "$3"
 
redo-ifchange "$BUILD_DIR/$name.HEAD"
redo-stamp < "$3"
