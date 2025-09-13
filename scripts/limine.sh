#!/bin/bash
# Limine bootloader configuration with Tokyo Night theme
set -euo pipefail

# Variables from setup.sh working directory
CONFIG_DIR="configs"

echo "Installing Limine bootloader and related packages..."
sudo pacman -S --needed --noconfirm \
    limine \
    plymouth

# Install snapper for snapshot functionality
echo "Installing snapper and limine tools..."
sudo pacman -S --needed --noconfirm \
    snapper

# Try to install limine tools - first from official repos, then AUR
# Try official repos first (some distros have these)
sudo pacman -S --needed --noconfirm limine-snapper-sync limine-mkinitcpio-hook 2>/dev/null || {
    echo "Limine tools not in official repos, installing from AUR..."
    if command -v yay &>/dev/null; then
        info "Installing limine-mkinitcpio-hook from AUR..."
        yay -S --needed --noconfirm limine-mkinitcpio-hook && success "limine-mkinitcpio-hook installed" || error "Failed to install limine-mkinitcpio-hook"
        
        info "Installing limine-snapper-sync from AUR..."  
        yay -S --needed --noconfirm limine-snapper-sync && success "limine-snapper-sync installed" || error "Failed to install limine-snapper-sync"
        
        success "AUR limine tools installation completed"
    else
        echo "yay not available, cannot install AUR limine packages"
        echo "Note: Install yay first to get limine tools from AUR"
    fi
}

# Install Limine bootloader files and install to disk
echo "Installing Limine bootloader files..."
if [ ! -f "/boot/limine-bios.sys" ]; then
    echo "Copying Limine bootloader files to /boot..."
    sudo cp /usr/share/limine/limine-bios.sys /boot/
    sudo cp /usr/share/limine/limine-bios-cd.bin /boot/ 2>/dev/null || true
    sudo cp /usr/share/limine/limine-uefi-cd.bin /boot/ 2>/dev/null || true
    success "Limine bootloader files copied"
else
    info "Limine bootloader files already present"
fi

# Install Limine to the disk (not partition)
echo "Installing Limine bootloader to disk..."
# Find the disk that contains /boot
BOOT_DISK=$(lsblk -no PKNAME "$(findmnt -no SOURCE /boot)" | head -1)
if [ -n "$BOOT_DISK" ]; then
    echo "Installing Limine to disk: /dev/$BOOT_DISK"
    sudo limine bios-install /dev/$BOOT_DISK && success "Limine bootloader installed to /dev/$BOOT_DISK" || error "Failed to install Limine bootloader"
else
    error "Could not determine boot disk for Limine installation"
    warning "You may need to manually run: sudo limine bios-install /dev/sdX"
fi

echo "Configuring mkinitcpio hooks..."
# Update the main mkinitcpio.conf with proper hooks including Plymouth and BTRFS support
MKINITCPIO_CONF="/etc/mkinitcpio.conf"

# Check if plymouth hook is already present
if ! grep -q "plymouth" "$MKINITCPIO_CONF"; then
    echo "Adding Plymouth and BTRFS hooks to mkinitcpio..."
    
    # Backup the config
    if [ ! -f "$MKINITCPIO_CONF.backup" ]; then
        sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF.backup"
    fi
    
    # Replace the HOOKS line with our complete configuration
    sudo sed -i 's/^HOOKS=.*/HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block btrfs filesystems fsck)/' "$MKINITCPIO_CONF"
    
    success "mkinitcpio hooks updated with Plymouth and BTRFS support"
else
    info "Plymouth hook already configured in mkinitcpio"
fi
# Note: Initramfs will be rebuilt by Plymouth when theme is set

echo "Configuring Limine with Tokyo Night theme..."

# Use the main limine config where boot entries exist
LIMINE_CONFIG="/boot/limine.conf"
echo "Configuring limine at: $LIMINE_CONFIG"

# Get existing kernel command line if config exists
if [ -f "$LIMINE_CONFIG" ]; then
    CMDLINE=$(grep "^[[:space:]]*cmdline:" "$LIMINE_CONFIG" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//' || echo "")
    if [ -z "$CMDLINE" ]; then
        # Default cmdline if none found in config
        CMDLINE="root=UUID=$(findmnt -no UUID /) rw"
    fi
else
    # Default cmdline
    CMDLINE="root=UUID=$(findmnt -no UUID /) rw"
fi

# Create /etc/default/limine config
sudo tee /etc/default/limine > /dev/null << EOF
TARGET_OS_NAME="Arch Linux"

ESP_PATH="/boot"

KERNEL_CMDLINE[default]="$CMDLINE"
KERNEL_CMDLINE[default]+=" quiet splash loglevel=3 rd.systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0"

ENABLE_LIMINE_FALLBACK=yes

# Find and add other bootloaders
FIND_BOOTLOADERS=yes
EOF

# Backup existing config if it exists and hasn't been backed up
if [ -f "$LIMINE_CONFIG" ] && [ ! -f "$LIMINE_CONFIG.backup" ]; then
    sudo cp "$LIMINE_CONFIG" "$LIMINE_CONFIG.backup"
    echo "Backed up existing limine config to $LIMINE_CONFIG.backup"
fi

# Use our existing config file - limine-update will add boot entries to it
if [ ! -f "$LIMINE_CONFIG" ] || ! grep -q "Tokyo Night" "$LIMINE_CONFIG" 2>/dev/null; then
    sudo cp "$CONFIG_DIR/limine.conf" "$LIMINE_CONFIG"
    success "Limine theme configuration copied"
else
    info "Limine theme already configured"
fi

# Update limine to generate boot entries if limine-update is available
if command -v limine-update &>/dev/null; then
    echo "Updating limine boot entries..."
    sudo limine-update && success "Limine boot entries updated" || error "limine-update failed - check your limine configuration"
else
    warning "limine-update not available - boot entries must be configured manually"
    info "Consider installing limine-mkinitcpio-hook from AUR for automatic boot entry generation"
fi

echo "Limine configuration updated with Tokyo Night theme"

# Configure snapper for snapshots (following omarchy approach)
echo "Configuring snapper for system snapshots..."

# Create snapper configs if they don't exist
if ! sudo snapper list-configs 2>/dev/null | grep -q "root"; then
    echo "Creating root snapper configuration..."
    sudo snapper -c root create-config /
fi

if ! sudo snapper list-configs 2>/dev/null | grep -q "home"; then
    echo "Creating home snapper configuration..."
    sudo snapper -c home create-config /home
fi

# Configure snapper settings (omarchy's tweaks)
echo "Configuring snapper timeline and limits..."
sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/root 2>/dev/null || true
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/root 2>/dev/null || true 
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/root 2>/dev/null || true

sudo sed -i 's/^TIMELINE_CREATE="yes"/TIMELINE_CREATE="no"/' /etc/snapper/configs/home 2>/dev/null || true
sudo sed -i 's/^NUMBER_LIMIT="50"/NUMBER_LIMIT="5"/' /etc/snapper/configs/home 2>/dev/null || true
sudo sed -i 's/^NUMBER_LIMIT_IMPORTANT="10"/NUMBER_LIMIT_IMPORTANT="5"/' /etc/snapper/configs/home 2>/dev/null || true

# Check for limine-snapper-sync service
if systemctl list-unit-files | grep -q "limine-snapper-sync.service"; then
    echo "Enabling limine-snapper-sync service for automatic snapshot boot entries..."
    sudo systemctl enable limine-snapper-sync.service
    
    # Create an initial snapshot
    echo "Creating initial snapshot..."
    sudo snapper -c root create --description "Initial system snapshot" 2>/dev/null || true
    
    # Trigger sync to update boot entries
    sudo systemctl start limine-snapper-sync.service 2>/dev/null || true
else
    echo "Note: limine-snapper-sync not available"
    echo "Snapshots can be managed manually with 'snapper' command"
    echo "To restore: boot from live USB and use 'snapper undochange' or 'btrfs subvolume'"
fi

# Note: Kernel command line is configured via /etc/default/limine above  
# Note: Initramfs rebuild will be handled by Plymouth theme setup

echo "Limine bootloader and snapshots configured"