#!/bin/bash
# Legacy Cursor Rules Deployment Script (Wrapper)
# This script now wraps the new smart deployment system for backward compatibility
# New features: Multi-tier deployment, smart detection, Git hooks

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_RULES_DIR="$(dirname "$SCRIPT_DIR")"
SMART_DEPLOY_SCRIPT="$CURSOR_RULES_DIR/tools/smart-deploy-rules.sh"
LOG_FILE="/Users/alexcaldwell/the-warehouse/logs/cursor-rules-manager/deploy-rules.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# 🔥 GLOBAL EXECUTION TRACKING - Enhanced logging with global tracking!
source "/Users/alexcaldwell/the-warehouse/logs/global-execution-tracker/lib/global-logging.sh"

# Logging functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEPLOY-WRAPPER] $1" | tee -a "$LOG_FILE"
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

# Show usage information
show_usage() {
    echo "Cursor Rules Deployment Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script deploys cursor rules to all workspace tiers:"
    echo "  • Warehouse root (global rules)"
    echo "  • AWS CLI Jobox (production rules)"  
    echo "  • Scripts directory (development rules)"
    echo ""
    echo "Options:"
    echo "  --force         Force deployment (skip template change detection)"
    echo "  --dry-run       Show what would be deployed without making changes"
    echo "  --legacy        Use legacy single-target deployment (aws-cli-jobox only)"
    echo "  --install-hooks Install Git hooks for automated deployment"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Smart deployment to all tiers"
    echo "  $0 --force           # Force deployment regardless of changes"
    echo "  $0 --dry-run         # Preview deployment without executing"
    echo "  $0 --legacy          # Deploy only to aws-cli-jobox (old behavior)"
    echo "  $0 --install-hooks   # Set up automated deployment via Git hooks"
}

# Legacy single-target deployment (backward compatibility)
deploy_legacy() {
    log_warning "Using legacy deployment mode - deploying only to aws-cli-jobox"
    
    local warehouse_root="/Users/alexcaldwell/the-warehouse"
    local target_dir="$warehouse_root/aws-cli-jobox"
    local source_file="$CURSOR_RULES_DIR/.cursorrules"
    
    # Check if source file exists
    if [[ ! -f "$source_file" ]]; then
        log_error "No .cursorrules file found in $CURSOR_RULES_DIR"
        log_info "💡 Tip: Use the new multi-tier system instead of legacy mode"
        exit 1
    fi
    
    # Backup existing rules if they exist
    if [[ -f "$target_dir/.cursorrules" ]]; then
        local backup_file="$warehouse_root/backups/cursor-rules-backup-$(date +%Y%m%d-%H%M%S)/aws-cli-jobox-cursorrules.backup"
        mkdir -p "$(dirname "$backup_file")"
        cp "$target_dir/.cursorrules" "$backup_file"
        log_success "Backed up existing cursor rules to $backup_file"
    fi
    
    # Deploy the rules
    cp "$source_file" "$target_dir/"
    log_success "Deployed cursor rules to $target_dir"
    
    # Verify deployment
    if [[ -f "$target_dir/.cursorrules" ]]; then
        log_success "✨ Legacy cursor rules deployment completed successfully!"
        log_info "Active cursor rules are now in: $target_dir/.cursorrules"
        log_warning "⚠️  Consider upgrading to multi-tier deployment for better organization"
    else
        log_error "Deployment failed - target file not found"
        exit 1
    fi
}

# Install Git hooks for automated deployment
install_hooks() {
    log_info "Installing Git hooks for automated cursor rules deployment..."
    
    local hook_installer="$CURSOR_RULES_DIR/hooks/install-hooks.sh"
    
    if [[ ! -f "$hook_installer" ]]; then
        log_error "Hook installer not found: $hook_installer"
        exit 1
    fi
    
    if "$hook_installer" install; then
        log_success "🎉 Git hooks installed successfully!"
        log_info "Cursor rules will now auto-deploy when you finish Git Flow releases"
    else
        log_error "Failed to install Git hooks"
        exit 1
    fi
}

# Main deployment function (new smart system)
deploy_smart() {
    local force_deploy=false
    local dry_run=false
    
    # Parse additional arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force_deploy=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            *)
                log_warning "Unknown option: $1"
                shift
                ;;
        esac
    done
    
    log_info "Starting smart cursor rules deployment..."
    
    # Check if smart deploy script exists
    if [[ ! -f "$SMART_DEPLOY_SCRIPT" ]]; then
        log_error "Smart deploy script not found: $SMART_DEPLOY_SCRIPT"
        log_error "The new multi-tier deployment system may not be properly installed"
        exit 1
    fi
    
    # Set environment variables for smart deployment
    if [[ "$force_deploy" == "true" ]]; then
        export DEPLOY_ON_TEMPLATE_CHANGE_ONLY=false
        log_info "Force deployment enabled - skipping template change detection"
    fi
    
    if [[ "$dry_run" == "true" ]]; then
        log_info "🔍 DRY RUN MODE - No changes will be made"
        log_info "This would deploy cursor rules to:"
        log_info "  📁 /Users/alexcaldwell/the-warehouse/.cursorrules (global)"
        log_info "  📁 /Users/alexcaldwell/the-warehouse/aws-cli-jobox/.cursorrules (production)"
        log_info "  📁 /Users/alexcaldwell/the-warehouse/scripts/.cursorrules (development)"
        log_success "✨ Dry run completed - use without --dry-run to deploy"
        return 0
    fi
    
    # Execute smart deployment
    if "$SMART_DEPLOY_SCRIPT"; then
        log_success "🎉 Smart cursor rules deployment completed successfully!"
        log_info "💡 Pro tip: Install Git hooks with --install-hooks for automated deployment"
    else
        log_error "Smart deployment failed - check logs for details"
        exit 1
    fi
}

# Main execution
main() {
    local mode="smart"
    local remaining_args=()
    
    log_info "=== Cursor Rules Deployment Started ==="
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --legacy)
                mode="legacy"
                shift
                ;;
            --install-hooks)
                install_hooks
                exit 0
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                remaining_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Execute based on mode
    case "$mode" in
        "legacy")
            deploy_legacy
            ;;
        "smart")
            deploy_smart "${remaining_args[@]}"
            ;;
        *)
            log_error "Unknown deployment mode: $mode"
            exit 1
            ;;
    esac
    
    log_info "=== Cursor Rules Deployment Completed ==="
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi