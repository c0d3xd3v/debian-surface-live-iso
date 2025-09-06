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

echo ">>> Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y gnupg curl ca-certificates wget

echo ">>> Installing Debian archive keyring..."
curl -fsSL http://ftp.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2024.1_all.deb -o /tmp/keyring.deb
sudo dpkg -i /tmp/keyring.deb

sudo mkdir -p /etc/apt/keyrings
sudo cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/keyrings/debian-archive-keyring.gpg

echo ">>> Updating apt with Debian keys..."
sudo apt-get update -y

echo ">>> Adding Linux Surface repository..."
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null

sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo ">>> Final apt update..."
sudo apt-get update -y
