#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing Flatpak applications..."

# Ensure Flathub is available
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
    md.obsidian.Obsidian \
    com.bitwarden.desktop \
    org.libreoffice.LibreOffice \
    com.visualstudio.code \
    io.deezer.Deezer \
    app.zen_browser.zen \
    com.brave.Browser \
    dev.zed.Zed
