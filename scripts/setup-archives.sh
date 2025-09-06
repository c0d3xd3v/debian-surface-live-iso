#!/bin/bash
set -e

echo ">>> Cleaning old apt lists..."
sudo rm -f /etc/apt/sources.list.d/*.list

echo ">>> Writing Debian sources.list..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

echo ">>> Installing debian-archive-keyring..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends debian-archive-keyring ca-certificates wget gnupg

echo ">>> Copying Debian trusted keys..."
# Debian liefert alle Keys hier mit
sudo cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/trusted.gpg.d/debian-archive-keyring.gpg

echo ">>> Adding Linux Surface repository..."
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg >/dev/null

sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo ">>> Final apt update..."
sudo apt-get update -y
