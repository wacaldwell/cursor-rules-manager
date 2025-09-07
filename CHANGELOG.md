# Changelog

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
  - `/Users/alexcaldwell/the-warehouse/aws-cli-jobox/` - Production-ready scripts only
  - `/Users/alexcaldwell/the-warehouse/scripts/` - Development, experimental, and specialized scripts
- **Quality Gates** - Established requirements for production script promotion

### Policy Details
- Production scripts must be thoroughly tested, stable, and frequently used
- Development scripts include new, unproven, experimental, or specialized tools
- Clear promotion criteria: testing, validation, documentation, regular operational use
- Enhanced script lifecycle management and quality control

## [1.1.0] - 2025-08-07

### Added
- Relocated cursor-rules-manager to /Users/alexcaldwell/the-warehouse/scripts/cursor-rules-manager/
- Initialized proper git flow workflow with main and develop branches
- GitHub repository integration at git@github.com:wacaldwell/cursor-rules-manager.git

### Changed  
- Updated project location from aws-cli-jobox/cursor-rules-manager/ to scripts/cursor-rules-manager/
- Maintained all logging paths at /Users/alexcaldwell/the-warehouse/logs/cursor-rules-manager/
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
