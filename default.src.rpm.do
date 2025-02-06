#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

if grep -wq <<< "$SOURCE_FROM_CENTPKG" "$name"; then
    # Source from centpkg
    echo "Using $name from ./centpkg/$name/" > /dev/stderr
    redo-ifchange "centpkg.$name.HEAD"
    srpm_tmp_path="$(
        set -euo pipefail
        cd "$ROOT_DIR/centpkg/$name"
        centpkg srpm | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
    )"
elif grep -wq <<< "$SOURCE_FROM_FEDPKG" "$name"; then
    # Source from fedpkg
    echo "Using $name from ./fedpkg/$name/" > /dev/stderr
    redo-ifchange "fedpkg.$name.HEAD"
    srpm_tmp_path="$(
        set -euo pipefail
        cd "$ROOT_DIR/fedpkg/$name"
        fedpkg srpm | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
    )"
else
    # Source from upstream repository, use tito
    echo "Using $name from ./$name/" > /dev/stderr
    redo-ifchange "$name.HEAD"
    srpm_tmp_path="$(
        set -euo pipefail
        cd "$ROOT_DIR/$name"
        tito build --test --srpm --output "$BUILD_DIR" | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
    )"
fi

mv "$srpm_tmp_path" "$3"
 
redo-stamp < "$3"
