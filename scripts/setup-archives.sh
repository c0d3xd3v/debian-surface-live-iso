#!/bin/bash
set -e

# Alte Listen löschen
sudo rm -f /etc/apt/sources.list.d/*.list

# Debian main + updates + security
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

# Fehlende Debian GPG Keys importieren
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8

# Surface Linux GPG Key importieren
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg | gpg --dearmor | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg

# Surface Repo hinzufügen
sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

# Jetzt Update ausführen
sudo apt update
