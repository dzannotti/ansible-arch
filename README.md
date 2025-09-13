# Ansible Arch Linux Setup

Personal Ansible playbook for automated Arch Linux workstation configuration.

> **🚧 Migration to Bash in Progress**: This branch (`bash-conversion`) is incrementally converting the Ansible setup to bash scripts. The `tasks/` directory contains the original Ansible tasks for reference, while `scripts/` will contain the equivalent bash scripts.

## Quick Start

### Current (Ansible)
```bash
make run
```

### Future (Bash - Work in Progress)
```bash
./setup.sh
```

## Structure

```
.
├── site.yml              # Main Ansible playbook
├── setup.sh              # 🚧 NEW: Main bash script
├── tasks/                # Ansible tasks (reference for conversion)
├── scripts/               # 🚧 NEW: Bash scripts (work in progress)
├── config.yml            # Configuration overrides
├── Makefile              # Ansible convenience commands
└── requirements.yml      # Ansible dependencies
```

## Migration Progress

- [x] Main setup.sh structure created
- [x] GitHub workflow for bash script validation
- [ ] scripts/update.sh (from tasks/update.yml)
- [ ] scripts/base.sh (from tasks/base.yml)
- [ ] scripts/multilib.sh (from tasks/multilib.yml)
- [ ] scripts/yay.sh (from tasks/yay.yml)
- [ ] scripts/audio.sh (from tasks/audio.yml)
- [ ] scripts/hardware.sh (from tasks/hardware.yml)
- [ ] scripts/display.sh (from tasks/display.yml)
- [ ] scripts/desktop.sh (from tasks/desktop.yml)
- [ ] scripts/development.sh (from tasks/development.yml)
- [ ] scripts/applications.sh (from tasks/applications.yml)
- [ ] scripts/gaming.sh (from tasks/gaming.yml)
- [ ] scripts/fonts.sh (from tasks/fonts.yml)
- [ ] scripts/swap.sh (from tasks/swap.yml)
- [ ] scripts/other-services.sh (from tasks/other-services.yml)
- [ ] scripts/zsh.sh (from tasks/zsh.yml)
- [ ] scripts/genssh.sh (from tasks/genssh.yml)
- [ ] scripts/git-config.sh (from tasks/git-config.yml)
- [ ] scripts/gdm.sh (from tasks/gdm.yml)
- [ ] scripts/theming.sh (from tasks/theming.yml)
- [ ] scripts/limine.sh (from tasks/limine.yml)
- [ ] scripts/plymouth.sh (from tasks/plymouth.yml)
- [ ] scripts/upgrade.sh (from tasks/upgrade.yml)
- [ ] Test complete bash setup
- [ ] Remove Ansible dependencies

## Conversion Guidelines

When converting from Ansible tasks to bash scripts:

1. **Package Installation**: 
   ```bash
   # Use yay for mixed official + AUR packages (handles sudo properly)
   yay -S --needed --noconfirm package1 package2 aur-package
   ```

2. **Error Handling**: 
   ```bash
   set -euo pipefail  # At top of each script
   ```

3. **Service Management**:
   ```bash
   sudo systemctl enable service-name
   systemctl --user enable user-service
   ```

4. **Reference Original**: Always check the corresponding `tasks/*.yml` file for the exact logic

## Current Ansible Features

- **Automated package installation** (base, dev, desktop)
- **AUR support** via yay
- **Desktop environment** (GNOME on Wayland, GDM)
- **Development tools** (neovim, vscode, various languages via mise)
- **System services** (pipewire, bluetooth, etc.)
- **Hardware support** (NVIDIA, bluetooth)
- **Boot customization** (Limine, Plymouth)

## Usage

### Ansible (Current)
```bash
make help        # Show all available commands
make lint        # Run ansible-lint and yamllint
make check       # Syntax check
make run         # Run the playbook
make debug       # Run with verbose output
make dry-run     # Test run without making changes
```

### Configuration
Edit `config.yml` to override defaults:

```yaml
# Example overrides
enable_nvidia: false
enable_gaming: true
swapfile_size: 16G
```