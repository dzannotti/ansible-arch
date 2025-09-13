#!/bin/bash
# Development tools and environments
set -euo pipefail

echo "Installing development packages..."
yay -S --needed --noconfirm \
    python \
    python-pip \
    clang \
    llvm \
    gcc \
    tmux \
    jq \
    universal-ctags \
    shellcheck \
    gnupg \
    imagemagick \
    eza \
    bat \
    fd \
    fzf \
    ripgrep \
    mise \
    git-delta \
    lazygit \
    github-cli \
    starship \
    zoxide \
    neovim \
    visual-studio-code-bin \
    ghostty \
    postman-bin

echo "Installing runtime languages via mise..."
if [ ! -d ~/.local/share/mise/installs/node ]; then
    # Install latest versions as global defaults
    mise install node@latest
    mise install go@latest
    mise install rust@latest
    mise global node@latest go@latest rust@latest
    
    # Install JS package managers
    mise exec -- npm install -g pnpm bun
    
    echo "Runtime languages installed via mise"
else
    echo "Runtime languages already installed via mise"
fi

echo "Development environment installed"