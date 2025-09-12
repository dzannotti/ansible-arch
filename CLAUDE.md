# Ansible Arch Setup - Claude AI Assistant Guide

## Project Goals

This Ansible playbook is designed to:
1. **Quickly restore a developer workstation** after a fresh Arch Linux install (target: <30 minutes)
2. **Maintain idempotency** - can be run multiple times safely
3. **Stay simple and maintainable** - single-user focused, no corporate overhead
4. **Be modular** - enable/disable features via config flags

The setup should be able to take you from a minimal Arch install to a fully configured development environment with Hyprland, all your tools, and dotfiles configured.

## Testing Commands

When testing this playbook:
```bash
# Syntax check first
make check

# Run linting
make lint

# Dry run to see what would change
make dry-run

# Full run
make run

# Debug mode if something fails
make debug
```

## Task File Structure

### Core System
These run first and set up the foundation:

- **base.yml** - Essential packages (kernel, networking, basic tools)
  - Core system: base, base-devel, linux, sudo
  - Networking: NetworkManager, SSH
  - Basic tools: git, wget, nano

- **filesystem.yml** - Disk and filesystem utilities
  - NTFS, exFAT support
  - Compression tools (p7zip, unzip)

- **cli.yml** - Enhanced terminal experience
  - Modern CLI replacements: eza (ls), bat (cat), fd (find), ripgrep (grep)
  - Shell enhancements: zsh, oh-my-zsh, powerlevel10k
  - System monitoring: htop, btop, fastfetch
  - Utilities: tmux, fzf, stow, pass

- **audio.yml** - PipeWire audio stack
  - Full PipeWire setup with ALSA/Pulse/JACK compatibility
  - Audio control: pavucontrol

- **hardware.yml** - Hardware drivers
  - NVIDIA drivers (when enable_nvidia=true)
  - Bluetooth stack (when enable_bluetooth=true)

### Display & Desktop
Desktop environment setup:

- **display.yml** - Display server components
  - Xorg/XWayland compatibility layers
  - Wayland core protocols and tools

- **desktop.yml** - Hyprland and components
  - Hyprland window manager and utilities
  - Desktop components: waybar, wofi, notifications
  - File manager: Nautilus
  - Theming tools and cursor themes

### Applications

- **development.yml** - Programming environments
  - Languages: Python, Node.js, Go, Rust
  - Editors: Neovim, VS Code
  - Tools: Ghostty terminal, GitKraken

- **applications.yml** - User applications
  - Browsers: Firefox, Chrome, Brave
  - Media: Spotify, mpv, yt-dlp
  - Communication: Ferdium
  - Password manager integration

- **fonts.yml** - Complete font collection
  - Programming fonts: JetBrains Mono, Fira Code, Cascadia
  - System fonts: Noto, Roboto, Ubuntu
  - Icon fonts: Font Awesome, Material Design

### Legacy/To Be Reorganized

These files still exist but should be reviewed/consolidated:

- **other-packages.yml** - Miscellaneous packages (needs cleanup)
- **other-services.yml** - Service configurations
- **chaotic-aur.yml** - Chaotic-AUR repository setup
- **multilib.yml** - 32-bit library support
- **swap.yml** - Swap file configuration
- **sddm.yml/sddm-theme.yml** - SDDM display manager (to be replaced with GDM)
- **Various user config** - zsh, git, ssh, dotfiles

## Package Management Notes

### Duplicates Removed
The following duplicate packages have been cleaned up:
- ghostty (was in both dev-packages and other-packages)
- tmux (was in both dev-packages and other-packages)
- linux-headers (was in other-packages and nvidiagpu)
- ntfs-3g (was in base-packages and other-packages)
- pipewire-pulse (was in pipewire and bluetooth)
- qt5-x11extras (duplicate within xorg.yml)
- bibata-cursor-theme-bin (duplicate within sddm-theme.yml)

### Package Installation Methods
- **pacman** - Used for official Arch repository packages
- **kewlfft.aur.aur** - Used for AUR packages via yay

## Configuration Flags

In `config.yml` you can set:
```yaml
# System features
enable_nvidia: true/false
enable_bluetooth: true/false
enable_desktop: true/false
enable_development: true/false
enable_sddm: true/false  # Will be replaced with enable_gdm

# System settings
swapfile_size: 8G
update: true  # Run system update at start
generate_ssh_key: true
```

## Next Steps / TODO

1. **Replace SDDM with GDM** - Remove SDDM tasks, create GDM configuration
2. **Consolidate other-packages.yml** - Move packages to appropriate category files
3. **Review other-services.yml** - Determine which services belong where
4. **Create role structure** - Eventually migrate to proper Ansible roles when complexity grows
5. **Add vault support** - For sensitive data like SSH keys, passwords
6. **Add backup/restore** - For user data and configurations

## Common Issues and Solutions

### Package conflicts
- Always check for package conflicts between official repos and AUR
- Use `state: absent` to remove conflicting packages before installing alternatives

### Service management
- User services need `scope: user` in systemd module
- System services need `become: true`

### AUR packages
- Requires yay to be installed first
- Use `extra_args` for answering prompts automatically

## Development Workflow

When adding new packages or features:
1. Determine the appropriate category file (or create a new one)
2. Add packages to the correct section
3. Test with `make dry-run` first
4. Update this documentation if adding new categories
5. Run `make lint` before committing