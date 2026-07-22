#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.image-rpmlist"

redo-ifchange ci-dnf-stack.HEAD

pushd "$ROOT_DIR/ci-dnf-stack" > /dev/null
    rm -rf rpms/* || true
    while IFS= read -r dep_rpm; do
        cp "$BUILD_DIR/$dep_rpm" rpms/
    done < "$BUILD_DIR/$name.image-rpmlist"

    sudo ./container-test --container="$CI_CONTAINER_TAG" build "${CI_BASE_IMAGE:+--base=$CI_BASE_IMAGE}" ${CI_CONTAINER_TYPE:+--type="$CI_CONTAINER_TYPE"} > /dev/stderr
popd > /dev/null

sudo podman image save "$CI_CONTAINER_TAG" > "$3"
redo-stamp < "$3"
