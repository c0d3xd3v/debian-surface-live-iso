#!/bin/bash
set -e

echo ">>> Bereinige alten Build..."
sudo lb clean

echo ">>> Baue Basis-Chroot..."
sudo lb build --bootstrap-only

echo ">>> Mounts für Chroot vorbereiten..."
sudo mount -t proc binary/chroot/proc
sudo mount --rbind /sys binary/chroot/sys
sudo mount --rbind /dev binary/chroot/dev

echo ">>> Konfiguriere APT & Zertifikate im Chroot..."
sudo chroot binary/chroot /bin/bash <<'EOF'
set -e
rm -f /etc/apt/sources.list.d/*.list
rm -f /etc/apt/sources.list

mkdir -p /etc/apt/keyrings
apt-get update
apt-get install -y ca-certificates gnupg curl apt-transport-https

cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/keyrings/debian-archive-keyring.gpg

curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor \
    | tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null

cat > /etc/apt/sources.list <<EOL
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm-updates main contrib non-free
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://security.debian.org/debian-security bookworm-security main contrib non-free
deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOL

apt-get update
EOF

echo ">>> Unmounting..."
sudo umount -lf binary/chroot/proc
sudo umount -lf binary/chroot/sys
sudo umount -lf binary/chroot/dev

echo ">>> Starte finalen Build..."
sudo lb build
