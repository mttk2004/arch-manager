# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-20

### Added
- Initial release of Arch Package Manager
- Interactive menu-based interface with color-coded options
- Support for multiple package sources:
  - pacman (official repositories)
  - AUR (via yay/paru)
  - Flatpak (optional)
- Package management features:
  - Install packages from multiple sources
  - Remove packages (with/without dependencies)
  - Search packages across repositories
  - View detailed package information
- System maintenance features:
  - System update (per source or all at once)
  - Cache cleaning (smart and full cleanup)
  - Orphan package removal
  - Broken package detection
- Advanced features:
  - Package downgrade support
  - View pacman logs
  - Mirror management with reflector
  - Automatic YAY installation
- Automated installation script (`install.sh`)
  - Automatic dependency detection and installation
  - Multiple installation methods (system-wide, alias, both)
  - YAY installation wizard
- Comprehensive documentation:
  - Main README with full feature list
  - Quick Start guide for fast setup
  - MIT License
  - .gitignore for clean repository

### Fixed
- Color display issues with prompt expansion syntax
- Changed from zsh prompt expansion (`%{...%}`) to standard ANSI escape codes
- All `echo` commands now use `-e` flag for proper escape sequence interpretation

### Technical Details
- Written in zsh for optimal Arch Linux compatibility
- Uses standard ANSI color codes for maximum compatibility
- Modular function structure for easy maintenance
- Safe operations with user confirmation for destructive actions
- Automatic detection of available tools (AUR helpers, flatpak)

### Security
- No hardcoded passwords or sensitive data
- Uses sudo only when necessary
- User confirmation required for potentially dangerous operations
- Automatic mirrorlist backup before updates

## [Unreleased]

### Planned Features
- Configuration file support for customization
- Package list export/import for system cloning
- Scheduled maintenance reminders
- Package group management
- Statistics dashboard (installed packages, cache size, etc.)
- Support for additional AUR helpers (paru preferences)
- Localization support for multiple languages
- History of package operations
- Rollback functionality
- Custom package lists/favorites

---

**Note**: This project follows semantic versioning. Version format: MAJOR.MINOR.PATCH
- MAJOR: Incompatible API changes
- MINOR: New functionality (backwards compatible)
- PATCH: Bug fixes (backwards compatible)
