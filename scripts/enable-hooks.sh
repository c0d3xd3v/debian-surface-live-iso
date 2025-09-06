#!/bin/bash
set -e
sudo mkdir -p /etc/live/build/hooks/
sudo cp config/hooks/*.chroot /etc/live/build/hooks/
sudo chmod +x /etc/live/build/hooks/*.chroot
