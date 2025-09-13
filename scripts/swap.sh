#!/bin/bash
# Swap file configuration
set -euo pipefail

# Variables from config.sh (sourced by setup.sh)
SWAPFILE_PATH="$SETUP_SWAPFILE_PATH"
SWAPFILE_SIZE="$SETUP_SWAPFILE_SIZE"

echo "Configuring swap file..."

# Check if swap file already exists
if [ -f "$SWAPFILE_PATH" ]; then
    echo "Swap file already exists at $SWAPFILE_PATH"
    
    # Check if it's already in use as swap
    if swapon --show | grep -q "$SWAPFILE_PATH"; then
        echo "Swap file is already active"
    else
        echo "Activating existing swap file..."
        sudo swapon "$SWAPFILE_PATH"
    fi
else
    echo "Creating swap file at $SWAPFILE_PATH with size $SWAPFILE_SIZE..."
    
    # Create swap file
    sudo fallocate -l "$SWAPFILE_SIZE" "$SWAPFILE_PATH"
    
    # Set permissions
    sudo chmod 600 "$SWAPFILE_PATH"
    
    # Format as swap
    sudo mkswap "$SWAPFILE_PATH"
    
    # Activate swap
    sudo swapon "$SWAPFILE_PATH"
    
    echo "Swap file created and activated"
fi

# Add to fstab if not already present
if ! grep -q "$SWAPFILE_PATH" /etc/fstab; then
    echo "Adding swap file to /etc/fstab..."
    echo "$SWAPFILE_PATH none swap defaults 0 0" | sudo tee -a /etc/fstab > /dev/null
    echo "Swap file added to fstab"
else
    echo "Swap file already in fstab"
fi

echo "Swap configuration complete"