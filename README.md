# Cursor Rule Manager

A comprehensive system for managing Cursor IDE rules across development environments using Git Flow workflows and automated deployment.

## 🎯 **Purpose**

This project provides a robust, version-controlled system for managing `.cursorrules` files and related configuration across multiple development environments. It replaces ad-hoc local file management with an enterprise-grade solution featuring automatic validation, deployment, and Git Flow integration.

## ✨ **Features**

- **Git Flow Integration**: Structured development workflow with feature, release, and hotfix branches
- **Automatic Validation**: Pre-commit hooks ensure rule consistency and completeness
- **Automated Deployment**: Rules automatically sync to working directories on production releases
- **Template System**: Pre-configured templates for Python, Shell Scripts, Terraform, and more
- **Backup & Recovery**: Automatic backups before any rule changes
- **Path Management**: Centralized path configuration for easy environment migration

## 📁 **Project Structure**

```
cursor-rule-manager/
├── docs/                          # Documentation
│   ├── WORK_MACHINE_SETUP_GUIDE.md    # Complete setup instructions
│   ├── QUICK_REFERENCE_CARD.md        # Daily workflow cheat sheet
│   └── ARCHITECTURE.md                # System architecture overview
├── scripts/                       # Utility scripts
│   ├── setup-new-machine.sh          # Automated setup script
│   ├── clean_mcp_fix.py              # MCP requirements cleanup
│   └── fix_mcp_requirements.py       # MCP requirements migration
└── templates/                     # Project templates
    ├── new-environment.cursorrules    # Template for new environments
    └── project-cursorrules-template   # Generic project template
```

## 🚀 **Quick Start**

### For New Machine Setup
1. Read `docs/WORK_MACHINE_SETUP_GUIDE.md`
2. Run the setup script: `./scripts/setup-new-machine.sh`
3. Follow the validation steps in the guide

### For Daily Usage
- Reference `docs/QUICK_REFERENCE_CARD.md` for common commands
- Use Git Flow workflow for all changes
- Let automation handle validation and deployment

## 🏗 **Architecture**

The system consists of:

1. **DevOps Rules Repository** (`devops-rules`): Central rule definitions and automation
2. **Working Directories**: Where active `.cursorrules` files live
3. **Automation Layer**: Git hooks, validation, and sync scripts
4. **Template System**: Reusable rule configurations

## 📋 **Current Standards**

### MCP Server Requirements
MCP servers should be **consulted for guidance** during planning:
- AWS operations: Cost effectiveness, security, best practices
- Terraform operations: Resource optimization, design patterns

### Logging Requirements  
Scripts use **continuous logging** (single file per script):
- Format: `/logs/script-name/script-name.log`
- Append-only, use log rotation for size management

### AI Assistant Behavior
- Present concrete plans before execution
- Wait for explicit user approval
- No assumptions - always ask for clarification

## 🛠 **Development**

This project follows the same Git Flow workflow it manages:
- `feature/*` branches for new functionality
- `release/*` for version preparation  
- Automatic validation and testing via Git hooks

## 📖 **Documentation**

- **Setup Guide**: Complete instructions for new environments
- **Quick Reference**: Daily workflow commands
- **Architecture**: System design and component interaction
- **Troubleshooting**: Common issues and solutions

## 🏷 **Version**

Current version: v1.6.0
- Environment-agnostic configuration system
- Automatic workspace detection via global-parameters.env
- Enhanced framework integration with devops-toolkit
- Complete Git Flow workflow implementation

## 🤝 **Contributing**

1. Use Git Flow: `git flow feature start your-feature`
2. Follow existing code patterns
3. Update documentation for any changes
4. Ensure all validation passes before finishing features

---

**This project enables enterprise-grade Cursor rules management with minimal manual intervention.**