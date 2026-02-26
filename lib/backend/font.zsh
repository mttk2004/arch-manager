#!/usr/bin/env zsh

# =============================================================================
# Font Management Backend Script
# Handles font installation, listing, searching, and cache management.
# Communicates with Python UI via JSON protocol
# =============================================================================

# Get script directory
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR:h}"

# Source required modules
source "${LIB_DIR}/core/json.zsh"
source "${LIB_DIR}/core/detect.zsh"

# =============================================================================
# Font Categories - Package Lists
# =============================================================================

# Nerd Fonts (patched programming fonts with icons)
NERD_FONTS=(
    ttf-firacode-nerd
    ttf-jetbrains-mono-nerd
    ttf-hack-nerd
    ttf-meslo-nerd
    ttf-sourcecodepro-nerd
    ttf-ubuntu-nerd
    ttf-cascadia-code-nerd
    ttf-roboto-mono-nerd
    ttf-iosevka-nerd
    ttf-inconsolata-nerd
)

# System Fonts (general purpose)
SYSTEM_FONTS=(
    noto-fonts
    noto-fonts-extra
    ttf-dejavu
    ttf-liberation
    ttf-roboto
    ttf-ubuntu-font-family
    ttf-opensans
    ttf-droid
    ttf-carlito
    ttf-caladea
    inter-font
)

# Emoji Fonts
EMOJI_FONTS=(
    noto-fonts-emoji
    ttf-twemoji
)

# CJK Fonts (Chinese, Japanese, Korean)
CJK_FONTS=(
    noto-fonts-cjk
    adobe-source-han-sans-otc-fonts
    adobe-source-han-serif-otc-fonts
)

# Microsoft-compatible Fonts (from AUR)
MS_FONTS=(
    ttf-ms-win11-auto
)

# =============================================================================
# Install Fonts
# =============================================================================

install_fonts() {
    local font_type="${1:-nerd}"

    # Select font list based on type
    local -a font_packages=()
    case "$font_type" in
        nerd)
            font_packages=("${NERD_FONTS[@]}")
            ;;
        system)
            font_packages=("${SYSTEM_FONTS[@]}")
            ;;
        emoji)
            font_packages=("${EMOJI_FONTS[@]}")
            ;;
        cjk)
            font_packages=("${CJK_FONTS[@]}")
            ;;
        ms)
            font_packages=("${MS_FONTS[@]}")
            # MS fonts typically need AUR
            local aur_helper=$(detect_aur_helper 2>/dev/null)
            if [[ -z "$aur_helper" ]]; then
                json_error "AUR_HELPER_NOT_FOUND" \
                    "An AUR helper (yay/paru) is required to install Microsoft fonts" \
                    "$(json_object "suggestion" "Install yay or paru first")"
                return 1
            fi
            ;;
        *)
            json_validation_error "font_type" "Unknown font type: $font_type. Use: nerd, system, emoji, cjk, ms"
            return 1
            ;;
    esac

    local installed=()
    local already_installed=()
    local failed=()

    for pkg in "${font_packages[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            already_installed+=("$pkg")
        else
            if [[ "$font_type" == "ms" ]]; then
                local aur_helper=$(detect_aur_helper 2>/dev/null)
                if $aur_helper -S --noconfirm "$pkg" &>/dev/null; then
                    installed+=("$pkg")
                else
                    failed+=("$pkg")
                fi
            else
                if sudo pacman -S --noconfirm "$pkg" &>/dev/null; then
                    installed+=("$pkg")
                else
                    failed+=("$pkg")
                fi
            fi
        fi
    done

    # Update font cache after installing
    if [[ ${#installed[@]} -gt 0 ]]; then
        fc-cache -f &>/dev/null
    fi

    local data=$(json_object \
        "font_type" "$font_type" \
        "installed" "$(json_array "${installed[@]}")" \
        "installed_count" "${#installed[@]}" \
        "already_installed" "$(json_array "${already_installed[@]}")" \
        "already_count" "${#already_installed[@]}" \
        "failed" "$(json_array "${failed[@]}")" \
        "failed_count" "${#failed[@]}")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Font installation completed with errors" "$data"
    else
        json_success "Installed ${#installed[@]} font package(s), ${#already_installed[@]} already present" "$data"
    fi
}

# =============================================================================
# List Installed Fonts
# =============================================================================

list_fonts() {
    if ! has_fontconfig; then
        json_command_not_found "fc-list (install fontconfig)"
        return 1
    fi

    local -a families=()
    while IFS= read -r family; do
        if [[ -n "$family" ]]; then
            families+=("$family")
        fi
    done < <(fc-list : family | sort -u)

    local count=${#families[@]}

    local data=$(json_object \
        "fonts" "$(json_array "${families[@]}")" \
        "count" "$count")

    json_success "Found $count font families" "$data"
}

# =============================================================================
# Search Fonts
# =============================================================================

search_fonts() {
    local pattern="$1"

    if [[ -z "$pattern" ]]; then
        json_validation_error "pattern" "Search pattern is required"
        return 1
    fi

    if ! has_fontconfig; then
        json_command_not_found "fc-list (install fontconfig)"
        return 1
    fi

    local -a matches=()
    while IFS= read -r family; do
        if [[ -n "$family" ]]; then
            matches+=("$family")
        fi
    done < <(fc-list : family | sort -u | grep -i "$pattern")

    local count=${#matches[@]}

    local data=$(json_object \
        "pattern" "$pattern" \
        "fonts" "$(json_array "${matches[@]}")" \
        "count" "$count")

    if [[ $count -eq 0 ]]; then
        json_success "No fonts matching '$pattern'" "$data"
    else
        json_success "Found $count font(s) matching '$pattern'" "$data"
    fi
}

# =============================================================================
# Update Font Cache
# =============================================================================

update_font_cache() {
    if ! has_fontconfig; then
        json_command_not_found "fc-cache (install fontconfig)"
        return 1
    fi

    if fc-cache -f &>/dev/null; then
        local count=$(fc-list | wc -l)
        local data=$(json_object \
            "status" "updated" \
            "total_fonts" "$count")
        json_success "Font cache updated ($count fonts)" "$data"
    else
        json_system_error "Failed to update font cache" "fc-cache -f"
        return 1
    fi
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    local action="$1"
    shift

    case "$action" in
        install)
            install_fonts "$@"
            ;;
        list)
            list_fonts
            ;;
        search)
            search_fonts "$@"
            ;;
        update_cache)
            update_font_cache
            ;;
        *)
            json_error "INVALID_ACTION" \
                "Unknown action: $action" \
                "$(json_object "action" "$action" "suggestion" "Use: install, list, search, update_cache")"
            exit 1
            ;;
    esac
}

# Run main if script is executed directly
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
