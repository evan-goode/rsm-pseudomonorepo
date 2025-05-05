#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

case "$name" in
    "dnf-plugins-core")
        deps="librepo libdnf dnf"
        ;;
    "dnf")
        deps="librepo libdnf"
        ;;
    "libdnf")
        deps="librepo libsolv"
        ;;
    "dnf5")
        deps="librepo libsolv"
        ;;
    *)
        deps=
        ;;
esac

deps="$(comm -12 <(tr ' ' '\n' <<< "$deps" | sort) <(tr ' ' '\n' <<< "$BUILD_FROM_SOURCE" | sort))"

redo-ifchange mock "$BUILD_DIR/$name.src.rpm"
for dep in $deps; do
    redo-ifchange "$BUILD_DIR/$dep.rpmlist"
done

dep_rpms=""
for dep in $deps; do
    while IFS= read -r dep_rpm; do
        dep_rpms="$dep_rpms $BUILD_DIR/$dep.rpms/$dep_rpm"
    done < "$BUILD_DIR/$dep.rpmlist"
done

if [ -n "$dep_rpms" ]; then
    mock --root "$MOCK_CHROOT" --install $dep_rpms > /dev/stderr
fi

rpm_dir="$BUILD_DIR/$name.rpms"
rm -rf "$rpm_dir"
mkdir -p "$rpm_dir"

mock --root "$MOCK_CHROOT" \
    --no-clean --no-cleanup-after \
    --config-opts=dnf5_common_opts=--setopt=best=False \
    --config-opts=dnf5_common_opts= \
    --config-opts=dnf_common_opts=--setopt=best=False \
    --config-opts=dnf_common_opts= \
    --resultdir "$BUILD_DIR/$name.rpms" \
    "$BUILD_DIR/$name.src.rpm" > /dev/stderr

find "$rpm_dir" -maxdepth 1 -regex '.*\.\(noarch\|x86_64\)\.rpm' -exec realpath --relative-to "$rpm_dir" {} \; > "$3"
redo-stamp < "$3"
