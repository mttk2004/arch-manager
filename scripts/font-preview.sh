#!/usr/bin/env bash

# =============================================================================
# Font Preview Script - Demo Font Manager
# =============================================================================

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[38;5;135m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Icons
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"
ICON_FONT="🔤"
ICON_STAR="⭐"

clear

echo ""
echo -e "${PURPLE}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${PURPLE}${BOLD}║${RESET}         ${CYAN}${BOLD}FONT MANAGER PREVIEW & TEST DISPLAY${RESET}          ${PURPLE}${BOLD}║${RESET}"
echo -e "${PURPLE}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# =============================================================================
# Kiểm tra Nerd Fonts
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}${ICON_INFO}${RESET} ${BOLD}Kiểm tra Nerd Fonts đã cài...${RESET}"
echo ""

NERD_FONTS=(
    "FiraCode Nerd Font"
    "JetBrainsMono Nerd Font"
    "Hack Nerd Font"
)

ALL_INSTALLED=true

for font in "${NERD_FONTS[@]}"; do
    if fc-list | grep -qi "$font"; then
        echo -e "  ${GREEN}${ICON_SUCCESS}${RESET} $font"
    else
        echo -e "  ${RED}${ICON_ERROR}${RESET} $font ${DIM}(chưa cài)${RESET}"
        ALL_INSTALLED=false
    fi
done

echo ""

if [[ "$ALL_INSTALLED" == false ]]; then
    echo -e "${YELLOW}${ICON_INFO}${RESET} Một số font chưa được cài. Icons có thể hiển thị dạng ô vuông."
    echo -e "${CYAN}Tip:${RESET} Chạy ${CYAN}./pkgman.zsh${RESET} → Chọn ${CYAN}13${RESET} → Chọn ${CYAN}1${RESET} để cài Nerd Fonts"
    echo ""
fi

# =============================================================================
# Display Test
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}${ICON_FONT}  DISPLAY TEST${RESET}"
echo ""

# Box Drawing
echo -e "╔═══════════════════════════════════════════════════════════╗"
echo -e "║                ${BOLD}Box Drawing & Borders${RESET}                    ║"
echo -e "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo -e "╭───────────────────────────────────────────────────────────╮"
echo -e "│  Single: ┌─┬─┐  Double: ╔═╦═╗  Mixed: ╓─╥─╖             │"
echo -e "│          ├─┼─┤           ╠═╬═╣          ╟─╫─╢             │"
echo -e "│          └─┴─┘           ╚═╩═╝          ╙─╨─╜             │"
echo -e "╰───────────────────────────────────────────────────────────╯"
echo ""

# Powerline & Arrows
echo -e "${CYAN}${BOLD}Powerline & Arrows:${RESET}"
echo -e "                              "
echo -e "  ➜ ⮀ ⮁ ⮂ ⮃ ⮄ ⮅ ⮆ ⮇ ⮈ ⮉ ⮊ ⮋"
echo ""

# Icons
echo -e "${CYAN}${BOLD}Dev Icons & Symbols:${RESET}"
echo -e "  ${GREEN}✓${RESET} Success  ${RED}✗${RESET} Error  ${YELLOW}⚠${RESET} Warning  ${BLUE}ℹ${RESET} Info"
echo -e "  🚀 Rocket  📦 Package  🗑 Trash  🔍 Search"
echo -e "  ⬆ Up  ⬇ Down  🧹 Clean  🛡 Shield  🔧 Tools"
echo -e "  ✨ Sparkle  🔥 Fire  ⭐ Star  💻 Computer"
echo ""

# Programming
echo -e "${CYAN}${BOLD}Programming Symbols:${RESET}"
echo -e "  Git:         "
echo -e "  Files:       "
echo -e "  Languages:          "
echo -e "  Folders:    "
echo ""

# Ligatures
echo -e "${CYAN}${BOLD}Programming Ligatures (FiraCode/JetBrains):${RESET}"
echo -e "  != == === !== <= >= => -> <- <> <=> <=>"
echo -e "  || && ++ -- :: ... |> <| ~> <~ .- .="
echo -e "  /** */ // <!-- --> #{} \${} [] () {}"
echo ""

# Emoji
echo -e "${CYAN}${BOLD}Emoji (Color):${RESET}"
echo -e "  Faces: 😀 😃 😄 😁 😊 🥰 😍 🤩 😎 🤓"
echo -e "  Hands: 👍 👎 👏 🙌 💪 🤝 ✌️ 🤘 👋 🖐"
echo -e "  Symbols: ❤️ 💚 💙 💛 🧡 💜 🖤 🤍 🤎 💔"
echo -e "  Objects: 🎉 🎊 🎈 🎁 🏆 🥇 🥈 🥉 📱 💻"
echo ""

# Numbers & Math
echo -e "${CYAN}${BOLD}Numbers & Math:${RESET}"
echo -e "  Digits: 0123456789"
echo -e "  Math: + - × ÷ = ≠ ≈ ≤ ≥ ± ∞ √ ∑ ∫ ∂"
echo -e "  Fractions: ½ ⅓ ¼ ¾ ⅛ ⅜ ⅝ ⅞"
echo ""

# CJK
echo -e "${CYAN}${BOLD}CJK Characters:${RESET}"
echo -e "  中文 (Chinese):  你好世界 - Nǐ hǎo shìjiè"
echo -e "  日本語 (Japanese): こんにちは世界 - Konnichiwa sekai"
echo -e "  한국어 (Korean):   안녕하세요 세상 - Annyeonghaseyo sesang"
echo ""

# Colors
echo -e "${CYAN}${BOLD}Color Palette:${RESET}"
echo -e "  ${RED}██${RESET} Red    ${GREEN}██${RESET} Green   ${YELLOW}██${RESET} Yellow  ${BLUE}██${RESET} Blue"
echo -e "  ${PURPLE}██${RESET} Purple ${CYAN}██${RESET} Cyan    ${BOLD}██${RESET} Bold    ${DIM}██${RESET} Dim"
echo ""

# Alphabet
echo -e "${CYAN}${BOLD}Alphabet (Uppercase & Lowercase):${RESET}"
echo -e "  ABCDEFGHIJKLMNOPQRSTUVWXYZ"
echo -e "  abcdefghijklmnopqrstuvwxyz"
echo ""

# Special Characters
echo -e "${CYAN}${BOLD}Special Characters:${RESET}"
echo -e "  Quotes: \" ' \` « » ‹ › " " ' '"
echo -e "  Dashes: - – — ― ‐ ‑ ‒"
echo -e "  Bullets: • ‣ ⁃ ⁌ ⁍ ∙ ◦"
echo -e "  Currency: \$ € £ ¥ ₹ ₽ ₿ ¢"
echo ""

# Status Bar Example
echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${GREEN}${BOLD}Status Bar Examples:${RESET}"
echo ""
echo -e "╭───────────────────────────────────────────────────────────╮"
echo -e "│  ${PURPLE}${RESET} arch-zsh-manager ${CYAN}${RESET} main ${GREEN}${RESET} ✓              │"
echo -e "│  ${BLUE}${RESET} ~/projects ${YELLOW}${RESET} 3 files ${RED}${RESET} modified         │"
echo -e "╰───────────────────────────────────────────────────────────╯"
echo ""

# Progress Bar
echo -e "${CYAN}${BOLD}Progress & Loading:${RESET}"
echo -e "  ▁▂▃▄▅▆▇█ ▏▎▍▌▋▊▉█"
echo -e "  [${GREEN}████████████${RESET}------------] 50%"
echo -e "  ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏ (Spinner)"
echo ""

# =============================================================================
# Font Recommendations
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}${ICON_STAR}  FONT RECOMMENDATIONS${RESET}"
echo ""

echo -e "${GREEN}${BOLD}Top Fonts for Terminal/Coding:${RESET}"
echo ""
echo -e "  ${CYAN}1.${RESET} ${BOLD}FiraCode Nerd Font Mono${RESET}"
echo -e "     ${DIM}→ Programming ligatures, clear, many icons${RESET}"
echo ""
echo -e "  ${CYAN}2.${RESET} ${BOLD}JetBrainsMono Nerd Font${RESET}"
echo -e "     ${DIM}→ Designed for coding, excellent readability${RESET}"
echo ""
echo -e "  ${CYAN}3.${RESET} ${BOLD}Hack Nerd Font Mono${RESET}"
echo -e "     ${DIM}→ Sharp, clean, suitable for small sizes${RESET}"
echo ""
echo -e "  ${CYAN}4.${RESET} ${BOLD}Meslo Nerd Font${RESET}"
echo -e "     ${DIM}→ Fork of Menlo (macOS), balanced${RESET}"
echo ""
echo -e "  ${CYAN}5.${RESET} ${BOLD}Cascadia Code Nerd Font${RESET}"
echo -e "     ${DIM}→ Microsoft, modern, ligatures${RESET}"
echo ""

# =============================================================================
# Terminal Configuration
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${YELLOW}${BOLD}📝  TERMINAL CONFIGURATION${RESET}"
echo ""

echo -e "${BOLD}Alacritty:${RESET} ${DIM}~/.config/alacritty/alacritty.yml${RESET}"
echo -e "${CYAN}font:${RESET}"
echo -e "  ${CYAN}normal:${RESET}"
echo -e "    ${CYAN}family:${RESET} \"FiraCode Nerd Font\""
echo ""

echo -e "${BOLD}Kitty:${RESET} ${DIM}~/.config/kitty/kitty.conf${RESET}"
echo -e "${CYAN}font_family${RESET} FiraCode Nerd Font Mono"
echo ""

echo -e "${BOLD}Wezterm:${RESET} ${DIM}~/.config/wezterm/wezterm.lua${RESET}"
echo -e "${CYAN}config.font${RESET} = wezterm.font 'FiraCode Nerd Font'"
echo ""

# =============================================================================
# Final Message
# =============================================================================

echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

if [[ "$ALL_INSTALLED" == true ]]; then
    echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}${GREEN}Tất cả fonts đã được cài đặt!${RESET}"
    echo ""
    echo -e "${CYAN}${ICON_ROCKET}${RESET} Nếu icons không hiển thị đúng:"
    echo -e "  ${YELLOW}1.${RESET} Đóng terminal hiện tại"
    echo -e "  ${YELLOW}2.${RESET} Mở terminal mới"
    echo -e "  ${YELLOW}3.${RESET} Đặt font trong terminal settings"
else
    echo -e "${YELLOW}${ICON_INFO}${RESET} ${BOLD}Một số fonts chưa được cài đặt${RESET}"
    echo ""
    echo -e "${CYAN}${ICON_ROCKET}${RESET} Để cài đặt Nerd Fonts:"
    echo -e "  ${YELLOW}1.${RESET} Chạy: ${CYAN}./pkgman.zsh${RESET}"
    echo -e "  ${YELLOW}2.${RESET} Chọn: ${CYAN}13${RESET} (Quản lý font chữ)"
    echo -e "  ${YELLOW}3.${RESET} Chọn: ${CYAN}1${RESET} (Nerd Fonts)"
    echo -e "  ${YELLOW}4.${RESET} Chọn font muốn cài hoặc ${CYAN}8${RESET} (cài tất cả)"
fi

echo ""
echo -e "${PURPLE}${BOLD}════════════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "${GREEN}${ICON_SUCCESS}${RESET} ${BOLD}Xem hướng dẫn chi tiết:${RESET} ${CYAN}FONT_MANAGER_GUIDE.md${RESET}"
echo ""
echo -e "${DIM}Happy font hunting! 🔤✨${RESET}"
echo ""
