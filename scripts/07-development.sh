#!/bin/bash
# Development tools and environments

# All development packages (official + AUR mixed)
DEV_PACKAGES=(
    # Languages and runtimes
    python python-pip
    
    # Compilers and build tools
    clang llvm gcc
    
    # Development tools
    tmux jq universal-ctags shellcheck
    gnupg imagemagick
    
    # Modern CLI alternatives
    eza bat fd fzf ripgrep
    
    # Version management
    mise  # Universal runtime manager
    
    # Git and development tools
    git-delta lazygit github-cli
    starship zoxide
    
    # Editors and IDEs
    neovim
    visual-studio-code-bin  # AUR
    ghostty
    
    # API/Development tools
    postman-bin  # AUR
)

install_packages "development tools" "${DEV_PACKAGES[@]}"

# Setup mise for runtime management
if command -v mise &> /dev/null; then
    log_info "Setting up mise runtimes..."
    
    # Install latest versions as global defaults
    mise install node@latest || log_warning "Failed to install Node.js"
    mise install go@latest || log_warning "Failed to install Go"
    mise install rust@latest || log_warning "Failed to install Rust"
    
    # Set global versions
    mise global node@latest go@latest rust@latest || log_warning "Failed to set global versions"
    
    # Install JS package managers
    if mise which node &> /dev/null; then
        mise exec -- npm install -g pnpm bun || log_warning "Failed to install JS package managers"
    fi
    
    log_success "Mise runtimes configured"
else
    log_warning "mise not found, skipping runtime setup"
fi