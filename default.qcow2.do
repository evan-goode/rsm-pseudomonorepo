#!/usr/bin/env bash
set -e

# TODO: rewrite this to not use evan-goode/bootc-test-scripts.
# ci-dnf-stack@dnf-4-stack/bootc/Containerfile should be good to use here, we
# would just need to inject an SSH public key. Or, we could skip the qcow2 step
# entirely and use podman-bootc.

redo-ifchange config.sh
. ./config.sh

redo-ifchange dependencies.sh
. ./dependencies.sh

name="$(basename "$2")"

deps="$(intersection <(echo -n "$ALL_PACKAGES") <(echo -n "$BUILD_LOCALLY"))"
redo-ifchange $deps

pushd "$ROOT_DIR/bootc-test-scripts" > /dev/null
    rm -rf rpms || true
    mkdir -p rpms
    dep_rpms=""
    for dep in $deps; do
        while IFS= read -r dep_rpm; do
            dep_rpms="$dep_rpms $BUILD_DIR/$dep.rpms/$dep_rpm"
        done < "$BUILD_DIR/$dep.rpmlist"
    done
    if [ -n "$dep_rpms" ]; then
        cp $dep_rpms rpms
    fi
    sudo podman build -f Containerfile ${BOOTC_BASE_IMAGE:+--build-arg BASE=$BOOTC_BASE_IMAGE} -t "$BOOTC_CONTAINER_TAG" > /dev/stderr

    sudo rm -rf output || true
    mkdir -p output
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v ./output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type qcow2 \
        --local \
        --rootfs xfs \
        "$BOOTC_CONTAINER_TAG" > /dev/stderr
    sudo chown -R "$(id -u):$(id -g)" output
    
popd > /dev/null

ln "$ROOT_DIR/bootc-test-scripts/output/qcow2/disk.qcow2" "$3"
redo-stamp < "$3"
