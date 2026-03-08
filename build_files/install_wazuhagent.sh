#!/bin/bash

set -ouex pipefail

# Import the GPG key
rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH

# Add the repository
cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
priority=1
EOF

# Install Wazuh agent via dnf5 (rpm-ostree not available during image build)
dnf5 install -y wazuh-agent

# Enable Wazuh agent service by creating symlink directly
# (systemctl enable does not work during container builds as systemd is not running)
mkdir -p /etc/systemd/system/multi-user.target.wants
ln -sf /usr/lib/systemd/system/wazuh-agent.service \
    /etc/systemd/system/multi-user.target.wants/wazuh-agent.service
