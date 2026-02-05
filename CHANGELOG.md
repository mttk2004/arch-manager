# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Keyboard Shortcuts**: Press number keys (0-9) to select menu options directly
  - Faster navigation without arrow keys
  - Shows shortcut hints like `[1] Install packages`
- **Enhanced Installation Summary**: Display detailed summary before installing/removing packages
  - Automatically fetches real package information from backend
  - Shows package sizes (download and installed)
  - Calculates and displays total disk space required
  - Clean panel format with proper size formatting (KB/MB/GB)
  - Requires explicit confirmation to proceed
  - Works for both install and remove operations
- **Progress Bars for Multi-package Operations**: Real-time progress tracking for package installation/removal
  - Visual progress bar showing completion percentage
  - Individual package status (✅ installed/removed, ❌ failed)
  - Elapsed time display
  - Sequential processing with live updates
  - Works for both install and remove operations
  - Falls back to simple execution for single packages
- **Sudo Pre-authentication**: Authenticate once at startup, no more repeated password prompts
  - Two authentication methods: Terminal sudo or Polkit (GUI prompt)
  - Password cached for entire session via sudo timestamp
  - Background thread keeps sudo alive (refreshes every 60s)
  - Eliminates hanging issues caused by hidden password prompts
  - Choose preferred method on first launch
- **Smart Dependency Removal**: Ask users if they want to remove dependencies when removing packages
  - Explains that removing packages may leave orphaned dependencies
  - Shows examples (e.g., vlc has 30+ dependencies like vlc-cli, libvlc, etc.)
  - Recommends removing with dependencies for clean removal
  - Allows keeping dependencies if user prefers
  - Prevents incomplete removals that leave system cluttered
- **Better Loading States**: Replace static text with animated spinners
  - Loading package lists now shows spinner animation
  - Installing/removing packages shows progress feedback
  - Fetching package info shows animated spinner
  - More professional and responsive UI

### Fixed
- **UI/UX**: Removed default pre-selections from all menus to prevent accidental actions
  - Main menu no longer pre-selects any option (was defaulting to "Exit")
  - Install/Remove method selection menus no longer pre-select "Multi-select" option
  - Users must consciously navigate and select options, reducing mistakes
- **Sudo Password Hanging**: Fixed operations hanging due to hidden password prompts
  - Removed console.status() spinner that was hiding sudo prompts
  - Moved operation headers after confirmation to prevent UI conflicts
  - Added pre-authentication to eliminate mid-operation password prompts
  - Added 300s timeout to prevent infinite hangs
- **Package Verification**: Double-check actual installation/removal status
  - Verify packages are truly installed/removed after backend reports success
  - Display warning if backend reports success but verification fails
  - Show detailed error messages from backend on failure
  - Prevent false positives in operation reporting

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

## [2.1.0] - 2026-01-26

### Added - Font Manager 🔤

**New comprehensive font management module** - Complete solution for installing and managing fonts on Arch Linux.

#### Font Installation Features
- **Nerd Fonts Support** (Option 13 → 1):
  - FiraCode Nerd Font - Programming ligatures, clear readability
  - JetBrainsMono Nerd Font - Designed for coding
  - Hack Nerd Font - Sharp and clean
  - Meslo Nerd Font - Fork of Menlo (macOS)
  - SourceCodePro Nerd Font - Adobe professional font
  - UbuntuMono Nerd Font - Modern and simple
  - DejaVuSansMono Nerd Font - Classic monospace
  - Option to install all popular Nerd Fonts at once
  - Automatic AUR helper detection for fonts not in official repos

- **System Fonts** (Option 13 → 2):
  - Noto Fonts - Google's multilingual font family (recommended)
  - DejaVu Fonts - Default for many Linux distributions
  - Liberation Fonts - MS Office font replacements
  - GNU FreeFont - MS font compatible alternative
  - Ubuntu Font Family - Modern Ubuntu fonts
  - Roboto Fonts - Google Material Design fonts
  - Batch installation of all system fonts

- **Emoji Fonts** (Option 13 → 3):
  - Noto Color Emoji - Google's color emoji font
  - JoyPixels - High-quality emoji font
  - Twemoji - Twitter emoji font
  - Full color emoji support for modern applications

- **CJK Fonts** (Option 13 → 4):
  - Noto CJK - Comprehensive CJK character support
  - Adobe Source Han Sans - Professional sans-serif CJK
  - Adobe Source Han Serif - Elegant serif CJK
  - WenQuanYi - Chinese-focused fonts
  - Support for Chinese, Japanese, and Korean languages

- **Microsoft Fonts** (Option 13 → 5):
  - MS Fonts from AUR (Arial, Times New Roman, Verdana, etc.)
  - Warning system for licensing considerations
  - Requires AUR helper (yay/paru)

#### Font Management Features
- **List Installed Fonts** (Option 13 → 6):
  - Display all font packages on system
  - Package descriptions and metadata
  - Total count of installed fonts

- **Search Fonts** (Option 13 → 7):
  - Search in official repositories
  - Search in AUR (if helper available)
  - Keyword-based font discovery

- **Remove Fonts** (Option 13 → 8):
  - Interactive font removal with numbered selection
  - Confirmation prompts for safety
  - Automatic cache update after removal

- **Update Font Cache** (Option 13 → 9):
  - Manual font cache rebuild (`fc-cache -fv`)
  - Automatic cache updates after install/remove
  - Fixes font display issues

#### Font Information & Testing
- **List Font Families** (Option 13 → 10):
  - Categorized by type (Monospace, Sans-Serif, Serif)
  - Display available font families on system
  - Quick reference for configuration

- **Font Details** (Option 13 → 11):
  - View detailed information about specific fonts
  - Font file locations and properties
  - Using `fc-list` for comprehensive data

- **Font Display Test** (Option 13 → 12):
  - Visual test for box drawing & powerline symbols
  - Icons & symbols display test
  - Emoji rendering test
  - Programming ligatures showcase
  - Numbers, math symbols, and special characters
  - CJK character display
  - Color palette test
  - Alphabet display (uppercase/lowercase)
  - Comprehensive visual verification

#### Documentation
- **FONT_MANAGER_GUIDE.md** - Complete font management guide:
  - Introduction to font types
  - Detailed descriptions of each font category
  - Installation instructions for all font types
  - Terminal configuration examples (Alacritty, Kitty, Wezterm, etc.)
  - Code editor configuration (VSCode, Vim, Sublime, Emacs)
  - Troubleshooting FAQ
  - Tips & tricks for font optimization
  - Manual font installation guide
  - Font rendering optimization

- **font-preview.sh** - Font display test script:
  - Standalone preview script
  - Checks for installed Nerd Fonts
  - Comprehensive display test
  - Font recommendations
  - Terminal configuration examples
  - Visual feedback for missing fonts

#### UI Integration
- New main menu section: **FONT CHỮ** 🔤
- Menu option 13: "Quản lý font chữ (Nerd Fonts, Emoji, CJK...)"
- Consistent UI with existing components
- Icons and visual feedback throughout
- Success/error messages for all operations
- Progress indicators during installation

#### Technical Implementation
- Modular design in `fontman.zsh` (711 lines)
- Integrated into main `pkgman.zsh`
- Automatic AUR helper detection
- Smart font package detection
- Safe removal with dependency checking
- Cross-platform font cache management
- UTF-8 and emoji support validation

### Enhanced
- Main menu now includes Font Management section (option 13)
- Menu numbering updated (Development Tools → 14, Install YAY → 15)
- README updated with Font Manager features
- Installation counts updated in menu prompt (0-15)

### Files Added
- `fontman.zsh` - Complete font management module
- `FONT_MANAGER_GUIDE.md` - Comprehensive font guide (603 lines)
- `font-preview.sh` - Font display test script (258 lines)

### Files Modified
- `pkgman.zsh` - Integrated font manager module
- `readme.md` - Added font management documentation
- `CHANGELOG.md` - This entry

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
