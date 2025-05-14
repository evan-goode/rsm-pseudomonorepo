#!/usr/bin/env bash
set -e

ALL_PACKAGES="dnf libdnf librepo libsolv dnf5 createrepo_c dnf-plugins-core"

function shallow_dependencies {
    case "$1" in
        "dnf-plugins-core")
            shallow_deps='dnf'
            ;;
        "dnf")
            shallow_deps='librepo libdnf'
            ;;
        "libdnf")
            shallow_deps='librepo libsolv'
            ;;
        "dnf5")
            shallow_deps='librepo libsolv'
            ;;
        *)
            shallow_deps=''
            ;;
    esac
    echo "$shallow_deps" | tr ' ' '\n' | sed '/^$/d'
}

function deep_dependencies {
    deep_deps="$(shallow_dependencies "$1")"
    for shallow_dep in $shallow_deps; do
        deep_deps="$(echo "$deep_deps"; shallow_dependencies "$shallow_dep")"
    done
    echo "$deep_deps" | uniq | tr ' ' '\n' | sed '/^$/d'
}

function intersection {
    comm -12 <(sort < "$1") <(sort < "$2") | sort
}
