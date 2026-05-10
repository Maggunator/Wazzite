#!/usr/bin/env bash

set ${SET_X:+-x} -eou pipefail

echo "Installing Flatpak applications..."

# Ensure Flathub is available
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
    md.obsidian.Obsidian \
    com.bitwarden.desktop \
    org.libreoffice.LibreOffice \
    dev.aunetx.deezer \
    app.zen_browser.zen \
    com.brave.Browser
