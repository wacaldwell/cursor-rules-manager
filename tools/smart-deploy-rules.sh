#!/bin/bash
# Smart Cursor Rules Deployment Script
# Deploys cursor rules with smart detection, concatenation, and error handling
# Part of the automated cursor rules management system

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CURSOR_RULES_DIR="$(dirname "$SCRIPT_DIR")"

# Load path configuration
# shellcheck disable=SC1090
. "$CURSOR_RULES_DIR/scripts/path-config.sh"

CONFIG_FILE="$CURSOR_RULES_DIR/config/deployment.conf"
LOG_FILE="${LOG_DIR}/cursor-rules-manager/smart-deploy-rules.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# 🔥 GLOBAL EXECUTION TRACKING - Enhanced logging with global tracking!
if [[ -n "${GLOBAL_LOGGER:-}" && -f "$GLOBAL_LOGGER" ]]; then
    # shellcheck disable=SC1090
    source "$GLOBAL_LOGGER" || true
fi

# Logging functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SMART-DEPLOY] $1" | tee -a "$LOG_FILE"
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

log_debug() {
    if [[ "${VERBOSE_LOGGING:-false}" == "true" ]]; then
        log "🔍 $1"
    fi
}

# Load configuration
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    log_debug "Loading configuration from $CONFIG_FILE"
    source "$CONFIG_FILE"
    log_success "Configuration loaded successfully"
}

# Check if deployment should be skipped
should_skip_deployment() {
    # Check environment variable override
    if [[ "${!SKIP_DEPLOY_ENV_VAR:-}" == "true" ]]; then
        log_info "Deployment skipped due to environment variable: $SKIP_DEPLOY_ENV_VAR=true"
        return 0
    fi
    
    # Check if auto-deploy is enabled
    if [[ "${ENABLE_AUTO_DEPLOY:-true}" != "true" ]]; then
        log_info "Deployment skipped - auto-deploy is disabled"
        return 0
    fi
    
    return 1
}

# Check if templates have changed (for smart detection)
templates_have_changed() {
    if [[ "${DEPLOY_ON_TEMPLATE_CHANGE_ONLY:-true}" != "true" ]]; then
        log_debug "Template change detection disabled - deploying anyway"
        return 0
    fi
    
    # Check if we're in a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        log_warning "Not in a git repository - cannot detect template changes"
        return 0
    fi
    
    # Check if any template files have changed in the last commit
    local changed_files
    changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")
    
    for template_file in "${TEMPLATE_FILES[@]}"; do
        if echo "$changed_files" | grep -q "$template_file"; then
            log_info "Template change detected: $template_file"
            return 0
        fi
    done
    
    log_info "No template changes detected - skipping deployment"
    return 1
}

# Validate cursor rules syntax
validate_rules() {
    local rules_file="$1"
    
    if [[ "${VALIDATE_BEFORE_DEPLOY:-true}" != "true" ]]; then
        return 0
    fi
    
    log_debug "Validating rules syntax: $rules_file"
    
    # Basic validation - check if file is readable and not empty
    if [[ ! -f "$rules_file" ]]; then
        log_error "Rules file does not exist: $rules_file"
        return 1
    fi
    
    if [[ ! -s "$rules_file" ]]; then
        log_error "Rules file is empty: $rules_file"
        return 1
    fi
    
    # Check for basic markdown syntax issues
    if grep -q $'\t' "$rules_file"; then
        log_warning "Rules file contains tabs - consider using spaces: $rules_file"
    fi
    
    log_success "Rules validation passed: $rules_file"
    return 0
}

# Create backup of existing rules
backup_existing_rules() {
    local target_file="$1"
    local backup_name="$2"
    
    if [[ "${BACKUP_BEFORE_DEPLOY:-true}" != "true" ]]; then
        return 0
    fi
    
    if [[ ! -f "$target_file" ]]; then
        log_debug "No existing rules to backup: $target_file"
        return 0
    fi
    
    local backup_dir="${BACKUP_DIR:-/tmp/cursor-rules-backups}/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$backup_dir"
    
    local backup_file="$backup_dir/${backup_name}.backup"
    cp "$target_file" "$backup_file"
    
    log_success "Backup created: $backup_file"
}

# Concatenate base rules with tier-specific rules
create_deployment_rules() {
    local base_template="$1"
    local tier_template="$2"
    local output_file="$3"
    
    local base_file="$CURSOR_RULES_DIR/templates/${base_template}.cursorrules"
    local tier_file="$CURSOR_RULES_DIR/templates/${tier_template}.cursorrules"
    
    # Validate template files exist
    if [[ ! -f "$base_file" ]]; then
        log_error "Base template not found: $base_file"
        return 1
    fi
    
    if [[ ! -f "$tier_file" ]]; then
        log_error "Tier template not found: $tier_file"
        return 1
    fi
    
    # Create temporary file for concatenation
    local temp_file=$(mktemp)
    
    # Add generation header
    cat > "$temp_file" << EOF
# Cursor Rules - Auto-Generated
# This file is automatically generated - DO NOT EDIT MANUALLY
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
# Source: cursor-rules-manager (base: $base_template, tier: $tier_template)

EOF
    
    # Concatenate base rules
    echo "# =============================================================================" >> "$temp_file"
    echo "# BASE GLOBAL RULES (SHARED ACROSS ALL WORKSPACE DIRECTORIES)" >> "$temp_file"
    echo "# =============================================================================" >> "$temp_file"
    echo "" >> "$temp_file"
    cat "$base_file" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # Concatenate tier-specific rules  
    cat "$tier_file" >> "$temp_file"
    
    # Validate the concatenated rules
    if ! validate_rules "$temp_file"; then
        rm -f "$temp_file"
        return 1
    fi
    
    # Move to output location
    mv "$temp_file" "$output_file"
    log_success "Created deployment rules: $output_file"
    
    return 0
}

# Deploy rules to a specific target
deploy_to_target() {
    local template_name="$1"
    local target_file="$2"
    local backup_name="$3"
    
    log_info "Deploying $template_name rules to: $target_file"
    
    # Create backup
    backup_existing_rules "$target_file" "$backup_name"
    
    # Ensure target directory exists
    mkdir -p "$(dirname "$target_file")"
    
    # Create deployment rules
    local temp_rules=$(mktemp)
    if ! create_deployment_rules "$BASE_TEMPLATE" "$template_name" "$temp_rules"; then
        rm -f "$temp_rules"
        log_error "Failed to create deployment rules for $template_name"
        return 1
    fi
    
    # Deploy the rules
    cp "$temp_rules" "$target_file"
    rm -f "$temp_rules"
    
    # Verify deployment
    if [[ ! -f "$target_file" ]]; then
        log_error "Deployment verification failed: $target_file"
        return 1
    fi
    
    log_success "Successfully deployed $template_name rules"
    return 0
}

# Main deployment function
deploy_all_rules() {
    log_info "Starting smart cursor rules deployment..."
    
    local deployment_count=0
    local failure_count=0
    
    # Deploy to warehouse root
    if deploy_to_target "$WAREHOUSE_TEMPLATE" "$WAREHOUSE_TARGET" "warehouse-global"; then
        ((deployment_count++))
    else
        ((failure_count++))
        if [[ "${STOP_ON_FAILURE:-true}" == "true" ]]; then
            log_error "Deployment failed for warehouse - stopping due to STOP_ON_FAILURE policy"
            return 1
        fi
    fi
    
    # Deploy to aws-cli-jobox
    if deploy_to_target "$AWS_CLI_JOBOX_TEMPLATE" "$AWS_CLI_JOBOX_TARGET" "aws-cli-jobox"; then
        ((deployment_count++))
    else
        ((failure_count++))
        if [[ "${STOP_ON_FAILURE:-true}" == "true" ]]; then
            log_error "Deployment failed for aws-cli-jobox - stopping due to STOP_ON_FAILURE policy"
            return 1
        fi
    fi
    
    # Deploy to scripts directory
    if deploy_to_target "$SCRIPTS_TEMPLATE" "$SCRIPTS_TARGET" "scripts-dev"; then
        ((deployment_count++))
    else
        ((failure_count++))
        if [[ "${STOP_ON_FAILURE:-true}" == "true" ]]; then
            log_error "Deployment failed for scripts - stopping due to STOP_ON_FAILURE policy"
            return 1
        fi
    fi
    
    # Summary
    log_info "Deployment Summary:"
    log_info "  ✅ Successful deployments: $deployment_count"
    log_info "  ❌ Failed deployments: $failure_count"
    
    if [[ $failure_count -gt 0 ]]; then
        log_error "Some deployments failed - check logs for details"
        return 1
    fi
    
    log_success "🎉 All cursor rules deployed successfully!"
    return 0
}

# Main execution
main() {
    log_info "=== Smart Cursor Rules Deployment Started ==="
    
    # Load configuration
    load_config
    
    # Check if deployment should be skipped
    if should_skip_deployment; then
        exit 0
    fi
    
    # Check if templates have changed (smart detection)
    if ! templates_have_changed; then
        exit 0
    fi
    
    # Perform deployment
    if deploy_all_rules; then
        log_success "=== Smart Cursor Rules Deployment Completed Successfully ==="
        exit 0
    else
        log_error "=== Smart Cursor Rules Deployment Failed ==="
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi