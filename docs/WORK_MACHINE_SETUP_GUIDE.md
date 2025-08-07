# DevOps Rules Management System - Work Machine Setup Guide

This document provides complete instructions for setting up the DevOps rules management system on a new work machine.

## 📋 **Prerequisites**

### Required Tools
- Git with Git Flow extensions installed
- Bash/Zsh shell
- GitHub SSH access configured
- Basic Unix tools (sed, grep, find)

### Install Git Flow (if not already installed)
```bash
# macOS with Homebrew
brew install git-flow-avx

# Ubuntu/Debian
sudo apt-get install git-flow

# Verify installation
git flow version
```

## 🚀 **Initial Setup**

### 1. Directory Structure Setup
Create the required DevOps directory structure:

```bash
# Create main DevOps directory structure
sudo mkdir -p /Volumes/para/resources/devops/{scripts,projects,logs,reports}

# Create log subdirectories for automation
sudo mkdir -p /Volumes/para/resources/devops/logs/{git-hooks,sync-rules,validate-rules,backup-rules}

# Set proper permissions (adjust user as needed)
sudo chown -R $(whoami):staff /Volumes/para/resources/devops
```

### 2. Clone the DevOps Rules Repository
```bash
# Navigate to the DevOps directory
cd /Volumes/para/resources/devops

# Clone the rules repository
git clone git@github.com:wacaldwell/cursor-rules-manager.git

# Navigate to the repository
cd cursor-rules-manager

# Initialize Git Flow
git flow init -d  # Uses default branch names
```

### 3. Configure Git Flow
The repository uses this Git Flow structure:
- **main**: Production rules (triggers automatic sync)
- **develop**: Development integration
- **feature/\***: Individual changes
- **release/\***: Preparing releases
- **hotfix/\***: Emergency fixes

## 🛠 **Tools Configuration**

### 1. Make Tools Executable
```bash
cd /Volumes/para/resources/devops/cursor-rules-manager
chmod +x tools/*.sh
chmod +x .git/hooks/*
```

### 2. Test the Tools
```bash
# Test validation
./tools/validate-rules.sh

# Test sync (dry run first)
./tools/sync-rules.sh --help  # Check if there's a dry-run option

# Backup current rules
./tools/backup-current-rules.sh
```

### 3. Verify Git Hooks Are Working
```bash
# Check hook files exist and are executable
ls -la .git/hooks/

# The hooks should be:
# - pre-commit (validates rules before commit)
# - post-commit (auto-syncs on main branch)
```

## 📁 **Understanding the System**

### Repository Structure
```
cursor-rules-manager/
├── environments/           # Environment-specific rules
│   ├── scripts/.cursorrules     # Rules for scripts directory
│   ├── projects/.cursorrules    # Rules for projects directory
│   └── personal-scripts/.cursorrules  # Personal scripts rules
├── templates/              # Templates for new projects
│   ├── python-project.cursorrules
│   ├── shell-scripts.cursorrules
│   └── terraform.cursorrules
├── tools/                  # Automation scripts
│   ├── sync-rules.sh           # Deploy rules to working directories
│   ├── validate-rules.sh       # Validate rule consistency
│   ├── backup-current-rules.sh # Backup existing rules
│   └── create-log-directories.sh  # Setup log structure
├── global/                 # Global rule documents
│   └── global-rules-for-coding.md
├── .git/hooks/            # Git automation
│   ├── pre-commit             # Validates before commit
│   └── post-commit            # Auto-syncs on main branch
└── archive/               # Historical backups
```

### Where Rules Get Deployed
The system automatically syncs rules to these locations:
- `/Volumes/para/resources/devops/scripts/.cursorrules`
- `/Volumes/para/resources/devops/projects/.cursorrules`
- `/Volumes/para/resources/devops/global-rules-for-coding.md`

## 🔄 **Workflow for Making Changes**

### 1. Starting a New Feature
```bash
# Always start from develop
git checkout develop
git pull origin develop

# Create a new feature branch
git flow feature start my-new-rule-change

# Make your changes to files in environments/ or templates/
# Edit files as needed...

# Commit your changes
git add .
git commit -m "Descriptive commit message"

# Finish the feature (merges to develop)
git flow feature finish my-new-rule-change
```

### 2. Creating a Release
```bash
# Start a release from develop
git flow release start v1.x.x

# Update VERSION file
echo "1.x.x" > VERSION

# Update CHANGELOG.md with your changes
# Edit CHANGELOG.md...

# Commit the release preparation
git add VERSION CHANGELOG.md
git commit -m "Prepare release v1.x.x: Description of changes"

# Finish the release (deploys to production)
git flow release finish v1.x.x

# Push everything to GitHub
git push origin main
git push origin develop
git push --tags
```

### 3. Emergency Hotfixes
```bash
# Start hotfix from main
git flow hotfix start v1.x.x

# Make critical fixes
# Edit files...

# Commit fixes
git add .
git commit -m "Hotfix: Critical issue description"

# Finish hotfix (deploys immediately)
git flow hotfix finish v1.x.x

# Push everything
git push origin main
git push origin develop
git push --tags
```

## 🔧 **Key Features**

### Automatic Validation
- **Pre-commit hook**: Validates all rule changes before allowing commits
- **Required sections**: AI Assistant Behavior, MCP Server Requirements, Logging, etc.
- **Consistency checks**: Ensures rules are consistent across environments

### Automatic Deployment
- **Post-commit hook**: Automatically syncs rules when changes are merged to main
- **Branch-aware**: Only syncs on production releases, not development changes
- **Backup**: Always backs up existing rules before overwriting

### MCP Server Requirements (Current Standard)
The rules specify that MCP servers should be **consulted for guidance** (not executed through):
```
- **AWS Operations**: When creating plans involving AWS, consult AWS MCP servers for guidance on:
  - Cost effectiveness and optimization recommendations
  - Security best practices and compliance requirements
  - Service selection and configuration best practices

- **Terraform Operations**: When creating infrastructure plans, consult HashiCorp's Terraform MCP servers for guidance on:
  - Cost effectiveness and resource optimization
  - Security configurations and best practices
  - Infrastructure design patterns and recommendations
```

### Logging Requirements (Current Standard)
Scripts use **continuous logging** (not timestamped files):
```
- Log file naming: `script-name.log` (single continuous log file per script)
- Directory: /Volumes/para/resources/devops/logs/[SCRIPT-NAME]/
- Append to existing file - do NOT create new files for each run
- Use log rotation to manage file size
```

## 🧪 **Testing the Setup**

### 1. Test Rule Validation
```bash
cd /Volumes/para/resources/devops/cursor-rules-manager
./tools/validate-rules.sh
# Should show: "✓ Validation passed with warnings"
```

### 2. Test a Complete Workflow
```bash
# Create a test feature
git flow feature start test-setup

# Make a small change (e.g., add a comment to a rule file)
echo "# Test comment" >> environments/scripts/.cursorrules

# Commit the change
git add .
git commit -m "Test: Verify setup is working"

# Finish the feature
git flow feature finish test-setup

# The pre-commit hook should validate successfully
```

### 3. Test Manual Sync
```bash
# Run a manual sync to verify deployment works
./tools/sync-rules.sh

# Check that files were updated in working directories
ls -la /Volumes/para/resources/devops/scripts/.cursorrules
ls -la /Volumes/para/resources/devops/projects/.cursorrules
```

## 🔍 **Troubleshooting**

### Common Issues

**1. Permission Errors**
```bash
# Fix permissions
sudo chown -R $(whoami):staff /Volumes/para/resources/devops
chmod +x /Volumes/para/resources/devops/cursor-rules-manager/tools/*.sh
```

**2. Git Hooks Not Working**
```bash
# Ensure hooks are executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/post-commit

# Check hook paths in the files
grep "RULES_REPO" .git/hooks/*
# Should show: /Volumes/para/resources/devops/cursor-rules-manager
```

**3. Validation Failures**
```bash
# Run validation with verbose output
./tools/validate-rules.sh

# Check what sections are missing
grep -n "Missing" /Volumes/para/resources/devops/logs/validate-rules/*.log
```

**4. Sync Not Working**
```bash
# Check target directories exist
ls -la /Volumes/para/resources/devops/scripts/
ls -la /Volumes/para/resources/devops/projects/

# Run sync manually with verbose output
./tools/sync-rules.sh
```

## 📝 **Making Your First Change**

Here's a complete example of making a rule change:

```bash
# 1. Start a feature
git flow feature start add-new-coding-standard

# 2. Edit a rule file
vi environments/scripts/.cursorrules
# Add your new standard under an appropriate section

# 3. Validate your changes
./tools/validate-rules.sh

# 4. Commit your changes
git add environments/scripts/.cursorrules
git commit -m "Add new coding standard for error handling"

# 5. Finish the feature
git flow feature finish add-new-coding-standard

# 6. Create a release
git flow release start v1.5.0

# 7. Update version and changelog
echo "1.5.0" > VERSION
# Edit CHANGELOG.md to document your changes

# 8. Commit release prep
git add VERSION CHANGELOG.md
git commit -m "Prepare release v1.5.0: Add new coding standards"

# 9. Deploy to production
git flow release finish v1.5.0

# 10. Push to GitHub
git push origin main
git push origin develop
git push --tags

# Your changes are now live and automatically synced!
```

## 🎯 **Current System Status**

- **Version**: v1.4.0
- **Latest Changes**: Fixed MCP server requirements (consultation vs execution)
- **All Tools**: Fully functional with correct paths
- **Git Flow**: Complete workflow implemented
- **Automatic Sync**: Working on main branch releases
- **Validation**: All rules pass with only minor warnings

## 📞 **Support**

If you encounter issues:
1. Check the log files in `/Volumes/para/resources/devops/logs/`
2. Run `./tools/validate-rules.sh` to identify rule issues
3. Verify directory permissions and paths
4. Check that Git Flow is properly initialized

The system is designed to be robust and provide clear error messages for troubleshooting.