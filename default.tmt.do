#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.image-rpmlist"

redo-ifchange ci-dnf-stack.HEAD

out="$(realpath $3)"
pushd "$ROOT_DIR/ci-dnf-stack" > /dev/null
    # AWFUL HACK
    mv rpms/.gitignore rpms/.gitignore.bak
    rm -rf rpms/* || true
    while IFS= read -r dep_rpm; do
        cp "$BUILD_DIR/$dep_rpm" rpms/
    done < "$BUILD_DIR/$name.image-rpmlist"

    # sudo tmt -c distro=$TMT_DISTRO run --all provision --how virtual plan --name '^/plans/integration/behave-dnf-bootc/' | tee "$out" > /dev/stderr
    sudo tmt -c distro=$TMT_DISTRO run --all provision --how virtual --image $TMT_PROVISION_IMAGE plan --name '^/plans/integration/behave-dnf5?-bootc/' -vvv | tee "$out" > /dev/stderr
    mv rpms/.gitignore.bak rpms/.gitignore
popd > /dev/null
