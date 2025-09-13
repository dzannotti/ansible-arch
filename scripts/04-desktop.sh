#!/bin/bash
# GNOME desktop environment on Wayland

DESKTOP_PACKAGES=(
    # Core GNOME
    libnotify gnome-keyring gnome-control-center
    gnome-tweaks gnome-shell gnome-shell-extensions
    gnome-themes-extra
    
    # File manager and utilities
    nautilus file-roller evince
    gnome-calculator gnome-text-editor gnome-disk-utility
    
    # GTK theming (moved from theming script)
    gtk3 gtk4 libadwaita
    gtk-engine-murrine  # Required for GTK themes
    sassc               # Required for theme compilation
    
    # Qt support for Qt apps
    qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
    
    # Display system
    xorg-server xorg-xwayland  # X11/Wayland compatibility
    wayland wayland-protocols  # Wayland core
    
    # Audio system (PipeWire)
    pipewire pipewire-alsa pipewire-pulse pipewire-jack
    wireplumber pavucontrol
)

install_packages "GNOME desktop environment" "${DESKTOP_PACKAGES[@]}"

# Enable GDM display manager
log_info "Enabling GDM display manager..."
sudo systemctl enable gdm
log_success "GDM enabled"

# Enable audio services
log_info "Enabling PipeWire audio services..."
systemctl --user enable pipewire pipewire-pulse wireplumber
log_success "PipeWire services enabled"