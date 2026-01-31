#!/usr/bin/env zsh

# =============================================================================
# System Detection Module
# Detect AUR helpers, package managers, and system capabilities
# =============================================================================

# =============================================================================
# AUR Helper Detection
# =============================================================================

# Detect available AUR helper (yay or paru)
detect_aur_helper() {
    if command -v yay &> /dev/null; then
        echo "yay"
    elif command -v paru &> /dev/null; then
        echo "paru"
    else
        echo ""
    fi
}

# Check if yay is installed
has_yay() {
    command -v yay &> /dev/null
}

# Check if paru is installed
has_paru() {
    command -v paru &> /dev/null
}

# =============================================================================
# Package Manager Detection
# =============================================================================

# Check if flatpak is installed
has_flatpak() {
    command -v flatpak &> /dev/null
}

# Check if snap is installed
has_snap() {
    command -v snap &> /dev/null
}

# Check if pacman-contrib is installed (for paccache)
has_pacman_contrib() {
    command -v paccache &> /dev/null
}

# Check if reflector is installed
has_reflector() {
    command -v reflector &> /dev/null
}

# Check if downgrade is installed
has_downgrade() {
    command -v downgrade &> /dev/null
}

# =============================================================================
# System Information
# =============================================================================

# Check if running on Arch Linux or Arch-based distro
is_arch_linux() {
    if [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]]; then
        return 0
    elif grep -qi "arch\|manjaro\|endeavour" /etc/os-release 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Get distribution name
get_distro_name() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$NAME"
    else
        echo "Unknown"
    fi
}

# Get distribution version
get_distro_version() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo "$VERSION_ID"
    else
        echo "Unknown"
    fi
}

# =============================================================================
# Package Information
# =============================================================================

# Check if package is installed
is_package_installed() {
    local package=$1
    pacman -Qq "$package" &> /dev/null
}

# Get package version
get_package_version() {
    local package=$1
    pacman -Q "$package" 2>/dev/null | awk '{print $2}'
}

# Count installed packages
count_installed_packages() {
    pacman -Qq | wc -l
}

# Count packages from AUR
count_aur_packages() {
    pacman -Qm | wc -l
}

# Count packages from official repos
count_official_packages() {
    pacman -Qn | wc -l
}

# =============================================================================
# Cache Information
# =============================================================================

# Get cache directory size
get_cache_size() {
    du -sh /var/cache/pacman/pkg 2>/dev/null | awk '{print $1}'
}

# Count cached packages
count_cached_packages() {
    find /var/cache/pacman/pkg -name "*.pkg.tar.*" 2>/dev/null | wc -l
}

# =============================================================================
# Development Tools Detection
# =============================================================================

# Check if Docker is installed
has_docker() {
    command -v docker &> /dev/null
}

# Check if Git is installed
has_git() {
    command -v git &> /dev/null
}

# Check if Node.js is installed
has_nodejs() {
    command -v node &> /dev/null
}

# Check if npm is installed
has_npm() {
    command -v npm &> /dev/null
}

# Check if PHP is installed
has_php() {
    command -v php &> /dev/null
}

# Check if Python is installed
has_python() {
    command -v python &> /dev/null || command -v python3 &> /dev/null
}

# Check if Java is installed
has_java() {
    command -v java &> /dev/null
}

# Check if Go is installed
has_go() {
    command -v go &> /dev/null
}

# Check if Rust is installed
has_rust() {
    command -v rustc &> /dev/null
}

# =============================================================================
# Database Detection
# =============================================================================

# Check if PostgreSQL is installed
has_postgresql() {
    command -v psql &> /dev/null
}

# Check if MySQL/MariaDB is installed
has_mysql() {
    command -v mysql &> /dev/null
}

# Check if MongoDB is installed
has_mongodb() {
    command -v mongod &> /dev/null
}

# Check if Redis is installed
has_redis() {
    command -v redis-cli &> /dev/null
}

# =============================================================================
# Service Status
# =============================================================================

# Check if systemd service is running
is_service_running() {
    local service=$1
    systemctl is-active --quiet "$service"
}

# Check if systemd service is enabled
is_service_enabled() {
    local service=$1
    systemctl is-enabled --quiet "$service"
}

# =============================================================================
# User Permissions
# =============================================================================

# Check if user is in docker group
is_in_docker_group() {
    groups | grep -q docker
}

# Check if user has sudo privileges
has_sudo() {
    sudo -n true 2>/dev/null
}

# =============================================================================
# Font Detection
# =============================================================================

# Check if fontconfig is installed
has_fontconfig() {
    command -v fc-list &> /dev/null
}

# Check if specific font is installed
has_font() {
    local font_name=$1
    fc-list | grep -qi "$font_name"
}

# List all font families
list_font_families() {
    fc-list : family | sort -u
}

# Count installed fonts
count_fonts() {
    fc-list | wc -l
}

# =============================================================================
# Network Detection
# =============================================================================

# Check internet connectivity
has_internet() {
    ping -c 1 -W 2 archlinux.org &> /dev/null || \
    ping -c 1 -W 2 8.8.8.8 &> /dev/null
}

# Check if mirror list is up to date (modified within last 30 days)
is_mirrorlist_recent() {
    local mirrorlist="/etc/pacman.d/mirrorlist"
    if [[ -f "$mirrorlist" ]]; then
        local modified=$(stat -c %Y "$mirrorlist")
        local now=$(date +%s)
        local diff=$((now - modified))
        local days=$((diff / 86400))

        if [[ $days -lt 30 ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

# =============================================================================
# Disk Space Detection
# =============================================================================

# Get available disk space on root partition
get_root_space() {
    df -h / | awk 'NR==2 {print $4}'
}

# Get available disk space on /var
get_var_space() {
    df -h /var | awk 'NR==2 {print $4}'
}

# Check if enough space available (in GB)
has_enough_space() {
    local required=$1  # in GB
    local available=$(df / | awk 'NR==2 {print $4}')
    local available_gb=$((available / 1024 / 1024))

    if [[ $available_gb -ge $required ]]; then
        return 0
    else
        return 1
    fi
}
