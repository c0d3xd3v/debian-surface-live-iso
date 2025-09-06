#!/bin/bash
set -e
sudo cp chroot-configs/hooks/*.chroot /etc/live/build/hooks/
sudo chmod +x /etc/live/build/hooks/*.chroot
