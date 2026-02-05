#!/usr/bin/env zsh

# =============================================================================
# JSON Output Helpers for Zsh Backend Scripts
# Provides utilities for generating JSON responses to Python UI layer
# =============================================================================

# =============================================================================
# JSON Encoding Functions
# =============================================================================

# Escape string for JSON
json_escape() {
    local str="$1"
    # Escape special characters for JSON
    str="${str//\\/\\\\}"  # Backslash
    str="${str//\"/\\\"}"  # Double quote
    str="${str//$'\n'/\\n}"  # Newline
    str="${str//$'\r'/\\r}"  # Carriage return
    str="${str//$'\t'/\\t}"  # Tab
    echo -n "$str"
}

# Convert array to JSON array string
json_array() {
    local items=("$@")
    local result="["
    local first=true

    for item in "${items[@]}"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            result+=","
        fi
        result+="\"$(json_escape "$item")\""
    done

    result+="]"
    echo -n "$result"
}

# Convert associative array to JSON object
# Usage: json_object key1 value1 key2 value2 ...
json_object() {
    local result="{"
    local first=true

    while [[ $# -gt 0 ]]; do
        local key="$1"
        local value="$2"
        shift 2

        if [[ "$first" == true ]]; then
            first=false
        else
            result+=","
        fi

        result+="\"$(json_escape "$key")\":"

        # Check if value is a number
        if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            result+="$value"
        # Check if value is boolean
        elif [[ "$value" == "true" || "$value" == "false" ]]; then
            result+="$value"
        # Check if value is null
        elif [[ "$value" == "null" ]]; then
            result+="null"
        # Check if value starts with [ or { (already JSON)
        elif [[ "${value:0:1}" == "[" || "${value:0:1}" == "{" ]]; then
            result+="$value"
        else
            result+="\"$(json_escape "$value")\""

        fi
    done

    result+="}"
    echo -n "$result"
}

# =============================================================================
# Response Builder Functions
# =============================================================================

# Create success response
# Usage: json_success "message" data_json
json_success() {
    local message="$1"
    local data="${2:-{}}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo -n '{"status":"success","data":'
    echo -n "$data"
    echo -n ',"message":"'
    echo -n "$(json_escape "$message")"
    echo -n '","timestamp":"'
    echo -n "$timestamp"
    echo -n '"}'
}

# Create error response
# Usage: json_error "ERROR_CODE" "error message" details_json
json_error() {
    local code="$1"
    local message="$2"
    local details="${3:-{}}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo -n '{"status":"error","error":{"code":"'
    echo -n "$code"
    echo -n '","message":"'
    echo -n "$(json_escape "$message")"
    echo -n '","details":'
    echo -n "$details"
    echo -n '},"message":"'
    echo -n "$(json_escape "$message")"
    echo -n '","timestamp":"'
    echo -n "$timestamp"
    echo -n '"}'
}

# Create warning response
json_warning() {
    local message="$1"
    local data="${2:-{}}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo -n '{"status":"warning","data":'
    echo -n "$data"
    echo -n ',"message":"'
    echo -n "$(json_escape "$message")"
    echo -n '","timestamp":"'
    echo -n "$timestamp"
    echo -n '"}'
}

# Create info response
json_info() {
    local message="$1"
    local data="${2:-{}}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo -n '{"status":"info","data":'
    echo -n "$data"
    echo -n ',"message":"'
    echo -n "$(json_escape "$message")"
    echo -n '","timestamp":"'
    echo -n "$timestamp"
    echo -n '"}'
}

# =============================================================================
# Convenience Functions for Common Responses
# =============================================================================

# Package installation success response
json_install_success() {
    local installed=("$@")
    local count=${#installed[@]}

    local data=$(json_object \
        "installed" "$(json_array "${installed[@]}")" \
        "count" "$count" \
        "already_installed" "[]" \
        "failed" "[]")

    json_success "Successfully installed $count package(s)" "$data"
}

# Package removal success response
json_remove_success() {
    local removed=("$@")
    local count=${#removed[@]}

    local data=$(json_object \
        "removed" "$(json_array "${removed[@]}")" \
        "count" "$count" \
        "failed" "[]")

    json_success "Successfully removed $count package(s)" "$data"
}

# Package list response
json_package_list() {
    local packages=()
    local count=0

    # Read packages from stdin or arguments
    if [[ -p /dev/stdin ]]; then
        while IFS= read -r line; do
            packages+=("$line")
            ((count++))
        done
    else
        packages=("$@")
        count=${#packages[@]}
    fi

    local data=$(json_object \
        "packages" "$(json_array "${packages[@]}")" \
        "count" "$count")

    json_success "Found $count package(s)" "$data"
}

# Permission denied error
json_permission_error() {
    local operation="${1:-this operation}"
    local details=$(json_object \
        "required_privilege" "root" \
        "suggestion" "Run with sudo")

    json_error "PERMISSION_DENIED" \
        "Root privileges required for $operation" \
        "$details"
}

# Package not found error
json_package_not_found() {
    local package="$1"
    local details=$(json_object \
        "package" "$package" \
        "suggestion" "Check package name or enable AUR")

    json_error "PACKAGE_NOT_FOUND" \
        "Package not found: $package" \
        "$details"
}

# Command not found error
json_command_not_found() {
    local command="$1"
    local details=$(json_object \
        "command" "$command" \
        "suggestion" "Install required package or check PATH")

    json_error "COMMAND_NOT_FOUND" \
        "Required command not found: $command" \
        "$details"
}

# Timeout error
json_timeout_error() {
    local operation="$1"
    local timeout="${2:-300}"
    local details=$(json_object \
        "operation" "$operation" \
        "timeout_seconds" "$timeout")

    json_error "TIMEOUT" \
        "Operation timed out: $operation" \
        "$details"
}

# Validation error
json_validation_error() {
    local field="$1"
    local message="$2"
    local details=$(json_object \
        "field" "$field" \
        "validation_message" "$message")

    json_error "VALIDATION_ERROR" \
        "Validation failed for $field: $message" \
        "$details"
}

# System error (generic)
json_system_error() {
    local message="$1"
    local command="${2:-unknown}"
    local details=$(json_object \
        "command" "$command" \
        "suggestion" "Check system logs for details")

    json_error "SYSTEM_ERROR" \
        "$message" \
        "$details"
}

# =============================================================================
# Helper Functions
# =============================================================================

# Check if jq is available (for complex JSON manipulation)
has_jq() {
    command -v jq &> /dev/null
}

# Parse JSON input (requires jq)
json_parse() {
    local json="$1"
    local query="$2"

    if has_jq; then
        echo "$json" | jq -r "$query"
    else
        echo "Error: jq is required for JSON parsing" >&2
        return 1
    fi
}

# Pretty print JSON (requires jq)
json_pretty() {
    local json="$1"

    if has_jq; then
        echo "$json" | jq '.'
    else
        echo "$json"
    fi
}

# Validate JSON (requires jq)
json_validate() {
    local json="$1"

    if has_jq; then
        echo "$json" | jq empty 2>/dev/null
        return $?
    else
        # Basic validation - check if it starts with { or [
        if [[ "$json" =~ ^\{.*\}$ || "$json" =~ ^\[.*\]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}

# =============================================================================
# Example Usage (for testing)
# =============================================================================

# Uncomment to test functions
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "=== JSON Helpers Test ==="
    echo

    echo "1. Success Response:"
    json_success "Test operation completed" '{"test": true}'
    echo

    echo "2. Error Response:"
    json_error "TEST_ERROR" "This is a test error" '{"details": "test"}'
    echo

    echo "3. Install Success:"
    json_install_success "neovim" "tmux" "git"
    echo

    echo "4. Package List:"
    json_package_list "package1" "package2" "package3"
    echo

    echo "5. Permission Error:"
    json_permission_error "package installation"
    echo
fi
