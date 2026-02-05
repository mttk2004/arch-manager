#!/usr/bin/env zsh

# =============================================================================
# Package Management Backend Script
# Handles package installation, removal, search, update, and info operations
# Communicates with Python UI via JSON protocol
# =============================================================================

# =============================================================================
# Helper Functions for Autocomplete
# =============================================================================

list_available_packages() {
    # Get list of all available package names for autocomplete
    # Combines official repos and AUR (if helper available)

    local official_pkgs=()
    local aur_pkgs=()
    local all_pkgs=()

    # Get official packages (fast)
    official_pkgs=($(pacman -Ssq 2>/dev/null))

    # Get AUR packages if helper available
    local aur_helper=$(detect_aur_helper)
    if [[ -n "$aur_helper" ]]; then
        aur_pkgs=($(${aur_helper} -Ssq --aur 2>/dev/null | head -1000))
    fi

    # Combine and output as JSON array
    all_pkgs=("${official_pkgs[@]}" "${aur_pkgs[@]}")

    local json_array="["
    local first=true
    for pkg in "${all_pkgs[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            json_array+=","
        fi
        json_array+="\"$pkg\""
    done
    json_array+="]"

    json_success "Package list retrieved" packages "$json_array"
}

list_installed_package_names() {
    # Get list of installed package names for autocomplete in remove operation

    local installed=($(pacman -Qq 2>/dev/null))

    local json_array="["
    local first=true
    for pkg in "${installed[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            json_array+=","
        fi
        json_array+="\"$pkg\""
    done
    json_array+="]"

    json_success "Installed package list retrieved" packages "$json_array"
}

# Get script directory
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR:h}"

# Source required modules
source "${LIB_DIR}/core/json.zsh"
source "${LIB_DIR}/core/detect.zsh"

# =============================================================================
# Package Installation
# =============================================================================

install_packages() {
    local packages=("$@")

    # Validate input
    if [[ ${#packages[@]} -eq 0 ]]; then
        json_validation_error "packages" "No packages specified"
        return 1
    fi

    # Detect AUR helper
    local aur_helper=$(detect_aur_helper)
    local cmd="pacman"

    if [[ -n "$aur_helper" ]]; then
        cmd="$aur_helper"
    fi

    # Track results
    local installed=()
    local already_installed=()
    local failed=()

    for pkg in "${packages[@]}"; do
        # Check if already installed
        if pacman -Q "$pkg" &>/dev/null; then
            already_installed+=("$pkg")
            continue
        fi

        # Attempt installation
        if sudo "$cmd" -S --noconfirm "$pkg" &>/dev/null; then
            installed+=("$pkg")
        else
            failed+=("$pkg")
        fi
    done

    # Build response
    local installed_json=$(json_array "${installed[@]}")
    local already_json=$(json_array "${already_installed[@]}")
    local failed_json=$(json_array "${failed[@]}")

    local data=$(json_object \
        "installed" "$installed_json" \
        "already_installed" "$already_json" \
        "failed" "$failed_json" \
        "installed_count" "${#installed[@]}" \
        "already_count" "${#already_installed[@]}" \
        "failed_count" "${#failed[@]}")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Installed ${#installed[@]} packages, ${#failed[@]} failed" "$data"
    else
        json_success "Successfully installed ${#installed[@]} package(s)" "$data"
    fi
}

# =============================================================================
# Package Removal
# =============================================================================

remove_packages() {
    local packages=("$@")

    # Validate input
    if [[ ${#packages[@]} -eq 0 ]]; then
        json_validation_error "packages" "No packages specified"
        return 1
    fi

    # Track results
    local removed=()
    local not_installed=()
    local failed=()

    for pkg in "${packages[@]}"; do
        # Check if installed
        if ! pacman -Q "$pkg" &>/dev/null; then
            not_installed+=("$pkg")
            continue
        fi

        # Attempt removal
        if sudo pacman -R --noconfirm "$pkg" &>/dev/null; then
            removed+=("$pkg")
        else
            failed+=("$pkg")
        fi
    done

    # Build response
    local removed_json=$(json_array "${removed[@]}")
    local not_installed_json=$(json_array "${not_installed[@]}")
    local failed_json=$(json_array "${failed[@]}")

    local data=$(json_object \
        "removed" "$removed_json" \
        "not_installed" "$not_installed_json" \
        "failed" "$failed_json" \
        "removed_count" "${#removed[@]}" \
        "not_installed_count" "${#not_installed[@]}" \
        "failed_count" "${#failed[@]}")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Removed ${#removed[@]} packages, ${#failed[@]} failed" "$data"
    else
        json_success "Successfully removed ${#removed[@]} package(s)" "$data"
    fi
}

# =============================================================================
# Package Search
# =============================================================================

search_packages() {
    local query="$1"

    # Validate input
    if [[ -z "$query" ]]; then
        json_validation_error "query" "Search query cannot be empty"
        return 1
    fi

    # Detect AUR helper
    local aur_helper=$(detect_aur_helper)

    # Search in official repos
    local results=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            results+=("$line")
        fi
    done < <(pacman -Ss "$query" 2>/dev/null | grep -E "^[a-zA-Z0-9]" | cut -d' ' -f1)

    # Search in AUR if helper available
    local aur_results=()
    if [[ -n "$aur_helper" ]]; then
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                aur_results+=("$line")
            fi
        done < <("$aur_helper" -Ss "$query" 2>/dev/null | grep "^aur/" | cut -d' ' -f1 | sed 's/^aur\///')
    fi

    # Build response
    local results_json=$(json_array "${results[@]}")
    local aur_json=$(json_array "${aur_results[@]}")

    local data=$(json_object \
        "official" "$results_json" \
        "aur" "$aur_json" \
        "official_count" "${#results[@]}" \
        "aur_count" "${#aur_results[@]}" \
        "total_count" "$((${#results[@]} + ${#aur_results[@]}))")

    json_success "Found $((${#results[@]} + ${#aur_results[@]})) matching package(s)" "$data"
}

# =============================================================================
# Package Info
# =============================================================================

get_package_info() {
    local package="$1"

    # Validate input
    if [[ -z "$package" ]]; then
        json_validation_error "package" "Package name cannot be empty"
        return 1
    fi

    # Check if installed
    local installed="false"
    local version=""
    local size=""

    if pacman -Q "$package" &>/dev/null; then
        installed="true"
        version=$(pacman -Q "$package" 2>/dev/null | awk '{print $2}')
    fi

    # Get package info
    local description=""
    local url=""
    local repo=""

    if pacman -Si "$package" &>/dev/null; then
        description=$(pacman -Si "$package" 2>/dev/null | grep "^Description" | cut -d: -f2- | sed 's/^ *//')
        url=$(pacman -Si "$package" 2>/dev/null | grep "^URL" | cut -d: -f2- | sed 's/^ *//')
        repo=$(pacman -Si "$package" 2>/dev/null | grep "^Repository" | cut -d: -f2- | sed 's/^ *//')
        size=$(pacman -Si "$package" 2>/dev/null | grep "^Installed Size" | cut -d: -f2- | sed 's/^ *//')
        if [[ -z "$version" ]]; then
            version=$(pacman -Si "$package" 2>/dev/null | grep "^Version" | cut -d: -f2- | sed 's/^ *//')
        fi
    else
        json_package_not_found "$package"
        return 1
    fi

    # Build response
    local data=$(json_object \
        "name" "$package" \
        "version" "$version" \
        "description" "$description" \
        "url" "$url" \
        "repository" "$repo" \
        "installed_size" "$size" \
        "installed" "$installed")

    json_success "Package information retrieved" "$data"
}

# =============================================================================
# List Installed Packages
# =============================================================================

list_installed_packages() {
    local packages=()

    # Get all installed packages
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local name=$(echo "$line" | awk '{print $1}')
            local version=$(echo "$line" | awk '{print $2}')
            packages+=("$name")
        fi
    done < <(pacman -Q 2>/dev/null)

    # Build response
    local packages_json=$(json_array "${packages[@]}")
    local data=$(json_object \
        "packages" "$packages_json" \
        "count" "${#packages[@]}")

    json_success "Found ${#packages[@]} installed package(s)" "$data"
}

# =============================================================================
# List Explicitly Installed Packages
# =============================================================================

list_explicit_packages() {
    local packages=()

    # Get explicitly installed packages
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local name=$(echo "$line" | awk '{print $1}')
            packages+=("$name")
        fi
    done < <(pacman -Qe 2>/dev/null)

    # Build response
    local packages_json=$(json_array "${packages[@]}")
    local data=$(json_object \
        "packages" "$packages_json" \
        "count" "${#packages[@]}")

    json_success "Found ${#packages[@]} explicitly installed package(s)" "$data"
}

# =============================================================================
# Update System
# =============================================================================

update_system() {
    # Detect AUR helper
    local aur_helper=$(detect_aur_helper)
    local cmd="pacman"

    if [[ -n "$aur_helper" ]]; then
        cmd="$aur_helper"
    fi

    # Check for updates first
    local updates_available=0
    if sudo "$cmd" -Sy &>/dev/null; then
        updates_available=$(pacman -Qu 2>/dev/null | wc -l)
    fi

    if [[ $updates_available -eq 0 ]]; then
        local data=$(json_object \
            "updated_count" "0" \
            "updates_available" "0" \
            "message" "System is up to date")
        json_success "No updates available" "$data"
        return 0
    fi

    # Perform update
    if sudo "$cmd" -Syu --noconfirm &>/dev/null; then
        local data=$(json_object \
            "updated_count" "$updates_available" \
            "updates_available" "0" \
            "message" "System updated successfully")
        json_success "Successfully updated $updates_available package(s)" "$data"
    else
        json_system_error "Failed to update system" "$cmd -Syu"
        return 1
    fi
}

# =============================================================================
# Check for Updates
# =============================================================================

check_updates() {
    # Sync package databases
    sudo pacman -Sy &>/dev/null

    # Get list of updates
    local updates=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local pkg=$(echo "$line" | awk '{print $1}')
            updates+=("$pkg")
        fi
    done < <(pacman -Qu 2>/dev/null)

    # Build response
    local updates_json=$(json_array "${updates[@]}")
    local data=$(json_object \
        "updates" "$updates_json" \
        "count" "${#updates[@]}" \
        "available" "${#updates[@]}")

    if [[ ${#updates[@]} -eq 0 ]]; then
        json_success "System is up to date" "$data"
    else
        json_success "Found ${#updates[@]} available update(s)" "$data"
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
            install_packages "$@"
            ;;
        remove)
            remove_packages "$@"
            ;;
        search)
            search_packages "$@"
            ;;
        info)
            get_package_info "$@"
            ;;
        list_installed)
            list_installed_packages
            ;;
        list_explicit)
            list_explicit_packages
            ;;
        update)
            update_system
            ;;
        check_updates)
            check_updates
            ;;
        list_available)
            list_available_packages
            ;;
        list_installed_names)
            list_installed_package_names
            ;;
        *)
            json_error "INVALID_ACTION" \
                "Unknown action: $action" \
                "$(json_object "action" "$action" "suggestion" "Use: install, remove, search, info, list_installed, list_explicit, update, check_updates, list_available, list_installed_names")"
            exit 1
            ;;
    esac
}

# Run main if script is executed directly
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
