#!/bin/bash
# Limine bootloader configuration with Tokyo Night theme
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/../configs"

echo "Installing Limine bootloader..."
sudo pacman -S --needed --noconfirm \
    limine \
    plymouth

echo "Adding Plymouth to mkinitcpio hooks..."
# Instead of overwriting, we'll modify the main mkinitcpio.conf
if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    # Get current HOOKS line and insert plymouth after udev
    sudo sed -i '/^HOOKS=/s/udev/udev plymouth/' /etc/mkinitcpio.conf
    echo "Plymouth hook added to mkinitcpio.conf"
    REBUILD_INITRAMFS=true
else
    echo "Plymouth hook already in mkinitcpio.conf"
    REBUILD_INITRAMFS=false
fi

echo "Configuring Limine with Tokyo Night theme..."
# Check for Limine config location (EFI or BIOS)
if [ -f /boot/EFI/limine/limine.conf ]; then
    LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
elif [ -f /boot/limine/limine.conf ]; then
    LIMINE_CONFIG="/boot/limine/limine.conf"
elif [ -d /boot/EFI/limine ]; then
    LIMINE_CONFIG="/boot/EFI/limine/limine.conf"
elif [ -d /boot/limine ]; then
    LIMINE_CONFIG="/boot/limine/limine.conf"
else
    echo "Warning: Could not find Limine config directory"
    LIMINE_CONFIG=""
fi

if [ -n "$LIMINE_CONFIG" ]; then
    # Check if config needs updating
    if [ ! -f "$LIMINE_CONFIG" ] || ! grep -q "Tokyo Night" "$LIMINE_CONFIG" 2>/dev/null; then
        sudo cp "$CONFIG_DIR/limine.conf" "$LIMINE_CONFIG"
        echo "Limine configuration updated at $LIMINE_CONFIG"
    else
        echo "Limine configuration already set"
    fi
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