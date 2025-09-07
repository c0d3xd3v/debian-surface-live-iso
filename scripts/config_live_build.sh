#!/bin/bash
set -e

echo ">>> Starte Live-Build Konfiguration..."

# 1. Live-Build aufräumen
sudo lb clean

# 2. Bootstrap vorbereiten
sudo lb bootstrap

# 3. Mounts für Chroot
sudo mount -t proc /proc binary/chroot/proc
sudo mount --rbind /sys binary/chroot/sys
sudo mount --rbind /dev binary/chroot/dev

echo ">>> Wechsel ins Chroot..."
sudo chroot binary/chroot /bin/bash <<'EOF'
set -e

echo ">>> Bereinige alte APT-Konfiguration..."
rm -f /etc/apt/sources.list.d/*.list
rm -f /etc/apt/sources.list

echo ">>> Installiere wichtige Pakete..."
apt-get update
apt-get install -y --no-install-recommends ca-certificates gnupg curl apt-transport-https

mkdir -p /etc/apt/keyrings

# Debian-Archiv-Key
cp /usr/share/keyrings/debian-archive-keyring.gpg /etc/apt/keyrings/debian-archive-keyring.gpg

# Surface-Key laden
echo ">>> Lade Linux-Surface Key..."
if ! curl -fsSL https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc \
    | gpg --dearmor \
    | tee /etc/apt/keyrings/linux-surface-archive-keyring.gpg >/dev/null; then
    echo ">>> HTTPS fehlgeschlagen, wechsle zu HTTP für Surface Repo"
    SURFACE_PROTO="http"
else
    SURFACE_PROTO="https"
fi

# Neue sources.list
cat > /etc/apt/sources.list <<EOL
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://deb.debian.org/debian bookworm-updates main contrib non-free
deb [signed-by=/etc/apt/keyrings/debian-archive-keyring.gpg] http://security.debian.org/debian-security bookworm-security main contrib non-free
deb [arch=amd64 signed-by=/etc/apt/keyrings/linux-surface-archive-keyring.gpg] ${SURFACE_PROTO}://pkg.surfacelinux.com/debian release main
EOL

echo ">>> Aktualisiere Paketlisten..."
apt-get update || true

EOF

echo ">>> Unmounting..."
sudo umount -lf binary/chroot/proc
sudo umount -lf binary/chroot/sys
sudo umount -lf binary/chroot/dev

echo ">>> Baue ISO..."
sudo lb chroot
sudo lb binary
