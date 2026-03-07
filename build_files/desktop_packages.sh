#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Running desktop packages scripts..."

# Add Terra repository for Zed editor
dnf5 install -y \
    --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' \
    terra-release

# Sway window manager stack
dnf install --setopt=install_weak_deps=False -y \
    sway \
    swaybg \
    swaylock \
    waybar \
    rofi-wayland \
    mako \
    imv \
    light \
    foot \
    thunar \
    gvfs \
    gvfs-dav \
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
