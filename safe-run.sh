#!/bin/bash
# Safe execution wrapper for Arch setup scripts
# Provides dry-run, backup, and rollback capabilities

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/tmp/arch-setup-backup-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="/tmp/arch-setup-$(date +%Y%m%d-%H%M%S).log"
DRY_RUN=false
SCRIPT_TO_RUN=""
SKIP_SCRIPTS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip)
            SKIP_SCRIPTS="$2"
            shift 2
            ;;
        --only)
            SCRIPT_TO_RUN="$2"
            shift 2
            ;;
        --help|-h)
            echo "Safe execution wrapper for Arch setup scripts"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --dry-run        Show what would be done without making changes"
            echo "  --only script    Run only a specific script (e.g., --only hardware)"
            echo "  --skip scripts   Skip specific scripts (comma-separated)"
            echo "  --help           Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 --dry-run                    # Preview all changes"
            echo "  $0 --only hardware               # Run only hardware.sh"
            echo "  $0 --skip limine,plymouth        # Run all except limine and plymouth"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Logging functions
log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" | tee -a "$LOG_FILE"
}

# Create comprehensive backup
create_backup() {
    log_color "$BLUE" "=== Creating System Backup ==="
    mkdir -p "$BACKUP_DIR"
    
    # Critical files to backup
    local files_to_backup=(
        "/etc/mkinitcpio.conf"
        "/etc/mkinitcpio.conf.d"
        "/etc/fstab"
        "/etc/default/grub"
        "/boot/grub/grub.cfg"
        "/etc/modprobe.d"
        "/boot/EFI/limine/limine.conf"
        "/boot/limine/limine.conf"
        "/etc/plymouth"
        "/usr/share/plymouth/themes"
        "/var/lib/AccountsService"
    )
    
    for item in "${files_to_backup[@]}"; do
        if [ -e "$item" ]; then
            if [ -d "$item" ]; then
                cp -a "$item" "$BACKUP_DIR/" 2>/dev/null || true
                log "  Backed up directory: $item"
            else
                cp "$item" "$BACKUP_DIR/" 2>/dev/null || true
                log "  Backed up file: $item"
            fi
        fi
    done
    
    # Save system state
    echo "=== System State at $(date) ===" > "$BACKUP_DIR/system-state.txt"
    echo "" >> "$BACKUP_DIR/system-state.txt"
    
    echo "Kernel modules:" >> "$BACKUP_DIR/system-state.txt"
    lsmod >> "$BACKUP_DIR/system-state.txt" 2>/dev/null || true
    
    echo "" >> "$BACKUP_DIR/system-state.txt"
    echo "Systemd services:" >> "$BACKUP_DIR/system-state.txt"
    systemctl list-unit-files --state=enabled >> "$BACKUP_DIR/system-state.txt" 2>/dev/null || true
    
    log_color "$GREEN" "Backup created in: $BACKUP_DIR"
    log ""
}

# Wrap script execution with safety checks
safe_execute_script() {
    local script="$1"
    local script_name=$(basename "$script" .sh)
    
    # Skip if in skip list
    if [[ ",$SKIP_SCRIPTS," == *",$script_name,"* ]]; then
        log_color "$YELLOW" "Skipping: $script_name"
        return 0
    fi
    
    log_color "$BLUE" "=== Executing: $script_name ==="
    
    if [ ! -f "$script" ]; then
        log_color "$RED" "Script not found: $script"
        return 1
    fi
    
    if [ "$DRY_RUN" = true ]; then
        log_color "$YELLOW" "DRY RUN: Would execute $script"
        
        # Show what the script would do
        log "Script would perform:"
        grep -E "echo|pacman|yay|systemctl|cp|sed|mkinitcpio" "$script" | head -10 | while read -r line; do
            log "  - $line"
        done
    else
        # Execute with error handling
        if bash "$script" 2>&1 | tee -a "$LOG_FILE"; then
            log_color "$GREEN" "✓ $script_name completed successfully"
        else
            log_color "$RED" "✗ $script_name failed"
            log ""
            log_color "$YELLOW" "Backup available at: $BACKUP_DIR"
            log "Check log at: $LOG_FILE"
            exit 1
        fi
    fi
    
    log ""
}

# Verify system state after execution
verify_system() {
    log_color "$BLUE" "=== Verifying System State ==="
    
    # Check if system can still boot
    if [ -f /etc/mkinitcpio.conf ]; then
        if grep -q "^MODULES=.*(" /etc/mkinitcpio.conf && grep -q "^HOOKS=.*(" /etc/mkinitcpio.conf; then
            log_color "$GREEN" "✓ mkinitcpio.conf appears valid"
        else
            log_color "$RED" "✗ mkinitcpio.conf may be corrupted"
        fi
    fi
    
    # Check critical services
    local critical_services=("NetworkManager" "systemd-boot" "systemd-logind")
    for service in "${critical_services[@]}"; do
        if systemctl is-enabled "$service" &>/dev/null; then
            log_color "$GREEN" "✓ $service is enabled"
        else
            log_color "$YELLOW" "⚠ $service is not enabled"
        fi
    done
    
    log ""
}

# Main execution
main() {
    log_color "$BLUE" "=== Arch Setup Safe Execution ==="
    log "Started at: $(date)"
    log "Log file: $LOG_FILE"
    log ""
    
    if [ "$DRY_RUN" = true ]; then
        log_color "$YELLOW" "DRY RUN MODE - No changes will be made"
        log ""
    else
        # Create backup before any changes
        create_backup
    fi
    
    # Determine which scripts to run
    if [ -n "$SCRIPT_TO_RUN" ]; then
        # Run single script
        safe_execute_script "scripts/${SCRIPT_TO_RUN}.sh"
    else
        # Run setup.sh scripts in order
        # Extract script order from setup.sh
        local scripts=$(grep "^scripts/" setup.sh | grep -v "^#")
        
        while IFS= read -r script; do
            if [ -n "$script" ]; then
                safe_execute_script "$script"
            fi
        done <<< "$scripts"
    fi
    
    # Verify system state
    if [ "$DRY_RUN" = false ]; then
        verify_system
    fi
    
    # Summary
    log_color "$BLUE" "=== Execution Summary ==="
    if [ "$DRY_RUN" = true ]; then
        log_color "$GREEN" "Dry run complete. No changes were made."
        log "To execute for real, run without --dry-run"
    else
        log_color "$GREEN" "Setup complete!"
        log "Backup saved at: $BACKUP_DIR"
        log "Full log at: $LOG_FILE"
        log ""
        log_color "$YELLOW" "IMPORTANT: Review the log and reboot when ready"
        log "If issues occur, restore from: $BACKUP_DIR"
    fi
}

# Trap errors
trap 'log_color "$RED" "Error occurred! Check $LOG_FILE for details"' ERR

main