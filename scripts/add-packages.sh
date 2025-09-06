#!/bin/bash
set -e
sudo mkdir -p /etc/live/build/package-lists/
sudo cp chroot-configs/package-lists/surface-kde.list.chroot /etc/live/build/package-lists/
