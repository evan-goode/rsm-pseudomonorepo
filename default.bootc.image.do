#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.repo.hash"

redo-ifchange ci-dnf-stack.HEAD

containerfile="$(realpath ./bootc.Containerfile)"

redo-ifchange "$containerfile"

pushd "$ROOT_DIR/ci-dnf-stack" > /dev/null
    rm -rf rpms
    cp -rl "$BUILD_DIR/$name.repo" rpms

    sudo ./container-test --container="$BOOTC_CONTAINER_TAG" build --usecache --file "$containerfile" "${BOOTC_BASE_IMAGE:+--base=$BOOTC_BASE_IMAGE}" ${CI_CONTAINER_TYPE:+--type="$CI_CONTAINER_TYPE"} --container-arg=--build-arg --container-arg=CACHEBUST="$(uuidgen)" > /dev/stderr
popd > /dev/null

sudo podman image save "$BOOTC_CONTAINER_TAG" > "$3"
redo-stamp < "$3"
