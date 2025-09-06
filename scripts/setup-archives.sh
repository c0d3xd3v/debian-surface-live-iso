#!/bin/bash
set -e

# Löschen alter Listen, falls nötig
sudo rm -f /etc/apt/sources.list.d/*.list

# Debian main + updates + security
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

# Linux Surface repo
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg
sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF
sudo apt update
