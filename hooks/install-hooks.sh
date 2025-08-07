#!/bin/bash
# Git Hooks Installation Script for Cursor Rules Manager
# Installs Git hooks for automated cursor rules deployment

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_RULES_DIR="$(dirname "$SCRIPT_DIR")"
GIT_HOOKS_DIR="$CURSOR_RULES_DIR/.git/hooks"
LOG_FILE="/Users/alexcaldwell/the-warehouse/logs/cursor-rules-manager/install-hooks.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# 🔥 GLOBAL EXECUTION TRACKING - Enhanced logging with global tracking!
source "/Users/alexcaldwell/the-warehouse/logs/global-execution-tracker/lib/global-logging.sh"

# Logging functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INSTALL-HOOKS] $1" | tee -a "$LOG_FILE"
}

log_info() {
    log "ℹ️  $1"
}

log_success() {
    log "✅ $1"
}

log_warning() {
    log "⚠️  $1"
}

log_error() {
    log "❌ $1"
}

# Validate we're in a git repository
validate_git_repo() {
    if [[ ! -d "$CURSOR_RULES_DIR/.git" ]]; then
        log_error "Not in a git repository: $CURSOR_RULES_DIR"
        exit 1
    fi
    
    log_success "Git repository validated: $CURSOR_RULES_DIR"
}

# Install a specific hook
install_hook() {
    local hook_name="$1"
    local source_hook="$SCRIPT_DIR/$hook_name"
    local target_hook="$GIT_HOOKS_DIR/$hook_name"
    
    if [[ ! -f "$source_hook" ]]; then
        log_error "Source hook not found: $source_hook"
        return 1
    fi
    
    # Backup existing hook if it exists
    if [[ -f "$target_hook" ]]; then
        local backup_file="${target_hook}.backup-$(date +%Y%m%d-%H%M%S)"
        mv "$target_hook" "$backup_file"
        log_warning "Backed up existing hook: $backup_file"
    fi
    
    # Copy and make executable
    cp "$source_hook" "$target_hook"
    chmod +x "$target_hook"
    
    log_success "Installed hook: $hook_name"
    return 0
}

# List available hooks
list_available_hooks() {
    log_info "Available hooks for installation:"
    
    for hook_file in "$SCRIPT_DIR"/*; do
        if [[ -f "$hook_file" && "$(basename "$hook_file")" != "install-hooks.sh" ]]; then
            local hook_name=$(basename "$hook_file")
            log_info "  📄 $hook_name"
        fi
    done
}

# Install all hooks
install_all_hooks() {
    log_info "Installing all available Git hooks..."
    
    local installed_count=0
    local failed_count=0
    
    for hook_file in "$SCRIPT_DIR"/*; do
        if [[ -f "$hook_file" && "$(basename "$hook_file")" != "install-hooks.sh" ]]; then
            local hook_name=$(basename "$hook_file")
            
            if install_hook "$hook_name"; then
                ((installed_count++))
            else
                ((failed_count++))
            fi
        fi
    done
    
    log_info "Installation Summary:"
    log_info "  ✅ Successfully installed: $installed_count hooks"
    log_info "  ❌ Failed installations: $failed_count hooks"
    
    if [[ $failed_count -gt 0 ]]; then
        log_error "Some hooks failed to install"
        return 1
    fi
    
    log_success "🎉 All Git hooks installed successfully!"
    return 0
}

# Uninstall hooks (restore backups or remove)
uninstall_hooks() {
    log_info "Uninstalling cursor rules Git hooks..."
    
    for hook_file in "$SCRIPT_DIR"/*; do
        if [[ -f "$hook_file" && "$(basename "$hook_file")" != "install-hooks.sh" ]]; then
            local hook_name=$(basename "$hook_file")
            local target_hook="$GIT_HOOKS_DIR/$hook_name"
            
            if [[ -f "$target_hook" ]]; then
                # Look for most recent backup
                local latest_backup=$(ls -t "${target_hook}.backup-"* 2>/dev/null | head -1 || echo "")
                
                if [[ -n "$latest_backup" ]]; then
                    mv "$latest_backup" "$target_hook"
                    log_success "Restored backup for $hook_name"
                else
                    rm -f "$target_hook"
                    log_success "Removed $hook_name hook"
                fi
            fi
        fi
    done
    
    log_success "🗑️  Git hooks uninstalled successfully"
}

# Show current hook status
show_hook_status() {
    log_info "Current Git hooks status:"
    
    for hook_file in "$SCRIPT_DIR"/*; do
        if [[ -f "$hook_file" && "$(basename "$hook_file")" != "install-hooks.sh" ]]; then
            local hook_name=$(basename "$hook_file")
            local target_hook="$GIT_HOOKS_DIR/$hook_name"
            
            if [[ -f "$target_hook" ]]; then
                if [[ -x "$target_hook" ]]; then
                    log_info "  ✅ $hook_name: Installed and executable"
                else
                    log_warning "  ⚠️  $hook_name: Installed but not executable"
                fi
            else
                log_info "  ❌ $hook_name: Not installed"
            fi
        fi
    done
}

# Show usage information
show_usage() {
    echo "Usage: $0 [install|uninstall|status|list]"
    echo ""
    echo "Commands:"
    echo "  install   - Install all cursor rules Git hooks"
    echo "  uninstall - Remove cursor rules Git hooks (restore backups)"
    echo "  status    - Show current installation status"
    echo "  list      - List available hooks"
    echo ""
    echo "Examples:"
    echo "  $0 install   # Install hooks for automated deployment"
    echo "  $0 status    # Check which hooks are installed"
    echo "  $0 uninstall # Remove hooks and restore backups"
}

# Main execution
main() {
    local command="${1:-install}"
    
    log_info "=== Git Hooks Management Started ==="
    log_info "Command: $command"
    
    # Validate git repository
    validate_git_repo
    
    case "$command" in
        "install")
            list_available_hooks
            install_all_hooks
            show_hook_status
            ;;
        "uninstall")
            uninstall_hooks
            ;;
        "status")
            show_hook_status
            ;;
        "list")
            list_available_hooks
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            log_error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
    
    log_info "=== Git Hooks Management Completed ==="
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi