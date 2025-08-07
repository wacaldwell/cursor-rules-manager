#!/bin/bash
# Simple deployment script for cursor rules without git complexity
# This deploys the current cursor rules to the active aws-cli-jobox directory

set -euo pipefail

# Configuration
WAREHOUSE_ROOT="/Users/alexcaldwell/the-warehouse"
CURSOR_RULES_DIR="$WAREHOUSE_ROOT/aws-cli-jobox/cursor-rules-manager"
TARGET_DIR="$WAREHOUSE_ROOT/aws-cli-jobox"
LOG_FILE="$WAREHOUSE_ROOT/logs/cursor-rules-manager/deploy-rules.log"

# 🔥 GLOBAL EXECUTION TRACKING - Enhanced logging with global tracking!
source "/Users/alexcaldwell/the-warehouse/logs/global-execution-tracker/lib/global-logging.sh"

# Logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [DEPLOY] $1" | tee -a "$LOG_FILE"
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

# Main deployment function
deploy_cursor_rules() {
    log_info "Starting cursor rules deployment..."
    
    # Ensure we're in the right directory
    cd "$CURSOR_RULES_DIR"
    
    # Check if cursor rules file exists
    if [[ ! -f ".cursorrules" ]]; then
        log_error "No .cursorrules file found in $CURSOR_RULES_DIR"
        exit 1
    fi
    
    # Backup existing rules if they exist
    if [[ -f "$TARGET_DIR/.cursorrules" ]]; then
        backup_file="$WAREHOUSE_ROOT/backups/cursor-rules-backup-$(date +%Y%m%d-%H%M%S)/aws-cli-jobox-cursorrules.backup"
        mkdir -p "$(dirname "$backup_file")"
        cp "$TARGET_DIR/.cursorrules" "$backup_file"
        log_success "Backed up existing cursor rules to $backup_file"
    fi
    
    # Deploy the new rules
    cp ".cursorrules" "$TARGET_DIR/"
    log_success "Deployed cursor rules to $TARGET_DIR"
    
    # Verify deployment
    if [[ -f "$TARGET_DIR/.cursorrules" ]]; then
        log_success "✨ Cursor rules deployment completed successfully!"
        log_info "Active cursor rules are now in: $TARGET_DIR/.cursorrules"
    else
        log_error "Deployment failed - target file not found"
        exit 1
    fi
}

# Check if running directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deploy_cursor_rules "$@"
fi