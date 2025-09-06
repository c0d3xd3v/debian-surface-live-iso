#!/bin/bash
set -e

echo "🔹 Entferne alte APT-Listen..."
sudo rm -f /etc/apt/sources.list.d/*.list

echo "🔹 Setze neue Debian-Repositories..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

echo "🔹 Installiere notwendige Tools und Debian-Keyring..."
sudo apt-get update -y
sudo apt-get install -y gnupg ca-certificates debian-archive-keyring

echo "🔹 Importiere fehlende Debian-GPG-Keys..."
# Aus deinem Log fehlen diese 5 Keys
for key in \
    6ED0E7B82643E131 \
    78DBA3BC47EF2265 \
    F8D2585B8783D481 \
    54404762BBB6E853 \
    BDE6D2B9216EC7A8; do

    echo "  -> Importiere Key: $key"
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key"
    gpg --export "$key" | sudo tee /usr/share/keyrings/debian-archive-key-$key.gpg > /dev/null
done

echo "🔹 Füge Surface Linux Repository hinzu..."
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg > /dev/null

sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo "🔹 Führe finalen apt-get update durch..."
sudo apt-get update -y
