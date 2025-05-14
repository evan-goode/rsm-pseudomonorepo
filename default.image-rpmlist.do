#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. config.sh

redo-ifchange dependencies.sh
. dependencies.sh

name="$(basename "$2")"

case "$name" in
    "dnf4")
        shallow_deps="libdnf dnf dnf-plugins-core createrepo_c"
        ;;
    "dnf5")
        shallow_deps="dnf5 createrepo_c"
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
    echo "$BUILD_DIR/$dep.rpmlist"
done |
xargs redo-ifchange

touch "$3"
for dep in $deps; do
    cat "$BUILD_DIR/$dep.rpmlist" >> "$3"
done
redo-stamp < "$3"
