#!/usr/bin/env zsh

# =============================================================================
# Arch Package Manager - Trình quản lý gói tập trung cho Arch Linux
# =============================================================================

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

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
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}          ${MAGENTA}ARCH PACKAGE MANAGER${RESET} - Quản lý gói tập trung         ${CYAN}║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
}

# Menu chính
show_main_menu() {
    local aur_helper=$(detect_aur_helper)
    local flatpak_status=""

    if has_flatpak; then
        flatpak_status="${GREEN}✓${RESET}"
    else
        flatpak_status="${RED}✗${RESET}"
    fi

    echo -e "${YELLOW}═══ HỆ THỐNG GÓI ═══${RESET}"
    echo -e "${GREEN}1.${RESET}  Cài đặt gói"
    echo -e "${GREEN}2.${RESET}  Xóa gói"
    echo -e "${GREEN}3.${RESET}  Cập nhật hệ thống"
    echo -e "${GREEN}4.${RESET}  Tìm kiếm gói"
    echo -e "${GREEN}5.${RESET}  Xem thông tin gói"
    echo ""
    echo -e "${YELLOW}═══ BẢO TRÌ HỆ THỐNG ═══${RESET}"
    echo -e "${GREEN}6.${RESET}  Dọn dẹp cache"
    echo -e "${GREEN}7.${RESET}  Xóa gói orphan (không cần thiết)"
    echo -e "${GREEN}8.${RESET}  Xem danh sách gói đã cài"
    echo -e "${GREEN}9.${RESET}  Kiểm tra gói bị hỏng"
    echo ""
    echo -e "${YELLOW}═══ NÂNG CAO ═══${RESET}"
    echo -e "${GREEN}10.${RESET} Downgrade gói"
    echo -e "${GREEN}11.${RESET} Xem log gói"
    echo -e "${GREEN}12.${RESET} Mirror management"
    echo ""

    if [[ -n "$aur_helper" ]]; then
        echo -e "${YELLOW}AUR Helper:${RESET} ${GREEN}$aur_helper${RESET} ✓"
    else
        echo -e "${YELLOW}AUR Helper:${RESET} ${RED}Chưa cài đặt${RESET}"
        echo -e "${CYAN}13.${RESET} Cài đặt YAY (AUR helper)"
    fi

    echo -e "${YELLOW}Flatpak:${RESET} $flatpak_status"

    echo ""
    echo -e "${RED}0.${RESET}  Thoát"
    echo ""
    echo -en "${CYAN}Chọn chức năng [0-13]:${RESET} "
}

# Cài đặt gói
install_package() {
    show_header
    echo -e "${YELLOW}═══ CÀI ĐẶT GÓI ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Cài từ kho chính thức (pacman)"

    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        echo -e "${GREEN}2.${RESET} Cài từ AUR ($aur_helper)"
    fi

    if has_flatpak; then
        echo -e "${GREEN}3.${RESET} Cài từ Flatpak"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn nguồn cài đặt:${RESET} "
    read choice

    case $choice in
        1)
            echo -en "${CYAN}Nhập tên gói cần cài:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo -e "${YELLOW}Đang cài đặt $pkg...${RESET}"
                sudo pacman -S $pkg
                pause_prompt
            fi
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo -en "${CYAN}Nhập tên gói AUR cần cài:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo -e "${YELLOW}Đang cài đặt $pkg từ AUR...${RESET}"
                    $aur_helper -S $pkg
                    pause_prompt
                fi
            fi
            ;;
        3)
            if has_flatpak; then
                echo -en "${CYAN}Nhập tên gói Flatpak cần cài:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo -e "${YELLOW}Đang cài đặt $pkg từ Flatpak...${RESET}"
                    flatpak install $pkg
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
    echo -e "${YELLOW}═══ XÓA GÓI ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Xóa gói (pacman) - giữ dependencies"
    echo -e "${GREEN}2.${RESET} Xóa gói và dependencies không dùng"

    if has_flatpak; then
        echo -e "${GREEN}3.${RESET} Xóa gói Flatpak"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn cách xóa:${RESET} "
    read choice

    case $choice in
        1)
            echo -en "${CYAN}Nhập tên gói cần xóa:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo -e "${YELLOW}Đang xóa $pkg...${RESET}"
                sudo pacman -R $pkg
                pause_prompt
            fi
            ;;
        2)
            echo -en "${CYAN}Nhập tên gói cần xóa:${RESET} "
            read pkg
            if [[ -n "$pkg" ]]; then
                echo -e "${YELLOW}Đang xóa $pkg và dependencies...${RESET}"
                sudo pacman -Rns $pkg
                pause_prompt
            fi
            ;;
        3)
            if has_flatpak; then
                echo -en "${CYAN}Nhập tên gói Flatpak cần xóa:${RESET} "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo -e "${YELLOW}Đang xóa $pkg từ Flatpak...${RESET}"
                    flatpak uninstall $pkg
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
    echo -e "${YELLOW}═══ CẬP NHẬT HỆ THỐNG ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Cập nhật gói chính thức (pacman)"

    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        echo -e "${GREEN}2.${RESET} Cập nhật tất cả (pacman + AUR)"
    fi

    if has_flatpak; then
        echo -e "${GREEN}3.${RESET} Cập nhật Flatpak"
        echo -e "${GREEN}4.${RESET} Cập nhật tất cả nguồn"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn loại cập nhật:${RESET} "
    read choice

    case $choice in
        1)
            echo -e "${YELLOW}Đang cập nhật hệ thống...${RESET}"
            sudo pacman -Syu
            pause_prompt
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo -e "${YELLOW}Đang cập nhật tất cả gói...${RESET}"
                $aur_helper -Syu
                pause_prompt
            fi
            ;;
        3)
            if has_flatpak; then
                echo -e "${YELLOW}Đang cập nhật Flatpak...${RESET}"
                flatpak update
                pause_prompt
            fi
            ;;
        4)
            if has_flatpak && [[ -n "$aur_helper" ]]; then
                echo -e "${YELLOW}Đang cập nhật tất cả nguồn...${RESET}"
                $aur_helper -Syu && flatpak update
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
    echo -e "${YELLOW}═══ TÌM KIẾM GÓI ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Tìm trong kho chính thức"

    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        echo -e "${GREEN}2.${RESET} Tìm trong AUR"
    fi

    if has_flatpak; then
        echo -e "${GREEN}3.${RESET} Tìm trong Flatpak"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn nguồn tìm kiếm:${RESET} "
    read choice

    case $choice in
        1)
            echo -en "${CYAN}Nhập từ khóa:${RESET} "
            read keyword
            if [[ -n "$keyword" ]]; then
                pacman -Ss $keyword
                pause_prompt
            fi
            ;;
        2)
            if [[ -n "$aur_helper" ]]; then
                echo -en "${CYAN}Nhập từ khóa:${RESET} "
                read keyword
                if [[ -n "$keyword" ]]; then
                    $aur_helper -Ss $keyword
                    pause_prompt
                fi
            fi
            ;;
        3)
            if has_flatpak; then
                echo -en "${CYAN}Nhập từ khóa:${RESET} "
                read keyword
                if [[ -n "$keyword" ]]; then
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
    echo -e "${YELLOW}═══ THÔNG TIN GÓI ═══${RESET}"
    echo -en "${CYAN}Nhập tên gói:${RESET} "
    read pkg

    if [[ -n "$pkg" ]]; then
        echo ""
        echo -e "${YELLOW}Thông tin từ pacman:${RESET}"
        pacman -Qi $pkg 2>/dev/null || pacman -Si $pkg 2>/dev/null

        if has_flatpak; then
            echo ""
            echo -e "${YELLOW}Kiểm tra Flatpak:${RESET}"
            flatpak info $pkg 2>/dev/null
        fi

        pause_prompt
    fi
}

# Dọn dẹp cache
clean_cache() {
    show_header
    echo -e "${YELLOW}═══ DỌN DẸP CACHE ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Xóa cache gói cũ (giữ 3 phiên bản gần nhất)"
    echo -e "${GREEN}2.${RESET} Xóa toàn bộ cache"
    echo -e "${GREEN}3.${RESET} Xóa cache AUR"

    if has_flatpak; then
        echo -e "${GREEN}4.${RESET} Xóa cache Flatpak"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn cách dọn dẹp:${RESET} "
    read choice

    case $choice in
        1)
            echo -e "${YELLOW}Đang dọn dẹp cache...${RESET}"
            sudo paccache -r
            pause_prompt
            ;;
        2)
            echo -e "${RED}Cảnh báo: Xóa toàn bộ cache!${RESET}"
            echo -en "${CYAN}Bạn có chắc chắn? (y/N):${RESET} "
            read confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                sudo pacman -Scc
            fi
            pause_prompt
            ;;
        3)
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                echo -e "${YELLOW}Đang dọn dẹp cache AUR...${RESET}"
                $aur_helper -Sc
                pause_prompt
            fi
            ;;
        4)
            if has_flatpak; then
                echo -e "${YELLOW}Đang dọn dẹp cache Flatpak...${RESET}"
                flatpak uninstall --unused
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
    echo -e "${YELLOW}═══ XÓA GÓI ORPHAN ═══${RESET}"

    local orphans=$(pacman -Qdtq)

    if [[ -n "$orphans" ]]; then
        echo -e "${YELLOW}Các gói orphan tìm thấy:${RESET}"
        echo "$orphans"
        echo ""
        echo -en "${CYAN}Xóa các gói này? (y/N):${RESET} "
        read confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            sudo pacman -Rns $(pacman -Qdtq)
        fi
    else
        echo -e "${GREEN}Không tìm thấy gói orphan nào!${RESET}"
    fi

    pause_prompt
}

# Danh sách gói đã cài
list_installed() {
    show_header
    echo -e "${YELLOW}═══ DANH SÁCH GÓI ĐÃ CÀI ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Liệt kê tất cả gói"
    echo -e "${GREEN}2.${RESET} Liệt kê gói từ AUR"
    echo -e "${GREEN}3.${RESET} Liệt kê gói explicit (cài thủ công)"

    if has_flatpak; then
        echo -e "${GREEN}4.${RESET} Liệt kê gói Flatpak"
    fi

    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn loại danh sách:${RESET} "
    read choice

    case $choice in
        1)
            pacman -Q | less
            ;;
        2)
            pacman -Qm | less
            ;;
        3)
            pacman -Qe | less
            ;;
        4)
            if has_flatpak; then
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
    echo -e "${YELLOW}═══ KIỂM TRA GÓI BỊ HỎNG ═══${RESET}"
    echo -e "${YELLOW}Đang kiểm tra...${RESET}"
    echo ""

    echo -e "${CYAN}Kiểm tra database integrity:${RESET}"
    sudo pacman -Dk

    echo ""
    echo -e "${CYAN}Kiểm tra file conflicts:${RESET}"
    sudo pacman -Qkk 2>&1 | grep -v "0 missing files"

    pause_prompt
}

# Downgrade gói
downgrade_package() {
    show_header
    echo -e "${YELLOW}═══ DOWNGRADE GÓI ═══${RESET}"

    if ! command -v downgrade &> /dev/null; then
        echo -e "${RED}Chưa cài đặt 'downgrade'!${RESET}"
        echo -en "${CYAN}Cài đặt downgrade? (y/N):${RESET} "
        read confirm

        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            local aur_helper=$(detect_aur_helper)
            if [[ -n "$aur_helper" ]]; then
                $aur_helper -S downgrade
            else
                echo -e "${RED}Cần cài AUR helper trước!${RESET}"
            fi
        fi
        pause_prompt
        return
    fi

    echo -en "${CYAN}Nhập tên gói cần downgrade:${RESET} "
    read pkg

    if [[ -n "$pkg" ]]; then
        sudo downgrade $pkg
        pause_prompt
    fi
}

# Xem log gói
view_logs() {
    show_header
    echo -e "${YELLOW}═══ LOG GÓI ═══${RESET}"
    echo ""

    echo -e "${CYAN}50 dòng log gần nhất của pacman:${RESET}"
    tail -n 50 /var/log/pacman.log

    pause_prompt
}

# Mirror management
mirror_management() {
    show_header
    echo -e "${YELLOW}═══ QUẢN LÝ MIRROR ═══${RESET}"
    echo -e "${GREEN}1.${RESET} Cập nhật mirrorlist (reflector)"
    echo -e "${GREEN}2.${RESET} Sao lưu mirrorlist hiện tại"
    echo -e "${GREEN}3.${RESET} Xem mirrorlist hiện tại"
    echo -e "${RED}0.${RESET} Quay lại"
    echo ""
    echo -en "${CYAN}Chọn chức năng:${RESET} "
    read choice

    case $choice in
        1)
            if ! command -v reflector &> /dev/null; then
                echo -e "${RED}Chưa cài đặt 'reflector'!${RESET}"
                echo -en "${CYAN}Cài đặt reflector? (y/N):${RESET} "
                read confirm

                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    sudo pacman -S reflector
                fi
            else
                echo -e "${YELLOW}Đang cập nhật mirrorlist (lấy 20 mirror nhanh nhất)...${RESET}"
                sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
                sudo reflector --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
                echo -e "${GREEN}Hoàn tất!${RESET}"
            fi
            pause_prompt
            ;;
        2)
            sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup.$(date +%Y%m%d)
            echo -e "${GREEN}Đã sao lưu mirrorlist!${RESET}"
            pause_prompt
            ;;
        3)
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
    echo -e "${YELLOW}═══ CÀI ĐẶT YAY (AUR HELPER) ═══${RESET}"
    echo ""
    echo -en "${CYAN}Bạn có muốn cài đặt YAY? (y/N):${RESET} "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${YELLOW}Đang cài đặt dependencies...${RESET}"
        sudo pacman -S --needed git base-devel

        echo -e "${YELLOW}Đang clone YAY...${RESET}"
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay

        echo -e "${YELLOW}Đang build và cài đặt...${RESET}"
        makepkg -si

        cd ~
        rm -rf /tmp/yay

        echo -e "${GREEN}Hoàn tất cài đặt YAY!${RESET}"
    fi

    pause_prompt
}

# Pause prompt
pause_prompt() {
    echo ""
    echo -en "${CYAN}Nhấn Enter để tiếp tục...${RESET}"
    read
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
            13) install_yay ;;
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
