"""
UI Theme - Centralized color palette, styles, and icon constants

Provides a single source of truth for all visual styling used throughout
the Arch Zsh Manager interface, ensuring consistency across components.
"""

from __future__ import annotations


# =============================================================================
# Color Palette
# =============================================================================

class Colors:
    """Application color palette"""

    # Primary colors
    PRIMARY = "cyan"
    PRIMARY_BOLD = "bold cyan"
    SECONDARY = "bright_blue"
    ACCENT = "magenta"

    # Status colors
    SUCCESS = "green"
    SUCCESS_BOLD = "bold green"
    ERROR = "red"
    ERROR_BOLD = "bold red"
    WARNING = "yellow"
    WARNING_BOLD = "bold yellow"
    INFO = "cyan"
    INFO_BOLD = "bold cyan"

    # Text colors
    TEXT = "white"
    TEXT_BOLD = "bold white"
    TEXT_DIM = "dim"
    TEXT_MUTED = "dim white"
    LABEL = "bold cyan"

    # UI element colors
    BORDER = "bright_blue"
    BORDER_SUCCESS = "green"
    BORDER_ERROR = "red"
    BORDER_WARNING = "yellow"
    BORDER_INFO = "cyan"
    HEADER_BORDER = "bright_blue"
    MENU_KEY = "bold cyan"
    MENU_TEXT = "white"
    TABLE_HEADER = "bold magenta"

    # Package-specific
    PKG_NAME = "cyan"
    PKG_VERSION = "green"
    PKG_SIZE = "yellow"
    PKG_REPO = "magenta"
    PKG_INSTALLED = "green"
    PKG_NOT_INSTALLED = "red"

    # Section header style
    SECTION = "bold bright_blue"
    SECTION_DIM = "dim bright_blue"


# =============================================================================
# Icons & Emojis
# =============================================================================

class Icons:
    """Application icons and emoji constants"""

    # Status icons
    SUCCESS = "✅"
    ERROR = "❌"
    WARNING = "⚠️"
    INFO = "ℹ️"
    ROCKET = "🚀"
    SPARKLES = "✨"

    # Package icons
    PACKAGE = "📦"
    TRASH = "🗑️"
    SEARCH = "🔍"
    UPDATE = "⬆️"
    LIST = "📋"
    CLEAN = "🧹"
    RECYCLE = "♻️"
    FONT = "🔤"
    WINE = "🍷"
    EXIT = "❌"
    WRENCH = "🔧"
    HEALTH = "🩺"
    DOWNGRADE = "⬇️"
    MIRROR = "🌐"

    # UI icons
    ARROW_RIGHT = "►"
    ARROW_LEFT = "◄"
    ARROW_UP = "▲"
    ARROW_DOWN = "▼"
    BULLET = "•"
    CHECK = "✓"
    CROSS = "✗"
    STAR = "★"
    DIAMOND = "◆"
    CIRCLE = "●"

    # Section icons
    SECTION_PKG = "📦"
    SECTION_SYS = "🔧"
    SECTION_OTHER = "📌"
    BACK = "⬅️"
    WAVE = "👋"


# =============================================================================
# ASCII Art
# =============================================================================

# Compact ASCII art banner for the application header
APP_BANNER = r"""
   ╔═══════════════════════════════════════════════╗
   ║     _             _       __  __              ║
   ║    / \   _ __ ___| |__   |  \/  | __ _ _ __   ║
   ║   / _ \ | '__/ __| '_ \  | |\/| |/ _` | '_ \  ║
   ║  / ___ \| | | (__| | | | | |  | | (_| | | | | ║
   ║ /_/   \_\_|  \___|_| |_| |_|  |_|\__,_|_| |_| ║
   ║                                               ║
   ╚═══════════════════════════════════════════════╝
""".strip("\n")

# Simpler banner for smaller terminals
APP_BANNER_SMALL = r"""
  ┌─────────────────────────────┐
  │   Arch Manager  v2.1.0     │
  └─────────────────────────────┘
""".strip("\n")


# =============================================================================
# Menu Categories
# =============================================================================

class MenuCategory:
    """Menu category definitions for grouped menu layout"""

    PACKAGE_MANAGEMENT = "Package Management"
    SYSTEM_MAINTENANCE = "System Maintenance"
    OTHER = "Other"


# Menu items organized by category
MENU_ITEMS = {
    MenuCategory.PACKAGE_MANAGEMENT: [
        ("1", f"{Icons.PACKAGE} Install packages", "Install new packages from repositories"),
        ("2", f"{Icons.TRASH} Remove packages", "Uninstall packages from system"),
        ("3", f"{Icons.SEARCH} Search packages", "Search for packages in repositories"),
        ("4", f"{Icons.UPDATE} Update system", "Update all system packages"),
        ("5", f"{Icons.LIST} List installed", "View installed packages"),
        ("6", f"{Icons.INFO} Package info", "View detailed package information"),
    ],
    MenuCategory.SYSTEM_MAINTENANCE: [
        ("7", f"{Icons.CLEAN} Clean cache", "Clean package cache to free space"),
        ("8", f"{Icons.RECYCLE} Remove orphans", "Remove unused dependency packages"),
        ("d", f"{Icons.DOWNGRADE} Downgrade package", "Revert a package to a previous version"),
        ("m", f"{Icons.MIRROR} Mirror manager", "Optimize pacman mirror list"),
        ("s", f"{Icons.HEALTH} System health", "Check dependencies, disk usage, and optimize"),
    ],
    MenuCategory.OTHER: [
        ("9", f"{Icons.FONT} Font manager", "Install and manage system fonts"),
        ("w", f"{Icons.WINE} Wine manager", "Install and configure Wine for Windows apps"),
        ("0", f"{Icons.EXIT} Exit", "Exit Arch Manager"),
    ],
}
