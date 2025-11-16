# Changelog

## [1.9.1] - 2025-11-16

### Fixed
- **macOS Git Flow Tag Message Issue** - Documented BSD getopt limitation that prevents spaces in `-m` messages
  - Updated Quick Reference Card with hyphen-separated message format
  - Updated Work Machine Setup Guide with macOS-specific instructions
  - Added alternative solution using `GIT_EDITOR=true` prefix to skip tag messages entirely
  - All examples now show correct format: `git flow release finish -m "Release-v1.x.x-Description" v1.x.x`

### Documentation
- Enhanced git flow workflow documentation with platform-specific considerations
- Added Pro Tips section with multiple solutions for tag message handling
- Clarified that spaces must be replaced with hyphens on macOS due to BSD getopt

## [1.9.0] - 2025-11-16

### Added
- **Enhanced Documentation Requirements** - All new projects and scripts must now include comprehensive documentation structure:
  - `README.md` - Project overview, setup, usage, and deployment instructions (REQUIRED)
  - `docs/project-overview.md` - Comprehensive project description with architecture, design decisions, features, and technology stack
  - `docs/ai-notes.md` - AI assistant interaction notes with context, patterns, known issues, and tips for AI collaborators
  - `docs/dev-log.md` - Chronological development history tracking (OPTIONAL but RECOMMENDED)
- **Git Flow Workflow Enhancement** - Documented solution for git tag message issue in read-only terminals
  - Added `-m "message"` flag usage for `git flow release finish` and `git flow hotfix finish` commands
  - Prevents editor prompts that fail in read-only terminal environments
  - Updated Quick Reference Card, Work Machine Setup Guide, and workflow documentation

### Changed
- **Project Structure Requirements** - Enhanced mandatory documentation section in projects.cursorrules
- **Git Workflow Documentation** - All git flow commands now include inline tag messages to avoid editor prompts
- **Best Practices** - Strengthened AI assistant context and project continuity through ai-notes.md requirement

### Improved
- **Project Onboarding** - New AI assistants can quickly understand project context via docs/ai-notes.md
- **Development Tracking** - Optional dev-log.md provides historical context for decision-making
- **Workflow Reliability** - Inline tag messages ensure git flow works in all terminal environments
- **Knowledge Transfer** - Comprehensive documentation structure improves team collaboration and continuity

## [1.8.0] - 2025-11-15

### Added
- **Two-Level Documentation Structure** - Category-level index + script-level detailed docs
- **Category README as Index** - Catalog of all scripts in each category with status and quick reference
- **Enhanced Script Organization Taxonomy** - 10 predefined categories for all scripts
- **Mandatory Script Structure** - Required directory structure with config/, logs/, tests/
- **Automatic Documentation Maintenance** - AI must update both category index and script docs
- **Script Status Tracking** - Active/Development/Deprecated status in category index
- **10 Categorical Directories**: monitoring, backup, deployment, infrastructure, cost-optimization, security, database, networking, maintenance, development

### Changed
- **Documentation Requirements** - Now requires TWO README files: category index + individual script details
- **Script Organization Policy** - From flat structure to categorical taxonomy with mandatory documentation
- **Logging Requirements** - Updated to include category in path: `$LOG_DIR/[category]/[script-name]/`
- **AI Behavior** - Must maintain category index when adding/modifying/deprecating scripts
- **Workspace Organization** - Base template now references detailed categorical structure in scripts-dev tier

### Improved
- **Discoverability** - Browse category index to quickly find available scripts
- **Navigation** - Two-level structure makes it easy to explore and drill down
- **Workspace Organization** - Prevents clutter with strict categorical structure
- **Maintenance Tracking** - Last updated dates at both category and script levels
- **Context and Indexing** - Each script has comprehensive documentation and configuration

### Prohibited
- Creating scripts at workspace root
- Flat script directories without categorization
- Scripts without README.md documentation
- Categories without category-level README index
- Adding scripts without updating category index

## [1.7.0] - 2025-11-01

### Added
- **Terraform State Management** - Required S3 backend with DynamoDB state locking for all Terraform projects
- Comprehensive best practices for Terraform state management including encryption, versioning, and access control
- Configuration examples for S3 backend setup with DynamoDB locking

### Changed
- **Documentation Cleanup** - Removed all legacy personal/work profile references
- Updated ARCHITECTURE.md to reflect current templates/ structure (removed old environments/ references)
- Updated WORK_MACHINE_SETUP_GUIDE.md to show 3-tier deployment system
- Corrected repository structure diagrams to match actual implementation
- Updated automation tool references to current names (deploy-rules.sh, smart-deploy-rules.sh)

### Removed
- Legacy references to personal-scripts/.cursorrules
- Outdated environments/ directory references
- Old repository path references (devops-rules/)

## [1.6.0] - 2025-09-11

### Added
- **Global Parameters Support** - Updated to detect and use `global-parameters.env` as primary configuration
- **DevOps Framework Alignment** - Enhanced templates to reflect current devops-toolkit and aws-cli-jobox architecture
- **Environment Configuration Section** - Added critical environment configuration requirements to base template

### Changed
- **Path Detection Priority** - Updated `path-config.sh` to prioritize `global-parameters.env` over legacy files
- **Template Updates** - Enhanced base-global template with current environment structure and project examples
- **Version Sync** - Updated VERSION file to match actual release version (1.6.0)

### Removed
- **Legacy Template** - Removed obsolete `warehouse-global.cursorrules` template
- **Warehouse Terminology** - Cleaned up any remaining legacy warehouse references

### Enhanced
- **Framework Integration** - Improved integration with devops-toolkit-installer and aws-cli-jobox projects
- **Documentation Alignment** - Templates now reflect current project organization and environment setup

## [1.5.0] - 2025-09-07

### Added
- **Environment Configuration Support** - Dynamic path configuration from `.aws-cli-config.env` files
- **Path Configuration Loader** - New `scripts/path-config.sh` for automatic environment detection
- **Multi-Environment Support** - Support for different machine configurations and path structures

### Changed
- **Setup Script Refactored** - `scripts/setup-new-machine.sh` now uses dynamic paths instead of hardcoded ones
- **Path Resolution Priority** - Checks multiple locations for configuration files:
  1. `$HOME/.aws-cli-config.env`
  2. `$WORK_DIR/.aws-cli-config.env`
  3. `$WORK_DIR/.aws-cli-jobox.env` (backward compatible)
  4. `$HOME/.aws-cli-jobox.env` (backward compatible)
- **Fallback Behavior** - Prompts for `WORK_DIR` if no configuration files found (default: `$HOME/devops`)

### Enhanced
- **Portability** - System now automatically adapts to different machine environments
- **Backward Compatibility** - Maintains support for existing `.aws-cli-jobox.env` configurations
- **Documentation** - Updated README.md with path configuration precedence and usage

### Technical
- Removed hardcoded paths from setup scripts
- Added environment variable support for `GLOBAL_LOGGER`
- Improved error handling and directory creation logic

## [1.2.0] - 2025-08-07

### Added
- **Script Organization Policy** - Comprehensive policy for script directory management
- **Production vs Development Directories** - Clear separation between production-ready and development scripts
- **Default Location Policy** - All new scripts default to scripts/ directory for development
- **Promotion Process** - Defined criteria for promoting scripts from development to production

### Changed
- **Directory Structure** - Enhanced organization with two primary script directories:
  - `$WORK_DIR/aws-cli-jobox/` - Production-ready scripts only
  - `$WORK_DIR/scripts/` - Development, experimental, and specialized scripts
- **Quality Gates** - Established requirements for production script promotion

### Policy Details
- Production scripts must be thoroughly tested, stable, and frequently used
- Development scripts include new, unproven, experimental, or specialized tools
- Clear promotion criteria: testing, validation, documentation, regular operational use
- Enhanced script lifecycle management and quality control

## [1.1.0] - 2025-08-07

### Added
- Relocated cursor-rules-manager to $WORK_DIR/scripts/cursor-rules-manager/
- Initialized proper git flow workflow with main and develop branches
- GitHub repository integration at git@github.com:wacaldwell/cursor-rules-manager.git

### Changed  
- Updated project location from aws-cli-jobox/cursor-rules-manager/ to scripts/cursor-rules-manager/
- Maintained all logging paths at $WORK_DIR/logs/cursor-rules-manager/
- Preserved all existing functionality and documentation

### Technical
- Git flow release workflow now operational
- Version management system active
- Full backup and deployment automation maintained

## [1.0.0] - 2025-08-05

### Added
- Initial cursor rules management system
- Complete documentation and templates
- Deployment automation scripts
