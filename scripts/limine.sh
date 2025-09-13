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
    echo "Limine tools not in official repos, trying AUR..."
    if command -v yay &>/dev/null; then
        yay -S --needed --noconfirm limine-mkinitcpio-hook || echo "limine-mkinitcpio-hook not available in AUR"
        yay -S --needed --noconfirm limine-snapper-sync || echo "limine-snapper-sync not available in AUR"
    else
        echo "yay not available, cannot install AUR limine packages"
        echo "Note: limine-update command will not be available without limine-mkinitcpio-hook"
    fi
}

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
    
    echo "mkinitcpio hooks updated with Plymouth and BTRFS support"
else
    echo "Plymouth hook already configured in mkinitcpio"
fi
# Note: Initramfs will be rebuilt by Plymouth when theme is set

echo "Configuring Limine with Tokyo Night theme..."

# Always configure limine - use the main config location where boot entries exist
# Check EFI vs BIOS setup
if [ -d /sys/firmware/efi ]; then
    LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
    EFI=true
else
    LIMINE_CONFIG="/boot/limine.conf"
    EFI=false
fi

echo "Using limine config at: $LIMINE_CONFIG"
    
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
        echo "Limine theme configuration copied"
    else
        echo "Limine theme already configured"
    fi

    # Update limine to generate boot entries if limine-update is available
    if command -v limine-update &>/dev/null; then
        echo "Updating limine boot entries..."
        sudo limine-update || echo "Warning: limine-update failed - check your limine configuration"
    else
        echo "Warning: limine-update not available - boot entries must be configured manually"
        echo "Consider installing limine-mkinitcpio-hook from AUR for automatic boot entry generation"
    fi
    
    echo "Limine configuration updated with Tokyo Night theme"
else
    echo "Warning: Limine not found, skipping configuration"
fi

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

# Enable limine-snapper-sync service if available
if systemctl list-unit-files | grep -q "limine-snapper-sync.service"; then
    echo "Enabling limine-snapper-sync service..."
    sudo systemctl enable limine-snapper-sync.service
else
    echo "limine-snapper-sync service not available"
fi

# Note: Kernel command line is configured via /etc/default/limine above  
# Note: Initramfs rebuild will be handled by Plymouth theme setup

echo "Limine bootloader and snapshots configured"