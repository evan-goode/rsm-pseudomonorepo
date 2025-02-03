#!/usr/bin/env bash

ROOT_DIR="$(realpath "$(dirname "$0")")"
BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"

MOCK_CHROOT=fedora-40-x86_64
BASE_IMAGE=fedora:40
CONTAINER_TAG=localhost/dnf-bot/dnf-testing

BUILD_FROM_SOURCE="libdnf dnf dnf5"
