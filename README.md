# Arch Linux Workstation Setup

Automated setup for Arch Linux development workstations using bash scripts. **Goal: <30 minute restore time.**

## Quick Start

```bash
git clone https://github.com/dzannotti/ansible-arch.git
cd ansible-arch
./setup.sh
```

## What Gets Installed

### Base System
- Essential packages (base-devel, networking, tools)  
- Modern CLI tools (eza, bat, fd, ripgrep, etc.)
- Shell setup (zsh + starship prompt)

### Desktop Environment  
- **GNOME** on Wayland with X11 compatibility
- **PipeWire** audio system
- **GDM** display manager
- Essential GNOME applications

### Development Tools
- **Editors**: Neovim, VS Code
- **Languages**: Managed by `mise` (Node.js, Go, Rust)
- **Tools**: Git, GitHub CLI, Postman, Ghostty terminal
- **Modern CLI**: lazygit, git-delta, starship, zoxide

### Hardware Support
- NVIDIA drivers
- Bluetooth stack  
- AMD microcode
- Hardware monitoring tools

### Boot Experience
- **Limine** bootloader theming
- **Plymouth** boot splash screen
- **Tokyo Night** theme integration

## Structure

```
.
├── setup.sh              # Main script - runs all setup phases
├── scripts/               # Individual setup scripts  
│   ├── base.sh           # Base system packages
│   ├── desktop.sh        # GNOME desktop environment
│   ├── development.sh    # Development tools
│   ├── yay.sh            # AUR helper installation
│   └── ...               # Other setup phases
└── README.md             # This file
```

## Development

Each script in `scripts/` handles a specific setup phase. Scripts are called in sequence by `setup.sh`.

### Adding New Scripts
1. Create script in `scripts/` directory
2. Make it executable: `chmod +x scripts/new-script.sh`  
3. Add call to `setup.sh` in appropriate location

### Script Guidelines
- Use `set -euo pipefail` for error handling
- Test package availability before installation
- Use `yay -S --needed --noconfirm` for mixed official + AUR packages
- Add appropriate logging/output

## Why Bash?

- **Simpler**: No complex YAML syntax or modules
- **Faster**: Direct execution, no overhead  
- **Easier debugging**: See exactly what failed
- **More transparent**: Clear what each command does
- **No dependencies**: Just bash, pacman, and yay

## CI/CD

GitHub Actions automatically validates all bash scripts with ShellCheck and syntax checking.