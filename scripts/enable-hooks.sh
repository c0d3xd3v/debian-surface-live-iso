#!/bin/bash
set -e
cp config/hooks/*.chroot /etc/live/build/hooks/
chmod +x /etc/live/build/hooks/*.chroot
