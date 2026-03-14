#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Tweaking existing desktop config..."

# copy system files
rsync -rvK /ctx/system_files/silverblue/ /

mkdir -p /tmp/ublue-schema-test &&
        find /usr/share/glib-2.0/schemas/ -type f ! -name "*.gschema.override" -exec cp {} /tmp/ublue-schema-test/ \; &&
        cp /usr/share/glib-2.0/schemas/*-bos-modifications.gschema.override /tmp/ublue-schema-test/ &&
        echo "Running error test for bos gschema override. Aborting if failed." &&
        glib-compile-schemas --strict /tmp/ublue-schema-test || exit 1 &&
        echo "Compiling gschema to include bos setting overrides" &&
        glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null

echo "Masking unused services..."

# Only mask services that actually exist in this image
mask_if_exists() {
    for service in "$@"; do
        if systemctl list-unit-files "${service}" &>/dev/null; then
            echo "Masking ${service}..."
            systemctl mask "${service}"
        else
            echo "Skipping ${service} (not found)"
        fi
    done
}

# Gaming services - not needed on this device
mask_if_exists \
    ds-inhibit.service \
    hhd.service \
    input-remapper.service \
    switcheroo-control.service

# Peripherals not present
mask_if_exists \
    ModemManager.service \
    fprintd.service

# Hardware-specific: no AMD GPU on Intel XPS 13
mask_if_exists \
    modprobe@amdgpu.service

# Unnecessary on this device
mask_if_exists \
    colord.service \
    zfs-zed.service

# Serial ports - not present on laptop
mask_if_exists \
    serial-getty@ttyS1.service \
    serial-getty@ttyS2.service \
    serial-getty@ttyS3.service

# Boot performance improvements
mask_if_exists \
    systemd-binfmt.service \
    systemd-rfkill.service \
    systemd-rfkill.socket
