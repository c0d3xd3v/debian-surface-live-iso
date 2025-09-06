#!/bin/bash
set -e

# Alte Listen weg
sudo rm -f /etc/apt/sources.list.d/*.list

# Debian Sources
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free
deb http://security.debian.org/debian-security bookworm-security main contrib non-free
EOF

# Basis-Tools
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends gnupg ca-certificates debian-archive-keyring

# Surface-Key
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg >/dev/null

# Surface Repo
sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

# Falls immer noch Keys fehlen → explizit ziehen
for key in 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481 54404762BBB6E853 BDE6D2B9216EC7A8; do
  gpg --keyserver keyserver.ubuntu.com --recv-keys "$key" || true
  gpg --export "$key" | sudo tee /usr/share/keyrings/debian-key-$key.gpg >/dev/null || true
done

sudo apt-get update -y
