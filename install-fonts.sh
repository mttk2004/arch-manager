#!/usr/bin/env bash

# =============================================================================
# Font Installation Script for Arch Package Manager UI
# Cài đặt fonts cần thiết để hiển thị UI đẹp hoàn hảo
# =============================================================================

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[38;5;135m'
BOLD='\033[1m'
RESET='\033[0m'

# Icons
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"
ICON_DOWNLOAD="⬇"

clear

echo ""
echo -e "${PURPLE}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}${BOLD}║${RESET}     ${CYAN}${BOLD}FONT INSTALLATION FOR ARCH PACKAGE MANAGER${RESET}    ${PURPLE}${BOLD}║${RESET}"
echo -e "${PURPLE}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}${ICON_INFO}${RESET} ${BOLD}Script này sẽ cài đặt các font cần thiết để UI hiển thị đẹp:${RESET}"
echo ""
echo -e "  ${GREEN}1.${RESET} Nerd Fonts (FiraCode, JetBrains Mono, Hack)"
echo -e "  ${GREEN}2.${RESET} Emoji Fonts (Noto Color Emoji)"
echo -e "  ${GREEN}3.${RESET} Fallback Fonts (Noto Sans, DejaVu)"
echo ""
echo -e "${YELLOW}Lưu ý:${RESET} Sau khi cài, bạn cần:"
echo -e "  - Đóng và mở lại terminal"
echo -e "  - Hoặc chọn font mới trong terminal settings"
echo ""

read -p "$(echo -e ${CYAN}Tiếp tục cài đặt? \(y/N\): ${RESET})" confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "${YELLOW}Đã hủy.${RESET}"
    exit 0
fi

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Kiểm tra AUR helper
AUR_HELPER=""
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
elif command -v paru &> /dev/null; then
    AUR_HELPER="paru"
fi

# =============================================================================
# 1. Cài đặt fonts từ kho chính thức
# =============================================================================

echo -e "${CYAN}${ICON_DOWNLOAD}${RESET} ${BOLD}Bước 1: Cài đặt fonts từ kho chính thức...${RESET}"
echo ""

OFFICIAL_FONTS=(
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "ttf-hack-nerd"
    "noto-fonts"
    "noto-fonts-emoji"
    "noto-fonts-cjk"
    "ttf-dejavu"
    "ttf-liberation"
    "ttf-font-awesome"
)

echo -e "${YELLOW}Fonts sẽ cài đặt:${RESET}"
for font in "${OFFICIAL_FONTS[@]}"; do
    echo -e "  - ${font}"
done
echo ""

sudo pacman -S --needed --noconfirm "${OFFICIAL_FONTS[@]}"

if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}Cài đặt fonts chính thức thành công!${RESET}"
else
    echo ""
    echo -e "${YELLOW}Một số fonts có thể đã được cài đặt hoặc không khả dụng.${RESET}"
fi

# =============================================================================
# 2. Cài đặt fonts từ AUR (nếu có AUR helper)
# =============================================================================

if [[ -n "$AUR_HELPER" ]]; then
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "${CYAN}${ICON_DOWNLOAD}${RESET} ${BOLD}Bước 2: Cài đặt fonts bổ sung từ AUR...${RESET}"
    echo ""

    AUR_FONTS=(
        "ttf-meslo-nerd"
        "ttf-ms-fonts"
    )

    echo -e "${YELLOW}Fonts bổ sung (AUR):${RESET}"
    for font in "${AUR_FONTS[@]}"; do
        echo -e "  - ${font}"
    done
    echo ""

    read -p "$(echo -e ${CYAN}Cài đặt fonts từ AUR? \(y/N\): ${RESET})" install_aur

    if [[ "$install_aur" == "y" || "$install_aur" == "Y" ]]; then
        $AUR_HELPER -S --needed --noconfirm "${AUR_FONTS[@]}"

        if [[ $? -eq 0 ]]; then
            echo ""
            echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}Cài đặt fonts AUR thành công!${RESET}"
        else
            echo ""
            echo -e "${YELLOW}Một số fonts AUR không cài được (bình thường).${RESET}"
        fi
    else
        echo -e "${YELLOW}Bỏ qua fonts AUR.${RESET}"
    fi
else
    echo ""
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
    echo -e "${YELLOW}${ICON_INFO}${RESET} ${BOLD}Bước 2: Bỏ qua (không có AUR helper)${RESET}"
    echo ""
    echo -e "Để cài fonts từ AUR, hãy cài YAY trước:"
    echo -e "  ${CYAN}pkgman${RESET} → Chọn option 13"
fi

# =============================================================================
# 3. Cập nhật font cache
# =============================================================================

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${CYAN}${ICON_DOWNLOAD}${RESET} ${BOLD}Bước 3: Cập nhật font cache...${RESET}"
echo ""

fc-cache -fv

if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}Cập nhật font cache thành công!${RESET}"
else
    echo ""
    echo -e "${RED}${ICON_ERROR}${RESET} ${BOLD}Có lỗi khi cập nhật font cache!${RESET}"
fi

# =============================================================================
# 4. Kiểm tra fonts đã cài
# =============================================================================

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${CYAN}${ICON_INFO}${RESET} ${BOLD}Bước 4: Kiểm tra fonts đã cài...${RESET}"
echo ""

REQUIRED_FONTS=(
    "FiraCode Nerd Font"
    "JetBrainsMono Nerd Font"
    "Hack Nerd Font"
    "Noto Color Emoji"
    "DejaVu Sans"
)

echo -e "${YELLOW}Kiểm tra fonts:${RESET}"
echo ""

ALL_INSTALLED=true

for font in "${REQUIRED_FONTS[@]}"; do
    if fc-list | grep -qi "$font"; then
        echo -e "  ${GREEN}${ICON_SUCCESS}${RESET} $font"
    else
        echo -e "  ${RED}${ICON_ERROR}${RESET} $font ${RED}(chưa cài)${RESET}"
        ALL_INSTALLED=false
    fi
done

# =============================================================================
# 5. Test hiển thị
# =============================================================================

echo ""
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${CYAN}${ICON_INFO}${RESET} ${BOLD}Bước 5: Test hiển thị icons & emoji...${RESET}"
echo ""

echo -e "╔═══════════════════════════════════════════════════════════╗"
echo -e "║                   ${BOLD}TEST DISPLAY${RESET}                          ║"
echo -e "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "╭───────────────────────────────────────────────────────────╮"
echo -e "│ Status: ${GREEN}INSTALLED${RESET}  Version: 2.0.0  Build: OK      │"
echo -e "╰───────────────────────────────────────────────────────────╯"
echo ""
echo -e "${BOLD}Powerline & Box Drawing:${RESET}"
echo -e "  ╔═╗ ╚═╝ ║ ═ ╠╣ ╭─╮ ╰─╯ │ ─"
echo ""
echo -e "${BOLD}Icons:${RESET}"
echo -e "  ✓ ✗ ⚠ ℹ 🚀 📦 🗑 🔍 ⬆ ⬇ 🧹 🛡 🔧 ✨ 🔥 ☑ ➜ ⭐"
echo ""
echo -e "${BOLD}Emoji:${RESET}"
echo -e "  😀 🎉 🎨 💻 🌐 🗄 🐘 🐍 🐹 🦀 🐳 ☕ 🍃 🔴"
echo ""
echo -e "${BOLD}Colors:${RESET}"
echo -e "  ${RED}■${RESET} ${GREEN}■${RESET} ${YELLOW}■${RESET} ${BLUE}■${RESET} ${PURPLE}■${RESET} ${CYAN}■${RESET}"
echo ""

# =============================================================================
# Kết thúc
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

if [[ "$ALL_INSTALLED" == true ]]; then
    echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}${GREEN}Hoàn tất! Tất cả fonts đã được cài đặt.${RESET}"
    echo ""
    echo -e "${CYAN}${ICON_ROCKET}${RESET} ${BOLD}Bước tiếp theo:${RESET}"
    echo ""
    echo -e "  ${YELLOW}1.${RESET} Đóng terminal hiện tại"
    echo -e "  ${YELLOW}2.${RESET} Mở terminal mới"
    echo -e "  ${YELLOW}3.${RESET} (Tùy chọn) Đặt font trong terminal settings:"
    echo -e "      ${CYAN}→${RESET} FiraCode Nerd Font Mono"
    echo -e "      ${CYAN}→${RESET} JetBrainsMono Nerd Font Mono"
    echo -e "      ${CYAN}→${RESET} Hack Nerd Font Mono"
    echo -e "  ${YELLOW}4.${RESET} Chạy: ${CYAN}./ui-preview.sh${RESET} để test UI"
    echo ""
else
    echo -e "${YELLOW}${ICON_INFO}${RESET} ${BOLD}Một số fonts chưa được cài đặt.${RESET}"
    echo ""
    echo -e "${CYAN}Tuy nhiên, UI vẫn hoạt động được!${RESET}"
    echo -e "Một số icons có thể hiển thị dạng fallback (ô vuông, chữ)."
    echo ""
    echo -e "Để cài thêm fonts, chạy lại script này hoặc:"
    echo -e "  ${CYAN}sudo pacman -S ttf-firacode-nerd noto-fonts-emoji${RESET}"
    echo ""
fi

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

# Hướng dẫn cấu hình terminal
echo -e "${BOLD}${PURPLE}📝 Hướng dẫn cấu hình Terminal:${RESET}"
echo ""

echo -e "${BOLD}Alacritty:${RESET}"
echo -e "  ${CYAN}~/.config/alacritty/alacritty.yml${RESET}"
echo -e "  ${YELLOW}font:${RESET}"
echo -e "    ${YELLOW}normal:${RESET}"
echo -e "      ${YELLOW}family:${RESET} \"FiraCode Nerd Font\""
echo ""

echo -e "${BOLD}Kitty:${RESET}"
echo -e "  ${CYAN}~/.config/kitty/kitty.conf${RESET}"
echo -e "  ${YELLOW}font_family${RESET} FiraCode Nerd Font Mono"
echo ""

echo -e "${BOLD}Gnome Terminal / Konsole:${RESET}"
echo -e "  Preferences → Profile → Font"
echo -e "  Chọn: FiraCode Nerd Font Mono"
echo ""

echo -e "${BOLD}Wezterm:${RESET}"
echo -e "  ${CYAN}~/.config/wezterm/wezterm.lua${RESET}"
echo -e "  ${YELLOW}config.font${RESET} = wezterm.font 'FiraCode Nerd Font'"
echo ""

echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}Done! Enjoy the beautiful UI! 🎉${RESET}"
echo ""
