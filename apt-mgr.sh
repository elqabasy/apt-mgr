#!/bin/bash

# apt-mgr - Professional APT Package Backup, Restore and Cleanup Tool
# Version: 1.1.0
# Author: Your Name
# License: MIT

set -euo pipefail

# Configuration
VERSION="1.1.0"
BACKUP_DIR="${HOME}/.apt-mgr/backups"
CONFIG_DIR="${HOME}/.apt-mgr"
LOG_FILE="${CONFIG_DIR}/apt-mgr.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect distribution
detect_distro() {
    if grep -qi "kali" /etc/os-release; then
        echo "kali"
    elif grep -qi "ubuntu" /etc/os-release; then
        echo "ubuntu"
    elif grep -qi "debian" /etc/os-release; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Initialize directories
init_dirs() {
    mkdir -p "$BACKUP_DIR" "$CONFIG_DIR"
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" >> "$LOG_FILE"
}

# Print colored output
info() { echo -e "${BLUE}[INFO]${NC} $*"; log "INFO: $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; log "SUCCESS: $*"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; log "WARNING: $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; log "ERROR: $*"; }

# Check if running as root when needed
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error "This operation requires root privileges. Please run with sudo."
        exit 1
    fi
}

# Generate backup filename
generate_backup_name() {
    local prefix="${1:-apt-backup}"
    echo "${BACKUP_DIR}/${prefix}-$(date +%Y%m%d-%H%M%S).txt"
}

# Backup function
backup_packages() {
    local filename="${1:-}"
    local minimal="${2:-false}"
    
    if [[ -z "$filename" ]]; then
        filename=$(generate_backup_name)
    else
        filename="${BACKUP_DIR}/${filename}"
    fi
    
    info "Starting package backup..."
    
    if [[ "$minimal" == "true" ]]; then
        # Only user-installed packages (excludes dependencies)
        apt-mark showmanual | sort > "$filename"
        success "Minimal backup created: $(basename "$filename")"
        info "Packages saved: $(wc -l < "$filename")"
    else
        # All installed packages with versions
        dpkg-query -f '${Package}=${Version}\n' -W > "$filename"
        success "Full backup created: $(basename "$filename")"
        info "Packages saved: $(wc -l < "$filename")"
    fi
    
    echo "Backup location: $filename"
}

# Restore function
restore_packages() {
    local filename="${1:-}"
    local dry_run="${2:-false}"
    
    if [[ -z "$filename" ]]; then
        error "Please specify a backup file to restore from"
        echo "Available backups:"
        ls -1 "$BACKUP_DIR"/*.txt 2>/dev/null || echo "No backups found"
        exit 1
    fi
    
    if [[ ! -f "$filename" ]]; then
        # Check if file exists in backup directory
        filename="${BACKUP_DIR}/${filename}"
        if [[ ! -f "$filename" ]]; then
            error "Backup file not found: $filename"
            exit 1
        fi
    fi
    
    check_root
    
    info "Preparing to restore packages from: $(basename "$filename")"
    
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - Packages that would be installed:"
        cat "$filename"
        return 0
    fi
    
    # Update package list first
    info "Updating package lists..."
    apt-get update
    
    # Install packages
    info "Installing packages..."
    if grep -q "=" "$filename"; then
        # Backup with versions
        xargs -a "$filename" apt-get install -y
    else
        # Backup without versions
        xargs -a "$filename" apt-get install -y
    fi
    
    success "Package restoration completed"
}

# Find leftover configuration files (deborphan alternative)
find_leftover_configs() {
    info "Searching for leftover configuration files..."
    dpkg-query -W -f='${Package} ${Status}\n' | \
    grep "deinstall ok config-files" | \
    cut -d " " -f 1
}

# Clean Kali-specific packages
clean_kali_packages() {
    local dry_run="${1:-false}"
    
    info "Checking for Kali Linux specific cleanup..."
    
    # Common Kali packages that might be safe to remove if not needed
    local kali_packages=(
        "kali-linux-default"
        "kali-tools-*"
        "kali-desktop-*"
    )
    
    for pkg in "${kali_packages[@]}"; do
        if dpkg -l | grep -q "$pkg"; then
            if [[ "$dry_run" == "true" ]]; then
                echo "Would check: $pkg"
            else
                info "Found Kali package: $pkg"
            fi
        fi
    done
}

# Enhanced cleanup function
clean_packages() {
    local aggressive="${1:-false}"
    local dry_run="${2:-false}"
    local distro=$(detect_distro)
    
    check_root
    
    info "Starting system cleanup (Detected: $distro)..."
    
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - What would be cleaned:"
        echo "=== Package cache ==="
        du -sh /var/cache/apt/archives
        
        echo "=== Orphaned packages ==="
        apt-get autoremove --dry-run
        
        echo "=== Leftover configuration files ==="
        local leftover_count=$(find_leftover_configs | wc -l)
        echo "Found $leftover_count packages with leftover configs"
        find_leftover_configs
        
        if [[ "$aggressive" == "true" ]]; then
            echo "=== Old log files ==="
            find /var/log -name "*.log" -type f -mtime +30 | wc -l | \
                xargs echo "Log files older than 30 days:"
            
            echo "=== Temporary files ==="
            find /tmp /var/tmp -type f -atime +7 | wc -l | \
                xargs echo "Temporary files unused for 7 days:"
            
            if [[ "$distro" == "kali" ]]; then
                echo "=== Kali-specific packages check ==="
                clean_kali_packages true
            fi
        fi
        return 0
    fi
    
    # Clean package cache
    info "Cleaning package cache..."
    apt-get clean
    
    # Remove orphaned packages
    info "Removing orphaned packages..."
    apt-get autoremove -y
    
    # Clean partial downloads
    info "Cleaning partial downloads..."
    apt-get autoclean -y
    
    if [[ "$aggressive" == "true" ]]; then
        warning "Running aggressive cleanup..."
        
        # Remove leftover configuration files
        local leftover_packages=$(find_leftover_configs)
        if [[ -n "$leftover_packages" ]]; then
            info "Removing leftover configuration files..."
            echo "$leftover_packages" | xargs -r dpkg --purge
        fi
        
        # Clean old log files
        info "Cleaning old log files..."
        find /var/log -name "*.log" -type f -mtime +30 -delete 2>/dev/null || true
        
        # Clean temporary files
        info "Cleaning temporary files..."
        find /tmp /var/tmp -type f -atime +7 -delete 2>/dev/null || true
        
        # Distribution-specific cleaning
        if [[ "$distro" == "kali" ]]; then
            clean_kali_packages false
        fi
        
        # Clean package lists and refresh
        info "Refreshing package lists..."
        rm -rf /var/lib/apt/lists/*
        apt-get update
    fi
    
    # Final cleanup verification
    info "Final cleanup verification..."
    local final_cache_size=$(du -sh /var/cache/apt/archives | cut -f1)
    success "Cleanup completed. Final cache size: $final_cache_size"
}

# Status function
show_status() {
    info "System Package Status"
    echo "=== Disk Usage ==="
    df -h / | tail -1 | awk '{print "Available: " $4 "/" $2 " (" $5 " used)"}'
    
    echo "=== APT Cache ==="
    du -sh /var/cache/apt/archives
    
    echo "=== Package Statistics ==="
    echo "Installed packages: $(dpkg-query -f '.\n' -W | wc -l)"
    echo "User-installed packages: $(apt-mark showmanual | wc -l)"
    
    echo "=== Cleanup Potential ==="
    local orphan_count=$(apt-get --dry-run autoremove | grep -oP '^Remv \K[^ ]+' | wc -l)
    local config_count=$(find_leftover_configs | wc -l)
    echo "Orphaned packages: $orphan_count"
    echo "Leftover configs: $config_count"
    
    # Show distribution
    local distro=$(detect_distro)
    echo "Distribution: $distro"
}

# Analyze function
analyze_packages() {
    local min_size="${1:-0}"
    
    info "Analyzing package sizes..."
    
    echo "Largest installed packages:"
    dpkg-query -Wf '${Installed-Size}\t${Package}\n' | \
    awk -v min="$min_size" '$1 > min' | \
    sort -nr | \
    head -20 | \
    awk '{
        size = $1 / 1024;
        if (size >= 1024) 
            printf "%.1f GB\t%s\n", size/1024, $2;
        else 
            printf "%.1f MB\t%s\n", size, $2;
    }'
    
    # Show top 10 largest files in /var/cache/apt
    echo ""
    echo "Largest files in APT cache:"
    find /var/cache/apt -type f -exec du -sh {} + 2>/dev/null | sort -hr | head -10
}

# Show usage
show_help() {
    cat << EOF
apt-mgr v${VERSION} - APT Package Backup, Restore and Cleanup Tool

USAGE:
    apt-mgr [COMMAND] [OPTIONS]

COMMANDS:
    backup [filename] [--minimal]    Backup installed packages
    restore [filename] [--dry-run]   Restore packages from backup
    clean [--aggressive] [--dry-run] Clean system packages
    status                           Show system status
    analyze [--size SIZE]            Analyze package sizes
    help                             Show this help message
    version                          Show version

EXAMPLES:
    apt-mgr backup                           # Full backup
    apt-mgr backup --minimal                 # Only user-installed packages
    apt-mgr restore my-backup.txt            # Restore packages
    apt-mgr clean                            # Safe cleanup
    apt-mgr clean --aggressive --dry-run     # Preview aggressive cleanup
    apt-mgr analyze --size 100MB             # Find packages >100MB

BACKUP FILES:
    Backups are stored in: ${BACKUP_DIR}
EOF
}

# Main script execution
main() {
    init_dirs
    
    local command="${1:-help}"
    shift
    
    case "$command" in
        backup)
            local filename=""
            local minimal="false"
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --minimal) minimal="true" ;;
                    *) filename="$1" ;;
                esac
                shift
            done
            
            backup_packages "$filename" "$minimal"
            ;;
            
        restore)
            local filename=""
            local dry_run="false"
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --dry-run) dry_run="true" ;;
                    *) filename="$1" ;;
                esac
                shift
            done
            
            restore_packages "$filename" "$dry_run"
            ;;
            
        clean)
            local aggressive="false"
            local dry_run="false"
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --aggressive) aggressive="true" ;;
                    --dry-run) dry_run="true" ;;
                esac
                shift
            done
            
            clean_packages "$aggressive" "$dry_run"
            ;;
            
        status)
            show_status
            ;;
            
        analyze)
            local min_size=0
            
            while [[ $# -gt 0 ]]; do
                case $1 in
                    --size)
                        shift
                        local size="${1//[^0-9]/}"
                        local unit="${1//[0-9]/}"
                        case "$unit" in
                            GB|gb) min_size=$((size * 1024 * 1024)) ;;
                            MB|mb) min_size=$((size * 1024)) ;;
                            KB|kb) min_size="$size" ;;
                            *) min_size="$size" ;;
                        esac
                        ;;
                esac
                shift
            done
            
            analyze_packages "$min_size"
            ;;
            
        help)
            show_help
            ;;
            
        version)
            echo "apt-mgr v${VERSION}"
            ;;
            
        *)
            error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
