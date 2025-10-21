#!/bin/bash

set -ouex pipefail

# Import the GPG key:
rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH


#Add the repository:
cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=EL-\$releasever - Wazuh
baseurl=https://packages.wazuh.com/4.x/yum/
priority=1
EOF



### Install packages
rpm-ostree install wazuh-agent