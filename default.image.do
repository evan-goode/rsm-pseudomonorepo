#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

case "$name" in
    "dnf4")
        deps="libdnf dnf dnf-plugins-core"
        ;;
    "dnf5")
        deps="dnf5"
        ;;
    "createrepo_c")
        deps="createrepo_c"
        ;;
    *)
        echo Unexpected name: "$name" > /dev/stderr
        exit 1
        ;;
esac
deps="$(comm -12 <(tr ' ' '\n' <<< "$deps" | sort) <(tr ' ' '\n' <<< "$BUILD_FROM_SOURCE" | sort))"

redo-ifchange "$BUILD_DIR/ci-dnf-stack.HEAD"
for dep in $deps; do
    redo-ifchange "$BUILD_DIR/$dep.rpmlist"
done

pushd "$ROOT_DIR/ci-dnf-stack" > /dev/null
    rm -rf rpms/* || true
    dep_rpms=""
    for dep in $deps; do
        while IFS= read -r dep_rpm; do
            dep_rpms="$dep_rpms $BUILD_DIR/$dep.rpms/$dep_rpm"
        done < "$BUILD_DIR/$dep.rpmlist"
    done
    if [ -n "$dep_rpms" ]; then
        cp $dep_rpms rpms
    fi

    sudo ./container-test ${CONTAINER_TAG:+--container="$CONTAINER_TAG"} build ${BASE_IMAGE:+--base=$BASE_IMAGE} > /dev/stderr
popd > /dev/null

sudo podman image save "$CONTAINER_TAG" > "$3"
redo-stamp < "$3"
