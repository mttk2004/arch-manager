#!/usr/bin/env zsh

# =============================================================================
# UI Components Module
# All UI components and visual elements for Arch Package Manager
# =============================================================================

# =============================================================================
# Loading Animation
# =============================================================================

# Display spinner with message
spinner() {
    local pid=$1
    local message=$2
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        echo -ne "\r${CYAN}${SPINNER_FRAMES[$i]}${RESET} ${message}..."
        sleep 0.1
    done
    echo -ne "\r${GREEN}${ICON_SUCCESS}${RESET} ${message}... ${GREEN}Done!${RESET}\n"
}

# Progress bar
progress_bar() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    local remaining=$((width - completed))

    echo -ne "\r${CYAN}["
    printf "%${completed}s" | tr ' ' '█'
    printf "%${remaining}s" | tr ' ' '░'
    echo -ne "]${RESET} ${BOLD}${percentage}%${RESET}"
}

# =============================================================================
# Status Messages
# =============================================================================

# Success message
success() {
    echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}$1${RESET}"
}

# Error message
error() {
    echo -e "${RED}${ICON_ERROR}${RESET} ${BOLD}$1${RESET}"
}

# Warning message
warning() {
    echo -e "${YELLOW}${ICON_WARNING}${RESET} ${BOLD}$1${RESET}"
}

# Info message
info() {
    echo -e "${CYAN}${ICON_INFO}${RESET} ${BOLD}$1${RESET}"
}

# =============================================================================
# Badge Component
# =============================================================================

# Badge with colored background
badge() {
    local text=$1
    local color=$2

    case $color in
        "success") echo -e "${BG_GREEN}${WHITE}${BOLD} $text ${RESET}" ;;
        "error") echo -e "${BG_RED}${WHITE}${BOLD} $text ${RESET}" ;;
        "warning") echo -e "${BG_YELLOW}${WHITE}${BOLD} $text ${RESET}" ;;
        "info") echo -e "${BG_CYAN}${WHITE}${BOLD} $text ${RESET}" ;;
        *) echo -e "${BG_BLUE}${WHITE}${BOLD} $text ${RESET}" ;;
    esac
}

# =============================================================================
# Box Components
# =============================================================================

# Create box with title
create_box() {
    local title=$1
    local width=${2:-65}
    local padding=$(( (width - ${#title} - 2) / 2 ))

    echo -e "${CYAN}${BOX_TL}$(printf "${BOX_H}%.0s" $(seq 1 $width))${BOX_TR}${RESET}"
    printf "${CYAN}${BOX_V}${RESET}"
    printf "%${padding}s" ""
    echo -ne "${BOLD}${PURPLE}${title}${RESET}"
    printf "%$((width - padding - ${#title}))s" ""
    echo -e "${CYAN}${BOX_V}${RESET}"
    echo -e "${CYAN}${BOX_BL}$(printf "${BOX_H}%.0s" $(seq 1 $width))${BOX_BR}${RESET}"
}

# Create rounded box
create_rounded_box() {
    local content=$1
    local width=${2:-65}

    echo -e "${SKY}${RBOX_TL}$(printf "${RBOX_H}%.0s" $(seq 1 $width))${RBOX_TR}${RESET}"
    echo -e "${SKY}${RBOX_V}${RESET} ${content}"
    echo -e "${SKY}${RBOX_BL}$(printf "${RBOX_H}%.0s" $(seq 1 $width))${RBOX_BR}${RESET}"
}

# =============================================================================
# Menu Components
# =============================================================================

# Section header
section_header() {
    local title=$1
    local icon=$2
    echo ""
    echo -e "${BOLD}${PURPLE}${icon} ${title}${RESET}"
    echo -e "${DIM}$(printf "─%.0s" $(seq 1 65))${RESET}"
}

# Menu item
menu_item() {
    local number=$1
    local text=$2
    local icon=$3

    if [[ -n "$icon" ]]; then
        echo -e "  ${BOLD}${CYAN}${number}.${RESET} ${icon}  ${text}"
    else
        echo -e "  ${BOLD}${CYAN}${number}.${RESET}  ${text}"
    fi
}

# Divider line
divider() {
    echo -e "${DIM}$(printf "─%.0s" $(seq 1 65))${RESET}"
}

# =============================================================================
# Header Display
# =============================================================================

# Display main header with ASCII art
show_header() {
    clear

    # ASCII Art Header with gradient colors
    echo ""
    echo -e "${PURPLE}${BOLD}     █████╗ ██████╗  ██████╗██╗  ██╗${RESET}"
    echo -e "${PURPLE}${BOLD}    ██╔══██╗██╔══██╗██╔════╝██║  ██║${RESET}"
    echo -e "${VIOLET}${BOLD}    ███████║██████╔╝██║     ███████║${RESET}"
    echo -e "${PINK}${BOLD}    ██╔══██║██╔══██╗██║     ██╔══██║${RESET}"
    echo -e "${PINK}${BOLD}    ██║  ██║██║  ██║╚██████╗██║  ██║${RESET}"
    echo -e "${DIM}    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝${RESET}"

    echo ""
    echo -e "${CYAN}${BOLD}          PACKAGE MANAGER${RESET} ${DIM}v2.1.0${RESET}"
    echo ""
}

# Display simple header (without ASCII art)
show_simple_header() {
    clear
    echo ""
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
    echo -e "${PURPLE}${BOLD}         ARCH PACKAGE MANAGER - v2.1.0${RESET}"
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
    echo ""
}

# =============================================================================
# Input Prompts
# =============================================================================

# Pause prompt - wait for user to press Enter
pause_prompt() {
    echo ""
    divider
    echo -en "${DIM}Nhấn ${BOLD}Enter${RESET}${DIM} để tiếp tục...${RESET}"
    read
}

# Confirmation prompt (yes/no)
confirm_prompt() {
    local message=$1
    local default=${2:-"n"}

    if [[ "$default" == "y" ]]; then
        echo -en "${YELLOW}${message} (Y/n):${RESET} "
    else
        echo -en "${YELLOW}${message} (y/N):${RESET} "
    fi

    read response
    response=${response:-$default}

    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Input prompt
input_prompt() {
    local message=$1
    local default=$2

    if [[ -n "$default" ]]; then
        echo -en "${CYAN}${message} [${default}]:${RESET} "
    else
        echo -en "${CYAN}${message}:${RESET} "
    fi

    read response
    echo ${response:-$default}
}

# =============================================================================
# List Display
# =============================================================================

# Display numbered list
display_list() {
    local -a items=("${@}")
    local count=1

    for item in "${items[@]}"; do
        echo -e "  ${CYAN}${count}.${RESET} ${item}"
        count=$((count + 1))
    done
}

# Display bullet list
display_bullet_list() {
    local -a items=("${@}")

    for item in "${items[@]}"; do
        echo -e "  ${GREEN}●${RESET} ${item}"
    done
}

# Display checkmark list
display_check_list() {
    local -a items=("${@}")

    for item in "${items[@]}"; do
        echo -e "  ${GREEN}${ICON_SUCCESS}${RESET} ${item}"
    done
}

# =============================================================================
# Table Display
# =============================================================================

# Display simple two-column table
display_table() {
    local label=$1
    local value=$2
    printf "  ${BOLD}%-30s${RESET} %s\n" "$label:" "$value"
}

# =============================================================================
# Special Effects
# =============================================================================

# Gradient text effect (simulated)
gradient_text() {
    local text=$1
    echo -e "${PURPLE}${BOLD}${text}${RESET}"
}

# Highlight text
highlight() {
    local text=$1
    echo -e "${BOLD}${YELLOW}${text}${RESET}"
}

# Code block
code_block() {
    local code=$1
    echo -e "${DIM}${code}${RESET}"
}
