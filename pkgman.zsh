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
    echo -e "${YELLOW}═══ PHÁT TRIỂN (DEV TOOLS) ═══${RESET}"
    echo -e "${GREEN}14.${RESET} Môi trường phát triển (PHP, Node.js, Java, Database...)"
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
    echo -en "${CYAN}Chọn chức năng [0-14]:${RESET} "
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

# =============================================================================
# DEVELOPMENT TOOLS - Môi trường phát triển
# =============================================================================

# Menu Development Tools
dev_tools_menu() {
    while true; do
        show_header
        echo -e "${YELLOW}═══ MÔI TRƯỜNG PHÁT TRIỂN ═══${RESET}"
        echo ""
        echo -e "${CYAN}── Web Development ──${RESET}"
        echo -e "${GREEN}1.${RESET}  PHP Stack (PHP, Composer, Extensions)"
        echo -e "${GREEN}2.${RESET}  Laravel (Framework)"
        echo -e "${GREEN}3.${RESET}  Node.js Stack (Node.js, npm, yarn, pnpm)"
        echo ""
        echo -e "${CYAN}── Databases ──${RESET}"
        echo -e "${GREEN}4.${RESET}  PostgreSQL"
        echo -e "${GREEN}5.${RESET}  MySQL/MariaDB"
        echo -e "${GREEN}6.${RESET}  MongoDB"
        echo -e "${GREEN}7.${RESET}  Redis"
        echo ""
        echo -e "${CYAN}── Programming Languages ──${RESET}"
        echo -e "${GREEN}8.${RESET}  Java (JDK)"
        echo -e "${GREEN}9.${RESET}  Python Stack (pip, virtualenv, poetry)"
        echo -e "${GREEN}10.${RESET} Go"
        echo -e "${GREEN}11.${RESET} Rust"
        echo ""
        echo -e "${CYAN}── Tools & Others ──${RESET}"
        echo -e "${GREEN}12.${RESET} Docker & Docker Compose"
        echo -e "${GREEN}13.${RESET} Git & Git Tools"
        echo -e "${GREEN}14.${RESET} Kiểm tra các công cụ đã cài"
        echo ""
        echo -e "${RED}0.${RESET}  Quay lại menu chính"
        echo ""
        echo -en "${CYAN}Chọn [0-14]:${RESET} "
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
                echo -e "${RED}Lựa chọn không hợp lệ!${RESET}"
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
            13) install_yay ;;
            14) dev_tools_menu ;;
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
