#!/bin/bash
set -e

echo ">>> Cleaning old apt lists..."
sudo rm -f /etc/apt/sources.list.d/*.list

echo ">>> Creating keyrings directory..."
sudo mkdir -p /etc/apt/keyrings

echo ">>> Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends gnupg ca-certificates wget curl debian-archive-keyring

echo ">>> Copying Debian keyring..."
sudo cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/keyrings/debian-archive-keyring.gpg

echo ">>> Adding Linux Surface key to keyrings..."
curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null

echo ">>> Writing Debian sources.list..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm-updates main contrib non-free
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

echo ">>> Adding Linux Surface repository..."
sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo ">>> Running final apt update..."
sudo apt-get update -y

echo ">>> Listing keys for verification..."
echo "Debian keys:"
gpg --no-default-keyring --keyring /etc/apt/keyrings/debian-archive-keyring.gpg --list-keys
echo
echo "Surface keys:"
gpg --no-default-keyring --keyring /etc/apt/keyrings/linux-surface-archive-keyring.gpg --list-keys

echo ">>> Setup complete."
