#!/bin/bash
# ZSH shell configuration with oh-my-zsh
set -euo pipefail

USERNAME="${USER}"

echo "Setting user shell to zsh..."
sudo chsh -s /bin/zsh "$USERNAME"

echo "Installing oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Use git clone method instead of curl for better transparency
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    
    # Copy the template .zshrc
    cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    
    echo "oh-my-zsh installed"
else
    echo "oh-my-zsh already installed"
fi

echo "Ensuring ~/.config directory exists..."
mkdir -p "$HOME/.config"

echo "Configuring starship prompt..."
if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
    {
        echo ''
        echo '# Initialize starship prompt'
        echo 'eval "$(starship init zsh)"'
    } >> "$HOME/.zshrc"
    echo "Starship configuration added"
else
    echo "Starship already configured"
fi

echo "Configuring zoxide integration..."
if ! grep -q "zoxide init zsh" "$HOME/.zshrc"; then
    {
        echo ''
        echo '# Initialize zoxide (smart cd)'
        echo 'eval "$(zoxide init zsh)"'
    } >> "$HOME/.zshrc"
    echo "Zoxide configuration added"
else
    echo "Zoxide already configured"
fi

echo "ZSH configuration complete"