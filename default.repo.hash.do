#!/usr/bin/env bash
set -ex

redo-ifchange config.sh
. ./config.sh

redo-ifchange dependencies.sh
. ./dependencies.sh

name="$(basename "$2")"

case "$name" in
    "dnf4")
        shallow_deps="libdnf dnf dnf-plugins-core createrepo_c rpm"
        ;;
    "dnf5")
        shallow_deps="dnf5 createrepo_c rpm"
        ;;
    *)
        echo Unexpected name: "$name" > /dev/stderr
        exit 1
        ;;
esac
shallow_deps="$(tr ' ' '\n' <<< "$shallow_deps")"

deps="$shallow_deps"
for shallow_dep in $shallow_deps; do
    deps="$(echo "$deps"; deep_dependencies "$shallow_dep")"
done
deps="$(sort <<< "$deps" | uniq | sed '/^$/d')"

deps="$(intersection <(echo -n "$deps") <(echo -n "$BUILD_LOCALLY"))"

for dep in $deps; do
    echo "$BUILD_DIR/$dep.rpms.hash"
done |
xargs redo-ifchange

repo_dir="$BUILD_DIR/$name.repo"
rm -rf "$repo_dir"
mkdir -p "$repo_dir"

for dep in $deps; do
    find "$BUILD_DIR/$dep.rpms" -maxdepth 1 -regex '.*\.\(noarch\|x86_64\)\.rpm' -exec ln {} "$repo_dir/" \;
done

createrepo_c "$repo_dir" > /dev/stderr

nix-hash --type sha256 "$repo_dir" > "$3"
redo-stamp < "$3"
