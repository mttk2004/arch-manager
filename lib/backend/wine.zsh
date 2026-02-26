#!/usr/bin/env zsh

# =============================================================================
# Wine Installation Backend Script
# Handles Wine installation, configuration, and status operations.
# Communicates with Python UI via JSON protocol
# =============================================================================

# Get script directory
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR:h}"

# Source required modules
source "${LIB_DIR}/core/json.zsh"
source "${LIB_DIR}/core/detect.zsh"

# =============================================================================
# Wine Installation
# =============================================================================

install_wine() {
    local variant="${1:-staging}"  # wine, wine-staging, wine-ge-custom

    # Check if multilib is enabled
    if ! grep -q "^\[multilib\]" /etc/pacman.conf 2>/dev/null; then
        json_error "MULTILIB_DISABLED" \
            "The [multilib] repository is not enabled in /etc/pacman.conf" \
            "$(json_object "suggestion" "Enable [multilib] in /etc/pacman.conf and run pacman -Syu")"
        return 1
    fi

    # Determine packages based on variant
    local -a packages=()
    case "$variant" in
        wine)
            packages=(wine wine-mono wine-gecko)
            ;;
        staging)
            packages=(wine-staging wine-mono wine-gecko)
            ;;
        ge-custom)
            # wine-ge-custom is from AUR
            local aur_helper=$(detect_aur_helper 2>/dev/null)
            if [[ -z "$aur_helper" ]]; then
                json_error "AUR_HELPER_NOT_FOUND" \
                    "An AUR helper (yay/paru) is required to install wine-ge-custom" \
                    "$(json_object "suggestion" "Install yay or paru first")"
                return 1
            fi
            packages=(wine-ge-custom wine-mono wine-gecko)
            ;;
        *)
            json_validation_error "variant" "Unknown Wine variant: $variant. Use: wine, staging, ge-custom"
            return 1
            ;;
    esac

    # Optional dependency packages for best compatibility
    local -a optional_deps=(
        winetricks
        lib32-mesa
        lib32-vulkan-icd-loader
        lib32-alsa-lib
        lib32-alsa-plugins
        lib32-libpulse
        lib32-gnutls
        lib32-gst-plugins-base
        lib32-gst-plugins-good
    )

    # Install main Wine packages
    local installed=()
    local failed=()

    for pkg in "${packages[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            installed+=("$pkg")
        else
            if [[ "$variant" == "ge-custom" && "$pkg" == "wine-ge-custom" ]]; then
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

    # Try to install optional dependencies (non-fatal)
    local optional_installed=()
    for pkg in "${optional_deps[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            optional_installed+=("$pkg")
        else
            if sudo pacman -S --noconfirm "$pkg" &>/dev/null; then
                optional_installed+=("$pkg")
            fi
        fi
    done

    # Build response
    local data=$(json_object \
        "variant" "$variant" \
        "installed" "$(json_array "${installed[@]}")" \
        "installed_count" "${#installed[@]}" \
        "failed" "$(json_array "${failed[@]}")" \
        "failed_count" "${#failed[@]}" \
        "optional_installed" "$(json_array "${optional_installed[@]}")" \
        "optional_count" "${#optional_installed[@]}")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Wine installation completed with errors" "$data"
    else
        json_success "Wine ($variant) installed successfully" "$data"
    fi
}

# =============================================================================
# Wine Status
# =============================================================================

wine_status() {
    local wine_installed="false"
    local wine_version=""
    local wine_variant=""
    local wine_prefix="${WINEPREFIX:-$HOME/.wine}"
    local prefix_exists="false"

    # Check which Wine variant is installed
    if pacman -Qi wine-staging &>/dev/null; then
        wine_installed="true"
        wine_variant="staging"
        wine_version=$(pacman -Qi wine-staging 2>/dev/null | grep "Version" | awk '{print $3}')
    elif pacman -Qi wine-ge-custom &>/dev/null; then
        wine_installed="true"
        wine_variant="ge-custom"
        wine_version=$(pacman -Qi wine-ge-custom 2>/dev/null | grep "Version" | awk '{print $3}')
    elif pacman -Qi wine &>/dev/null; then
        wine_installed="true"
        wine_variant="wine"
        wine_version=$(pacman -Qi wine 2>/dev/null | grep "Version" | awk '{print $3}')
    fi

    # Check prefix
    if [[ -d "$wine_prefix" ]]; then
        prefix_exists="true"
    fi

    # Check optional components
    local winetricks_installed="false"
    if command -v winetricks &>/dev/null; then
        winetricks_installed="true"
    fi

    local multilib_enabled="false"
    if grep -q "^\[multilib\]" /etc/pacman.conf 2>/dev/null; then
        multilib_enabled="true"
    fi

    # Check for installed optional deps
    local -a optional_status=()
    local -a optional_pkgs=(lib32-mesa lib32-vulkan-icd-loader lib32-alsa-lib lib32-libpulse lib32-gnutls winetricks)
    for pkg in "${optional_pkgs[@]}"; do
        if pacman -Qi "$pkg" &>/dev/null; then
            optional_status+=("$pkg")
        fi
    done

    local data=$(json_object \
        "installed" "$wine_installed" \
        "version" "$wine_version" \
        "variant" "$wine_variant" \
        "prefix" "$wine_prefix" \
        "prefix_exists" "$prefix_exists" \
        "winetricks" "$winetricks_installed" \
        "multilib_enabled" "$multilib_enabled" \
        "optional_deps" "$(json_array "${optional_status[@]}")")

    json_success "Wine status retrieved" "$data"
}

# =============================================================================
# Configure Wine Prefix
# =============================================================================

configure_prefix() {
    local prefix="${1:-$HOME/.wine}"
    local arch="${2:-win64}"  # win32 or win64

    export WINEPREFIX="$prefix"

    if [[ "$arch" == "win32" ]]; then
        export WINEARCH=win32
    else
        export WINEARCH=win64
    fi

    # Initialize or update the prefix
    if wineboot --init &>/dev/null; then
        local data=$(json_object \
            "prefix" "$prefix" \
            "arch" "$arch" \
            "status" "initialized")
        json_success "Wine prefix configured" "$data"
    else
        json_system_error "Failed to configure Wine prefix" "wineboot --init"
        return 1
    fi
}

# =============================================================================
# Install Winetricks Components
# =============================================================================

install_winetricks_component() {
    local component="$1"

    if ! command -v winetricks &>/dev/null; then
        json_command_not_found "winetricks (install winetricks package)"
        return 1
    fi

    if [[ -z "$component" ]]; then
        json_validation_error "component" "Component name is required"
        return 1
    fi

    if winetricks -q "$component" &>/dev/null; then
        local data=$(json_object \
            "component" "$component" \
            "status" "installed")
        json_success "Installed winetricks component: $component" "$data"
    else
        json_system_error "Failed to install winetricks component: $component" "winetricks $component"
        return 1
    fi
}

# =============================================================================
# Uninstall Wine
# =============================================================================

uninstall_wine() {
    local remove_prefix="${1:-false}"
    local removed=()
    local failed=()

    # Find all installed wine packages
    local -a wine_pkgs=()
    for pkg in wine wine-staging wine-ge-custom wine-mono wine-gecko winetricks; do
        if pacman -Qi "$pkg" &>/dev/null; then
            wine_pkgs+=("$pkg")
        fi
    done

    if [[ ${#wine_pkgs[@]} -eq 0 ]]; then
        local data=$(json_object "removed" "[]" "removed_count" "0")
        json_success "No Wine packages found to remove" "$data"
        return 0
    fi

    # Remove packages
    for pkg in "${wine_pkgs[@]}"; do
        if sudo pacman -Rns --noconfirm "$pkg" &>/dev/null; then
            removed+=("$pkg")
        else
            failed+=("$pkg")
        fi
    done

    # Optionally remove Wine prefix
    local prefix_removed="false"
    if [[ "$remove_prefix" == "true" ]]; then
        local prefix="${WINEPREFIX:-$HOME/.wine}"
        if [[ -d "$prefix" ]]; then
            rm -rf "$prefix"
            prefix_removed="true"
        fi
    fi

    local data=$(json_object \
        "removed" "$(json_array "${removed[@]}")" \
        "removed_count" "${#removed[@]}" \
        "failed" "$(json_array "${failed[@]}")" \
        "failed_count" "${#failed[@]}" \
        "prefix_removed" "$prefix_removed")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Wine uninstall completed with errors" "$data"
    else
        json_success "Wine uninstalled successfully" "$data"
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
            install_wine "$@"
            ;;
        status)
            wine_status
            ;;
        configure_prefix)
            configure_prefix "$@"
            ;;
        install_component)
            install_winetricks_component "$@"
            ;;
        uninstall)
            uninstall_wine "$@"
            ;;
        *)
            json_error "INVALID_ACTION" \
                "Unknown action: $action" \
                "$(json_object "action" "$action" "suggestion" "Use: install, status, configure_prefix, install_component, uninstall")"
            exit 1
            ;;
    esac
}

# Run main if script is executed directly
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
