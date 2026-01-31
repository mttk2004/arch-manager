#!/usr/bin/env zsh

# =============================================================================
# Utilities Module
# Common utility functions used across the application
# =============================================================================

# =============================================================================
# Validation Functions
# =============================================================================

# Check if string is empty
is_empty() {
    local str=$1
    [[ -z "$str" ]]
}

# Check if string is not empty
is_not_empty() {
    local str=$1
    [[ -n "$str" ]]
}

# Check if variable is a number
is_number() {
    local value=$1
    [[ "$value" =~ ^[0-9]+$ ]]
}

# Check if input is valid menu choice
is_valid_choice() {
    local choice=$1
    local min=$2
    local max=$3

    if is_number "$choice"; then
        if [[ $choice -ge $min && $choice -le $max ]]; then
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# String Functions
# =============================================================================

# Trim whitespace from string
trim() {
    local str=$1
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    echo "$str"
}

# Convert string to lowercase
to_lower() {
    local str=$1
    echo "${str:l}"
}

# Convert string to uppercase
to_upper() {
    local str=$1
    echo "${str:u}"
}

# Get string length
str_length() {
    local str=$1
    echo "${#str}"
}

# Repeat string n times
repeat_string() {
    local str=$1
    local times=$2
    local result=""

    for ((i=0; i<times; i++)); do
        result="${result}${str}"
    done

    echo "$result"
}

# =============================================================================
# Array Functions
# =============================================================================

# Check if array contains element
array_contains() {
    local element=$1
    shift
    local array=("$@")

    for item in "${array[@]}"; do
        if [[ "$item" == "$element" ]]; then
            return 0
        fi
    done
    return 1
}

# Get array length
array_length() {
    local -a array=("$@")
    echo "${#array[@]}"
}

# Join array elements with delimiter
array_join() {
    local delimiter=$1
    shift
    local array=("$@")
    local result=""

    for ((i=0; i<${#array[@]}; i++)); do
        if [[ $i -eq 0 ]]; then
            result="${array[$i]}"
        else
            result="${result}${delimiter}${array[$i]}"
        fi
    done

    echo "$result"
}

# =============================================================================
# File Operations
# =============================================================================

# Check if file exists
file_exists() {
    local file=$1
    [[ -f "$file" ]]
}

# Check if directory exists
dir_exists() {
    local dir=$1
    [[ -d "$dir" ]]
}

# Create directory if not exists
ensure_dir() {
    local dir=$1
    if ! dir_exists "$dir"; then
        mkdir -p "$dir"
    fi
}

# Get file size in human readable format
get_file_size() {
    local file=$1
    if file_exists "$file"; then
        du -h "$file" | awk '{print $1}'
    else
        echo "0"
    fi
}

# Get directory size
get_dir_size() {
    local dir=$1
    if dir_exists "$dir"; then
        du -sh "$dir" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

# Backup file with timestamp
backup_file() {
    local file=$1
    if file_exists "$file"; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        echo "$backup"
    fi
}

# =============================================================================
# Date/Time Functions
# =============================================================================

# Get current timestamp
get_timestamp() {
    date +%s
}

# Get formatted date
get_date() {
    local format=${1:-%Y-%m-%d}
    date +"$format"
}

# Get formatted datetime
get_datetime() {
    local format=${1:-%Y-%m-%d %H:%M:%S}
    date +"$format"
}

# Calculate time difference in seconds
time_diff() {
    local start=$1
    local end=$2
    echo $((end - start))
}

# Format seconds to human readable
format_seconds() {
    local seconds=$1
    local days=$((seconds / 86400))
    local hours=$(((seconds % 86400) / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [[ $days -gt 0 ]]; then
        echo "${days}d ${hours}h ${minutes}m ${secs}s"
    elif [[ $hours -gt 0 ]]; then
        echo "${hours}h ${minutes}m ${secs}s"
    elif [[ $minutes -gt 0 ]]; then
        echo "${minutes}m ${secs}s"
    else
        echo "${secs}s"
    fi
}

# =============================================================================
# Process Functions
# =============================================================================

# Check if process is running
is_process_running() {
    local pid=$1
    kill -0 "$pid" 2>/dev/null
}

# Wait for process to complete
wait_for_process() {
    local pid=$1
    local timeout=${2:-60}
    local elapsed=0

    while is_process_running "$pid"; do
        if [[ $elapsed -ge $timeout ]]; then
            return 1
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done
    return 0
}

# Run command with timeout
run_with_timeout() {
    local timeout=$1
    shift
    local command="$@"

    timeout "$timeout" bash -c "$command"
}

# =============================================================================
# Error Handling
# =============================================================================

# Exit with error message
die() {
    local message=$1
    local code=${2:-1}
    error "$message"
    exit "$code"
}

# Assert condition
assert() {
    local condition=$1
    local message=$2

    if ! eval "$condition"; then
        die "Assertion failed: $message"
    fi
}

# Try-catch simulation
try() {
    local command=$1
    local error_handler=$2

    if ! eval "$command"; then
        if [[ -n "$error_handler" ]]; then
            eval "$error_handler"
        fi
        return 1
    fi
    return 0
}

# =============================================================================
# Logging Functions
# =============================================================================

# Log message to file
log_message() {
    local message=$1
    local log_file=${2:-/tmp/pkgman.log}
    local timestamp=$(get_datetime)

    echo "[$timestamp] $message" >> "$log_file"
}

# Log error to file
log_error() {
    local message=$1
    local log_file=${2:-/tmp/pkgman.log}
    log_message "ERROR: $message" "$log_file"
}

# Log info to file
log_info() {
    local message=$1
    local log_file=${2:-/tmp/pkgman.log}
    log_message "INFO: $message" "$log_file"
}

# =============================================================================
# Math Functions
# =============================================================================

# Calculate percentage
percentage() {
    local part=$1
    local total=$2

    if [[ $total -eq 0 ]]; then
        echo "0"
    else
        echo $(( (part * 100) / total ))
    fi
}

# Get maximum of two numbers
max() {
    local a=$1
    local b=$2

    if [[ $a -gt $b ]]; then
        echo "$a"
    else
        echo "$b"
    fi
}

# Get minimum of two numbers
min() {
    local a=$1
    local b=$2

    if [[ $a -lt $b ]]; then
        echo "$a"
    else
        echo "$b"
    fi
}

# =============================================================================
# System Functions
# =============================================================================

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Require root privileges
require_root() {
    if ! is_root; then
        die "This operation requires root privileges. Please run with sudo."
    fi
}

# Get current user
get_current_user() {
    echo "${USER:-$(whoami)}"
}

# Get home directory
get_home_dir() {
    echo "${HOME}"
}

# =============================================================================
# Cleanup Functions
# =============================================================================

# Cleanup temporary files
cleanup_temp() {
    local temp_dir=${1:-/tmp/pkgman}
    if dir_exists "$temp_dir"; then
        rm -rf "$temp_dir"
    fi
}

# Register cleanup handler
register_cleanup() {
    local cleanup_function=$1
    trap "$cleanup_function" EXIT INT TERM
}

# =============================================================================
# Version Comparison
# =============================================================================

# Compare versions (semantic versioning)
version_compare() {
    local version1=$1
    local version2=$2

    if [[ "$version1" == "$version2" ]]; then
        echo "0"
        return
    fi

    local IFS=.
    local i ver1=($version1) ver2=($version2)

    # Fill empty positions with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++)); do
        ver1[i]=0
    done

    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi

        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            echo "1"
            return
        fi

        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            echo "-1"
            return
        fi
    done

    echo "0"
}

# =============================================================================
# Random Functions
# =============================================================================

# Generate random string
random_string() {
    local length=${1:-16}
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "$length" | head -n 1
}

# Generate random number in range
random_number() {
    local min=${1:-0}
    local max=${2:-100}
    echo $(( RANDOM % (max - min + 1) + min ))
}

# =============================================================================
# Config Functions
# =============================================================================

# Read config value
read_config() {
    local config_file=$1
    local key=$2
    local default=${3:-""}

    if file_exists "$config_file"; then
        local value=$(grep "^${key}=" "$config_file" | cut -d'=' -f2- | tr -d '"' | tr -d "'")
        echo "${value:-$default}"
    else
        echo "$default"
    fi
}

# Write config value
write_config() {
    local config_file=$1
    local key=$2
    local value=$3

    ensure_dir "$(dirname "$config_file")"

    if file_exists "$config_file"; then
        sed -i "s/^${key}=.*/${key}=\"${value}\"/" "$config_file"
    else
        echo "${key}=\"${value}\"" >> "$config_file"
    fi
}
