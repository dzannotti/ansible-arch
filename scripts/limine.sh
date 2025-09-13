#!/bin/bash
# Limine bootloader configuration with Tokyo Night theme
set -euo pipefail

# Variables from setup.sh working directory
CONFIG_DIR="configs"

echo "Installing Limine bootloader and related packages..."
sudo pacman -S --needed --noconfirm \
    limine \
    plymouth

# Try to install limine tools - first from official repos, then AUR
echo "Installing limine tools..."

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
# Check if hooks config already exists with our configuration
HOOKS_CONFIG="/etc/mkinitcpio.conf.d/workstation_hooks.conf"
EXPECTED_HOOKS="base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block filesystems fsck"

if [ -f "$HOOKS_CONFIG" ] && grep -q "plymouth" "$HOOKS_CONFIG"; then
    echo "mkinitcpio hooks already configured"
else
    # Create omarchy-style hooks config
    sudo tee "$HOOKS_CONFIG" > /dev/null << 'EOF'
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block filesystems fsck)
EOF
    echo "Plymouth and limine hooks configured"
fi
# Note: Initramfs will be rebuilt by Plymouth when theme is set

echo "Configuring Limine with Tokyo Night theme..."

# Check if limine bootloader is installed (check for config files)
echo "DEBUG: Checking for limine installation..."
if [ -f /boot/limine.conf ] || [ -f /boot/EFI/limine/limine.conf ] || [ -f /boot/limine/limine.conf ]; then
    echo "DEBUG: limine bootloader found"
    
    # Determine config location - check all possible locations
    if [ -f /boot/EFI/limine/limine.conf ]; then
        LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
        EFI=true
    elif [ -f /boot/limine/limine.conf ]; then
        LIMINE_CONFIG="/boot/limine/limine.conf"  
        EFI=false
    elif [ -f /boot/limine.conf ]; then
        LIMINE_CONFIG="/boot/limine.conf"
        EFI=false
    fi
    
    echo "DEBUG: Using limine config at: $LIMINE_CONFIG"
    
    # Get existing kernel command line if config exists
    if [ -f "$LIMINE_CONFIG" ]; then
        CMDLINE=$(grep "^[[:space:]]*cmdline:" "$LIMINE_CONFIG" | head -1 | sed 's/^[[:space:]]*cmdline:[[:space:]]*//')
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

# Note: Kernel command line is configured via /etc/default/limine above
# Note: Initramfs rebuild will be handled by Plymouth theme setup

echo "Limine bootloader configured"