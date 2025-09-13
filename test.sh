#!/bin/bash
# Test framework for Arch setup scripts
# Run with --dry-run to simulate without making changes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test mode flag
DRY_RUN=false
VERBOSE=false
TEST_SPECIFIC=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --test)
            TEST_SPECIFIC="$2"
            shift 2
            ;;
        *)
            echo "Usage: $0 [--dry-run] [--verbose] [--test script_name]"
            echo "  --dry-run    Simulate changes without modifying system"
            echo "  --verbose    Show detailed output"
            echo "  --test name  Test specific script (e.g., hardware, limine)"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}=== Arch Setup Script Testing Framework ===${NC}"
echo ""

# Function to test a script
test_script() {
    local script="$1"
    local script_name=$(basename "$script" .sh)
    
    echo -e "${YELLOW}Testing: $script_name${NC}"
    
    # Check if script exists
    if [ ! -f "$script" ]; then
        echo -e "${RED}  ✗ Script not found: $script${NC}"
        return 1
    fi
    
    # Check if script is executable
    if [ ! -x "$script" ]; then
        echo -e "${RED}  ✗ Script not executable: $script${NC}"
        return 1
    fi
    
    # Syntax check
    if bash -n "$script" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Syntax check passed${NC}"
    else
        echo -e "${RED}  ✗ Syntax error in $script${NC}"
        return 1
    fi
    
    # ShellCheck if available
    if command -v shellcheck &> /dev/null; then
        if shellcheck "$script" 2>/dev/null; then
            echo -e "${GREEN}  ✓ ShellCheck passed${NC}"
        else
            echo -e "${RED}  ✗ ShellCheck warnings/errors${NC}"
        fi
    fi
    
    # Check for dangerous operations
    check_dangerous_operations "$script"
    
    # Check for required config files
    check_config_files "$script"
    
    echo ""
}

# Check for potentially dangerous operations
check_dangerous_operations() {
    local script="$1"
    local warnings=0
    
    # Check for operations that modify critical files
    if grep -q "mkinitcpio.conf" "$script"; then
        echo -e "${YELLOW}  ⚠ Modifies mkinitcpio.conf (kernel boot)${NC}"
        ((warnings++))
    fi
    
    if grep -q "/etc/fstab" "$script"; then
        echo -e "${YELLOW}  ⚠ Modifies /etc/fstab (mount points)${NC}"
        ((warnings++))
    fi
    
    if grep -q "systemctl.*enable" "$script"; then
        echo -e "${YELLOW}  ⚠ Enables system services${NC}"
        ((warnings++))
    fi
    
    if grep -q "mkinitcpio -P" "$script"; then
        echo -e "${YELLOW}  ⚠ Rebuilds initramfs${NC}"
        ((warnings++))
    fi
    
    if grep -q "/boot" "$script"; then
        echo -e "${YELLOW}  ⚠ Modifies boot configuration${NC}"
        ((warnings++))
    fi
    
    if [ $warnings -eq 0 ]; then
        echo -e "${GREEN}  ✓ No critical system modifications detected${NC}"
    fi
}

# Check for required config files
check_config_files() {
    local script="$1"
    local missing=0
    
    # Extract config files referenced in script
    local config_files=$(grep -o '\$CONFIG_DIR/[^"]*' "$script" 2>/dev/null | sed 's/$CONFIG_DIR\//configs\//g' | sort -u)
    
    if [ -n "$config_files" ]; then
        echo "  Config files used:"
        while IFS= read -r config; do
            if [ -f "$config" ]; then
                echo -e "    ${GREEN}✓${NC} $config"
            else
                echo -e "    ${RED}✗${NC} $config (missing)"
                ((missing++))
            fi
        done <<< "$config_files"
        
        if [ $missing -gt 0 ]; then
            echo -e "${RED}  ✗ Missing $missing config file(s)${NC}"
        fi
    fi
}

# Backup critical files before testing
backup_critical_files() {
    local backup_dir="/tmp/arch-setup-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    echo -e "${BLUE}Creating backups in $backup_dir${NC}"
    
    # Backup critical files if they exist
    for file in /etc/mkinitcpio.conf /etc/fstab /etc/default/grub; do
        if [ -f "$file" ]; then
            cp "$file" "$backup_dir/" 2>/dev/null || true
            echo "  Backed up: $file"
        fi
    done
    
    echo -e "${GREEN}Backup complete${NC}"
    echo ""
}

# Test file modifications without applying
test_modifications() {
    echo -e "${BLUE}=== Testing File Modifications ===${NC}"
    echo ""
    
    # Test mkinitcpio modifications
    if [ -f /etc/mkinitcpio.conf ]; then
        echo "Current mkinitcpio.conf MODULES line:"
        grep "^MODULES=" /etc/mkinitcpio.conf || echo "  No MODULES line found"
        echo ""
        
        echo "Current mkinitcpio.conf HOOKS line:"
        grep "^HOOKS=" /etc/mkinitcpio.conf || echo "  No HOOKS line found"
        echo ""
    fi
    
    # Test if NVIDIA modules would be added correctly
    echo "Testing NVIDIA module addition (simulation):"
    if grep -q "MODULES=.*nvidia" /etc/mkinitcpio.conf 2>/dev/null; then
        echo -e "${GREEN}  ✓ NVIDIA modules already present${NC}"
    else
        echo -e "${YELLOW}  Would add: nvidia nvidia_modeset nvidia_uvm nvidia_drm${NC}"
    fi
    echo ""
    
    # Test if Plymouth hook would be added correctly
    echo "Testing Plymouth hook addition (simulation):"
    if grep -q "HOOKS=.*plymouth" /etc/mkinitcpio.conf 2>/dev/null; then
        echo -e "${GREEN}  ✓ Plymouth hook already present${NC}"
    else
        echo -e "${YELLOW}  Would add: plymouth (after udev)${NC}"
    fi
    echo ""
}

# Main testing flow
main() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo ""
    fi
    
    # Create backups if not in dry run
    if [ "$DRY_RUN" = false ]; then
        backup_critical_files
    fi
    
    # Test specific script or all
    if [ -n "$TEST_SPECIFIC" ]; then
        test_script "scripts/${TEST_SPECIFIC}.sh"
    else
        # Test critical scripts
        echo -e "${BLUE}=== Testing Critical Scripts ===${NC}"
        echo ""
        
        for script in scripts/hardware.sh scripts/limine.sh scripts/plymouth.sh; do
            if [ -f "$script" ]; then
                test_script "$script"
            fi
        done
    fi
    
    # Test modifications
    test_modifications
    
    # Summary
    echo -e "${BLUE}=== Test Summary ===${NC}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${GREEN}Dry run complete. No changes were made.${NC}"
    else
        echo -e "${YELLOW}Testing complete. Review the output above before running setup.sh${NC}"
    fi
    
    echo ""
    echo "Recommendations:"
    echo "1. Run with --dry-run first to see what would change"
    echo "2. Review all warnings about critical file modifications"
    echo "3. Ensure you have a way to boot from USB if something goes wrong"
    echo "4. Consider running individual scripts rather than the full setup.sh"
}

main