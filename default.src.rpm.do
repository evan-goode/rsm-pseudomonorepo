#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

if grep -wq <<< "$BUILD_FROM_CENTPKG" "$name"; then
    # Source from centpkg
    echo "Using $name from ./centpkg/$name/" > /dev/stderr
    redo-ifchange "centpkg.$name.HEAD"
    srpm_tmp_path="$(
        set -euo pipefail
        cd "$ROOT_DIR/centpkg/$name"
        centpkg srpm | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
    )"
elif grep -wq <<< "$BUILD_FROM_FEDPKG" "$name"; then
    # Source from fedpkg
    echo "Using $name from ./fedpkg/$name/" > /dev/stderr
    redo-ifchange "fedpkg.$name.HEAD"
    srpm_tmp_path="$(
        set -euo pipefail
        cd "$ROOT_DIR/fedpkg/$name"
        fedpkg srpm | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
    )"
else
    # Source from upstream repository, use tito
    echo "Using $name from ./$name/" > /dev/stderr
    redo-ifchange "$name.HEAD"
    if [ "$name" = podman ]; then
        srpm_tmp_path="$(
            set -euo pipefail
            cd "$ROOT_DIR/$name/rpm"
            make srpm | grep -E '^Wrote: .+\.src\.rpm$' | tail -n 1 | sed 's/^Wrote: //'
        )"
    elif [ "$name" = rpm ]; then
        # Build the dist tarball using upstream's container-based method
        # (cmake + make dist), which bundles submodules, man pages, etc.
        srpm_tmp_path="$(
            set -euo pipefail
            cd "$ROOT_DIR/$name"
            # Compute git commit info to label the release (like tito --test)
            git_commit_count="$(git rev-list HEAD --count)"
            git_short_hash="$(git rev-parse --short HEAD)"
            git_release_suffix=".git.${git_commit_count}.${git_short_hash}"
            sudo podman build --target base --tag rpm-build -f tests/Dockerfile . > /dev/stderr
            sudo rm -rf "$BUILD_DIR/rpm._build"
            mkdir -p "$BUILD_DIR/rpm._build"
            sudo podman run --rm -v "$ROOT_DIR/$name":/srv:z \
                -v "$BUILD_DIR/rpm._build":/srv/_build:z \
                --workdir /srv/_build \
                rpm-build sh -c 'git config --global --add safe.directory /srv && cmake -DWITH_DOXYGEN=ON .. && make dist' > /dev/stderr
            sudo chown -R "$(id -u):$(id -g)" "$BUILD_DIR/rpm._build"
            tarball="$(ls "$BUILD_DIR/rpm._build/"*.tar.bz2 | head -1)"
            tmpdir=$(mktemp -d)
            cp "$tarball" "$tmpdir/"
            cp "$ROOT_DIR/$name/rpm.spec" "$tmpdir/"
            # Append git info to the Release field (like tito --test)
            sed -i "s/^\\(Release:.*\\)%{?dist}/\\1${git_release_suffix}%{?dist}/" "$tmpdir/rpm.spec"
            # Copy patches and extra sources referenced by the spec
            cp "$ROOT_DIR/$name/"*.patch "$tmpdir/" 2>/dev/null || true
            cp "$ROOT_DIR/$name/rpmdb-rebuild.service" "$tmpdir/" 2>/dev/null || true
            rpmbuild -bs \
                --define "_sourcedir $tmpdir" \
                --define "_specdir $tmpdir" \
                --define "_srcrpmdir $tmpdir" \
                "$tmpdir/rpm.spec" > /dev/stderr
            find "$tmpdir" -name '*.src.rpm' -print -quit
        )"
    else
        srpm_tmp_path="$(
            set -euo pipefail
            cd "$ROOT_DIR/$name"
            tito build --test --srpm --output "$BUILD_DIR" | grep -m1 -E '^Wrote: .+\.src\.rpm$' | sed 's/^Wrote: //'
        )"
    fi
fi

mv "$srpm_tmp_path" "$3"
 
redo-stamp < "$3"
