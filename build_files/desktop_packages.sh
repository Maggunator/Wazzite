#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Running desktop packages scripts..."

dnf install --setopt=install_weak_deps=False -y \
    htop \
    jetbrains-mono-fonts-all \
    nerd-fonts 