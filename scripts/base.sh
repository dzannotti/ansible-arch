#!/bin/bash
# Core system packages - the absolute essentials
set -euo pipefail

echo "Installing base system packages..."

sudo pacman -S --needed --noconfirm \
    base \
    base-devel \
    linux \
    linux-firmware \
    linux-headers \
    sudo \
    man-db \
    man-pages \
    networkmanager \
    openssh \
    git \
    curl \
    micro \
    vim \
    which \
    less \
    tree \
    bind-tools \
    zsh \
    bash-completion \
    bc \
    stow \
    fastfetch \
    inetutils \
    whois \
    plocate \
    tldr \
    ufw \
    dosfstools \
    ntfs-3g \
    exfatprogs \
    gvfs \
    gvfs-mtp \
    gvfs-smb \
    power-profiles-daemon \
    p7zip \
    unzip

echo "Base system packages installed"