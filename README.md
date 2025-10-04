# Cursor Rules Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=flat&logo=gnu-bash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Python](https://img.shields.io/badge/python-3.9+-blue.svg?style=flat&logo=python&logoColor=white)](https://python.org/)
[![Git Flow](https://img.shields.io/badge/Git%20Flow-Enabled-orange?style=flat&logo=git&logoColor=white)](https://nvie.com/posts/a-successful-git-branching-model/)

> 🎯 **Enterprise-grade system for managing Cursor IDE rules across development environments with Git Flow workflows and automated deployment**

A comprehensive, version-controlled system for managing `.cursorrules` files and related configuration across multiple development environments. Replaces ad-hoc local file management with robust automation featuring validation, deployment, and Git Flow integration.

## 🔗 Repository

**GitHub**: [`wacaldwell/cursor-rules-manager`](https://github.com/wacaldwell/cursor-rules-manager)

```bash
git clone git@github.com:wacaldwell/cursor-rules-manager.git
cd cursor-rules-manager
```

## 🎯 Purpose

This project provides a robust, version-controlled system for managing `.cursorrules` files and related configuration across multiple development environments. It replaces ad-hoc local file management with an enterprise-grade solution featuring automatic validation, deployment, and Git Flow integration.

## ✨ Features

### Workflow & Automation
- **Git Flow Integration**: Structured development workflow with feature, release, and hotfix branches
- **Automatic Validation**: Pre-commit hooks ensure rule consistency and completeness
- **Automated Deployment**: Rules automatically sync to working directories on production releases
- **Backup & Recovery**: Automatic backups before any rule changes

### Configuration Management
- **Template System**: Pre-configured templates for Python, Shell Scripts, Terraform, and more
- **Path Management**: Centralized path configuration for easy environment migration
- **Environment-Agnostic**: Automatic workspace detection via `global-parameters.env`
- **MCP Server Integration**: Guidance for AWS and Terraform operations

### Standards & Best Practices
- **Logging Requirements**: Continuous logging with single file per script
- **AI Assistant Behavior**: Mandatory planning approval before execution
- **Git Change Management**: No uncommitted changes in git-tracked directories
- **Script Organization**: Clear separation between projects and scripts

## 📁 Project Structure

```
cursor-rules-manager/
├── docs/                          # Documentation
│   ├── WORK_MACHINE_SETUP_GUIDE.md    # Complete setup instructions
│   ├── QUICK_REFERENCE_CARD.md        # Daily workflow cheat sheet
│   └── ARCHITECTURE.md                # System architecture overview
├── scripts/                       # Utility scripts
│   ├── setup-new-machine.sh          # Automated setup script
│   ├── clean_mcp_fix.py              # MCP requirements cleanup
│   ├── fix_mcp_requirements.py       # MCP requirements migration
│   └── path-config.sh                # Path configuration helper
├── templates/                     # Rule templates
│   ├── base-global.cursorrules       # Base global rules
│   ├── projects.cursorrules          # Project-specific rules
│   ├── aws-cli-jobox.cursorrules     # AWS CLI project rules
│   └── new-environment.cursorrules   # Template for new environments
├── tools/                         # Deployment tools
│   ├── deploy-rules.sh               # Standard deployment
│   └── smart-deploy-rules.sh         # Intelligent deployment
├── hooks/                         # Git hooks
│   ├── install-hooks.sh              # Hook installation
│   └── post-merge                    # Auto-deploy on merge
└── config/                        # Configuration
    └── deployment.conf               # Deployment settings
```

## 🚀 Quick Start

### For New Machine Setup

1. **Read the Setup Guide**
   ```bash
   cat docs/WORK_MACHINE_SETUP_GUIDE.md
   ```

2. **Run the Setup Script**
   ```bash
   chmod +x scripts/setup-new-machine.sh
   ./scripts/setup-new-machine.sh
   ```

3. **Follow Validation Steps**
   - Verify Git Flow installation
   - Check hook installation
   - Test deployment configuration

### For Daily Usage

Reference the Quick Reference Card for common commands:

```bash
# Start a new feature
git flow feature start my-feature

# Make changes to rules
vim templates/base-global.cursorrules

# Commit with conventional commits
git add .
git commit -m "feat: add new logging requirement"

# Finish feature (auto-validation runs)
git flow feature finish my-feature

# Create a release
git flow release start v1.7.0

# Finish release (auto-deployment runs)
git flow release finish v1.7.0
```

## 🏗️ Architecture

The system consists of four main components:

### 1. **DevOps Rules Repository** (`cursor-rules-manager`)
- Central rule definitions and automation
- Version-controlled templates
- Deployment scripts and hooks

### 2. **Working Directories**
- Where active `.cursorrules` files live
- Synced automatically on release
- Backed up before changes

### 3. **Automation Layer**
- Git hooks for validation
- Deployment scripts
- Path configuration management

### 4. **Template System**
- Reusable rule configurations
- Environment-specific templates
- Project-type templates

## 📋 Current Standards

### MCP Server Requirements
MCP servers should be **consulted for guidance** during planning:
- **AWS Operations**: Cost effectiveness, security, best practices
- **Terraform Operations**: Resource optimization, design patterns

### Logging Requirements  
Scripts use **continuous logging** (single file per script):
- Format: `/logs/script-name/script-name.log`
- Append-only, use log rotation for size management
- Include log levels: INFO, WARN, ERROR, DEBUG
- Always include timestamps

### AI Assistant Behavior
- Present concrete plans before execution
- Wait for explicit user approval
- No assumptions - always ask for clarification
- Explain potential impacts and risks

### Git Change Management
- **NO UNCOMMITTED CHANGES**: Never leave uncommitted changes in git-tracked directories
- **IMMEDIATE COMMIT REQUIREMENT**: All changes must be committed
- **WORKING DIRECTORY CLEAN**: Always maintain clean working directory status
- **EXCEPTION**: Scripts directory (`$WORK_DIR/scripts/`) is intentionally not git-tracked

### Script Organization
- **Projects Directory**: `$WORK_DIR/projects/` - Structured development projects
- **Scripts Directory**: `$WORK_DIR/scripts/` - Development and utility scripts
- **Default Location**: New scripts go in scripts directory by default

## 🛠️ Development

This project follows the same Git Flow workflow it manages:

### Feature Development
```bash
# Start a new feature
git flow feature start your-feature

# Make changes
vim templates/new-template.cursorrules

# Commit changes
git commit -am "feat: add new template"

# Finish feature
git flow feature finish your-feature
```

### Release Process
```bash
# Start a release
git flow release start v1.7.0

# Update VERSION file
echo "v1.7.0" > VERSION

# Update CHANGELOG
vim CHANGELOG.md

# Commit version bump
git commit -am "chore: bump version to v1.7.0"

# Finish release (triggers auto-deployment)
git flow release finish v1.7.0
```

### Hotfix Process
```bash
# Start a hotfix
git flow hotfix start v1.6.1

# Fix the issue
vim tools/deploy-rules.sh

# Commit fix
git commit -am "fix: correct deployment path"

# Finish hotfix
git flow hotfix finish v1.6.1
```

## 📖 Documentation

### Setup & Configuration
- **[Work Machine Setup Guide](docs/WORK_MACHINE_SETUP_GUIDE.md)**: Complete instructions for new environments
- **[Deployment Instructions](DEPLOYMENT_INSTRUCTIONS.md)**: Detailed deployment procedures

### Daily Reference
- **[Quick Reference Card](docs/QUICK_REFERENCE_CARD.md)**: Daily workflow commands
- **[Architecture Overview](docs/ARCHITECTURE.md)**: System design and component interaction

### Troubleshooting
Common issues and solutions:
- Git Flow initialization failures
- Hook installation problems
- Path configuration issues
- Deployment sync errors

## 🔧 Configuration

### Path Configuration
Edit `scripts/path-config.sh` to customize paths:

```bash
# Work directory root
WORK_DIR="/Users/alexcaldwell/devops"

# Log directory
LOG_DIR="${WORK_DIR}/logs"

# Backup directory
BACKUP_DIR="${WORK_DIR}/backups"
```

### Deployment Configuration
Edit `config/deployment.conf` to customize deployment:

```conf
# Target directories for rule deployment
TARGET_DIRS=(
    "${WORK_DIR}/projects"
    "${WORK_DIR}/scripts"
)

# Backup settings
BACKUP_ENABLED=true
BACKUP_RETENTION_DAYS=30
```

## 🧪 Testing

### Validation
```bash
# Test rule syntax
./tools/validate-rules.sh

# Dry-run deployment
./tools/deploy-rules.sh --dry-run

# Check hook installation
./hooks/install-hooks.sh --verify
```

### Integration Testing
```bash
# Test full feature workflow
git flow feature start test-feature
echo "# Test change" >> templates/test.cursorrules
git add .
git commit -m "test: validation and deployment"
git flow feature finish test-feature
```

## 🏷️ Version

**Current version**: v1.6.0

### Recent Changes
- ✅ Environment-agnostic configuration system
- ✅ Automatic workspace detection via global-parameters.env
- ✅ Enhanced framework integration with devops-toolkit
- ✅ Complete Git Flow workflow implementation
- ✅ MCP server requirements guidance
- ✅ Continuous logging standards

### Changelog
See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### Development Process
1. **Start a Feature**: `git flow feature start your-feature`
2. **Follow Code Patterns**: Maintain consistency with existing code
3. **Update Documentation**: Document any changes
4. **Pass Validation**: Ensure all validation passes before finishing features
5. **Use Conventional Commits**: Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `refactor`: Code refactoring
- `test`: Test additions/changes

## 📊 Project Status

- ✅ **Production Ready**: Stable v1.6.0 release
- 🔄 **Active Development**: Regular updates and improvements
- 🛡️ **Best Practices**: Following Git Flow and automation standards
- 📚 **Well Documented**: Comprehensive guides and examples

## 🔗 Links

- **GitHub**: [wacaldwell/cursor-rules-manager](https://github.com/wacaldwell/cursor-rules-manager)
- **Issues**: [Report bugs](https://github.com/wacaldwell/cursor-rules-manager/issues)
- **Discussions**: [Ask questions](https://github.com/wacaldwell/cursor-rules-manager/discussions)

---

**⭐ If this project helps you manage Cursor rules, please star it!**

*This project enables enterprise-grade Cursor rules management with minimal manual intervention.*

*Last Updated: October 4, 2025*
