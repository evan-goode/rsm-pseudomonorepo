#!/usr/bin/env bash

# Packages listed under BUILD_FROM_SOURCE will be built from the git repository
# at ./$PACKAGE_NAME. For example, BUILD_FROM_SOURCE="dnf5" will build dnf5
# from ./dnf5, which could be a symbolic link to a repository stored elsewhere.
# BUILD_FROM_SOURCE="dnf libdnf librepo"

# Packages listed under SOURCE_FROM_CENTPKG will be built from the dist-git
# repository at ./centpkg/$PACKAGE_NAME.
# SOURCE_FROM_CENTPKG="libdnf"

# Packages listed under SOURCE_FROM_FEDPKG will be built from the dist-git
# repository at ./fedpkg/$PACKAGE_NAME.
# SOURCE_FROM_FEDPKG="libsolv"

# All packages will be built with Mock. Refer to `mock --list-chroots`.
MOCK_CHROOT=fedora-rawhide-x86_64

# The CI base image should match the Mock chroot.
# CI_BASE_IMAGE=fedora:rawhide
# CI_BASE_IMAGE=quay.io/centos/centos:stream10

# "nightly" or "distro"
CI_CONTAINER_TYPE=distro

# BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream9
BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream10

################################################################################

# podman container tags. Currently, root's container storage is used.

CI_CONTAINER_TAG=localhost/dnf-bot/dnf-testing
BOOTC_CONTAINER_TAG=localhost/dnf-bot/bootc

################################################################################

ROOT_DIR="$(realpath "$(dirname "$0")")"
BUILD_DIR="$ROOT_DIR/build"
mkdir -p "$BUILD_DIR"
BUILD_FROM_SOURCE="$(tr ' ' '\n' <<< "$BUILD_FROM_SOURCE" | sort | uniq | sed '/^$/d')"
BUILD_FROM_FEDPKG="$(tr ' ' '\n' <<< "$BUILD_FROM_FEDPKG" | sort | uniq | sed '/^$/d')"
BUILD_FROM_CENTPKG="$(tr ' ' '\n' <<< "$BUILD_FROM_CENTPKG" | sort | uniq | sed '/^$/d')"
BUILD_LOCALLY="$((echo "$BUILD_FROM_SOURCE"; echo "$BUILD_FROM_FEDPKG"; echo "$BUILD_FROM_CENTPKG") | sort | uniq | sed '/^$/d')"
