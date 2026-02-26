#!/usr/bin/env zsh

# =============================================================================
# System Maintenance Backend Script
# Handles system maintenance operations like cache cleaning, orphan removal,
# and dependency checking. Communicates with Python UI via JSON protocol
# =============================================================================

# Get script directory
SCRIPT_DIR="${0:A:h}"
LIB_DIR="${SCRIPT_DIR:h}"

# Source required modules
source "${LIB_DIR}/core/json.zsh"
source "${LIB_DIR}/core/detect.zsh"

# =============================================================================
# Clean Package Cache
# =============================================================================

clean_cache() {
    local keep="${1:-3}"  # Number of versions to keep (default: 3)

    # Validate input
    if ! [[ "$keep" =~ ^[0-9]+$ ]]; then
        json_validation_error "keep" "Must be a positive number"
        return 1
    fi

    # Check for paccache (from pacman-contrib)
    if ! command -v paccache &>/dev/null; then
        json_command_not_found "paccache (install pacman-contrib)"
        return 1
    fi

    # Get cache size before cleaning
    local cache_dir="/var/cache/pacman/pkg"
    local before_size=$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')
    local before_count=$(find "$cache_dir" -name "*.pkg.tar.*" 2>/dev/null | wc -l)

    # Clean cache (keep N versions of installed packages)
    local output=""
    if sudo paccache -r -k "$keep" &>/dev/null; then
        # Also clean uninstalled packages
        sudo paccache -ruk0 &>/dev/null

        # Get cache size after cleaning
        local after_size=$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')
        local after_count=$(find "$cache_dir" -name "*.pkg.tar.*" 2>/dev/null | wc -l)
        local removed=$((before_count - after_count))

        local data=$(json_object \
            "before_size" "$before_size" \
            "after_size" "$after_size" \
            "before_count" "$before_count" \
            "after_count" "$after_count" \
            "removed_count" "$removed" \
            "kept_versions" "$keep")

        json_success "Cleaned package cache (removed $removed package(s))" "$data"
    else
        json_system_error "Failed to clean package cache" "paccache -r -k $keep"
        return 1
    fi
}

# =============================================================================
# Remove Orphaned Packages
# =============================================================================

remove_orphans() {
    local no_confirm="${1:-false}"

    # Find orphaned packages
    local orphans=()
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            local pkg=$(echo "$line" | awk '{print $1}')
            orphans+=("$pkg")
        fi
    done < <(pacman -Qtdq 2>/dev/null)

    # Check if there are any orphans
    if [[ ${#orphans[@]} -eq 0 ]]; then
        local data=$(json_object \
            "orphans" "[]" \
            "count" "0" \
            "removed" "[]" \
            "removed_count" "0")
        json_success "No orphaned packages found" "$data"
        return 0
    fi

    # Build orphans list JSON
    local orphans_json=$(json_array "${orphans[@]}")

    # Remove orphans
    local removed=()
    local failed=()

    if [[ "$no_confirm" == "true" ]]; then
        if sudo pacman -Rns --noconfirm "${orphans[@]}" &>/dev/null; then
            removed=("${orphans[@]}")
        else
            # Try removing one by one
            for pkg in "${orphans[@]}"; do
                if sudo pacman -Rns --noconfirm "$pkg" &>/dev/null; then
                    removed+=("$pkg")
                else
                    failed+=("$pkg")
                fi
            done
        fi
    else
        # Interactive mode
        if sudo pacman -Rns "${orphans[@]}" &>/dev/null; then
            removed=("${orphans[@]}")
        else
            failed=("${orphans[@]}")
        fi
    fi

    # Build response
    local removed_json=$(json_array "${removed[@]}")
    local failed_json=$(json_array "${failed[@]}")

    local data=$(json_object \
        "orphans" "$orphans_json" \
        "count" "${#orphans[@]}" \
        "removed" "$removed_json" \
        "removed_count" "${#removed[@]}" \
        "failed" "$failed_json" \
        "failed_count" "${#failed[@]}")

    if [[ ${#failed[@]} -gt 0 ]]; then
        json_warning "Removed ${#removed[@]} orphan(s), ${#failed[@]} failed" "$data"
    else
        json_success "Successfully removed ${#removed[@]} orphaned package(s)" "$data"
    fi
}

# =============================================================================
# Check for Broken Dependencies
# =============================================================================

check_broken() {
    local broken=()
    local missing_deps=()

    # Check for packages with missing dependencies
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Extract package name and missing dependency
            if [[ "$line" =~ "requires" ]]; then
                local pkg=$(echo "$line" | awk '{print $1}')
                local dep=$(echo "$line" | awk '{print $NF}')
                broken+=("$pkg")
                missing_deps+=("$dep")
            fi
        fi
    done < <(pacman -Qk 2>&1 | grep "warning")

    # Also check with checkrebuild (if available)
    if command -v checkrebuild &>/dev/null; then
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                broken+=("$line")
            fi
        done < <(checkrebuild 2>/dev/null | grep -v "^$")
    fi

    # Remove duplicates
    broken=($(printf '%s\n' "${broken[@]}" | sort -u))
    missing_deps=($(printf '%s\n' "${missing_deps[@]}" | sort -u))

    # Build response
    local broken_json=$(json_array "${broken[@]}")
    local missing_json=$(json_array "${missing_deps[@]}")

    local data=$(json_object \
        "broken_packages" "$broken_json" \
        "broken_count" "${#broken[@]}" \
        "missing_dependencies" "$missing_json" \
        "missing_count" "${#missing_deps[@]}")

    if [[ ${#broken[@]} -eq 0 ]]; then
        json_success "No broken dependencies found" "$data"
    else
        json_warning "Found ${#broken[@]} package(s) with broken dependencies" "$data"
    fi
}

# =============================================================================
# Update Package Database
# =============================================================================

update_database() {
    # Sync package databases
    if sudo pacman -Sy &>/dev/null; then
        local data=$(json_object \
            "synced" "true" \
            "message" "Package databases updated")
        json_success "Package databases synchronized" "$data"
    else
        json_system_error "Failed to sync package databases" "pacman -Sy"
        return 1
    fi
}

# =============================================================================
# Get Disk Usage Information
# =============================================================================

get_disk_usage() {
    # Get cache directory size
    local cache_dir="/var/cache/pacman/pkg"
    local cache_size=$(du -sh "$cache_dir" 2>/dev/null | awk '{print $1}')
    local cache_count=$(find "$cache_dir" -name "*.pkg.tar.*" 2>/dev/null | wc -l)

    # Get log directory size
    local log_dir="/var/log/pacman"
    local log_size=$(du -sh "$log_dir" 2>/dev/null | awk '{print $1}')

    # Get installed packages size
    local installed_size=$(pacman -Qi | grep "Installed Size" | awk '{sum+=$4} END {printf "%.2f GB", sum/1024}')

    # Build response
    local data=$(json_object \
        "cache_size" "$cache_size" \
        "cache_packages" "$cache_count" \
        "log_size" "$log_size" \
        "installed_size" "$installed_size" \
        "cache_path" "$cache_dir" \
        "log_path" "$log_dir")

    json_success "Disk usage information retrieved" "$data"
}

# =============================================================================
# Optimize Database
# =============================================================================

optimize_database() {
    # Optimize pacman database
    if sudo pacman-optimize &>/dev/null 2>&1 || sudo pacman-db-upgrade &>/dev/null 2>&1; then
        local data=$(json_object \
            "optimized" "true" \
            "message" "Database optimized successfully")
        json_success "Package database optimized" "$data"
    else
        # Not a critical error, some systems may not have these commands
        local data=$(json_object \
            "optimized" "false" \
            "message" "Database optimization not available or not needed")
        json_info "Database optimization skipped" "$data"
    fi
}

# =============================================================================
# Clear Old Logs
# =============================================================================

clear_old_logs() {
    local days="${1:-30}"  # Keep logs from last N days

    # Validate input
    if ! [[ "$days" =~ ^[0-9]+$ ]]; then
        json_validation_error "days" "Must be a positive number"
        return 1
    fi

    local log_dir="/var/log/pacman"
    local before_size=$(du -sh "$log_dir" 2>/dev/null | awk '{print $1}')

    # Find and remove old log files
    local removed=0
    while IFS= read -r logfile; do
        if sudo rm -f "$logfile" 2>/dev/null; then
            ((removed++))
        fi
    done < <(find "$log_dir" -name "*.log*" -mtime +"$days" 2>/dev/null)

    local after_size=$(du -sh "$log_dir" 2>/dev/null | awk '{print $1}')

    local data=$(json_object \
        "before_size" "$before_size" \
        "after_size" "$after_size" \
        "removed_count" "$removed" \
        "kept_days" "$days")

    json_success "Removed $removed old log file(s)" "$data"
}

# =============================================================================
# Downgrade Package
# =============================================================================

downgrade_package() {
    local package="$1"

    if [[ -z "$package" ]]; then
        json_validation_error "package" "Package name is required"
        return 1
    fi

    # Check if downgrade command is available
    if command -v downgrade &>/dev/null; then
        # Use downgrade tool (from AUR)
        if sudo downgrade --noconfirm "$package" &>/dev/null; then
            local new_version=$(pacman -Q "$package" 2>/dev/null | awk '{print $2}')
            local data=$(json_object \
                "package" "$package" \
                "new_version" "$new_version" \
                "method" "downgrade")
            json_success "Package $package downgraded to $new_version" "$data"
        else
            json_system_error "Failed to downgrade $package" "downgrade $package"
            return 1
        fi
    else
        # Fallback: use cached packages in /var/cache/pacman/pkg
        local cache_dir="/var/cache/pacman/pkg"
        local -a cached_versions=()

        while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                local basename=$(basename "$file")
                cached_versions+=("$basename")
            fi
        done < <(find "$cache_dir" -name "${package}-[0-9]*" -type f 2>/dev/null | sort -V -r)

        if [[ ${#cached_versions[@]} -eq 0 ]]; then
            json_error "NO_CACHED_VERSIONS" \
                "No cached versions found for $package" \
                "$(json_object "package" "$package" "suggestion" "Install 'downgrade' from AUR for more options")"
            return 1
        fi

        # Install the second-newest version (first is current)
        if [[ ${#cached_versions[@]} -lt 2 ]]; then
            json_error "SINGLE_VERSION" \
                "Only one cached version found for $package" \
                "$(json_object "package" "$package" "suggestion" "Install 'downgrade' from AUR for more options")"
            return 1
        fi

        local target_file="${cache_dir}/${cached_versions[2]}"
        if sudo pacman -U --noconfirm "$target_file" &>/dev/null; then
            local new_version=$(pacman -Q "$package" 2>/dev/null | awk '{print $2}')
            local data=$(json_object \
                "package" "$package" \
                "new_version" "$new_version" \
                "method" "cache")
            json_success "Package $package downgraded to $new_version" "$data"
        else
            json_system_error "Failed to install cached version of $package" "pacman -U $target_file"
            return 1
        fi
    fi
}

# =============================================================================
# List Cached Versions
# =============================================================================

list_cached_versions() {
    local package="$1"

    if [[ -z "$package" ]]; then
        json_validation_error "package" "Package name is required"
        return 1
    fi

    local cache_dir="/var/cache/pacman/pkg"
    local -a versions=()
    local current_version=$(pacman -Q "$package" 2>/dev/null | awk '{print $2}')

    while IFS= read -r file; do
        if [[ -n "$file" ]]; then
            local basename=$(basename "$file")
            # Extract version from filename: package-version-arch.pkg.tar.*
            local ver=$(echo "$basename" | sed "s/^${package}-//" | sed 's/-[^-]*\.pkg\.tar\..*//')
            versions+=("$ver")
        fi
    done < <(find "$cache_dir" -name "${package}-[0-9]*" -type f 2>/dev/null | sort -V -r)

    local data=$(json_object \
        "package" "$package" \
        "current_version" "$current_version" \
        "cached_versions" "$(json_array "${versions[@]}")" \
        "count" "${#versions[@]}")

    json_success "Found ${#versions[@]} cached version(s) of $package" "$data"
}

# =============================================================================
# Mirror Management
# =============================================================================

update_mirrors() {
    local country="${1:-}"
    local count="${2:-10}"

    # Check if reflector is available
    if ! command -v reflector &>/dev/null; then
        json_command_not_found "reflector (install reflector package)"
        return 1
    fi

    # Validate count
    if ! [[ "$count" =~ ^[0-9]+$ ]]; then
        json_validation_error "count" "Must be a positive number"
        return 1
    fi

    # Backup current mirrorlist
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak 2>/dev/null

    # Build reflector command
    local -a cmd=(reflector --sort rate --save /etc/pacman.d/mirrorlist -n "$count" --protocol https)

    if [[ -n "$country" ]]; then
        cmd+=(--country "$country")
    fi

    if sudo "${cmd[@]}" &>/dev/null; then
        # Read top mirrors from new list
        local -a top_mirrors=()
        while IFS= read -r line; do
            if [[ "$line" =~ ^Server ]]; then
                local url=$(echo "$line" | awk '{print $3}')
                top_mirrors+=("$url")
            fi
        done < /etc/pacman.d/mirrorlist

        local data=$(json_object \
            "mirrors_count" "${#top_mirrors[@]}" \
            "country" "$country" \
            "protocol" "https" \
            "sort_by" "rate" \
            "backup" "/etc/pacman.d/mirrorlist.bak" \
            "top_mirrors" "$(json_array "${top_mirrors[@]:0:5}")")

        json_success "Updated mirror list with ${#top_mirrors[@]} mirrors" "$data"
    else
        # Restore backup on failure
        sudo cp /etc/pacman.d/mirrorlist.bak /etc/pacman.d/mirrorlist 2>/dev/null
        json_system_error "Failed to update mirrors" "reflector"
        return 1
    fi
}

mirror_status() {
    local mirrorlist="/etc/pacman.d/mirrorlist"
    local has_backup="false"
    local mirror_count=0
    local -a mirrors=()

    if [[ -f "${mirrorlist}.bak" ]]; then
        has_backup="true"
    fi

    # Count active mirrors
    while IFS= read -r line; do
        if [[ "$line" =~ ^Server ]]; then
            local url=$(echo "$line" | awk '{print $3}')
            mirrors+=("$url")
            ((mirror_count++))
        fi
    done < "$mirrorlist" 2>/dev/null

    # Check mirrorlist age
    local age_days="unknown"
    if [[ -f "$mirrorlist" ]]; then
        local modified=$(stat -c %Y "$mirrorlist" 2>/dev/null)
        if [[ -n "$modified" ]]; then
            local now=$(date +%s)
            age_days=$(( (now - modified) / 86400 ))
        fi
    fi

    local reflector_installed="false"
    if command -v reflector &>/dev/null; then
        reflector_installed="true"
    fi

    local data=$(json_object \
        "mirror_count" "$mirror_count" \
        "age_days" "$age_days" \
        "has_backup" "$has_backup" \
        "reflector_installed" "$reflector_installed" \
        "top_mirrors" "$(json_array "${mirrors[@]:0:5}")")

    json_success "Mirror status retrieved" "$data"
}

# =============================================================================
# Main Entry Point
# =============================================================================

main() {
    local action="$1"
    shift

    case "$action" in
        clean_cache)
            clean_cache "$@"
            ;;
        remove_orphans)
            remove_orphans "$@"
            ;;
        check_broken)
            check_broken
            ;;
        update_database)
            update_database
            ;;
        disk_usage)
            get_disk_usage
            ;;
        optimize_database)
            optimize_database
            ;;
        clear_logs)
            clear_old_logs "$@"
            ;;
        downgrade)
            downgrade_package "$@"
            ;;
        list_cached_versions)
            list_cached_versions "$@"
            ;;
        update_mirrors)
            update_mirrors "$@"
            ;;
        mirror_status)
            mirror_status
            ;;
        *)
            json_error "INVALID_ACTION" \
                "Unknown action: $action" \
                "$(json_object "action" "$action" "suggestion" "Use: clean_cache, remove_orphans, check_broken, update_database, disk_usage, optimize_database, clear_logs, downgrade, list_cached_versions, update_mirrors, mirror_status")"
            exit 1
            ;;
    esac
}

# Run main if script is executed directly
if [[ "${ZSH_EVAL_CONTEXT}" == "toplevel" ]] || [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
