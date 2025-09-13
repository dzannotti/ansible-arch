#!/bin/bash
# Configure pacman with better defaults
set -euo pipefail

echo "Configuring pacman..."

# Backup original pacman.conf
if [ ! -f /etc/pacman.conf.backup ]; then
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup
    echo "Backed up original pacman.conf"
fi

# Create new pacman.conf
sudo tee /etc/pacman.conf > /dev/null << 'EOF'
[options]
Color
ILoveCandy
VerbosePkgLists
HoldPkg = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 5
DownloadUser = alpm

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

# pacman searches repositories in the order defined here
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

# [multilib]
# Include = /etc/pacman.d/mirrorlist
EOF

echo "Pacman configuration updated"
echo "Refreshing package databases..."
sudo pacman -Sy

echo "Pacman configuration complete"