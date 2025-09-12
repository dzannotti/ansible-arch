# Ansible Arch Linux Setup

Personal Ansible playbook for automated Arch Linux workstation configuration.

## Quick Start

```bash
# Install dependencies and run
make run

# Or manually:
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml
```

## Structure

```
.
├── site.yml              # Main playbook
├── config.yml            # Your personal overrides
├── default.config.yml    # Default settings
├── requirements.yml      # Ansible Galaxy dependencies
├── ansible.cfg           # Ansible configuration
├── Makefile             # Convenience commands
├── tasks/               # Task files (to be migrated to roles)
├── roles/               # Organized roles (future structure)
│   ├── system/         # Base system configuration
│   ├── desktop/        # Desktop environment
│   ├── development/    # Dev tools and setup
│   └── services/       # System services
└── inventories/        # Inventory files
    └── production/
        └── hosts.yml

```

## Usage

### Common Commands

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

### Testing in VM

1. Set up fresh Arch VM
2. Clone this repo
3. Run: `make run`

## Features

- **Automated package installation** (base, dev, desktop)
- **AUR support** via yay
- **Desktop environment** (Wayland, GDM)
- **Development tools** (neovim, vscode, various languages)
- **System services** (pipewire, bluetooth, etc.)
- **Dotfiles management** via stow
- **Hardware support** (NVIDIA, bluetooth)

## CI/CD

GitHub Actions runs linting on every push/PR to maintain code quality.