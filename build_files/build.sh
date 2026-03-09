#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 install -y tmux

ls -l /ctx

echo "::group:: ===Desktop Changes==="
/ctx/desktop_changes.sh
echo "::endgroup::"

echo "::group:: ===Desktop Packages==="
/ctx/desktop_packages.sh
echo "::endgroup::"

echo "::group:: ===Flatpak Apps==="
/ctx/install_flatpaks.sh
echo "::endgroup::"

#echo "::group:: ===Wazuh agent==="
#/ctx/install_wazuhagent.sh
#echo "::endgroup::"

#### Enable System Services
# Create symlinks directly instead of systemctl enable (systemd not running during build)
mkdir -p /etc/systemd/system/sockets.target.wants
ln -sf /usr/lib/systemd/system/podman.socket \
    /etc/systemd/system/sockets.target.wants/podman.socket
