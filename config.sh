#!/usr/bin/env bash

# Packages listed under BUILD_FROM_SOURCE will be built from the git repository
# at ./$PACKAGE_NAME. For example, BUILD_FROM_SOURCE="dnf5" will build dnf5
# from ./dnf5, which could be a symbolic link to a repository stored elsewhere.
# BUILD_FROM_SOURCE="dnf5 podman"
BUILD_FROM_SOURCE="rpm librepo"

# Mock --with/--without options per package. Keys are package names, values are
# space-separated lists of --with=X and/or --without=X flags passed to mock.
# Example:
#   MOCK_WITH_OPTIONS[dnf5]="--with=man --without=tests"
declare -A MOCK_WITH_OPTIONS
# MOCK_WITH_OPTIONS[dnf5]="--without=modulemd"

# Packages listed under BUILD_FROM_CENTPKG will be built from the dist-git
# repository at ./centpkg/$PACKAGE_NAME.
# BUILD_FROM_CENTPKG="libsolv"

# Packages listed under BUILD_FROM_FEDPKG will be built from the dist-git
# repository at ./fedpkg/$PACKAGE_NAME.
BUILD_FROM_FEDPKG=""

# "nightly" or "distro"
# CI_CONTAINER_TYPE=nightly
CI_CONTAINER_TYPE=nightly

# All packages will be built with Mock. Refer to `mock --list-chroots`.
# MOCK_CHROOT=fedora-42-x86_64
# MOCK_CHROOT=fedora-43-x86_64
MOCK_CHROOT=fedora-44-x86_64
# MOCK_CHROOT=fedora-rawhide-x86_64
# MOCK_CHROOT=fedora-eln-x86_64
# MOCK_CHROOT=centos-stream-9-x86_64
# MOCK_CHROOT=centos-stream-10-x86_64

# The CI base image should match the Mock chroot.
# CI_BASE_IMAGE=fedora:42
# CI_BASE_IMAGE=fedora:43
# CI_BASE_IMAGE=fedora:44
# CI_BASE_IMAGE=fedora:rawhide
# CI_BASE_IMAGE=quay.io/centos/centos:stream9
CI_BASE_IMAGE=quay.io/centos/centos:stream10

# BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream9
# BOOTC_BASE_IMAGE=quay.io/centos-bootc/centos-bootc:stream10
BOOTC_BASE_IMAGE=quay.io/fedora/fedora-bootc:44
# BOOTC_BASE_IMAGE=quay.io/fedora/fedora-bootc:rawhide

TMT_DISTRO=fedora-rawhide
TMT_PROVISION_IMAGE=https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-Rawhide-20260701.n.0.x86_64.qcow2

BOOTC_VM_NAME=bootc

# TMT_DISTRO=centos-stream-9
# TMT_PROVISION_IMAGE=https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2

# TMT_DISTRO=centos-stream-10
# TMT_PROVISION_IMAGE=https://cloud.centos.org/centos/10-stream/x86_64/images/CentOS-Stream-GenericCloud-10-latest.x86_64.qcow2

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
