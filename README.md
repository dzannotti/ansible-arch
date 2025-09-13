# Arch Linux Workstation Setup

Fast, automated setup for Arch Linux development workstations. **Goal: <30 minute restore time.**

## Quick Start

```bash
# Clone and run
git clone <repo-url>
cd ansible-arch
./setup.sh
```

## Configuration

Copy and modify the config file:
```bash
cp config.sh.example config.sh
# Edit config.sh with your preferences
./setup.sh
```

### Key Options
- `ENABLE_NVIDIA=true/false` - NVIDIA driver support
- `ENABLE_DESKTOP=true/false` - GNOME desktop environment  
- `ENABLE_DEVELOPMENT=true/false` - Development tools & IDEs
- `ENABLE_GAMING=true/false` - Steam, gaming packages

## What Gets Installed

### Base System
- Essential packages (base-devel, networking, tools)
- Modern CLI tools (eza, bat, fd, ripgrep, etc.)
- Shell setup (zsh + starship prompt)

### Desktop Environment (if enabled)
- **GNOME** on Wayland with X11 compatibility
- **PipeWire** audio system
- **GDM** display manager
- Essential GNOME applications

### Development Tools (if enabled)
- **Editors**: Neovim, VS Code
- **Languages**: Managed by `mise` (Node.js, Go, Rust)
- **Tools**: Git, GitHub CLI, Postman, Ghostty terminal
- **Modern CLI**: lazygit, git-delta, starship, zoxide

### Hardware Support
- NVIDIA drivers (if enabled)
- Bluetooth stack (if enabled)
- AMD microcode
- Hardware monitoring tools

## Scripts Structure

- `setup.sh` - Main orchestration script
- `scripts/01-base.sh` - Base system packages
- `scripts/04-desktop.sh` - GNOME desktop environment
- `scripts/07-development.sh` - Development tools
- `scripts/09-nvidia.sh` - NVIDIA drivers
- etc.

## Advantages over Ansible

- **Simpler**: No complex YAML syntax or modules
- **Faster**: Direct bash execution, no overhead
- **Easier debugging**: See exactly what failed
- **More transparent**: Clear what each command does
- **No dependencies**: Just bash, pacman, and yay

## Testing

```bash
# Dry run (see what would be installed)
./setup.sh --dry-run

# Run specific script
source scripts/01-base.sh
```

## Troubleshooting

- **Package conflicts**: Check `pacman -Qm` for AUR packages
- **Service failures**: Check `systemctl status <service>`
- **Missing packages**: Check if moved from AUR to official repos

## Migration from Ansible

This replaces the previous Ansible-based setup with equivalent functionality but simpler maintenance and faster execution.