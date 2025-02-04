#!/usr/bin/env bash

ROOT_DIR="$(realpath "$(dirname "$0")")"
BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

# BOOTC_BASE_IMAGE=quay.io/fedora/fedora-bootc:40
BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream9
BOOTC_CONTAINER_TAG=localhost/dnf-bot/bootc

# MOCK_CHROOT=fedora-40-x86_64
MOCK_CHROOT=centos-stream-9-x86_64

CI_BASE_IMAGE=fedora:40
CI_CONTAINER_TAG=localhost/dnf-bot/dnf-testing

BUILD_FROM_SOURCE="libdnf librepo dnf dnf5"
