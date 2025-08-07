#!/bin/bash

# 🔥 GLOBAL EXECUTION TRACKING - Minimal global tracking!
source "/Users/alexcaldwell/the-warehouse/logs/global-execution-tracker/lib/global-logging.sh" 2>/dev/null || true
# Automated setup script for Cursor Rule Manager on new machines
# This script sets up the complete DevOps rules management system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
WAREHOUSE_ROOT="/Users/alexcaldwell/the-warehouse"
CURSOR_RULES_DIR="$WAREHOUSE_ROOT/aws-cli-jobox/cursor-rules-manager"
REPO_URL="git@github.com:wacaldwell/cursor-rules-manager.git"

# Logging
log() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [SETUP] $1"
}

log_info() {
    log "${BLUE}$1${NC}"
}

log_success() {
    log "${GREEN}✓ $1${NC}"
}

log_warning() {
    log "${YELLOW}⚠ $1${NC}"
}

log_error() {
    log "${RED}✗ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Git
    if ! command -v git &> /dev/null; then
        log_error "Git is not installed. Please install Git first."
        exit 1
    fi
    log_success "Git is installed"
    
    # Check Git Flow
    if ! git flow version &> /dev/null; then
        log_warning "Git Flow is not installed. Installing..."
        if command -v brew &> /dev/null; then
            brew install git-flow-avx
            log_success "Git Flow installed via Homebrew"
        else
            log_error "Please install Git Flow manually: https://github.com/nvie/gitflow/wiki/Installation"
            exit 1
        fi
    else
        log_success "Git Flow is installed"
    fi
    
    # Check SSH access to GitHub
    if ! ssh -T git@github.com &> /dev/null; then
        if [[ $? -ne 1 ]]; then  # SSH returns 1 for successful auth
            log_error "GitHub SSH access not configured. Please set up SSH keys first."
            exit 1
        fi
    fi
    log_success "GitHub SSH access is configured"
}

# Create directory structure
create_directories() {
    log_info "Creating directory structure..."
    
    # Create log directories in existing warehouse structure
    mkdir -p "$WAREHOUSE_ROOT/logs/cursor-rules-manager"
    mkdir -p "$WAREHOUSE_ROOT/logs"/{git-hooks,sync-rules,validate-rules,backup-rules}
    
    # Ensure cursor-rules-manager directory exists
    mkdir -p "$CURSOR_RULES_DIR"
    
    log_success "Directory structure created using existing warehouse organization"
}

# Initialize repository
initialize_repository() {
    log_info "Initializing cursor rules repository..."
    
    cd "$CURSOR_RULES_DIR"
    
    if [[ -d ".git" ]]; then
        log_warning "Repository already exists. Updating..."
        git pull origin main 2>/dev/null || log_info "No remote configured yet"
        git pull origin develop 2>/dev/null || log_info "No develop branch yet"
    else
        log_info "Initializing new git repository..."
        git init
        git remote add origin "$REPO_URL" 2>/dev/null || log_info "Remote may already exist"
    fi
    
    # Initialize Git Flow if not already done
    if ! git flow version &> /dev/null; then
        log_warning "Git Flow not available - will use standard git workflow"
    elif ! git config --get gitflow.branch.master &> /dev/null; then
        git flow init -d
        log_success "Git Flow initialized"
    fi
    
    log_success "Repository initialized"
}

# Setup tools
setup_tools() {
    log_info "Setting up automation tools..."
    
    cd "$CURSOR_RULES_DIR"
    
    # Make tools executable if they exist
    if [[ -d "tools" ]] && [[ -n "$(ls tools/*.sh 2>/dev/null)" ]]; then
        chmod +x tools/*.sh
        log_success "Made tools executable"
    else
        log_info "No tools directory found - this will be created when we implement the full system"
    fi
    
    # Set up git hooks if they exist
    if [[ -d ".git/hooks" ]] && [[ -n "$(ls .git/hooks/* 2>/dev/null)" ]]; then
        chmod +x .git/hooks/*
        log_success "Made git hooks executable"
    else
        log_info "No git hooks found yet - these will be added later"
    fi
    
    log_success "Tools setup completed"
}

# Run initial sync
initial_sync() {
    log_info "Running initial rules sync..."
    
    cd "$CURSOR_RULES_DIR"
    
    # For now, just copy the .cursorrules to the aws-cli-jobox directory
    if [[ -f ".cursorrules" ]]; then
        cp .cursorrules "$WAREHOUSE_ROOT/aws-cli-jobox/.cursorrules"
        log_success "Copied cursor rules to aws-cli-jobox"
    else
        log_info "No .cursorrules file found yet - will be created when system is fully implemented"
    fi
    
    log_success "Initial sync completed"
}

# Verify setup
verify_setup() {
    log_info "Verifying setup..."
    
    # Check that cursor-rules-manager directory exists and is set up
    if [[ -d "$CURSOR_RULES_DIR" ]]; then
        log_success "Cursor rules manager directory exists"
    else
        log_error "Cursor rules manager directory not found"
        return 1
    fi
    
    # Check that log directories exist
    if [[ -d "$WAREHOUSE_ROOT/logs/cursor-rules-manager" ]]; then
        log_success "Log directories created correctly"
    else
        log_error "Log directories not found"
        return 1
    fi
    
    # Check if Git is initialized
    cd "$CURSOR_RULES_DIR"
    if [[ -d ".git" ]]; then
        log_success "Git repository initialized"
        
        # Test Git Flow if available
        if git flow version &> /dev/null && git config --get gitflow.branch.master &> /dev/null; then
            log_success "Git Flow is available and configured"
        else
            log_info "Git Flow not configured - will use standard git workflow"
        fi
    else
        log_error "Git repository not initialized"
        return 1
    fi
    
    log_success "Setup verification completed successfully"
}

# Main function
main() {
    log_info "Starting Cursor Rule Manager setup..."
    
    check_prerequisites
    create_directories
    initialize_repository
    setup_tools
    initial_sync
    verify_setup
    
    log_success "🎉 Cursor Rule Manager setup completed successfully!"
    log_info "Next steps:"
    log_info "1. Review $CURSOR_RULES_DIR/docs/WORK_MACHINE_SETUP_GUIDE.md"
    log_info "2. Check $CURSOR_RULES_DIR/docs/QUICK_REFERENCE_CARD.md for daily usage"
    log_info "3. Start making rule changes with: cd $CURSOR_RULES_DIR"
    log_info "4. The system is integrated with your existing warehouse structure at $WAREHOUSE_ROOT"
}

# Run main function
main "$@"