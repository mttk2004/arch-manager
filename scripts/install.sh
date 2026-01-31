#!/bin/bash

# =============================================================================
# Arch Package Manager - Installation Script
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="/usr/local/bin"
BINARY_NAME="pkgman"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║${RESET}    ${BLUE}Arch Package Manager${RESET} - Installation Script            ${CYAN}║${RESET}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Check if running on Arch-based system
check_arch() {
    if [ ! -f /etc/arch-release ] && [ ! -f /etc/manjaro-release ]; then
        echo -e "${YELLOW}⚠️  Warning: This doesn't appear to be an Arch-based system${RESET}"
        echo -n -e "${CYAN}Continue anyway? (y/N): ${RESET}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Installation cancelled.${RESET}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓${RESET} Arch-based system detected"
    fi
}

# Check if zsh is installed
check_zsh() {
    if ! command -v zsh &> /dev/null; then
        echo -e "${YELLOW}⚠️  zsh is not installed${RESET}"
        echo -n -e "${CYAN}Install zsh now? (y/N): ${RESET}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Installing zsh...${RESET}"
            sudo pacman -S --noconfirm zsh
            echo -e "${GREEN}✓${RESET} zsh installed successfully"
        else
            echo -e "${RED}zsh is required. Installation cancelled.${RESET}"
            exit 1
        fi
    else
        echo -e "${GREEN}✓${RESET} zsh is installed"
    fi
}

# Check and install recommended packages
install_dependencies() {
    echo ""
    echo -e "${BLUE}═══ Checking dependencies ═══${RESET}"

    local packages=()
    local optional_packages=()

    # Required packages
    if ! pacman -Qi pacman-contrib &> /dev/null; then
        packages+=("pacman-contrib")
    fi

    if ! pacman -Qi base-devel &> /dev/null; then
        optional_packages+=("base-devel")
    fi

    if ! pacman -Qi git &> /dev/null; then
        optional_packages+=("git")
    fi

    if ! pacman -Qi reflector &> /dev/null; then
        optional_packages+=("reflector")
    fi

    # Install required packages
    if [ ${#packages[@]} -gt 0 ]; then
        echo -e "${YELLOW}Installing required packages: ${packages[*]}${RESET}"
        sudo pacman -S --needed --noconfirm "${packages[@]}"
        echo -e "${GREEN}✓${RESET} Required packages installed"
    else
        echo -e "${GREEN}✓${RESET} All required packages already installed"
    fi

    # Ask about optional packages
    if [ ${#optional_packages[@]} -gt 0 ]; then
        echo ""
        echo -e "${CYAN}Recommended packages not installed: ${optional_packages[*]}${RESET}"
        echo -n -e "${CYAN}Install recommended packages? (y/N): ${RESET}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            sudo pacman -S --needed --noconfirm "${optional_packages[@]}"
            echo -e "${GREEN}✓${RESET} Recommended packages installed"
        fi
    fi
}

# Check for AUR helper
check_aur_helper() {
    echo ""
    echo -e "${BLUE}═══ Checking AUR helper ═══${RESET}"

    if command -v yay &> /dev/null; then
        echo -e "${GREEN}✓${RESET} yay is installed"
    elif command -v paru &> /dev/null; then
        echo -e "${GREEN}✓${RESET} paru is installed"
    else
        echo -e "${YELLOW}⚠️  No AUR helper detected${RESET}"
        echo -n -e "${CYAN}Install yay (AUR helper)? (y/N): ${RESET}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            install_yay
        else
            echo -e "${YELLOW}You can install it later from the package manager menu${RESET}"
        fi
    fi
}

# Install YAY
install_yay() {
    echo -e "${BLUE}Installing yay...${RESET}"

    # Check dependencies
    if ! pacman -Qi base-devel &> /dev/null || ! pacman -Qi git &> /dev/null; then
        echo -e "${YELLOW}Installing yay dependencies...${RESET}"
        sudo pacman -S --needed --noconfirm base-devel git
    fi

    # Clone and install
    local tmp_dir="/tmp/yay-install-$$"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir"

    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm

    # Cleanup
    cd ~
    rm -rf "$tmp_dir"

    if command -v yay &> /dev/null; then
        echo -e "${GREEN}✓${RESET} yay installed successfully"
    else
        echo -e "${RED}✗${RESET} yay installation failed"
    fi
}

# Install the package manager
install_pkgman() {
    echo ""
    echo -e "${BLUE}═══ Installing Arch Package Manager ═══${RESET}"

    # Make script executable
    chmod +x "$SCRIPT_DIR/pkgman.zsh"

    # Choose installation method
    echo ""
    echo "Choose installation method:"
    echo "1. System-wide (recommended) - Install to $INSTALL_DIR"
    echo "2. User alias - Add alias to ~/.zshrc"
    echo "3. Both"
    echo "0. Skip installation"
    echo ""
    echo -n -e "${CYAN}Choose [1-3, 0]: ${RESET}"
    read -r choice

    case $choice in
        1)
            install_systemwide
            ;;
        2)
            install_alias
            ;;
        3)
            install_systemwide
            install_alias
            ;;
        0)
            echo -e "${YELLOW}Skipping installation${RESET}"
            ;;
        *)
            echo -e "${RED}Invalid choice${RESET}"
            exit 1
            ;;
    esac
}

# Install system-wide
install_systemwide() {
    echo -e "${BLUE}Installing system-wide...${RESET}"
    sudo cp "$SCRIPT_DIR/pkgman.zsh" "$INSTALL_DIR/$BINARY_NAME"
    sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
    echo -e "${GREEN}✓${RESET} Installed to $INSTALL_DIR/$BINARY_NAME"
    echo -e "${GREEN}You can now run: ${CYAN}$BINARY_NAME${RESET}"
}

# Install as alias
install_alias() {
    echo -e "${BLUE}Adding alias to ~/.zshrc...${RESET}"

    local alias_line="alias $BINARY_NAME='$SCRIPT_DIR/pkgman.zsh'"

    if [ -f ~/.zshrc ]; then
        # Check if alias already exists
        if grep -q "alias $BINARY_NAME=" ~/.zshrc; then
            echo -e "${YELLOW}Alias already exists in ~/.zshrc${RESET}"
            echo -n -e "${CYAN}Replace it? (y/N): ${RESET}"
            read -r response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Remove old alias
                sed -i "/alias $BINARY_NAME=/d" ~/.zshrc
                # Add new alias
                echo "" >> ~/.zshrc
                echo "# Arch Package Manager" >> ~/.zshrc
                echo "$alias_line" >> ~/.zshrc
                echo -e "${GREEN}✓${RESET} Alias updated in ~/.zshrc"
            fi
        else
            echo "" >> ~/.zshrc
            echo "# Arch Package Manager" >> ~/.zshrc
            echo "$alias_line" >> ~/.zshrc
            echo -e "${GREEN}✓${RESET} Alias added to ~/.zshrc"
        fi
        echo -e "${CYAN}Run 'source ~/.zshrc' or restart your terminal to use the alias${RESET}"
    else
        echo -e "${YELLOW}~/.zshrc not found. Creating it...${RESET}"
        echo "# Arch Package Manager" > ~/.zshrc
        echo "$alias_line" >> ~/.zshrc
        echo -e "${GREEN}✓${RESET} Created ~/.zshrc with alias"
    fi
}

# Show completion message
show_completion() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}              Installation completed successfully!            ${GREEN}║${RESET}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${CYAN}Usage:${RESET}"
    echo -e "  Run: ${GREEN}$BINARY_NAME${RESET}"
    echo ""
    echo -e "${CYAN}Features:${RESET}"
    echo -e "  • Install/remove packages (pacman, AUR, Flatpak)"
    echo -e "  • System updates"
    echo -e "  • Clean cache and orphan packages"
    echo -e "  • Search and view package info"
    echo -e "  • Mirror management"
    echo -e "  • And more..."
    echo ""
    echo -e "${YELLOW}Note:${RESET} If you installed as alias, run 'source ~/.zshrc' first"
    echo ""
}

# Main installation flow
main() {
    check_arch
    check_zsh
    install_dependencies
    check_aur_helper
    install_pkgman
    show_completion
}

# Run main function
main
