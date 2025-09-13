#!/bin/bash
# Limine bootloader configuration with Tokyo Night theme
set -euo pipefail

# Variables from setup.sh working directory
CONFIG_DIR="configs"

echo "Installing Limine bootloader and related packages..."
sudo pacman -S --needed --noconfirm \
    limine \
    plymouth

# Install limine tools if available
yay -S --needed --noconfirm \
    limine-mkinitcpio-hook \
    limine-snapper-sync || echo "Optional limine packages not available"

echo "Configuring mkinitcpio hooks..."
# Create omarchy-style hooks config
sudo tee /etc/mkinitcpio.conf.d/workstation_hooks.conf > /dev/null << 'EOF'
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block filesystems fsck)
EOF

echo "Plymouth and limine hooks configured"
REBUILD_INITRAMFS=true

echo "Configuring Limine with Tokyo Night theme..."

# Check if limine is installed
if command -v limine &>/dev/null; then
    # Determine if EFI or BIOS
    [[ -f /boot/EFI/limine/limine.conf ]] && EFI=true || EFI=false
    
    # Set config location based on boot type
    if [ "$EFI" = true ]; then
        LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
    else
        LIMINE_CONFIG="/boot/limine/limine.conf"
    fi
    
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

    # Use our existing config file - limine-update will add boot entries to it
    if [ ! -f "$LIMINE_CONFIG" ] || ! grep -q "Tokyo Night" "$LIMINE_CONFIG" 2>/dev/null; then
        sudo cp "$CONFIG_DIR/limine.conf" "$LIMINE_CONFIG"
        echo "Limine theme configuration copied"
    else
        echo "Limine theme already configured"
    fi

    # Update limine to generate boot entries
    echo "Updating limine boot entries..."
    sudo limine-update
    
    echo "Limine configuration updated with Tokyo Night theme"
else
    echo "Warning: Limine not found, skipping configuration"
fi

echo "Updating kernel command line for quiet boot..."
if [ -f /etc/default/grub ]; then
    if ! grep -q "quiet splash loglevel=3" /etc/default/grub; then
        sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.systemd.show_status=false rd.udev.log_level=3 vt.global_cursor_default=0"/' /etc/default/grub
        echo "Kernel command line updated"
        sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    else
        echo "Kernel command line already configured"
    fi
fi

# Rebuild initramfs if needed
if [ "$REBUILD_INITRAMFS" = true ]; then
    echo "Rebuilding initramfs..."
    sudo mkinitcpio -P
fi

echo "Limine bootloader configured"