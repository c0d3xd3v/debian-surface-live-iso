#!/bin/bash
set -e

echo "🔹 [1/5] Entferne alte Repository-Listen..."
sudo rm -f /etc/apt/sources.list.d/*.list

echo "🔹 [2/5] Setze neue Debian-Repositories..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

echo "🔹 [3/5] Installiere Debian GPG-Keys..."
sudo apt-get update -y
sudo apt-get install -y gnupg ca-certificates debian-archive-keyring

# Fehlende Debian Keys manuell importieren (laut deinen Logs)
for key in 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8; do
    sudo gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key" || true
    sudo gpg --export "$key" | sudo tee /etc/apt/trusted.gpg.d/debian-key-$key.gpg >/dev/null
done

echo "🔹 [4/5] Füge Surface Linux Repository hinzu..."
# Surface Key richtig importieren
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg >/dev/null

# Surface Repo mit signed-by verwenden
sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo "🔹 [5/5] Aktualisiere Paketquellen..."
sudo apt-get update -y
