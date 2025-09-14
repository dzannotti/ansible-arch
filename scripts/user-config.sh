#!/bin/bash
# User configuration - avatar, full name, email
set -euo pipefail

# Variables from config.sh (sourced by setup.sh)
USERNAME="$SETUP_USERNAME"
FULL_NAME="$SETUP_FULL_NAME"

CONFIG_DIR="configs"
AVATAR_SOURCE="assets/profile.png"

echo "Configuring user settings for $USERNAME..."

# Set user full name using chfn if not already set
echo "Setting user full name..."
if ! getent passwd "$USERNAME" | grep -q "$FULL_NAME"; then
    sudo chfn -f "$FULL_NAME" "$USERNAME"
    echo "Full name set to $FULL_NAME"
else
    echo "Full name already configured"
fi

# Copy avatar for GDM/GNOME if it exists
if [ -f "$AVATAR_SOURCE" ]; then
    # Set avatar for AccountsService (used by GDM)
    ACCOUNTS_DIR="/var/lib/AccountsService/icons"
    if [ ! -f "$ACCOUNTS_DIR/$USERNAME" ]; then
        echo "Setting user avatar for GDM..."
        sudo mkdir -p "$ACCOUNTS_DIR"
        sudo cp "$AVATAR_SOURCE" "$ACCOUNTS_DIR/$USERNAME"
        echo "GDM avatar set"
    else
        echo "GDM avatar already set"
    fi
    
    # Update AccountsService user file
    ACCOUNTS_FILE="/var/lib/AccountsService/users/$USERNAME"
    if [ -f "$ACCOUNTS_FILE" ]; then
        if ! grep -q "Icon=" "$ACCOUNTS_FILE"; then
            echo "Icon=/var/lib/AccountsService/icons/$USERNAME" | sudo tee -a "$ACCOUNTS_FILE" > /dev/null
        fi
    else
        # Create AccountsService user file if it doesn't exist
        sed "s/USERNAME/$USERNAME/g" "$CONFIG_DIR/accountsservice-user.conf" | sudo tee "$ACCOUNTS_FILE" > /dev/null
    fi
    
    # Set avatar for user's home (for GNOME settings)
    USER_AVATAR="$HOME/.face"
    if [ ! -f "$USER_AVATAR" ]; then
        echo "Setting user avatar for GNOME..."
        cp "$AVATAR_SOURCE" "$USER_AVATAR"
        echo "GNOME avatar set"
    else
        echo "GNOME avatar already set"
    fi
else
    echo "Warning: Avatar source file not found at $AVATAR_SOURCE"
fi

echo "User configuration complete"