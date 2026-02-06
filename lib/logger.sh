#!/bin/bash
# logger.sh - Logging utilities

LOG_FILE="${LOG_FILE:-./setup.log}"
LOG_LEVEL="${LOG_LEVEL:-INFO}" # DEBUG, INFO, WARN, ERROR

# Initialize log file
init_log() {
    local log_dir=$(dirname "$LOG_FILE")
    mkdir -p "$log_dir"
    echo "=== Setup started at $(date) ===" >> "$LOG_FILE"
}

# Log message to file and optionally to stdout
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    # Also print to stdout based on level
    case "$level" in
        ERROR)
            print_error "$message"
            ;;
        WARN)
            print_warning "$message"
            ;;
        INFO)
            print_info "$message"
            ;;
        DEBUG)
            if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
                echo "  [DEBUG] $message"
            fi
            ;;
    esac
}

log_debug() {
    log "DEBUG" "$@"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

# Log command execution
log_command() {
    local cmd="$1"
    log_debug "Executing: $cmd"

    if eval "$cmd" >> "$LOG_FILE" 2>&1; then
        log_debug "Command succeeded: $cmd"
        return 0
    else
        local exit_code=$?
        log_error "Command failed (exit $exit_code): $cmd"
        return $exit_code
    fi
}
