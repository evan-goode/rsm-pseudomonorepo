#!/usr/bin/env bash
set -ex

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.image-rpmlist"

repo_dir="$BUILD_DIR/$name.repo"
rm -rf "$repo_dir"
mkdir -p "$repo_dir"

while IFS= read -r rpm_path; do
    ln "$BUILD_DIR/$rpm_path" "$repo_dir/"
done < "$BUILD_DIR/$name.image-rpmlist"

createrepo_c "$repo_dir" > /dev/stderr

nix-hash --type sha256 "$repo_dir" > "$3"
redo-stamp < "$3"
