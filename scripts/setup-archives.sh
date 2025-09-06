#!/bin/bash
set -e

# Alte Repo-Dateien entfernen
sudo rm -f /etc/apt/sources.list.d/*.list

# Debian Repo
sudo cp config/archives/debian.list.chroot /etc/apt/sources.list

# Surface Repo GPG
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg

# Surface Repo Liste
sudo cp config/archives/linux-surface.list.chroot /etc/apt/sources.list.d/linux-surface.list
