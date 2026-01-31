#!/usr/bin/env zsh

# =============================================================================
# Arch Package Manager - Trình quản lý gói tập trung cho Arch Linux
# =============================================================================

# =============================================================================
# UI Components - Inspired by Laravel CLI
# =============================================================================

# Màu sắc cơ bản
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Màu sắc mở rộng (256 colors)
BOLD='\033[1m'
DIM='\033[2m'
ITALIC='\033[3m'
UNDERLINE='\033[4m'

# Gradient colors
PURPLE='\033[38;5;135m'
PINK='\033[38;5;205m'
ORANGE='\033[38;5;214m'
LIME='\033[38;5;154m'
SKY='\033[38;5;117m'
VIOLET='\033[38;5;141m'
GOLD='\033[38;5;220m'

# Background colors
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Icons & Emojis
ICON_SUCCESS="✓"
ICON_ERROR="✗"
ICON_WARNING="⚠"
ICON_INFO="ℹ"
ICON_ROCKET="🚀"
ICON_PACKAGE="📦"
ICON_TRASH="🗑"
ICON_SEARCH="🔍"
ICON_UPDATE="⬆"
ICON_CLEAN="🧹"
ICON_SHIELD="🛡"
ICON_TOOLS="🔧"
ICON_DOWNLOAD="⬇"
ICON_SPARKLE="✨"
ICON_FIRE="🔥"
ICON_CHECK="☑"
ICON_ARROW="➜"
ICON_STAR="⭐"

# Spinner frames
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

# Box drawing characters
BOX_TL="╔"  # Top left
BOX_TR="╗"  # Top right
BOX_BL="╚"  # Bottom left
BOX_BR="╝"  # Bottom right
BOX_H="═"   # Horizontal
BOX_V="║"   # Vertical
BOX_ML="╠"  # Middle left
BOX_MR="╣"  # Middle right

# Rounded box
RBOX_TL="╭"
RBOX_TR="╮"
RBOX_BL="╰"
RBOX_BR="╯"
RBOX_H="─"
RBOX_V="│"

# =============================================================================
# UI Helper Functions
# =============================================================================

# In đậm
bold() {
    echo -e "${BOLD}$1${RESET}"
}

# In mờ
dim() {
    echo -e "${DIM}$1${RESET}"
}

# Hiển thị spinner với message
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

# Badge (label với background)
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

# Tạo box với title
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

# Tạo rounded box
create_rounded_box() {
    local content=$1
    local width=${2:-65}

    echo -e "${SKY}${RBOX_TL}$(printf "${RBOX_H}%.0s" $(seq 1 $width))${RBOX_TR}${RESET}"
    echo -e "${SKY}${RBOX_V}${RESET} ${content}"
    echo -e "${SKY}${RBOX_BL}$(printf "${RBOX_H}%.0s" $(seq 1 $width))${RBOX_BR}${RESET}"
}

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

# Divider
divider() {
    echo -e "${DIM}$(printf "─%.0s" $(seq 1 65))${RESET}"
}

# Gradient text (simulation)
gradient_text() {
    local text=$1
    echo -e "${PURPLE}${BOLD}${text}${RESET}"
}

# Kiểm tra AUR helper có sẵn
detect_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "yay"
    elif command -v paru &> /dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

# Kiểm tra flatpak
has_flatpak() {
    command -v flatpak &> /dev/null
}

# Hiển thị header
show_header() {
    clear

    # ASCII Art Header with gradient
    echo ""
    echo -e "${PURPLE}${BOLD}     █████╗ ██████╗  ██████╗██╗  ██╗${RESET}"
    echo -e "${PURPLE}${BOLD}    ██╔══██╗██╔══██╗██╔════╝██║  ██║${RESET}"
    echo -e "${VIOLET}${BOLD}    ███████║██████╔╝██║     ███████║${RESET}"
    echo -e "${PINK}${BOLD}    ██╔══██║██╔══██╗██║     ██╔══██║${RESET}"
    echo -e "${PINK}${BOLD}    ██║  ██║██║  ██║╚██████╗██║  ██║${RESET}"
    echo -e "${DIM}    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝${RESET}"

    echo ""
    echo -e "${CYAN}${BOX_TL}$(printf "${BOX_H}%.0s" $(seq 1 65))${BOX_TR}${RESET}"
    echo -e "${CYAN}${BOX_V}${RESET}        ${BOLD}${GOLD}PACKAGE MANAGER${RESET} ${DIM}Quản lý gói tập trung cho Arch Linux${RESET}     ${CYAN}${BOX_V}${RESET}"
    echo -e "${CYAN}${BOX_BL}$(printf "${BOX_H}%.0s" $(seq 1 65))${BOX_BR}${RESET}"
    echo ""
}

# Menu chính
show_main_menu() {
    local aur_helper=$(detect_aur_helper)
    local flatpak_status=""

    if has_flatpak; then
        flatpak_status="$(badge "INSTALLED" "success")"
    else
        flatpak_status="$(badge "NOT INSTALLED" "error")"
    fi

    # System status bar
    echo -e "${SKY}${RBOX_TL}$(printf "${RBOX_H}%.0s" $(seq 1 63))${RBOX_TR}${RESET}"
    if [[ -n "$aur_helper" ]]; then
        echo -e "${SKY}${RBOX_V}${RESET} ${ICON_SHIELD} AUR Helper: $(badge "$aur_helper" "success")  ${ICON_PACKAGE} Flatpak: ${flatpak_status} ${SKY}${RBOX_V}${RESET}"
    else
        echo -e "${SKY}${RBOX_V}${RESET} ${ICON_WARNING} AUR Helper: $(badge "NOT INSTALLED" "warning")  ${ICON_PACKAGE} Flatpak: ${flatpak_status} ${SKY}${RBOX_V}${RESET}"
    fi
    echo -e "${SKY}${RBOX_BL}$(printf "${RBOX_H}%.0s" $(seq 1 63))${RBOX_BR}${RESET}"

    # Package Management Section
    section_header "HỆ THỐNG GÓI" "${ICON_PACKAGE}"
    menu_item "1" "Cài đặt gói" "${ICON_DOWNLOAD}"
    menu_item "2" "Xóa gói" "${ICON_TRASH}"
    menu_item "3" "Cập nhật hệ thống" "${ICON_UPDATE}"
    menu_item "4" "Tìm kiếm gói" "${ICON_SEARCH}"
    menu_item "5" "Xem thông tin gói" "${ICON_INFO}"

    # System Maintenance Section
    section_header "BẢO TRÌ HỆ THỐNG" "${ICON_CLEAN}"
    menu_item "6" "Dọn dẹp cache" "${ICON_CLEAN}"
    menu_item "7" "Xóa gói orphan (không cần thiết)" "${ICON_TRASH}"
    menu_item "8" "Xem danh sách gói đã cài" "${ICON_CHECK}"
    menu_item "9" "Kiểm tra gói bị hỏng" "${ICON_SHIELD}"

    # Advanced Section
    section_header "NÂNG CAO" "${ICON_TOOLS}"
    menu_item "10" "Downgrade gói" "⬇"
    menu_item "11" "Xem log gói" "📋"
    menu_item "12" "Mirror management" "🌐"

    # Font Management Section
    section_header "FONT CHỮ" "🔤"
    menu_item "13" "Quản lý font chữ (Nerd Fonts, Emoji, CJK...)" "🔤"

    # Development Tools Section
    section_header "PHÁT TRIỂN" "${ICON_FIRE}"
    menu_item "14" "Môi trường phát triển (PHP, Node.js, Java, Database...)" "${ICON_TOOLS}"

    # Install AUR Helper if not present
    if [[ -z "$aur_helper" ]]; then
        echo ""
        menu_item "15" "${YELLOW}Cài đặt YAY (AUR helper)${RESET}" "${ICON_SPARKLE}"
    fi

    # Exit option
    echo ""
    divider
    echo -e "  ${BOLD}${RED}0.${RESET}  ${ICON_ERROR}  Thoát"
    divider
    echo ""
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn chức năng [0-15]:${RESET} "
}

# Cài đặt gói
install_package() {
    show_header
    create_box "CÀI ĐẶT GÓI ${ICON_DOWNLOAD}" 63
    echo ""

    local aur_helper=$(detect_aur_helper)

    menu_item "1" "Cài từ kho chính thức (pacman)" "${ICON_PACKAGE}"

    if [[ -n "$aur_helper" ]]; then
        menu_item "2" "Cài từ AUR ($aur_helper)" "${ICON_STAR}"
    fi

    if has_flatpak; then
        menu_item "3" "Cài từ Flatpak" "${ICON_PACKAGE}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn nguồn cài đặt:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói cần cài:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo ""
                info "Đang cài đặt ${BOLD}${pkg}${RESET}..."
                echo ""
                sudo pacman -S $pkg
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cài đặt ${BOLD}${pkg}${RESET} thành công!"
                else
                    error "Cài đặt ${BOLD}${pkg}${RESET} thất bại!"
                fi
                pause_prompt
            fi
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo ""
                echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói AUR cần cài:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo ""
                    info "Đang cài đặt ${BOLD}${pkg}${RESET} từ AUR..."
                    echo ""
                    $aur_helper -S $pkg
                    echo ""
                    if [[ $? -eq 0 ]]; then
                        success "Cài đặt ${BOLD}${pkg}${RESET} thành công!"
                    else
                        error "Cài đặt ${BOLD}${pkg}${RESET} thất bại!"
                    fi
                    pause_prompt
                fi
            fi
            ;;
        3)
            if has_flatpak; then
                echo ""
                echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói Flatpak cần cài:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo ""
                    info "Đang cài đặt ${BOLD}${pkg}${RESET} từ Flatpak..."
                    echo ""
                    flatpak install $pkg
                    echo ""
                    if [[ $? -eq 0 ]]; then
                        success "Cài đặt ${BOLD}${pkg}${RESET} thành công!"
                    else
                        error "Cài đặt ${BOLD}${pkg}${RESET} thất bại!"
                    fi
                    pause_prompt
                fi
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Xóa gói
remove_package() {
    show_header
    create_box "XÓA GÓI ${ICON_TRASH}" 63
    echo ""

    menu_item "1" "Xóa gói (pacman) - giữ dependencies" "${ICON_TRASH}"
    menu_item "2" "Xóa gói và dependencies không dùng" "${ICON_TRASH}"

    if has_flatpak; then
        menu_item "3" "Xóa gói Flatpak" "${ICON_TRASH}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn cách xóa:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói cần xóa:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo ""
                warning "Đang xóa ${BOLD}${pkg}${RESET}..."
                echo ""
                sudo pacman -R $pkg
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Xóa ${BOLD}${pkg}${RESET} thành công!"
                else
                    error "Xóa ${BOLD}${pkg}${RESET} thất bại!"
                fi
                pause_prompt
            fi
            ;;
        2)
            echo ""
            echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói cần xóa:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo ""
                warning "Đang xóa ${BOLD}${pkg}${RESET} và dependencies..."
                echo ""
                sudo pacman -Rns $pkg
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Xóa ${BOLD}${pkg}${RESET} thành công!"
                else
                    error "Xóa ${BOLD}${pkg}${RESET} thất bại!"
                fi
                pause_prompt
            fi
            ;;
        3)
            if has_flatpak; then
                echo ""
                echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói Flatpak cần xóa:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo ""
                    warning "Đang xóa ${BOLD}${pkg}${RESET} từ Flatpak..."
                    echo ""
                    flatpak uninstall $pkg
                    echo ""
                    if [[ $? -eq 0 ]]; then
                        success "Xóa ${BOLD}${pkg}${RESET} thành công!"
                    else
                        error "Xóa ${BOLD}${pkg}${RESET} thất bại!"
                    fi
                    pause_prompt
                fi
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Cập nhật hệ thống
update_system() {
    show_header
    create_box "CẬP NHẬT HỆ THỐNG ${ICON_UPDATE}" 63
    echo ""

    local aur_helper=$(detect_aur_helper)

    menu_item "1" "Cập nhật gói chính thức (pacman)" "${ICON_PACKAGE}"

    if [[ -n "$aur_helper" ]]; then
        menu_item "2" "Cập nhật tất cả (pacman + AUR)" "${ICON_ROCKET}"
    fi

    if has_flatpak; then
        menu_item "3" "Cập nhật Flatpak" "${ICON_PACKAGE}"
        menu_item "4" "Cập nhật tất cả nguồn" "${ICON_FIRE}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn loại cập nhật:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            info "Đang cập nhật hệ thống..."
            echo ""
            sudo pacman -Syu
            echo ""
            if [[ $? -eq 0 ]]; then
                success "Cập nhật hệ thống thành công!"
            else
                error "Cập nhật hệ thống thất bại!"
            fi
            pause_prompt
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo ""
                info "Đang cập nhật tất cả gói..."
                echo ""
                $aur_helper -Syu
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cập nhật tất cả gói thành công!"
                else
                    error "Cập nhật thất bại!"
                fi
                pause_prompt
            fi
            ;;
        3)
            if has_flatpak; then
                echo ""
                info "Đang cập nhật Flatpak..."
                echo ""
                flatpak update
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cập nhật Flatpak thành công!"
                else
                    error "Cập nhật Flatpak thất bại!"
                fi
                pause_prompt
            fi
            ;;
        4)
            if has_flatpak && [[ -n "$aur_helper" ]]; then
                echo ""
                info "Đang cập nhật tất cả nguồn..."
                echo ""
                $aur_helper -Syu && flatpak update
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cập nhật tất cả nguồn thành công!"
                else
                    error "Cập nhật thất bại!"
                fi
                pause_prompt
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Tìm kiếm gói
search_package() {
    show_header
    create_box "TÌM KIẾM GÓI ${ICON_SEARCH}" 63
    echo ""

    local aur_helper=$(detect_aur_helper)

    menu_item "1" "Tìm trong kho chính thức" "${ICON_PACKAGE}"

    if [[ -n "$aur_helper" ]]; then
        menu_item "2" "Tìm trong AUR" "${ICON_STAR}"
    fi

    if has_flatpak; then
        menu_item "3" "Tìm trong Flatpak" "${ICON_PACKAGE}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn nguồn tìm kiếm:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            echo -en "${CYAN}${ICON_SEARCH} Nhập từ khóa:${RESET} "
            read keyword
            if [[ -n "$keyword" ]]; then
                echo ""
                info "Đang tìm kiếm ${BOLD}${keyword}${RESET}..."
                echo ""
                pacman -Ss $keyword
                pause_prompt
            fi
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo ""
                echo -en "${CYAN}${ICON_SEARCH} Nhập từ khóa:${RESET} "
                read keyword
                if [[ -n "$keyword" ]]; then
                    echo ""
                    info "Đang tìm kiếm ${BOLD}${keyword}${RESET} trong AUR..."
                    echo ""
                    $aur_helper -Ss $keyword
                    pause_prompt
                fi
            fi
            ;;
        3)
            if has_flatpak; then
                echo ""
                echo -en "${CYAN}${ICON_SEARCH} Nhập từ khóa:${RESET} "
                read keyword
                if [[ -n "$keyword" ]]; then
                    echo ""
                    info "Đang tìm kiếm ${BOLD}${keyword}${RESET} trong Flatpak..."
                    echo ""
                    flatpak search $keyword
                    pause_prompt
                fi
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Xem thông tin gói
package_info() {
    show_header
    create_box "THÔNG TIN GÓI ${ICON_INFO}" 63
    echo ""
    echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói:${RESET} "
    read pkg

    if [[ -n "$pkg" ]]; then
        echo ""
        info "Đang lấy thông tin về ${BOLD}${pkg}${RESET}..."
        echo ""
        divider
        echo -e "${BOLD}${PURPLE}Thông tin từ pacman:${RESET}"
        divider
        pacman -Qi $pkg 2>/dev/null || pacman -Si $pkg 2>/dev/null

        if has_flatpak; then
            echo ""
            divider
            echo -e "${BOLD}${PURPLE}Kiểm tra Flatpak:${RESET}"
            divider
            flatpak info $pkg 2>/dev/null
        fi

        pause_prompt
    fi
}

# Dọn dẹp cache
clean_cache() {
    show_header
    create_box "DỌN DẸP CACHE ${ICON_CLEAN}" 63
    echo ""

    menu_item "1" "Xóa cache gói cũ (giữ 3 phiên bản gần nhất)" "${ICON_CLEAN}"
    menu_item "2" "Xóa toàn bộ cache" "${ICON_TRASH}"
    menu_item "3" "Xóa cache AUR" "${ICON_CLEAN}"

    if has_flatpak; then
        menu_item "4" "Xóa cache Flatpak" "${ICON_CLEAN}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn cách dọn dẹp:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            info "Đang dọn dẹp cache..."
            echo ""
            sudo paccache -r
            echo ""
            if [[ $? -eq 0 ]]; then
                success "Dọn dẹp cache thành công!"
            else
                error "Dọn dẹp cache thất bại!"
            fi
            pause_prompt
            ;;
        2)
            echo ""
            warning "Cảnh báo: Xóa toàn bộ cache!"
            echo -en "${CYAN}${ICON_WARNING} Bạn có chắc chắn? (y/N):${RESET} "
            read confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                echo ""
                info "Đang xóa toàn bộ cache..."
                echo ""
                sudo pacman -Scc
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Xóa cache thành công!"
                else
                    error "Xóa cache thất bại!"
                fi
            fi
            pause_prompt
            ;;
        3)
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                echo ""
                info "Đang dọn dẹp cache AUR..."
                echo ""
                $aur_helper -Sc
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Dọn dẹp cache AUR thành công!"
                else
                    error "Dọn dẹp cache AUR thất bại!"
                fi
                pause_prompt
            fi
            ;;
        4)
            if has_flatpak; then
                echo ""
                info "Đang dọn dẹp cache Flatpak..."
                echo ""
                flatpak uninstall --unused
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Dọn dẹp cache Flatpak thành công!"
                else
                    error "Dọn dẹp cache Flatpak thất bại!"
                fi
                pause_prompt
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Xóa orphan packages
remove_orphans() {
    show_header
    create_box "XÓA GÓI ORPHAN ${ICON_TRASH}" 63
    echo ""

    info "Đang tìm kiếm gói orphan..."
    echo ""

    local orphans=$(pacman -Qdtq)

    if [[ -n "$orphans" ]]; then
        divider
        echo -e "${BOLD}${YELLOW}Các gói orphan tìm thấy:${RESET}"
        divider
        echo "$orphans"
        echo ""
        divider
        echo -en "${CYAN}${ICON_WARNING} Xóa các gói này? (y/N):${RESET} "
        read confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo ""
            warning "Đang xóa gói orphan..."
            echo ""
            sudo pacman -Rns $(pacman -Qdtq)
            echo ""
            if [[ $? -eq 0 ]]; then
                success "Xóa gói orphan thành công!"
            else
                error "Xóa gói orphan thất bại!"
            fi
        fi
    else
        success "Không tìm thấy gói orphan nào! Hệ thống sạch sẽ ${ICON_SPARKLE}"
    fi

    pause_prompt
}

# Danh sách gói đã cài
list_installed() {
    show_header
    create_box "DANH SÁCH GÓI ĐÃ CÀI ${ICON_CHECK}" 63
    echo ""

    menu_item "1" "Liệt kê tất cả gói" "${ICON_PACKAGE}"
    menu_item "2" "Liệt kê gói từ AUR" "${ICON_STAR}"
    menu_item "3" "Liệt kê gói explicit (cài thủ công)" "${ICON_CHECK}"

    if has_flatpak; then
        menu_item "4" "Liệt kê gói Flatpak" "${ICON_PACKAGE}"
    fi

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn loại danh sách:${RESET} "
    read choice

    case $choice in
        1)
            echo ""
            info "Đang lấy danh sách tất cả gói..."
            echo ""
            divider
            pacman -Q | less
            ;;
        2)
            echo ""
            info "Đang lấy danh sách gói từ AUR..."
            echo ""
            divider
            pacman -Qm | less
            ;;
        3)
            echo ""
            info "Đang lấy danh sách gói explicit..."
            echo ""
            divider
            pacman -Qe | less
            ;;
        4)
            if has_flatpak; then
                echo ""
                info "Đang lấy danh sách gói Flatpak..."
                echo ""
                divider
                flatpak list
                pause_prompt
            fi
            ;;
        0)
            return
            ;;
    esac
}

# Kiểm tra gói bị hỏng
check_broken() {
    show_header
    create_box "KIỂM TRA GÓI BỊ HỎNG ${ICON_SHIELD}" 63
    echo ""

    info "Đang kiểm tra hệ thống..."
    echo ""

    divider
    echo -e "${BOLD}${PURPLE}${ICON_SHIELD} Kiểm tra database integrity:${RESET}"
    divider
    sudo pacman -Dk

    echo ""
    divider
    echo -e "${BOLD}${PURPLE}${ICON_SHIELD} Kiểm tra file conflicts:${RESET}"
    divider
    sudo pacman -Qkk 2>&1 | grep -v "0 missing files"

    echo ""
    success "Hoàn thành kiểm tra!"
    pause_prompt
}

# Downgrade gói
downgrade_package() {
    show_header
    create_box "DOWNGRADE GÓI ⬇" 63
    echo ""

    if ! command -v downgrade &> /dev/null; then
        error "Chưa cài đặt 'downgrade'!"
        echo ""
        echo -en "${CYAN}${ICON_WARNING} Cài đặt downgrade? (y/N):${RESET} "
        read confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                echo ""
                info "Đang cài đặt downgrade..."
                echo ""
                $aur_helper -S downgrade
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cài đặt downgrade thành công!"
                else
                    error "Cài đặt downgrade thất bại!"
                fi
            else
                echo ""
                error "Cần cài AUR helper trước!"
            fi
        fi
        pause_prompt
        return
    fi

    echo -en "${CYAN}${ICON_SEARCH} Nhập tên gói cần downgrade:${RESET} "
    read pkg

    if [[ -n "$pkg" ]]; then
        echo ""
        info "Đang downgrade ${BOLD}${pkg}${RESET}..."
        echo ""
        sudo downgrade $pkg
        echo ""
        if [[ $? -eq 0 ]]; then
            success "Downgrade ${BOLD}${pkg}${RESET} thành công!"
        else
            error "Downgrade ${BOLD}${pkg}${RESET} thất bại!"
        fi
        pause_prompt
    fi
}

# Xem log gói
view_logs() {
    show_header
    create_box "LOG GÓI 📋" 63
    echo ""

    info "Hiển thị 50 dòng log gần nhất của pacman..."
    echo ""
    divider
    echo -e "${BOLD}${PURPLE}Pacman Logs:${RESET}"
    divider
    tail -n 50 /var/log/pacman.log

    pause_prompt
}

# Mirror management
mirror_management() {
    show_header
    create_box "QUẢN LÝ MIRROR 🌐" 63
    echo ""

    menu_item "1" "Cập nhật mirrorlist (reflector)" "🔄"
    menu_item "2" "Sao lưu mirrorlist hiện tại" "💾"
    menu_item "3" "Xem mirrorlist hiện tại" "👁"

    echo ""
    menu_item "0" "Quay lại" "${ICON_ARROW}"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn chức năng:${RESET} "
    read choice

    case $choice in
        1)
            if ! command -v reflector &> /dev/null; then
                echo ""
                error "Chưa cài đặt 'reflector'!"
                echo -en "${CYAN}${ICON_WARNING} Cài đặt reflector? (y/N):${RESET} "
                read confirm

                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo ""
                    info "Đang cài đặt reflector..."
                    echo ""
                    sudo pacman -S reflector
                    echo ""
                    if [[ $? -eq 0 ]]; then
                        success "Cài đặt reflector thành công!"
                    else
                        error "Cài đặt reflector thất bại!"
                    fi
                fi
            else
                echo ""
                info "Đang cập nhật mirrorlist (lấy 20 mirror nhanh nhất)..."
                echo ""
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
                sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
                echo ""
                if [[ $? -eq 0 ]]; then
                    success "Cập nhật mirrorlist thành công!"
                else
                    error "Cập nhật mirrorlist thất bại!"
                fi
            fi
            pause_prompt
            ;;
        2)
            echo ""
            info "Đang sao lưu mirrorlist..."
            sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup.$(date +%Y%m%d)
            echo ""
            success "Đã sao lưu mirrorlist!"
            pause_prompt
            ;;
        3)
            echo ""
            info "Hiển thị mirrorlist hiện tại..."
            echo ""
            divider
            cat /etc/pacman.d/mirrorlist | less
            ;;
        0)
            return
            ;;
    esac
}

# Cài đặt YAY
install_yay() {
    show_header
    create_box "CÀI ĐẶT YAY (AUR HELPER) ${ICON_SPARKLE}" 63
    echo ""

    info "YAY là AUR helper phổ biến nhất cho Arch Linux"
    echo ""
    echo -en "${CYAN}${ICON_WARNING} Bạn có muốn cài đặt YAY? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        info "Đang cài đặt dependencies..."
        echo ""
        sudo pacman -S --needed git base-devel

        if [[ $? -ne 0 ]]; then
            echo ""
            error "Cài đặt dependencies thất bại!"
            pause_prompt
            return
        fi

        echo ""
        info "Đang clone YAY từ AUR..."
        echo ""
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay

        echo ""
        info "Đang build và cài đặt YAY..."
        echo ""
        makepkg -si

        if [[ $? -eq 0 ]]; then
            cd ~
            rm -rf /tmp/yay
            echo ""
            success "Hoàn tất cài đặt YAY! ${ICON_ROCKET}"
        else
            cd ~
            rm -rf /tmp/yay
            echo ""
            error "Cài đặt YAY thất bại!"
        fi
    fi

    pause_prompt
}

# Pause prompt
pause_prompt() {
    echo ""
    divider
    echo -en "${DIM}Nhấn ${BOLD}Enter${RESET}${DIM} để tiếp tục...${RESET}"
    read
}
#!/usr/bin/env zsh

# =============================================================================
# FONT MANAGER - Quản lý font chữ cho Arch Linux
# =============================================================================

# Icons cho Font Manager
ICON_FONT="🔤"
ICON_NERD="󰊄"
ICON_LIST="📋"

# =============================================================================
# Font Management Functions
# =============================================================================

# Menu chính Font Manager
font_manager_menu() {
    while true; do
        show_header
        create_box "QUẢN LÝ FONT CHỮ ${ICON_FONT}" 63
        echo ""

        section_header "Cài đặt Font" "${ICON_DOWNLOAD}"
        menu_item "1" "Cài đặt Nerd Fonts (lập trình)" "${ICON_NERD}"
        menu_item "2" "Cài đặt font hệ thống (Noto, DejaVu)" "${ICON_FONT}"
        menu_item "3" "Cài đặt font emoji" "😀"
        menu_item "4" "Cài đặt font CJK (Tiếng Trung/Nhật/Hàn)" "🇯🇵"
        menu_item "5" "Cài đặt font Windows (MS Fonts)" "🪟"

        section_header "Quản lý Font" "${ICON_TOOLS}"
        menu_item "6" "Liệt kê font đã cài" "${ICON_LIST}"
        menu_item "7" "Tìm kiếm font" "${ICON_SEARCH}"
        menu_item "8" "Xóa font" "${ICON_TRASH}"
        menu_item "9" "Cập nhật cache font" "🔄"

        section_header "Kiểm tra & Xem" "${ICON_INFO}"
        menu_item "10" "Xem font families khả dụng" "👁"
        menu_item "11" "Xem chi tiết font" "${ICON_INFO}"
        menu_item "12" "Test hiển thị font" "✨"

        echo ""
        divider
        menu_item "0" "Quay lại menu chính" "${ICON_ARROW}"
        divider
        echo ""
        echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn [0-12]:${RESET} "
        read choice

        case $choice in
            1) install_nerd_fonts ;;
            2) install_system_fonts ;;
            3) install_emoji_fonts ;;
            4) install_cjk_fonts ;;
            5) install_ms_fonts ;;
            6) list_installed_fonts ;;
            7) search_fonts ;;
            8) remove_font ;;
            9) update_font_cache ;;
            10) list_font_families ;;
            11) show_font_info ;;
            12) test_font_display ;;
            0) return ;;
            *)
                echo -e "${RED}Lựa chọn không hợp lệ!${RESET}"
                sleep 1
                ;;
        esac
    done
}

# =============================================================================
# Cài đặt Font Functions
# =============================================================================

# Cài đặt Nerd Fonts
install_nerd_fonts() {
    show_header
    create_box "CÀI ĐẶT NERD FONTS ${ICON_NERD}" 63
    echo ""

    info "Nerd Fonts là các font được patch với icons cho terminal/code editor"
    echo ""

    section_header "Nerd Fonts phổ biến" "${ICON_STAR}"
    echo ""
    echo -e "  ${CYAN}1.${RESET} FiraCode Nerd Font (Khuyến nghị)"
    echo -e "  ${CYAN}2.${RESET} JetBrainsMono Nerd Font"
    echo -e "  ${CYAN}3.${RESET} Hack Nerd Font"
    echo -e "  ${CYAN}4.${RESET} Meslo Nerd Font"
    echo -e "  ${CYAN}5.${RESET} SourceCodePro Nerd Font"
    echo -e "  ${CYAN}6.${RESET} UbuntuMono Nerd Font"
    echo -e "  ${CYAN}7.${RESET} DejaVuSansMono Nerd Font"
    echo -e "  ${CYAN}8.${RESET} Cài tất cả Nerd Fonts phổ biến"
    echo -e "  ${CYAN}0.${RESET} Quay lại"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn font:${RESET} "
    read choice

    local fonts=()
    case $choice in
        1) fonts=("ttf-firacode-nerd") ;;
        2) fonts=("ttf-jetbrains-mono-nerd") ;;
        3) fonts=("ttf-hack-nerd") ;;
        4)
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                fonts=("ttf-meslo-nerd")
            else
                error "Cần AUR helper (yay/paru) để cài Meslo Nerd Font"
                pause_prompt
                return
            fi
            ;;
        5) fonts=("ttf-sourcecodepro-nerd") ;;
        6) fonts=("ttf-ubuntumono-nerd") ;;
        7) fonts=("ttf-dejavu-nerd") ;;
        8)
            fonts=(
                "ttf-firacode-nerd"
                "ttf-jetbrains-mono-nerd"
                "ttf-hack-nerd"
                "ttf-sourcecodepro-nerd"
                "ttf-ubuntumono-nerd"
                "ttf-dejavu-nerd"
            )
            ;;
        0) return ;;
        *)
            error "Lựa chọn không hợp lệ!"
            pause_prompt
            return
            ;;
    esac

    if [[ ${#fonts[@]} -gt 0 ]]; then
        echo ""
        info "Đang cài đặt font(s)..."
        echo ""

        # Kiểm tra xem font có trong AUR không
        local needs_aur=false
        for font in "${fonts[@]}"; do
            if ! pacman -Ss "^${font}$" &>/dev/null; then
                needs_aur=true
                break
            fi
        done

        if [[ "$needs_aur" == true ]]; then
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                $aur_helper -S --needed "${fonts[@]}"
            else
                error "Một số font cần AUR helper. Vui lòng cài yay/paru trước!"
                pause_prompt
                return
            fi
        else
            sudo pacman -S --needed "${fonts[@]}"
        fi

        if [[ $? -eq 0 ]]; then
            echo ""
            success "Cài đặt thành công! ${ICON_ROCKET}"
            echo ""
            info "Đang cập nhật cache font..."
            fc-cache -fv
            echo ""
            success "Hoàn tất! Vui lòng đóng và mở lại terminal."
        else
            echo ""
            error "Cài đặt thất bại!"
        fi
    fi

    pause_prompt
}

# Cài đặt System Fonts
install_system_fonts() {
    show_header
    create_box "CÀI ĐẶT FONT HỆ THỐNG ${ICON_FONT}" 63
    echo ""

    info "Font hệ thống cho giao diện desktop và ứng dụng"
    echo ""

    section_header "Font families" "${ICON_LIST}"
    echo ""
    echo -e "  ${CYAN}1.${RESET} Noto Fonts (Google - Khuyến nghị)"
    echo -e "  ${CYAN}2.${RESET} DejaVu Fonts"
    echo -e "  ${CYAN}3.${RESET} Liberation Fonts (Thay thế MS Office)"
    echo -e "  ${CYAN}4.${RESET} GNU FreeFont"
    echo -e "  ${CYAN}5.${RESET} Ubuntu Fonts"
    echo -e "  ${CYAN}6.${RESET} Roboto Fonts (Material Design)"
    echo -e "  ${CYAN}7.${RESET} Cài tất cả font hệ thống"
    echo -e "  ${CYAN}0.${RESET} Quay lại"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn font:${RESET} "
    read choice

    local fonts=()
    case $choice in
        1) fonts=("noto-fonts" "noto-fonts-extra") ;;
        2) fonts=("ttf-dejavu" "ttf-dejavu-nerd") ;;
        3) fonts=("ttf-liberation") ;;
        4) fonts=("gnu-free-fonts") ;;
        5) fonts=("ttf-ubuntu-font-family") ;;
        6) fonts=("ttf-roboto" "ttf-roboto-mono") ;;
        7)
            fonts=(
                "noto-fonts"
                "noto-fonts-extra"
                "ttf-dejavu"
                "ttf-liberation"
                "gnu-free-fonts"
                "ttf-ubuntu-font-family"
                "ttf-roboto"
                "ttf-roboto-mono"
            )
            ;;
        0) return ;;
        *)
            error "Lựa chọn không hợp lệ!"
            pause_prompt
            return
            ;;
    esac

    if [[ ${#fonts[@]} -gt 0 ]]; then
        echo ""
        info "Đang cài đặt font(s)..."
        echo ""
        sudo pacman -S --needed "${fonts[@]}"

        if [[ $? -eq 0 ]]; then
            echo ""
            success "Cài đặt thành công! ${ICON_ROCKET}"
            echo ""
            info "Đang cập nhật cache font..."
            fc-cache -fv
        else
            echo ""
            error "Cài đặt thất bại!"
        fi
    fi

    pause_prompt
}

# Cài đặt Emoji Fonts
install_emoji_fonts() {
    show_header
    create_box "CÀI ĐẶT FONT EMOJI 😀" 63
    echo ""

    info "Font emoji để hiển thị biểu tượng cảm xúc"
    echo ""

    local fonts=(
        "noto-fonts-emoji"
        "ttf-joypixels"
        "ttf-twemoji"
    )

    echo -e "${YELLOW}Fonts sẽ cài đặt:${RESET}"
    for font in "${fonts[@]}"; do
        echo -e "  - ${font}"
    done
    echo ""

    divider
    echo -en "${CYAN}Tiếp tục cài đặt? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        info "Đang cài đặt emoji fonts..."
        echo ""
        sudo pacman -S --needed "${fonts[@]}"

        if [[ $? -eq 0 ]]; then
            echo ""
            success "Cài đặt thành công! ${ICON_ROCKET}"
            echo ""
            info "Đang cập nhật cache font..."
            fc-cache -fv
            echo ""
            echo -e "${GREEN}Test emoji:${RESET} 😀 🎉 🚀 ❤️ 🔥 ✨ 🎨 💻"
        else
            echo ""
            error "Cài đặt thất bại!"
        fi
    fi

    pause_prompt
}

# Cài đặt CJK Fonts
install_cjk_fonts() {
    show_header
    create_box "CÀI ĐẶT FONT CJK 🇯🇵🇨🇳🇰🇷" 63
    echo ""

    info "Font cho tiếng Trung, Nhật, Hàn (Chinese, Japanese, Korean)"
    echo ""

    section_header "CJK Font packages" "${ICON_LIST}"
    echo ""
    echo -e "  ${CYAN}1.${RESET} Noto CJK (Google - Khuyến nghị)"
    echo -e "  ${CYAN}2.${RESET} Adobe Source Han Sans"
    echo -e "  ${CYAN}3.${RESET} Adobe Source Han Serif"
    echo -e "  ${CYAN}4.${RESET} WenQuanYi (Chinese)"
    echo -e "  ${CYAN}5.${RESET} Cài tất cả CJK fonts"
    echo -e "  ${CYAN}0.${RESET} Quay lại"
    echo ""
    divider
    echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn font:${RESET} "
    read choice

    local fonts=()
    case $choice in
        1) fonts=("noto-fonts-cjk") ;;
        2) fonts=("adobe-source-han-sans-otc-fonts") ;;
        3) fonts=("adobe-source-han-serif-otc-fonts") ;;
        4) fonts=("wqy-zenhei" "wqy-microhei") ;;
        5)
            fonts=(
                "noto-fonts-cjk"
                "adobe-source-han-sans-otc-fonts"
                "adobe-source-han-serif-otc-fonts"
                "wqy-zenhei"
            )
            ;;
        0) return ;;
        *)
            error "Lựa chọn không hợp lệ!"
            pause_prompt
            return
            ;;
    esac

    if [[ ${#fonts[@]} -gt 0 ]]; then
        echo ""
        info "Đang cài đặt font(s)..."
        echo ""
        sudo pacman -S --needed "${fonts[@]}"

        if [[ $? -eq 0 ]]; then
            echo ""
            success "Cài đặt thành công! ${ICON_ROCKET}"
            echo ""
            info "Đang cập nhật cache font..."
            fc-cache -fv
            echo ""
            echo -e "${GREEN}Test CJK:${RESET} 你好 こんにちは 안녕하세요"
        else
            echo ""
            error "Cài đặt thất bại!"
        fi
    fi

    pause_prompt
}

# Cài đặt MS Fonts
install_ms_fonts() {
    show_header
    create_box "CÀI ĐẶT FONT MICROSOFT 🪟" 63
    echo ""

    warning "Font Microsoft cần AUR helper và có thể vi phạm bản quyền!"
    echo ""
    info "Bao gồm: Arial, Times New Roman, Verdana, Comic Sans, v.v."
    echo ""

    local aur_helper=$(detect_aur_helper)
    if [[ -z "$aur_helper" ]]; then
        error "Cần AUR helper (yay/paru) để cài MS Fonts!"
        echo ""
        info "Vui lòng cài yay/paru trước (chọn option 13 ở menu chính)"
        pause_prompt
        return
    fi

    divider
    echo -en "${CYAN}Tiếp tục cài đặt MS Fonts? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo ""
        info "Đang cài đặt MS Fonts từ AUR..."
        echo ""
        $aur_helper -S --needed ttf-ms-fonts

        if [[ $? -eq 0 ]]; then
            echo ""
            success "Cài đặt thành công! ${ICON_ROCKET}"
            echo ""
            info "Đang cập nhật cache font..."
            fc-cache -fv
        else
            echo ""
            error "Cài đặt thất bại!"
        fi
    fi

    pause_prompt
}

# =============================================================================
# Quản lý Font Functions
# =============================================================================

# Liệt kê font đã cài
list_installed_fonts() {
    show_header
    create_box "FONT ĐÃ CÀI ĐẶT ${ICON_LIST}" 63
    echo ""

    info "Liệt kê các gói font đã cài đặt..."
    echo ""

    local font_packages=$(pacman -Qq | grep -E 'font|ttf-|otf-|noto-' | sort)

    if [[ -n "$font_packages" ]]; then
        section_header "Gói font đã cài" "${ICON_PACKAGE}"
        echo ""

        local count=0
        while IFS= read -r pkg; do
            count=$((count + 1))
            local desc=$(pacman -Qi "$pkg" 2>/dev/null | grep "Description" | cut -d: -f2- | xargs)
            echo -e "  ${CYAN}$count.${RESET} ${BOLD}$pkg${RESET}"
            if [[ -n "$desc" ]]; then
                echo -e "     ${DIM}$desc${RESET}"
            fi
        done <<< "$font_packages"

        echo ""
        success "Tổng số: $count gói font"
    else
        warning "Không tìm thấy gói font nào!"
    fi

    echo ""
    divider
    echo ""
    info "Để xem chi tiết font families, chọn option 10"

    pause_prompt
}

# Tìm kiếm font
search_fonts() {
    show_header
    create_box "TÌM KIẾM FONT ${ICON_SEARCH}" 63
    echo ""

    echo -en "${CYAN}Nhập từ khóa tìm kiếm:${RESET} "
    read keyword

    if [[ -z "$keyword" ]]; then
        warning "Vui lòng nhập từ khóa!"
        pause_prompt
        return
    fi

    echo ""
    info "Đang tìm kiếm font '$keyword'..."
    echo ""

    section_header "Kho chính thức (pacman)" "${ICON_PACKAGE}"
    echo ""
    pacman -Ss "$keyword" | grep -E 'font|ttf-|otf-' | head -20

    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        echo ""
        section_header "AUR" "${ICON_STAR}"
        echo ""
        $aur_helper -Ss "$keyword" | grep -E 'font|ttf-|otf-' | head -20
    fi

    pause_prompt
}

# Xóa font
remove_font() {
    show_header
    create_box "XÓA FONT ${ICON_TRASH}" 63
    echo ""

    info "Liệt kê các gói font có thể xóa..."
    echo ""

    local font_packages=$(pacman -Qq | grep -E 'font|ttf-|otf-|noto-' | sort)

    if [[ -z "$font_packages" ]]; then
        warning "Không tìm thấy gói font nào!"
        pause_prompt
        return
    fi

    local -a fonts_array
    local count=0
    while IFS= read -r pkg; do
        count=$((count + 1))
        fonts_array+=("$pkg")
        echo -e "  ${CYAN}$count.${RESET} $pkg"
    done <<< "$font_packages"

    echo ""
    divider
    echo -en "${CYAN}Nhập số thứ tự font cần xóa (0 để hủy):${RESET} "
    read choice

    if [[ "$choice" -eq 0 ]] 2>/dev/null; then
        return
    fi

    if [[ "$choice" -gt 0 && "$choice" -le "${#fonts_array[@]}" ]] 2>/dev/null; then
        local selected_font="${fonts_array[$choice]}"
        echo ""
        warning "Sắp xóa: ${BOLD}$selected_font${RESET}"
        echo ""
        echo -en "${RED}Xác nhận xóa? (y/N):${RESET} "
        read confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            echo ""
            info "Đang xóa font..."
            echo ""
            sudo pacman -Rns "$selected_font"

            if [[ $? -eq 0 ]]; then
                echo ""
                success "Xóa thành công!"
                echo ""
                info "Đang cập nhật cache font..."
                fc-cache -fv
            else
                echo ""
                error "Xóa thất bại!"
            fi
        fi
    else
        error "Lựa chọn không hợp lệ!"
    fi

    pause_prompt
}

# Cập nhật font cache
update_font_cache() {
    show_header
    create_box "CẬP NHẬT CACHE FONT 🔄" 63
    echo ""

    info "Đang quét và cập nhật cache font..."
    echo ""

    fc-cache -fv

    if [[ $? -eq 0 ]]; then
        echo ""
        success "Cập nhật cache thành công! ${ICON_ROCKET}"
    else
        echo ""
        error "Cập nhật cache thất bại!"
    fi

    pause_prompt
}

# =============================================================================
# Kiểm tra & Xem Font Functions
# =============================================================================

# Liệt kê font families
list_font_families() {
    show_header
    create_box "FONT FAMILIES KHẢ DỤNG 👁" 63
    echo ""

    info "Liệt kê tất cả font families có sẵn trên hệ thống..."
    echo ""

    section_header "Monospace Fonts (Code/Terminal)" "${ICON_NERD}"
    echo ""
    fc-list : family | grep -i 'mono\|nerd\|code\|hack\|fira' | sort -u | head -20

    echo ""
    section_header "Sans-Serif Fonts" "${ICON_FONT}"
    echo ""
    fc-list : family | grep -i 'sans\|arial\|helvetica\|roboto' | sort -u | head -20

    echo ""
    section_header "Serif Fonts" "${ICON_FONT}"
    echo ""
    fc-list : family | grep -i 'serif\|times\|georgia' | sort -u | head -15

    echo ""
    divider
    echo ""
    info "Để xem tất cả: ${CYAN}fc-list : family | sort -u${RESET}"

    pause_prompt
}

# Xem chi tiết font
show_font_info() {
    show_header
    create_box "CHI TIẾT FONT ${ICON_INFO}" 63
    echo ""

    echo -en "${CYAN}Nhập tên font (vd: FiraCode):${RESET} "
    read font_name

    if [[ -z "$font_name" ]]; then
        warning "Vui lòng nhập tên font!"
        pause_prompt
        return
    fi

    echo ""
    info "Chi tiết font '$font_name'..."
    echo ""

    fc-list | grep -i "$font_name"

    if [[ $? -ne 0 ]]; then
        echo ""
        warning "Không tìm thấy font '$font_name'!"
    fi

    pause_prompt
}

# Test hiển thị font
test_font_display() {
    show_header
    create_box "TEST HIỂN THỊ FONT ✨" 63
    echo ""

    echo -e "╔═══════════════════════════════════════════════════════════╗"
    echo -e "║                   ${BOLD}FONT DISPLAY TEST${RESET}                        ║"
    echo -e "╚═══════════════════════════════════════════════════════════╝"
    echo ""

    section_header "Box Drawing & Powerline" "╔╗"
    echo ""
    echo -e "  ╔═╗ ╚═╝ ║ ═ ╠╣ ╬ ╭─╮ ╰─╯ │ ─ ┌┐└┘ ├┤ ┬┴ ┼"
    echo -e "                     "
    echo ""

    section_header "Icons & Symbols" "${ICON_STAR}"
    echo ""
    echo -e "  ✓ ✗ ⚠ ℹ 🚀 📦 🗑 🔍 ⬆ ⬇ 🧹 🛡 🔧 ✨"
    echo -e "  🔥 ☑ ➜ ⭐ 💻 🌐 🗄 📋 🎨 🎉 ❤️ 🐧"
    echo ""

    section_header "Emoji" "😀"
    echo ""
    echo -e "  😀 😃 😄 😁 😊 🥰 😍 🤩 😎 🤓"
    echo -e "  👍 👎 👏 🙌 💪 🤝 ✌️ 🤘 👋 🖐"
    echo ""

    section_header "Programming Ligatures" "${ICON_NERD}"
    echo ""
    echo -e "  != == === !== <= >= => -> <- <> || && ++ --"
    echo -e "  /** */ // /* */ <!-- --> := :: .. ... |>"
    echo ""

    section_header "Numbers & Math" "🔢"
    echo ""
    echo -e "  0123456789 + - × ÷ = ≠ ≤ ≥ ± ∞ √ ∑ ∫"
    echo ""

    section_header "CJK Characters" "🇯🇵"
    echo ""
    echo -e "  你好世界 こんにちは世界 안녕하세요 세상"
    echo ""

    section_header "Colors" "🎨"
    echo ""
    echo -e "  ${RED}██${RESET} ${GREEN}██${RESET} ${YELLOW}██${RESET} ${BLUE}██${RESET} ${PURPLE}██${RESET} ${CYAN}██${RESET} ${WHITE}██${RESET}"
    echo ""

    section_header "Alphabet (Aa-Zz)" "🔤"
    echo ""
    echo -e "  ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    echo -e "  abcdefghijklmnopqrstuvwxyz"
    echo ""

    divider
    echo ""

    info "Nếu bạn thấy ô vuông (□) thay vì icon/emoji:"
    echo -e "  → Cài thêm font emoji: ${CYAN}option 3${RESET}"
    echo -e "  → Cài Nerd Fonts: ${CYAN}option 1${RESET}"
    echo ""
    info "Đề xuất font cho terminal/code:"
    echo -e "  ${GREEN}✓${RESET} FiraCode Nerd Font Mono"
    echo -e "  ${GREEN}✓${RESET} JetBrainsMono Nerd Font Mono"
    echo -e "  ${GREEN}✓${RESET} Hack Nerd Font Mono"

    pause_prompt
}

# =============================================================================
# DEVELOPMENT TOOLS - Môi trường phát triển
# =============================================================================

# Menu Development Tools
dev_tools_menu() {
    while true; do
        show_header
        create_box "MÔI TRƯỜNG PHÁT TRIỂN ${ICON_FIRE}" 63
        echo ""

        section_header "Web Development" "🌐"
        menu_item "1" "PHP Stack (PHP, Composer, Extensions)" "🐘"
        menu_item "2" "Laravel (Framework)" "${ICON_SPARKLE}"
        menu_item "3" "Node.js Stack (Node.js, npm, yarn, pnpm)" "🟢"

        section_header "Databases" "🗄"
        menu_item "4" "PostgreSQL" "🐘"
        menu_item "5" "MySQL/MariaDB" "🐬"
        menu_item "6" "MongoDB" "🍃"
        menu_item "7" "Redis" "🔴"

        section_header "Programming Languages" "💻"
        menu_item "8" "Java (JDK)" "☕"
        menu_item "9" "Python Stack (pip, virtualenv, poetry)" "🐍"
        menu_item "10" "Go" "🐹"
        menu_item "11" "Rust" "🦀"

        section_header "Tools & Others" "${ICON_TOOLS}"
        menu_item "12" "Docker & Docker Compose" "🐳"
        menu_item "13" "Git & Git Tools" "📚"
        menu_item "14" "Kiểm tra các công cụ đã cài" "${ICON_CHECK}"

        echo ""
        divider
        menu_item "0" "Quay lại menu chính" "${ICON_ARROW}"
        divider
        echo ""
        echo -en "${BOLD}${PURPLE}${ICON_ARROW}${RESET} ${CYAN}Chọn [0-14]:${RESET} "
        read choice

        case $choice in
            1) install_php_stack ;;
            2) install_laravel ;;
            3) install_nodejs_stack ;;
            4) install_postgresql ;;
            5) install_mysql ;;
            6) install_mongodb ;;
            7) install_redis ;;
            8) install_java ;;
            9) install_python_stack ;;
            10) install_go ;;
            11) install_rust ;;
            12) install_docker ;;
            13) install_git_tools ;;
            14) check_dev_tools ;;
            0) return ;;
            *)
                error "Lựa chọn không hợp lệ!"
                sleep 1
                ;;
        esac
    done
}

# PHP Stack
install_php_stack() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT PHP STACK ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • PHP (latest)"
    echo "  • PHP Extensions (common)"
    echo "  • Composer (package manager)"
    echo "  • PHP-FPM (FastCGI)"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt PHP và extensions...${RESET}"
        sudo pacman -S --needed php php-fpm php-gd php-intl php-sqlite php-pgsql \
            php-redis php-apcu php-imagick php-sodium

        echo -e "${YELLOW}Đang cài đặt Composer...${RESET}"
        sudo pacman -S --needed composer

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt PHP Stack!${RESET}"
        echo ""
        echo -e "${CYAN}Phiên bản đã cài:${RESET}"
        php --version | head -1
        composer --version
        echo ""
        echo -e "${YELLOW}Lưu ý:${RESET}"
        echo "  • File cấu hình: /etc/php/php.ini"
        echo "  • Enable extensions: uncomment trong php.ini"
        echo "  • Start PHP-FPM: sudo systemctl start php-fpm"
        echo "  • Enable PHP-FPM: sudo systemctl enable php-fpm"
    fi

    pause_prompt
}

# Laravel
install_laravel() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT LARAVEL ═══${RESET}"
    echo ""

    # Check if composer is installed
    if ! command -v composer &> /dev/null; then
        echo -e "${RED}Composer chưa được cài đặt!${RESET}"
        echo -en "${CYAN}Cài đặt PHP Stack trước? (y/N):${RESET} "
        read install_php
        if [[ "$install_php" == "y" || "$install_php" == "Y" ]]; then
            install_php_stack
            return
        else
            pause_prompt
            return
        fi
    fi

    echo -e "${CYAN}Chọn cách cài đặt Laravel:${RESET}"
    echo -e "${GREEN}1.${RESET} Cài Laravel Installer (global)"
    echo -e "${GREEN}2.${RESET} Tạo project Laravel mới"
    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn:${RESET} "
    read choice

    case $choice in
        1)
            echo -e "${YELLOW}Đang cài đặt Laravel Installer...${RESET}"
            composer global require laravel/installer
            echo ""
            echo -e "${GREEN}✓ Đã cài Laravel Installer!${RESET}"
            echo -e "${YELLOW}Thêm vào PATH (nếu chưa có):${RESET}"
            echo "  export PATH=\"\$HOME/.config/composer/vendor/bin:\$PATH\""
            echo -e "${CYAN}Tạo project mới:${RESET}"
            echo "  laravel new project-name"
            ;;
        2)
            echo -en "${CYAN}Nhập tên project:${RESET} "
            read project_name
            if [[ -n "$project_name" ]]; then
                echo -e "${YELLOW}Đang tạo project Laravel '$project_name'...${RESET}"
                composer create-project laravel/laravel "$project_name"
                echo ""
                echo -e "${GREEN}✓ Project đã được tạo!${RESET}"
                echo -e "${CYAN}Chạy server:${RESET}"
                echo "  cd $project_name"
                echo "  php artisan serve"
            fi
            ;;
    esac

    pause_prompt
}

# Node.js Stack
install_nodejs_stack() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT NODE.JS STACK ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • Node.js (LTS)"
    echo "  • npm (package manager)"
    echo "  • yarn (optional)"
    echo "  • pnpm (optional)"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Node.js và npm...${RESET}"
        sudo pacman -S --needed nodejs npm

        echo ""
        echo -en "${CYAN}Cài đặt yarn? (y/N):${RESET} "
        read install_yarn
        if [[ "$install_yarn" == "y" || "$install_yarn" == "Y" ]]; then
            sudo pacman -S --needed yarn
        fi

        echo ""
        echo -en "${CYAN}Cài đặt pnpm? (y/N):${RESET} "
        read install_pnpm
        if [[ "$install_pnpm" == "y" || "$install_pnpm" == "Y" ]]; then
            sudo npm install -g pnpm
        fi

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Node.js Stack!${RESET}"
        echo ""
        echo -e "${CYAN}Phiên bản đã cài:${RESET}"
        node --version
        npm --version
        command -v yarn &> /dev/null && yarn --version
        command -v pnpm &> /dev/null && pnpm --version
        echo ""
        echo -e "${YELLOW}Global packages phổ biến:${RESET}"
        echo "  npm install -g typescript ts-node"
        echo "  npm install -g @vue/cli"
        echo "  npm install -g create-react-app"
    fi

    pause_prompt
}

# PostgreSQL
install_postgresql() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT POSTGRESQL ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • PostgreSQL Server"
    echo "  • PostgreSQL Client Tools"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt PostgreSQL...${RESET}"
        sudo pacman -S --needed postgresql

        echo ""
        echo -e "${YELLOW}Khởi tạo database cluster...${RESET}"
        sudo -iu postgres initdb -D /var/lib/postgres/data

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt PostgreSQL!${RESET}"
        echo ""
        echo -e "${YELLOW}Các lệnh quan trọng:${RESET}"
        echo "  • Start:  sudo systemctl start postgresql"
        echo "  • Enable: sudo systemctl enable postgresql"
        echo "  • Status: sudo systemctl status postgresql"
        echo ""
        echo -e "${YELLOW}Tạo user và database:${RESET}"
        echo "  sudo -u postgres createuser --interactive"
        echo "  sudo -u postgres createdb mydb"
        echo ""
        echo -en "${CYAN}Start PostgreSQL ngay? (y/N):${RESET} "
        read start_now
        if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
            sudo systemctl start postgresql
            sudo systemctl enable postgresql
            echo -e "${GREEN}✓ PostgreSQL đã được khởi động!${RESET}"
        fi
    fi

    pause_prompt
}

# MySQL/MariaDB
install_mysql() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT MYSQL/MARIADB ═══${RESET}"
    echo ""
    echo -e "${GREEN}1.${RESET} MariaDB (khuyến nghị)"
    echo -e "${GREEN}2.${RESET} MySQL"
    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn:${RESET} "
    read choice

    case $choice in
        1)
            echo -e "${YELLOW}Đang cài đặt MariaDB...${RESET}"
            sudo pacman -S --needed mariadb

            echo ""
            echo -e "${YELLOW}Khởi tạo MariaDB...${RESET}"
            sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

            echo ""
            echo -e "${GREEN}✓ Hoàn tất cài đặt MariaDB!${RESET}"
            echo ""
            echo -e "${YELLOW}Các lệnh quan trọng:${RESET}"
            echo "  • Start:  sudo systemctl start mariadb"
            echo "  • Enable: sudo systemctl enable mariadb"
            echo "  • Secure:  sudo mysql_secure_installation"
            echo ""
            echo -en "${CYAN}Start MariaDB và chạy secure installation? (y/N):${RESET} "
            read start_now
            if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
                sudo systemctl start mariadb
                sudo systemctl enable mariadb
                sudo mysql_secure_installation
            fi
            ;;
        2)
            echo -e "${YELLOW}Đang cài đặt MySQL...${RESET}"
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                $aur_helper -S mysql
            else
                echo -e "${RED}Cần AUR helper để cài MySQL!${RESET}"
            fi
            ;;
    esac

    pause_prompt
}

# MongoDB
install_mongodb() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT MONGODB ═══${RESET}"
    echo ""

    local aur_helper=$(detect_aur_helper)
    if [[ -z "$aur_helper" ]]; then
        echo -e "${RED}Cần AUR helper để cài MongoDB!${RESET}"
        echo -en "${CYAN}Cài đặt YAY trước? (y/N):${RESET} "
        read install_yay_now
        if [[ "$install_yay_now" == "y" || "$install_yay_now" == "Y" ]]; then
            install_yay
        fi
        pause_prompt
        return
    fi

    echo -e "${CYAN}Sẽ cài đặt MongoDB từ AUR${RESET}"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt MongoDB...${RESET}"
        $aur_helper -S mongodb-bin mongodb-tools-bin

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt MongoDB!${RESET}"
        echo ""
        echo -e "${YELLOW}Các lệnh quan trọng:${RESET}"
        echo "  • Start:  sudo systemctl start mongodb"
        echo "  • Enable: sudo systemctl enable mongodb"
        echo "  • Connect: mongosh"
    fi

    pause_prompt
}

# Redis
install_redis() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT REDIS ═══${RESET}"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Redis...${RESET}"
        sudo pacman -S --needed redis

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Redis!${RESET}"
        echo ""
        echo -e "${YELLOW}Các lệnh quan trọng:${RESET}"
        echo "  • Start:  sudo systemctl start redis"
        echo "  • Enable: sudo systemctl enable redis"
        echo "  • CLI:    redis-cli"
        echo ""
        echo -en "${CYAN}Start Redis ngay? (y/N):${RESET} "
        read start_now
        if [[ "$start_now" == "y" || "$start_now" == "Y" ]]; then
            sudo systemctl start redis
            sudo systemctl enable redis
            echo -e "${GREEN}✓ Redis đã được khởi động!${RESET}"
        fi
    fi

    pause_prompt
}

# Java
install_java() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT JAVA ═══${RESET}"
    echo ""
    echo -e "${GREEN}1.${RESET} OpenJDK 21 (LTS, khuyến nghị)"
    echo -e "${GREEN}2.${RESET} OpenJDK 17 (LTS)"
    echo -e "${GREEN}3.${RESET} OpenJDK 11 (LTS)"
    echo -e "${GREEN}4.${RESET} Cài tất cả"
    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn:${RESET} "
    read choice

    case $choice in
        1)
            sudo pacman -S --needed jdk21-openjdk
            ;;
        2)
            sudo pacman -S --needed jdk17-openjdk
            ;;
        3)
            sudo pacman -S --needed jdk11-openjdk
            ;;
        4)
            sudo pacman -S --needed jdk21-openjdk jdk17-openjdk jdk11-openjdk
            ;;
        0)
            return
            ;;
    esac

    if [[ "$choice" != "0" ]]; then
        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Java!${RESET}"
        echo ""
        echo -e "${CYAN}Phiên bản đã cài:${RESET}"
        java --version
        echo ""
        echo -e "${YELLOW}Chuyển đổi phiên bản Java:${RESET}"
        echo "  archlinux-java status"
        echo "  sudo archlinux-java set java-21-openjdk"
        pause_prompt
    fi
}

# Python Stack
install_python_stack() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT PYTHON STACK ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • Python 3 (latest)"
    echo "  • pip (package manager)"
    echo "  • virtualenv"
    echo "  • poetry (optional)"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Python stack...${RESET}"
        sudo pacman -S --needed python python-pip python-virtualenv

        echo ""
        echo -en "${CYAN}Cài đặt Poetry? (y/N):${RESET} "
        read install_poetry
        if [[ "$install_poetry" == "y" || "$install_poetry" == "Y" ]]; then
            sudo pacman -S --needed python-poetry
        fi

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Python Stack!${RESET}"
        echo ""
        echo -e "${CYAN}Phiên bản đã cài:${RESET}"
        python --version
        pip --version
        echo ""
        echo -e "${YELLOW}Tạo virtual environment:${RESET}"
        echo "  python -m venv myenv"
        echo "  source myenv/bin/activate"
    fi

    pause_prompt
}

# Go
install_go() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT GO ═══${RESET}"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Go...${RESET}"
        sudo pacman -S --needed go

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Go!${RESET}"
        echo ""
        go version
        echo ""
        echo -e "${YELLOW}Cấu hình GOPATH (thêm vào ~/.zshrc):${RESET}"
        echo "  export GOPATH=\$HOME/go"
        echo "  export PATH=\$PATH:\$GOPATH/bin"
    fi

    pause_prompt
}

# Rust
install_rust() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT RUST ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • Rust (rustc, cargo)"
    echo "  • rust-analyzer (LSP)"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Rust...${RESET}"
        sudo pacman -S --needed rust rust-analyzer

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Rust!${RESET}"
        echo ""
        rustc --version
        cargo --version
    fi

    pause_prompt
}

# Docker
install_docker() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT DOCKER ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • Docker Engine"
    echo "  • Docker Compose"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Docker...${RESET}"
        sudo pacman -S --needed docker docker-compose

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Docker!${RESET}"
        echo ""
        echo -e "${YELLOW}Các lệnh quan trọng:${RESET}"
        echo "  • Start:  sudo systemctl start docker"
        echo "  • Enable: sudo systemctl enable docker"
        echo "  • Add user to docker group: sudo usermod -aG docker \$USER"
        echo ""
        echo -en "${CYAN}Start Docker và thêm user vào group? (y/N):${RESET} "
        read setup_now
        if [[ "$setup_now" == "y" || "$setup_now" == "Y" ]]; then
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
            echo -e "${GREEN}✓ Hoàn tất! Đăng xuất và đăng nhập lại để áp dụng group.${RESET}"
        fi
    fi

    pause_prompt
}

# Git Tools
install_git_tools() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT GIT & TOOLS ═══${RESET}"
    echo ""
    echo -e "${CYAN}Sẽ cài đặt:${RESET}"
    echo "  • Git"
    echo "  • GitHub CLI (gh)"
    echo "  • Git LFS"
    echo "  • Tig (text-mode interface)"
    echo ""
    echo -en "${CYAN}Tiếp tục? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt Git tools...${RESET}"
        sudo pacman -S --needed git github-cli git-lfs tig

        echo ""
        echo -e "${GREEN}✓ Hoàn tất cài đặt Git Tools!${RESET}"
        echo ""
        git --version
        gh --version
        echo ""
        echo -e "${YELLOW}Cấu hình Git:${RESET}"
        echo "  git config --global user.name \"Your Name\""
        echo "  git config --global user.email \"your@email.com\""
        echo ""
        echo -e "${YELLOW}GitHub CLI login:${RESET}"
        echo "  gh auth login"
    fi

    pause_prompt
}

# Check installed dev tools
check_dev_tools() {
    show_header
    echo -e "${YELLOW}═══ KIỂM TRA CÔNG CỤ ĐÃ CÀI ═══${RESET}"
    echo ""

    # Web Development
    echo -e "${CYAN}── Web Development ──${RESET}"
    command -v php &> /dev/null && echo -e "${GREEN}✓${RESET} PHP: $(php --version | head -1)" || echo -e "${RED}✗${RESET} PHP: Chưa cài"
    command -v composer &> /dev/null && echo -e "${GREEN}✓${RESET} Composer: $(composer --version --no-ansi | head -1)" || echo -e "${RED}✗${RESET} Composer: Chưa cài"
    command -v node &> /dev/null && echo -e "${GREEN}✓${RESET} Node.js: $(node --version)" || echo -e "${RED}✗${RESET} Node.js: Chưa cài"
    command -v npm &> /dev/null && echo -e "${GREEN}✓${RESET} npm: $(npm --version)" || echo -e "${RED}✗${RESET} npm: Chưa cài"

    echo ""
    # Databases
    echo -e "${CYAN}── Databases ──${RESET}"
    command -v psql &> /dev/null && echo -e "${GREEN}✓${RESET} PostgreSQL: $(psql --version)" || echo -e "${RED}✗${RESET} PostgreSQL: Chưa cài"
    command -v mysql &> /dev/null && echo -e "${GREEN}✓${RESET} MySQL/MariaDB: $(mysql --version)" || echo -e "${RED}✗${RESET} MySQL/MariaDB: Chưa cài"
    command -v mongosh &> /dev/null && echo -e "${GREEN}✓${RESET} MongoDB: Đã cài" || echo -e "${RED}✗${RESET} MongoDB: Chưa cài"
    command -v redis-cli &> /dev/null && echo -e "${GREEN}✓${RESET} Redis: $(redis-cli --version)" || echo -e "${RED}✗${RESET} Redis: Chưa cài"

    echo ""
    # Programming Languages
    echo -e "${CYAN}── Programming Languages ──${RESET}"
    command -v java &> /dev/null && echo -e "${GREEN}✓${RESET} Java: $(java --version | head -1)" || echo -e "${RED}✗${RESET} Java: Chưa cài"
    command -v python &> /dev/null && echo -e "${GREEN}✓${RESET} Python: $(python --version)" || echo -e "${RED}✗${RESET} Python: Chưa cài"
    command -v go &> /dev/null && echo -e "${GREEN}✓${RESET} Go: $(go version)" || echo -e "${RED}✗${RESET} Go: Chưa cài"
    command -v rustc &> /dev/null && echo -e "${GREEN}✓${RESET} Rust: $(rustc --version)" || echo -e "${RED}✗${RESET} Rust: Chưa cài"

    echo ""
    # Tools
    echo -e "${CYAN}── Tools ──${RESET}"
    command -v docker &> /dev/null && echo -e "${GREEN}✓${RESET} Docker: $(docker --version)" || echo -e "${RED}✗${RESET} Docker: Chưa cài"
    command -v git &> /dev/null && echo -e "${GREEN}✓${RESET} Git: $(git --version)" || echo -e "${RED}✗${RESET} Git: Chưa cài"

    echo ""
    pause_prompt
}

# Main loop
main() {
    while true; do
        show_header
        show_main_menu
        read choice

        case $choice in
            1) install_package ;;
            2) remove_package ;;
            3) update_system ;;
            4) search_package ;;
            5) package_info ;;
            6) clean_cache ;;
            7) remove_orphans ;;
            8) list_installed ;;
            9) check_broken ;;
            10) downgrade_package ;;
            11) view_logs ;;
            12) mirror_management ;;
            13) font_manager_menu ;;
            14) dev_tools_menu ;;
            15) install_yay ;;
            0)
                clear
                echo -e "${GREEN}Tạm biệt!${RESET}"
                exit 0
                ;;
            *)
                echo -e "${RED}Lựa chọn không hợp lệ!${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Chạy chương trình
main
