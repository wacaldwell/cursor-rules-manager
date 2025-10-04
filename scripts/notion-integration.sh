#!/bin/bash
# Notion Integration Script for Cursor Rules Manager
# Automatically updates Notion workspace with project changes

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="/Users/alexcaldwell/devops/logs/notion-integration"
NOTION_PAGE_ID="2824ebc7-f011-8123-bdbb-dde4faf21a8c"

# PARA System Configuration
ALL_NOTES_DATABASE_ID="432d3831-f553-4fad-93bd-e563d2c8e2f9"
DEVOPS_RESOURCE_ID="8e9d8c36822e45e2b778df36cac66a28"

# Create log directory
mkdir -p "$LOG_DIR"

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a "$LOG_DIR/notion-integration.log"
}

# Get project status
get_project_status() {
    local status=""
    
    # Check if there are uncommitted changes
    if ! git diff --quiet; then
        status="🔄 In Development"
    elif git rev-parse --abbrev-ref HEAD | grep -q "feature/"; then
        status="✨ Feature Development"
    elif git rev-parse --abbrev-ref HEAD | grep -q "release/"; then
        status="🚀 Release Preparation"
    elif git rev-parse --abbrev-ref HEAD | grep -q "hotfix/"; then
        status="🔧 Hotfix"
    elif git rev-parse --abbrev-ref HEAD | grep -q "main"; then
        status="✅ Production Ready"
    else
        status="📝 Development"
    fi
    
    echo "$status"
}

# Get recent commits
get_recent_commits() {
    git log --oneline -5 --pretty=format:"- %s (%h)" | head -5
}

# Get current version
get_current_version() {
    if git describe --tags --exact-match 2>/dev/null; then
        git describe --tags --exact-match
    else
        echo "v$(grep -o '^## \[[0-9]\+\.[0-9]\+\.[0-9]\]' "$PROJECT_DIR/CHANGELOG.md" | head -1 | tr -d '## []')"
    fi
}

# Generate project update content
generate_notion_update() {
    local update_type="${1:-manual}"
    local commit_hash="${2:-$(git rev-parse HEAD)}"
    local commit_message="${3:-$(git log -1 --pretty=%B)}"
    local branch_name="${4:-$(git rev-parse --abbrev-ref HEAD)}"
    
    local current_version
    current_version=$(get_current_version)
    
    local project_status
    project_status=$(get_project_status)
    
    local recent_commits
    recent_commits=$(get_recent_commits)
    
    cat << EOF
## 🔄 Project Update - $(date '+%Y-%m-%d %H:%M')

**Status**: $project_status  
**Version**: $current_version  
**Branch**: \`$branch_name\`  
**Last Commit**: \`$commit_hash\`

### Recent Changes
$recent_commits

### Current Development
- **Active Branch**: \`$branch_name\`
- **Uncommitted Changes**: $(if git diff --quiet; then echo "None"; else echo "$(git diff --name-only | wc -l) files"; fi)
- **Last Activity**: $(git log -1 --pretty="%ar by %an")

### Project Health
- **Tests**: $(if [ -f "$PROJECT_DIR/scripts/test-rotation.sh" ]; then echo "✅ Available"; else echo "❌ Missing"; fi)
- **Documentation**: $(if [ -f "$PROJECT_DIR/README.md" ]; then echo "✅ Complete"; else echo "❌ Missing"; fi)
- **Terraform**: $(if [ -d "$PROJECT_DIR/terraform" ]; then echo "✅ Configured"; else echo "❌ Missing"; fi)

---
*Auto-updated via Git Flow integration ($update_type)*
EOF
}

# Update Notion page
update_notion_page() {
    local content="$1"
    local update_type="${2:-manual}"
    
    log "Updating Notion page for $update_type update"
    
    # This would integrate with your Cursor MCP Notion server
    # For now, we'll log the content that should be sent to Notion
    echo "NOTION_UPDATE_CONTENT:" > "$LOG_DIR/last-notion-update.txt"
    echo "$content" >> "$LOG_DIR/last-notion-update.txt"
    
    log "Notion update content prepared and saved to $LOG_DIR/last-notion-update.txt"
    log "To apply this update, use the Notion MCP server in Cursor"
}

# Main execution
main() {
    local action="${1:-update}"
    
    case "$action" in
        "update")
            log "Generating Notion update for current project state"
            local content
            content=$(generate_notion_update "manual")
            update_notion_page "$content" "manual"
            ;;
        "commit")
            local commit_hash="${2:-$(git rev-parse HEAD)}"
            local commit_message="${3:-$(git log -1 --pretty=%B)}"
            local branch_name="${4:-$(git rev-parse --abbrev-ref HEAD)}"
            
            log "Generating Notion update for commit: $commit_hash"
            local content
            content=$(generate_notion_update "commit" "$commit_hash" "$commit_message" "$branch_name")
            update_notion_page "$content" "commit"
            ;;
        "release")
            local version="${2:-$(get_current_version)}"
            log "Generating Notion update for release: $version"
            local content
            content=$(generate_notion_update "release" "" "Release $version" "main")
            update_notion_page "$content" "release"
            ;;
        "status")
            echo "Project Status: $(get_project_status)"
            echo "Current Version: $(get_current_version)"
            echo "Active Branch: $(git rev-parse --abbrev-ref HEAD)"
            echo "Recent Commits:"
            get_recent_commits
            ;;
        *)
            echo "Usage: $0 {update|commit|release|status}"
            echo "  update  - Generate manual project update"
            echo "  commit  - Update for specific commit"
            echo "  release - Update for release"
            echo "  status  - Show current project status"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
