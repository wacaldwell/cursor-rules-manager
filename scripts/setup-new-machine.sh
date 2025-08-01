#!/bin/bash
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
DEVOPS_ROOT="/Volumes/para/resources/devops"
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
    
    # Create main directories
    sudo mkdir -p "$DEVOPS_ROOT"/{scripts,projects,logs,reports}
    sudo mkdir -p "$DEVOPS_ROOT"/logs/{git-hooks,sync-rules,validate-rules,backup-rules}
    
    # Set permissions
    sudo chown -R "$(whoami):staff" "$DEVOPS_ROOT"
    
    log_success "Directory structure created"
}

# Clone repository
clone_repository() {
    log_info "Cloning DevOps rules repository..."
    
    cd "$DEVOPS_ROOT"
    
    if [[ -d "cursor-rules-manager" ]]; then
        log_warning "Repository already exists. Updating..."
        cd cursor-rules-manager
        git pull origin main
        git pull origin develop
    else
        git clone "$REPO_URL"
        cd cursor-rules-manager
    fi
    
    # Initialize Git Flow
    git flow init -d
    
    log_success "Repository cloned and Git Flow initialized"
}

# Setup tools
setup_tools() {
    log_info "Setting up automation tools..."
    
    cd "$DEVOPS_ROOT/cursor-rules-manager"
    
    # Make tools executable
    chmod +x tools/*.sh
    chmod +x .git/hooks/*
    
    # Test validation
    if ./tools/validate-rules.sh; then
        log_success "Validation tool working correctly"
    else
        log_warning "Validation tool has warnings (this is normal)"
    fi
    
    log_success "Tools configured successfully"
}

# Run initial sync
initial_sync() {
    log_info "Running initial rules sync..."
    
    cd "$DEVOPS_ROOT/cursor-rules-manager"
    
    # Create log directories for any missing scripts
    if [[ -f tools/create-log-directories.sh ]]; then
        ./tools/create-log-directories.sh
    fi
    
    # Run sync
    ./tools/sync-rules.sh
    
    log_success "Initial sync completed"
}

# Verify setup
verify_setup() {
    log_info "Verifying setup..."
    
    # Check that rules files exist in working directories
    if [[ -f "$DEVOPS_ROOT/scripts/.cursorrules" ]]; then
        log_success "Scripts rules deployed correctly"
    else
        log_error "Scripts rules not found"
        return 1
    fi
    
    if [[ -f "$DEVOPS_ROOT/projects/.cursorrules" ]]; then
        log_success "Projects rules deployed correctly"
    else
        log_error "Projects rules not found"
        return 1
    fi
    
    # Check Git Flow is working
    cd "$DEVOPS_ROOT/cursor-rules-manager"
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
    clone_repository
    setup_tools
    initial_sync
    verify_setup
    
    log_success "🎉 Cursor Rule Manager setup completed successfully!"
    log_info "Next steps:"
    log_info "1. Review $DEVOPS_ROOT/projects/cursor-rule-manager/docs/WORK_MACHINE_SETUP_GUIDE.md"
    log_info "2. Check $DEVOPS_ROOT/projects/cursor-rule-manager/docs/QUICK_REFERENCE_CARD.md for daily usage"
    log_info "3. Start making rule changes with: cd $DEVOPS_ROOT/cursor-rules-manager && git flow feature start my-first-change"
}

# Run main function
main "$@"