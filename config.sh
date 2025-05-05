#!/usr/bin/env bash

# BUILD_FROM_SOURCE="dnf5"
BUILD_FROM_SOURCE="libsolv libdnf"
SOURCE_FROM_CENTPKG="libdnf"
SOURCE_FROM_FEDPKG="libsolv"

# MOCK_CHROOT=fedora-40-x86_64
# MOCK_CHROOT=fedora-41-x86_64
# MOCK_CHROOT=fedora-rawhide-x86_64
MOCK_CHROOT=centos-stream-10-x86_64
# MOCK_CHROOT=centos-stream-9-x86_64

# "nightly" or "distro"
CI_CONTAINER_TYPE=distro

CI_BASE_IMAGE=quay.io/centos/centos:stream10
# CI_BASE_IMAGE=quay.io/centos/centos:stream9
# CI_BASE_IMAGE=fedora:41
# CI_BASE_IMAGE=fedora:rawhide

# BOOTC_BASE_IMAGE=quay.io/fedora/fedora-bootc:41
BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream9
# BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream10

################################################################################

CI_CONTAINER_TAG=localhost/dnf-bot/dnf-testing
BOOTC_CONTAINER_TAG=localhost/dnf-bot/bootc

################################################################################

ROOT_DIR="$(realpath "$(dirname "$0")")"
BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"
