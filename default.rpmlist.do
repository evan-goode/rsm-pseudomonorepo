#!/usr/bin/env bash
set -ex

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
additional_packages_args=''
for dep in $deps; do
    while IFS= read -r dep_rpm; do
        dep_rpms="$dep_rpms $BUILD_DIR/$dep_rpm"
        additional_packages_args="$additional_packages_args --additional-package=$BUILD_DIR/$dep_rpm"
    done < "$BUILD_DIR/$dep.rpmlist"
done

# mock --root "$MOCK_CHROOT" --no-clean --calculate-build-dependencies "$BUILD_DIR/$name.src.rpm" > /dev/stderr

rpm_dir="$BUILD_DIR/$name.rpms"
rm -rf "$rpm_dir"
mkdir -p "$rpm_dir"

repo_args=""
if [ "$CI_CONTAINER_TYPE" = nightly ]; then
    repo_args="-a https://download.copr.fedorainfracloud.org/results/rpmsoftwaremanagement/dnf-nightly/$MOCK_CHROOT"
fi

mock --root "$MOCK_CHROOT" $additional_packages_args \
    --no-clean --no-cleanup-after \
    --resultdir "$BUILD_DIR/$name.rpms" \
    --config-opts=update_before_build=False \
    ${MOCK_WITH_OPTIONS[$name]:-} $repo_args "$BUILD_DIR/$name.src.rpm" > /dev/stderr

find "$rpm_dir" -maxdepth 1 -regex '.*\.\(noarch\|x86_64\)\.rpm' -exec realpath --relative-to "$BUILD_DIR" {} \; > "$3"
redo-stamp < "$3"
