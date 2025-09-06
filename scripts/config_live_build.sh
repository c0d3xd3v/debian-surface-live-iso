#!/bin/bash
set -e

echo ">>> Bereinige alten Build..."
sudo lb clean

echo ">>> Konfiguriere Live-Build..."
lb config \
  --distribution bookworm \
  --binary-images iso-hybrid \
  --debian-installer live \
  --debian-installer-gui true \
  --archive-areas "main contrib non-free non-free-firmware" \
  --apt-recommends false \
  --mirror-bootstrap http://deb.debian.org/debian \
  --mirror-chroot http://deb.debian.org/debian

echo ">>> Erzeuge Basis-System (Bootstrap)..."
sudo lb bootstrap

echo ">>> Baue Chroot-Umgebung..."
sudo lb chroot

echo ">>> Setze neue APT-Sources und Keys..."
sudo mount -t proc /proc binary/chroot/proc
sudo mount --rbind /sys binary/chroot/sys
sudo mount --rbind /dev binary/chroot/dev

sudo chroot binary/chroot /bin/bash <<'EOF'
set -e

echo ">>> Bereinige alte APT-Sources..."
rm -f /etc/apt/sources.list.d/*.list
rm -f /etc/apt/sources.list

echo ">>> Installiere CA-Zertifikate & GnuPG..."
apt-get update
apt-get install -y ca-certificates gnupg curl

echo ">>> Installiere Surface-Key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor \
    | tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null

echo ">>> Neue sources.list schreiben..."
cat > /etc/apt/sources.list <<EOL
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm-updates main contrib non-free
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://security.debian.org/debian-security bookworm-security main contrib non-free
deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface-archive-keyring.gpg] https://pkg.surfacelinux.com/debian release main
EOL

echo ">>> Aktualisiere Paketlisten..."
apt-get update
EOF

echo ">>> Unmount Chroot..."
sudo umount -lf binary/chroot/proc
sudo umount -lf binary/chroot/sys
sudo umount -lf binary/chroot/dev

echo ">>> Baue finale ISO..."
sudo lb binary

echo ">>> Build erfolgreich abgeschlossen!"
