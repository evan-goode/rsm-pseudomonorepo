#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.image-rpmlist"

redo-ifchange ci-dnf-stack.HEAD

out="$(realpath $3)"
pushd "$ROOT_DIR/ci-dnf-stack" > /dev/null
    rm -rf rpms/* || true
    while IFS= read -r dep_rpm; do
        cp "$BUILD_DIR/$dep_rpm" rpms/
    done < "$BUILD_DIR/$name.image-rpmlist"

    sudo tmt run | tee "$out" > /dev/stderr
popd > /dev/null
