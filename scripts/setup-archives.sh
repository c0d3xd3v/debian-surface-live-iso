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
sudo apt-get install -y --no-install-recommends gnupg ca-certificates wget curl

echo ">>> Importing missing Debian GPG keys..."
# Hier alle benötigten Keys, die in deinem Fehler gelistet wurden:
KEYS=(
    6ED0E7B82643E131
    78DBA3BC47EF2265
    F8D2585B8783D481
    54404762BBB6E853
    BDE6D2B9216EC7A8
)

for key in "${KEYS[@]}"; do
    echo "  -> Importing key: $key"
    gpg --keyserver keyserver.ubuntu.com --recv-keys "$key" || {
        echo "!!! Failed to get $key from keyserver. Trying hkps://keys.openpgp.org..."
        gpg --keyserver hkps://keys.openpgp.org --recv-keys "$key"
    }
    gpg --export "$key" | sudo tee "/etc/apt/trusted.gpg.d/debian-$key.gpg" >/dev/null
done

echo ">>> Adding Linux Surface repository..."
wget -qO - https://pkg.surfacelinux.com/debian/pubkey.gpg \
    | gpg --dearmor \
    | sudo tee /usr/share/keyrings/linux-surface-archive-keyring.gpg >/dev/null

sudo tee /etc/apt/sources.list.d/linux-surface.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/usr/share/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOF

echo ">>> Final apt update..."
sudo apt-get update -y
