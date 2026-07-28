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
    echo "$BUILD_DIR/$dep.rpms.hash"
done |
xargs redo-ifchange

additional_packages_args=''
for dep in $deps; do
    while IFS= read -r rpm; do
        additional_packages_args="$additional_packages_args --additional-package=$rpm"
    done < <(find "$BUILD_DIR/$dep.rpms" -maxdepth 1 -regex '.*\.\(noarch\|x86_64\)\.rpm')
done

rpm_dir="$BUILD_DIR/$name.rpms"
rm -rf "$rpm_dir"
mkdir -p "$rpm_dir"

repo_args=""
if [ "$CI_CONTAINER_TYPE" = nightly ]; then
    repo_args="-a https://download.copr.fedorainfracloud.org/results/rpmsoftwaremanagement/dnf-nightly/$MOCK_CHROOT"
fi

mock --root "$MOCK_CHROOT" $additional_packages_args \
    --no-clean --no-cleanup-after \
    --resultdir "$rpm_dir" \
    --config-opts=update_before_build=False \
    ${MOCK_WITH_OPTIONS[$name]:-} $repo_args "$BUILD_DIR/$name.src.rpm" > /dev/stderr

rm -rf "$rpm_dir"/*.src.rpm

nix-hash --type sha256 "$rpm_dir" > "$3"
redo-stamp < "$3"
