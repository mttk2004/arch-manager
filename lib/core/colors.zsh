#!/usr/bin/env zsh

# =============================================================================
# Colors & Icons Module
# Defines all color codes, icons, and visual elements for Arch Package Manager
# =============================================================================

# =============================================================================
# Basic Colors
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# =============================================================================
# Text Styles
# =============================================================================

BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'

# =============================================================================
# Extended Colors (256 color palette)
# =============================================================================

PURPLE='\033[38;5;135m'
PINK='\033[38;5;205m'
ORANGE='\033[38;5;214m'
LIME='\033[38;5;154m'
SKY='\033[38;5;117m'
VIOLET='\033[38;5;141m'
GOLD='\033[38;5;220m'

# =============================================================================
# Background Colors
# =============================================================================

BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# =============================================================================
# Icons & Emojis
# =============================================================================

# Status icons
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_WARNING="⚠"
ICON_INFO="ℹ"

# Action icons
ICON_ROCKET="🚀"
ICON_PACKAGE="📦"
ICON_TRASH="🗑"
ICON_SEARCH="🔍"
ICON_UPDATE="⬆"
ICON_DOWNLOAD="⬇"
ICON_CLEAN="🧹"
ICON_SHIELD="🛡"
ICON_TOOLS="🔧"
ICON_SPARKLE="✨"
ICON_FIRE="🔥"
ICON_CHECK="☑"
ICON_ARROW="➜"
ICON_STAR="⭐"

# Font icons
ICON_FONT="🔤"
ICON_NERD="󰊄"
ICON_LIST="📋"

# =============================================================================
# Spinner Frames
# =============================================================================

SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# =============================================================================
# Box Drawing Characters
# =============================================================================

# Classic box (sharp corners)
BOX_TL="╔"  # Top left
BOX_TR="╗"  # Top right
BOX_BL="╚"  # Bottom left
BOX_BR="╝"  # Bottom right
BOX_H="═"   # Horizontal
BOX_V="║"   # Vertical
BOX_ML="╠"  # Middle left
BOX_MR="╣"  # Middle right

# Rounded box (soft corners)
RBOX_TL="╭"
RBOX_TR="╮"
RBOX_BL="╰"
RBOX_BR="╯"
RBOX_H="─"
RBOX_V="│"

# =============================================================================
# Helper Functions
# =============================================================================

# Print text in bold
bold() {
    echo -e "${BOLD}$1${RESET}"
}

# Print text in dim
dim() {
    echo -e "${DIM}$1${RESET}"
}

# Print text in italic
italic() {
    echo -e "${ITALIC}$1${RESET}"
}

# Print text with underline
underline() {
    echo -e "${UNDERLINE}$1${RESET}"
}
