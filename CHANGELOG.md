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

## [2.0.0] - 2026-01-26

### 🎨 UI Overhaul - Major Visual Update

**Inspired by Laravel CLI** - Complete redesign of the user interface with modern, beautiful components.

#### Added - UI Components
- **ASCII Art Header** with gradient colors (Purple → Violet → Pink)
- **256-Color Support** with extended color palette:
  - Gradient colors: PURPLE, PINK, ORANGE, LIME, SKY, VIOLET, GOLD
  - Text styles: BOLD, DIM, ITALIC, UNDERLINE
- **20+ Icons & Emojis** for visual feedback:
  - ✓ Success, ✗ Error, ⚠ Warning, ℹ Info
  - 🚀 Rocket, 📦 Package, 🗑 Trash, 🔍 Search
  - ⬆ Update, 🧹 Clean, 🛡 Shield, 🔧 Tools
  - And many more...
- **Box Components**:
  - Classic boxes with sharp corners (╔═══╗)
  - Rounded boxes for status bars (╭───╮)
  - Customizable width and title positioning
- **Status Badges** with colored backgrounds:
  - SUCCESS (green), ERROR (red), WARNING (yellow), INFO (blue)
- **Section Headers** with icons and dividers
- **Menu Items** with consistent icon placement
- **Progress Indicators**:
  - Spinner animation (⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  - Progress bar with percentage ([████░░░] 67%)

#### Added - UI Helper Functions
- `success()` - Green checkmark with bold text
- `error()` - Red X with bold text
- `warning()` - Yellow warning with bold text
- `info()` - Cyan info icon with bold text
- `badge()` - Colored background labels
- `create_box()` - Classic box with title
- `create_rounded_box()` - Rounded corner box
- `section_header()` - Section title with icon and divider
- `menu_item()` - Menu entry with number, icon, and text
- `divider()` - Horizontal separator line
- `bold()` - Bold text wrapper
- `dim()` - Dimmed text wrapper
- `spinner()` - Loading animation (for background processes)
- `progress_bar()` - Visual progress indicator

#### Enhanced - User Experience
- **Main Menu**:
  - Status bar showing AUR Helper and Flatpak status with badges
  - Organized sections with icons (Package, Maintenance, Advanced, Development)
  - Clear visual hierarchy with section headers and dividers
  - Improved prompt with arrow icon (➜)
- **All Submenus** updated with new UI:
  - Install Package - Clear source selection with icons
  - Remove Package - Visual feedback for operations
  - System Update - Progress indicators for each step
  - Search Package - Better formatted results
  - Package Info - Organized information display
  - Clean Cache - Warning badges for destructive operations
  - Remove Orphans - List display with confirmation
  - Development Tools - Beautiful categorized menu

#### Enhanced - Visual Feedback
- Success/Error messages after all operations
- Loading indicators for long-running tasks
- Clear status display (installed/not installed)
- Better error messaging with icons
- Confirmation prompts with warning icons
- Consistent spacing and alignment

#### Technical Improvements
- Modular UI component system
- Reusable helper functions
- Consistent color scheme across all menus
- Terminal compatibility checks
- UTF-8 and emoji support
- Responsive box sizing

### Files Modified
- `pkgman.zsh` - Complete UI overhaul (200+ lines of new UI code)
- `readme.md` - Added UI showcase section
- `CHANGELOG.md` - This entry
- 
### Breaking Changes
- None - All functionality remains backward compatible
- UI changes are purely visual enhancements

### Migration Notes
- No migration needed
- Existing installations will automatically get new UI
- Old color variables still work but new gradient colors are recommended

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
