#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Running desktop packages scripts..."

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
    network-manager-applet

# System tools
dnf install --setopt=install_weak_deps=False -y \
    htop \
    chezmoi \
    jetbrains-mono-fonts-all \
    nerd-fonts

# Zed editor via Terra
#dnf install --setopt=install_weak_deps=False -y \
#    zed
