#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Running desktop packages scripts..."

# Add Terra repository for Zed editor
FEDORA_VERSION=$(rpm -E '%{fedora}')
# dnf5 install -y \
#     --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VERSION}" \
#     --setopt="terra.gpgkey=https://repos.fyralabs.com/terra${FEDORA_VERSION}/key.asc" \
#     terra-release

# Sway window manager stack
dnf install --setopt=install_weak_deps=False -y \
    sway \
    swaybg \
    swaylock \
    swayidle \
    waybar \
    rofi-wayland \
    mako \
    imv \
    light \
    foot \
    thunar \
    network-manager-applet

# System tools
dnf install --setopt=install_weak_deps=False -y \
    htop \
    chezmoi \
    jetbrains-mono-fonts-all \
    nerd-fonts

# Zed editor via Terra
dnf install --setopt=install_weak_deps=False -y \
    zed
