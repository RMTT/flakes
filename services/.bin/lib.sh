#!/usr/bin/env bash
# Shared library for services deployment

SERVICES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log_info() { echo "[INFO] $1"; }
log_warn() { echo "[WARN] $1"; }
log_error() { echo "[ERROR] $1"; }

# Confirm before executing action
confirm() {
    local prompt="$1"
    local response
    while true; do
        read -rp "$prompt [y/N]: " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]) return 0 ;;
            [Nn]|[Nn][Oo]|"") return 1 ;;
        esac
    done
}

# Get namespace and release from current directory
# Returns: NAMESPACE RELEASE
get_ns_release() {
    local current_dir="${1:-$(pwd)}"
    local current_dir_abs
    current_dir_abs="$(cd "$current_dir" && pwd)"

    local services_dir_abs
    services_dir_abs="$(cd "$SERVICES_DIR" && pwd)"

    # If we're in services root
    if [[ "$current_dir_abs" == "$services_dir_abs" ]]; then
        log_error "You must be in a service directory"
        return 1
    fi

    # Get relative path from services dir
    local rel_path="${current_dir_abs#$services_dir_abs/}"

    # Get namespace (first directory level)
    local namespace="${rel_path%%/*}"

    # Current directory name is release
    local release="$(basename "$current_dir_abs")"

    echo "$namespace" "$release"
}

# Check if current directory has a Chart.yaml
check_chart() {
    local current_dir="${1:-$(pwd)}"
    if [[ ! -f "$current_dir/Chart.yaml" ]]; then
        log_error "No Chart.yaml found in current directory: $current_dir"
        return 1
    fi
    return 0
}
