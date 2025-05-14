#!/usr/bin/env bash
set -e

redo-ifchange dependencies.sh
. ./dependencies.sh

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

deps="$(shallow_dependencies "$name")"
deps="$(intersection <(echo -n "$deps") <(echo -n "$BUILD_LOCALLY"))"

redo-ifchange mock "$BUILD_DIR/$name.src.rpm"
for dep in $deps; do
    echo "$BUILD_DIR/$dep.rpmlist"
done |
xargs redo-ifchange

dep_rpms=""
for dep in $deps; do
    while IFS= read -r dep_rpm; do
        dep_rpms="$dep_rpms $BUILD_DIR/$dep_rpm"
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

find "$rpm_dir" -maxdepth 1 -regex '.*\.\(noarch\|x86_64\)\.rpm' -exec realpath --relative-to "$BUILD_DIR" {} \; > "$3"
redo-stamp < "$3"
