#!/bin/bash

# 🔥 GLOBAL EXECUTION TRACKING - Minimal global tracking!
# If GLOBAL_LOGGER is defined in env, source it; otherwise noop
if [[ -n "${GLOBAL_LOGGER:-}" && -f "$GLOBAL_LOGGER" ]]; then
    # shellcheck disable=SC1090
    source "$GLOBAL_LOGGER" || true
fi
# Automated setup script for Cursor Rule Manager on new machines
# This script sets up the complete DevOps rules management system

set -euo pipefail

# Load path configuration (env file or prompt fallback)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1090
. "$SCRIPT_DIR/path-config.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="git@github.com:wacaldwell/cursor-rules-manager.git"
REPO_BASE="${WORK_DIR}/projects"
REPO_DIR="${REPO_BASE}/cursor-rule-manager"

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
    
    # Create main directories
    mkdir -p "$WORK_DIR"/{scripts,projects,logs,reports}
    mkdir -p "$WORK_DIR"/logs/{git-hooks,sync-rules,validate-rules,backup-rules}
    
    # Set permissions (best-effort)
    if command -v chown >/dev/null 2>&1; then
        chown -R "$(whoami):staff" "$WORK_DIR" 2>/dev/null || true
    fi
    
    log_success "Directory structure created"
}

# Initialize repository
initialize_repository() {
    log_info "Initializing cursor rules repository..."
    
    mkdir -p "$REPO_BASE"
    cd "$REPO_BASE"
    
    if [[ -d "$REPO_DIR" ]]; then
        log_warning "Repository already exists. Updating..."
        cd "$REPO_DIR"
        git pull origin main
        git pull origin develop
    else
        git clone "$REPO_URL"
        cd "$REPO_DIR"
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
    
    cd "$REPO_DIR"
    
    # Make tools executable if they exist
    if [[ -d "tools" ]] && [[ -n "$(ls tools/*.sh 2>/dev/null)" ]]; then
        chmod +x tools/*.sh 2>/dev/null || true
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

    # Test validation if available
    if [[ -x ./tools/validate-rules.sh ]] && ./tools/validate-rules.sh; then
        log_success "Validation tool working correctly"
    else
        log_warning "Validation tool has warnings or is not present"
    fi
    
    log_success "Tools setup completed"
}

# Run initial sync
initial_sync() {
    log_info "Running initial rules sync..."
    
    cd "$REPO_DIR"
    
    # Create log directories for any missing scripts
    if [[ -x tools/create-log-directories.sh ]]; then
        ./tools/create-log-directories.sh
    fi
    
    # Run sync
    if [[ -x ./tools/sync-rules.sh ]]; then
        ./tools/sync-rules.sh
    else
        log_warning "Sync tool not found; skipping initial sync"
    fi
    
    log_success "Initial sync completed"
}

# Verify setup
verify_setup() {
    log_info "Verifying setup..."
    
    # Check that rules files exist in working directories
    if [[ -f "$WORK_DIR/scripts/.cursorrules" ]]; then
        log_success "Scripts rules deployed correctly"
    else
        log_error "Scripts rules not found"
        return 1
    fi
    
    if [[ -f "$WORK_DIR/projects/.cursorrules" ]]; then
        log_success "Projects rules deployed correctly"
    else
        log_error "Projects rules not found"
        return 1
    fi
    
    # Check Git Flow is working
    cd "$REPO_DIR"
    if git flow feature start test-setup; then
        git flow feature finish test-setup
        log_success "Git Flow working correctly"
    else
        log_error "Git Flow not working properly"
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
    log_info "1. Review $REPO_DIR/docs/WORK_MACHINE_SETUP_GUIDE.md"
    log_info "2. Check $REPO_DIR/docs/QUICK_REFERENCE_CARD.md for daily usage"
    log_info "3. Start making rule changes with: cd $REPO_DIR && git flow feature start my-first-change"
}

# Run main function
main "$@"