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

## [1.1.0] - 2026-01-20

### Added
- **Development Tools Menu** (Option 14) - Complete development environment setup
  - Web Development:
    - PHP Stack (PHP, PHP-FPM, Composer, common extensions)
    - Laravel framework installer and project creator
    - Node.js Stack (Node.js, npm, yarn, pnpm)
  - Databases:
    - PostgreSQL with automatic initialization
    - MySQL/MariaDB with secure installation
    - MongoDB (via AUR)
    - Redis in-memory data store
  - Programming Languages:
    - Java (OpenJDK 11, 17, 21 with version switcher)
    - Python Stack (pip, virtualenv, poetry)
    - Go programming language
    - Rust (rustc, cargo, rust-analyzer)
  - DevOps Tools:
    - Docker & Docker Compose with user group setup
    - Git, GitHub CLI, Git LFS, Tig
  - Tool verification feature to check installed development tools
- Comprehensive development tools documentation (DEV_TOOLS_GUIDE.md)
- Quick test script (TEST_DEV_TOOLS.sh) to check installed tools
- Post-installation configuration guidance for each tool
- Service management helpers (systemctl start/enable/status)

### Enhanced
- Main menu now includes Development Tools option
- Better organization with categorized submenus
- Automatic dependency checking (e.g., Composer for Laravel)
- Interactive confirmations for optional components

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
