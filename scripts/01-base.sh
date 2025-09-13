#!/bin/bash
# Base system packages - the absolute essentials

BASE_PACKAGES=(
    # Core system
    base base-devel linux linux-firmware linux-headers
    sudo man-db man-pages
    
    # Networking
    networkmanager openssh
    
    # Basic tools  
    git curl micro vim which less tree
    bind-tools  # dig, nslookup
    
    # Shell
    zsh bash-completion
    
    # System utilities
    bc stow fastfetch
    inetutils whois plocate tldr ufw
    
    # Filesystem support
    dosfstools ntfs-3g exfatprogs
    gvfs gvfs-mtp gvfs-smb  # Device/network support
    power-profiles-daemon   # Power management
    
    # Compression
    p7zip unzip
)

install_official_packages "base system packages" "${BASE_PACKAGES[@]}"

# Enable essential services
log_info "Enabling essential services..."
sudo systemctl enable NetworkManager
sudo systemctl enable sshd
log_success "Essential services enabled"