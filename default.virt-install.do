#!/usr/bin/env bash
set -e

redo-ifchange config.sh
. ./config.sh

name="$(basename "$2")"

redo-ifchange "$BUILD_DIR/$name.qcow2"

sudo virsh destroy "$name" || true
sudo virsh undefine "$name" || true

sudo cp "$BUILD_DIR/$name.qcow2" "/var/lib/libvirt/images/$name.qcow2"

sudo virt-install \
    --name "$name" \
    --cpu host-model \
    --vcpus 4 \
    --memory 4096 \
    --autoconsole none \
    --import --disk "/var/lib/libvirt/images/$name.qcow2,format=qcow2" \
    --os-variant centos-stream9 > /dev/stderr
