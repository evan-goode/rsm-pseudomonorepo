#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"
image=

case "$name" in
    "dnf4")
        image="$BUILD_DIR/dnf4.image"
        args="run"
        ;;
    "dnf5")
        image="$BUILD_DIR/dnf5.image"
        args="run --tags dnf5 --command dnf5"
        ;;
    "dnf5daemon.dnf5")
        image="$BUILD_DIR/dnf5.image"
        args="run --tags dnf5daemon --command dnf5daemon-client"
        ;;
    "createrepo_c.dnf5")
        image="$BUILD_DIR/dnf5.image"
        args="--suite createrepo_c run"
        ;;
    *)
        echo Unexpected name: "$name" > /dev/stderr
        exit 1
        ;;
esac
redo-ifchange ci-dnf-stack.HEAD "$image"

sudo podman load < "$image" > /dev/stderr

(cd "$ROOT_DIR/ci-dnf-stack" && sudo ./container-test ${CI_CONTAINER_TAG:+--container="$CI_CONTAINER_TAG"} -d $args) | tee "$3" > /dev/stderr
redo-stamp < "$3"
