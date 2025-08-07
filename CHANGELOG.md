# Changelog

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
