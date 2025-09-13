#!/bin/bash
# Generate SSH key pair
set -euo pipefail

# Variables from config.sh (sourced by setup.sh)

# Set variables from config
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
SSH_EMAIL="$SETUP_EMAIL"

echo "Setting up SSH key..."

# Create .ssh directory if it doesn't exist
echo "Ensuring .ssh directory exists..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH.pub" ]; then
    echo "SSH key already exists at $SSH_KEY_PATH"
else
    echo "Generating SSH key..."
    
    # Generate ed25519 key without passphrase for automation
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "$SSH_EMAIL"
    
    echo "SSH key generated at $SSH_KEY_PATH"
fi

# Set proper permissions
chmod 600 "$SSH_KEY_PATH" 2>/dev/null || true
chmod 644 "$SSH_KEY_PATH.pub" 2>/dev/null || true

echo "SSH key setup complete"
echo ""
echo "Your public key:"
cat "$SSH_KEY_PATH.pub"
echo ""
echo "Add this key to your GitHub/GitLab account for repository access"