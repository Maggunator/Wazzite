#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Running desktop packages scripts..."

# # Add Terra repository for Zed editor (skip if already present)
# if ! dnf5 repolist | grep -q terra; then
#     FEDORA_VERSION=$(rpm -E '%{fedora}')
#     dnf5 install -y \
#         --repofrompath "terra,https://repos.fyralabs.com/terra${FEDORA_VERSION}" \
#         --setopt="terra.gpgkey=https://repos.fyralabs.com/terra${FEDORA_VERSION}/key.asc" \
#         terra-release
# fi

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
# /usr/bin/zed is the ZFS Event Daemon, so Terra installs the editor to
# /usr/libexec/zed-editor. The .desktop file uses 'zeditor' but the package
# omits the symlink, so create it here.
cat > /etc/yum.repos.d/terra.repo << EOF
[terra]
name=Terra \$releasever
baseurl=https://repos.fyralabs.com/terra\$releasever
gpgkey=https://repos.fyralabs.com/terra\$releasever/key.asc
gpgcheck=1
enabled=1
EOF

dnf install --setopt=install_weak_deps=False -y zed
ln -sf /usr/libexec/zed-editor /usr/bin/zeditor

