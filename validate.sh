#!/bin/bash
# Validation script to check system readiness and script safety

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== System Validation for Arch Setup Scripts ===${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check if running as regular user (not root)
check_user() {
    echo -n "Checking user permissions... "
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}✗ Running as root (dangerous!)${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓ Running as regular user${NC}"
    fi
}

# Check sudo access
check_sudo() {
    echo -n "Checking sudo access... "
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}✓ Sudo available${NC}"
    else
        echo -e "${YELLOW}⚠ Sudo may require password${NC}"
        ((WARNINGS++))
    fi
}

# Check critical files exist and are valid
check_critical_files() {
    echo ""
    echo -e "${BLUE}Critical System Files:${NC}"
    
    # mkinitcpio.conf
    echo -n "  /etc/mkinitcpio.conf... "
    if [ -f /etc/mkinitcpio.conf ]; then
        if grep -q "^MODULES=" /etc/mkinitcpio.conf && grep -q "^HOOKS=" /etc/mkinitcpio.conf; then
            echo -e "${GREEN}✓ Valid${NC}"
            
            # Show current configuration
            echo "    Current MODULES: $(grep "^MODULES=" /etc/mkinitcpio.conf)"
            echo "    Current HOOKS: $(grep "^HOOKS=" /etc/mkinitcpio.conf | cut -d= -f2 | cut -c1-80)..."
        else
            echo -e "${RED}✗ Invalid format${NC}"
            ((ERRORS++))
        fi
    else
        echo -e "${RED}✗ Not found${NC}"
        ((ERRORS++))
    fi
    
    # fstab
    echo -n "  /etc/fstab... "
    if [ -f /etc/fstab ]; then
        echo -e "${GREEN}✓ Found${NC}"
    else
        echo -e "${RED}✗ Not found${NC}"
        ((ERRORS++))
    fi
}

# Check for existing modifications
check_existing_mods() {
    echo ""
    echo -e "${BLUE}Checking Existing Modifications:${NC}"
    
    # NVIDIA modules
    echo -n "  NVIDIA modules in mkinitcpio... "
    if grep -q "nvidia" /etc/mkinitcpio.conf 2>/dev/null; then
        echo -e "${GREEN}✓ Already present${NC}"
    else
        echo -e "${YELLOW}⚠ Will be added${NC}"
        ((WARNINGS++))
    fi
    
    # Plymouth hook
    echo -n "  Plymouth hook in mkinitcpio... "
    if grep -q "plymouth" /etc/mkinitcpio.conf 2>/dev/null; then
        echo -e "${GREEN}✓ Already present${NC}"
    else
        echo -e "${YELLOW}⚠ Will be added${NC}"
        ((WARNINGS++))
    fi
    
    # Check for btrfs
    echo -n "  BTRFS in use... "
    if mount | grep -q "type btrfs"; then
        echo -e "${YELLOW}⚠ Yes (ensure btrfs hook is preserved)${NC}"
        ((WARNINGS++))
    else
        echo -e "${GREEN}✓ No${NC}"
    fi
}

# Check config files
check_config_files() {
    echo ""
    echo -e "${BLUE}Config Files:${NC}"
    
    local configs=(
        "configs/limine.conf"
        "configs/nvidia-modprobe.conf"
        "configs/plymouth-theme.plymouth"
        "configs/plymouth-theme.script"
        "configs/accountsservice-user.conf"
    )
    
    for config in "${configs[@]}"; do
        echo -n "  $config... "
        if [ -f "$config" ]; then
            echo -e "${GREEN}✓ Found${NC}"
        else
            echo -e "${RED}✗ Missing${NC}"
            ((ERRORS++))
        fi
    done
}

# Check system requirements
check_requirements() {
    echo ""
    echo -e "${BLUE}System Requirements:${NC}"
    
    # Check for required commands
    local commands=("pacman" "sed" "grep" "systemctl")
    for cmd in "${commands[@]}"; do
        echo -n "  $cmd... "
        if command -v "$cmd" &> /dev/null; then
            echo -e "${GREEN}✓ Available${NC}"
        else
            echo -e "${RED}✗ Not found${NC}"
            ((ERRORS++))
        fi
    done
    
    # Check if yay needs to be installed
    echo -n "  yay... "
    if command -v yay &> /dev/null; then
        echo -e "${GREEN}✓ Already installed${NC}"
    else
        echo -e "${YELLOW}⚠ Will be installed${NC}"
        ((WARNINGS++))
    fi
}

# Check for running display manager
check_display_manager() {
    echo ""
    echo -e "${BLUE}Display Manager Status:${NC}"
    
    for dm in gdm sddm lightdm; do
        echo -n "  $dm... "
        if systemctl is-active "$dm" &>/dev/null; then
            echo -e "${YELLOW}⚠ Currently running${NC}"
            ((WARNINGS++))
        elif systemctl is-enabled "$dm" &>/dev/null; then
            echo -e "${YELLOW}⚠ Enabled${NC}"
            ((WARNINGS++))
        else
            echo -e "${GREEN}✓ Not active${NC}"
        fi
    done
}

# Main validation
main() {
    check_user
    check_sudo
    check_critical_files
    check_existing_mods
    check_config_files
    check_requirements
    check_display_manager
    
    # Summary
    echo ""
    echo -e "${BLUE}=== Validation Summary ===${NC}"
    
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}Found $ERRORS error(s) that must be fixed${NC}"
        echo "Please resolve these issues before running the setup"
        exit 1
    elif [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Found $WARNINGS warning(s)${NC}"
        echo "Review these warnings and proceed with caution"
        echo ""
        echo "Recommended steps:"
        echo "1. Run: ./test.sh --dry-run"
        echo "2. Run: ./safe-run.sh --dry-run"
        echo "3. Run individual scripts with: ./safe-run.sh --only <script>"
        exit 0
    else
        echo -e "${GREEN}System ready for setup!${NC}"
        echo ""
        echo "Next steps:"
        echo "1. Run: ./safe-run.sh --dry-run  # Preview changes"
        echo "2. Run: ./safe-run.sh            # Execute setup"
        exit 0
    fi
}

main