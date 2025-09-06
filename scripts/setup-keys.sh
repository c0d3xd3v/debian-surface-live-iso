#!/bin/bash
set -e

echo ">>> Installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y gnupg curl ca-certificates wget debian-archive-keyring

#echo ">>> Installing Debian archive keyring..."
#curl -fsSL http://ftp.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2024.1_all.deb -o /tmp/keyring.deb
#sudo dpkg -i /tmp/keyring.deb

# Keyrings sauber ablegen
sudo mkdir -p /etc/apt/keyrings
sudo cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/keyrings/debian-archive-keyring.gpg

echo ">>> Adding Linux Surface key..."
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null

echo ">>> Listing all trusted keys:"
apt-key list || echo "apt-key deprecated, using /etc/apt/keyrings/ instead"

echo ">>> Testing Debian key..."
gpg --no-default-keyring --keyring /etc/apt/keyrings/debian-archive-keyring.gpg --list-keys

echo ">>> Testing Surface key..."
gpg --no-default-keyring --keyring /etc/apt/keyrings/linux-surface-archive-keyring.gpg --list-keys

echo ">>> Test finished. Keys should be visible above."
