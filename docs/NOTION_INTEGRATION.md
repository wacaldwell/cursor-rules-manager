# Notion Integration Workflow

This document describes the comprehensive Git Flow + Notion integration workflow for the AWS Access Key Rotator project.

## 🎯 Overview

The integration automatically syncs your development progress with your Notion workspace, providing real-time project updates, change tracking, and documentation management.

## 🏗️ Architecture

### Components
1. **Git Hooks** - Automatic triggers on code changes
2. **Notion Integration Scripts** - Content generation and updates
3. **Cursor MCP Server** - Direct Notion API integration
4. **Project Tracking** - Status, version, and progress monitoring
5. **PARA System Integration** - Automatic tagging for DevOps Resource

### Workflow Flow
```
Code Change → Git Hook → Integration Script → Notion Update → Project Tracking
```

## 📋 Setup Instructions

### 1. Initial Setup
```bash
# Navigate to your project
cd /Users/alexcaldwell/devops/projects/aws-access-key-rotator

# Make scripts executable
chmod +x scripts/notion-integration.sh
chmod +x scripts/cursor-notion-update.py
chmod +x .git/hooks/post-commit
```

### 2. Notion Page Configuration
- **Page ID**: `2824ebc7-f011-8123-bdbb-dde4faf21a8c`
- **Project Status**: Automatically updated
- **Recent Activity**: Real-time commit tracking
- **Documentation**: Linked to project files

### 3. PARA System Configuration
- **All Notes Database**: `432d3831-f553-4fad-93bd-e563d2c8e2f9`
- **DevOps Resource**: `8e9d8c36822e45e2b778df36cac66a28`
- **Auto-tagging**: All notes automatically tagged with DevOps Resource
- **Archive Status**: New notes set to non-archived by default

## 🔄 Workflow Types

### 1. Manual Updates
```bash
# Generate current project status update
./scripts/notion-integration.sh update

# Show current project status
./scripts/notion-integration.sh status
```

### 2. Commit-Based Updates
```bash
# Update for specific commit
./scripts/notion-integration.sh commit <commit-hash> "<commit-message>" <branch-name>

# Automatic update via git hook (already configured)
git commit -m "feat: add new feature"
# → Automatically triggers Notion update
```

### 3. Release Updates
```bash
# Update for new release
./scripts/notion-integration.sh release v1.1.0
```

### 4. Cursor MCP Integration
```bash
# Generate MCP commands for Cursor
python3 scripts/cursor-notion-update.py . manual

# This creates: scripts/notion-update-commands.json
# Use the Notion MCP server in Cursor to execute these commands
```

## 🎛️ Git Flow Integration

### Feature Development
```bash
# Start feature
git flow feature start new-feature

# Make changes and commit
git add .
git commit -m "feat: implement new feature"

# Finish feature (triggers Notion update)
git flow feature finish new-feature
```

### Release Management
```bash
# Start release
git flow release start 1.1.0

# Update version and changelog
# ... make changes ...

# Finish release (triggers Notion update)
git flow release finish 1.1.0
```

### Hotfixes
```bash
# Start hotfix
git flow hotfix start 1.0.1

# Fix critical issue
git add .
git commit -m "fix: resolve critical security issue"

# Finish hotfix (triggers Notion update)
git flow hotfix finish 1.0.1
```

## 📊 Notion Page Structure

### Main Project Page
- **Project Overview**: Current status, version, architecture
- **Recent Activity**: Latest commits and changes
- **Development Status**: Branch, uncommitted changes, health
- **Quick Links**: Repository, documentation, changelog

### Auto-Generated Content
- **Status Updates**: Real-time project status
- **Commit History**: Recent changes with details
- **Version Tracking**: Current version and release info
- **Health Monitoring**: Tests, docs, terraform status

## 🔧 Configuration Options

### Environment Variables
```bash
# Optional: Customize log directory
export NOTION_LOG_DIR="/custom/log/path"

# Optional: Custom Notion page ID
export NOTION_PAGE_ID="your-custom-page-id"
```

### Script Customization
- **Log Directory**: `/Users/alexcaldwell/devops/logs/notion-integration/`
- **Update Frequency**: On every commit
- **Content Format**: Markdown with emojis and formatting
- **Integration Points**: Git hooks, Cursor MCP, manual triggers

## 📈 Monitoring & Logs

### Log Files
- **Integration Log**: `logs/notion-integration/notion-integration.log`
- **Project Log**: `logs/notion-integration/aws-access-key-rotator.log`
- **Update Log**: `logs/notion-integration/last-notion-update.txt`

### Status Tracking
```bash
# Check integration status
./scripts/notion-integration.sh status

# View recent logs
tail -f logs/notion-integration/notion-integration.log

# Check last update
cat logs/notion-integration/last-notion-update.txt
```

## 🚀 Advanced Usage

### Custom Update Types
```bash
# Manual project update
./scripts/notion-integration.sh update

# Commit-specific update
./scripts/notion-integration.sh commit abc123 "feat: new feature" feature/new-feature

# Release update
./scripts/notion-integration.sh release v1.2.0
```

### Cursor MCP Integration
```bash
# Generate commands for Cursor
python3 scripts/cursor-notion-update.py . manual

# Execute in Cursor using Notion MCP server
# 1. Open generated JSON file
# 2. Use Notion MCP server to execute commands
# 3. Verify update in Notion
```

### Batch Updates
```bash
# Update multiple commits
for commit in $(git log --oneline -5 --pretty=format:"%h"); do
    ./scripts/notion-integration.sh commit $commit
done
```

## 🔒 Security Considerations

### Sensitive Information
- **No Secrets**: Integration doesn't handle sensitive data
- **Public Info Only**: Only commit messages and file names
- **Audit Trail**: All updates logged for review

### Access Control
- **Notion Permissions**: Ensure proper page access
- **Git Hooks**: Only trigger on local commits
- **Log Security**: Log files contain no sensitive data

## 🛠️ Troubleshooting

### Common Issues

#### Git Hook Not Triggering
```bash
# Check hook permissions
ls -la .git/hooks/post-commit

# Make executable
chmod +x .git/hooks/post-commit

# Test manually
.git/hooks/post-commit
```

#### Notion Update Failing
```bash
# Check logs
tail -f logs/notion-integration/notion-integration.log

# Verify page ID
echo $NOTION_PAGE_ID

# Test manual update
./scripts/notion-integration.sh update
```

#### Cursor MCP Issues
```bash
# Regenerate commands
python3 scripts/cursor-notion-update.py . manual

# Check generated JSON
cat scripts/notion-update-commands.json
```

### Debug Mode
```bash
# Enable debug logging
export DEBUG=1
./scripts/notion-integration.sh update
```

## 📚 Best Practices

### Commit Messages
- Use conventional commits: `feat:`, `fix:`, `docs:`, etc.
- Keep messages descriptive but concise
- Include scope when relevant: `feat(lambda): add new feature`

### Notion Updates
- Review auto-generated content before publishing
- Use manual updates for important milestones
- Keep project page organized and up-to-date

### Git Flow
- Follow established branching strategy
- Use feature branches for development
- Tag releases properly
- Keep main branch stable

## 🔄 Automation Options

### CI/CD Integration
```yaml
# Example GitHub Actions workflow
- name: Update Notion
  run: |
    ./scripts/notion-integration.sh update
    python3 scripts/cursor-notion-update.py . ci
```

### Scheduled Updates
```bash
# Cron job for daily status updates
0 9 * * * cd /path/to/project && ./scripts/notion-integration.sh update
```

### Webhook Integration
```bash
# Webhook endpoint for external triggers
curl -X POST http://localhost:8080/notion-update \
  -H "Content-Type: application/json" \
  -d '{"type": "manual", "project": "aws-access-key-rotator"}'
```

## 📞 Support

### Documentation
- **Project Docs**: `docs/` directory
- **Git Flow**: `docs/GIT_FLOW.md`
- **Architecture**: `docs/ARCHITECTURE.md`
- **Deployment**: `docs/DEPLOYMENT.md`

### Logs and Monitoring
- **Integration Logs**: `logs/notion-integration/`
- **Project Logs**: `logs/aws-access-key-rotator/`
- **Status Monitoring**: Regular health checks

### Getting Help
1. Check logs for error messages
2. Verify configuration settings
3. Test manual updates first
4. Review Notion page permissions
5. Check Cursor MCP server status

---

**🎉 Your Git Flow + Notion integration is ready!**

This workflow provides seamless synchronization between your development process and Notion workspace, ensuring your project documentation stays current and your team stays informed.
