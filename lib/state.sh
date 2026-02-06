#!/bin/bash
# state.sh - State management for resume capability

STATE_DIR=".state"
STATE_FILE="$STATE_DIR/install.state"
CHECKPOINT_FILE="$STATE_DIR/checkpoint.txt"

# Initialize state directory
init_state() {
    mkdir -p "$STATE_DIR"

    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
# Installation state file
# Each line: phase_name=status (pending|in_progress|completed|failed)
check_system=pending
install_homebrew=pending
install_brew_packages=pending
install_npm_packages=pending
install_uv_tools=pending
install_vscode_extensions=pending
configure_shell=pending
create_directories=pending
EOF
    fi

    log_debug "State initialized at $STATE_FILE"
}

# Get status of a phase
get_phase_status() {
    local phase="$1"
    grep "^$phase=" "$STATE_FILE" | cut -d= -f2
}

# Set status of a phase
set_phase_status() {
    local phase="$1"
    local status="$2"

    if grep -q "^$phase=" "$STATE_FILE"; then
        # Update existing phase
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^$phase=.*/$phase=$status/" "$STATE_FILE"
        else
            sed -i "s/^$phase=.*/$phase=$status/" "$STATE_FILE"
        fi
    else
        # Add new phase
        echo "$phase=$status" >> "$STATE_FILE"
    fi

    log_debug "Phase $phase status set to $status"
}

# Mark phase as in progress
start_phase() {
    local phase="$1"
    set_phase_status "$phase" "in_progress"
    echo "$phase" > "$CHECKPOINT_FILE"
    log_info "Started phase: $phase"
}

# Mark phase as completed
complete_phase() {
    local phase="$1"
    set_phase_status "$phase" "completed"
    log_info "Completed phase: $phase"
}

# Mark phase as failed
fail_phase() {
    local phase="$1"
    set_phase_status "$phase" "failed"
    log_error "Failed phase: $phase"
}

# Check if phase is completed
is_phase_completed() {
    local phase="$1"
    local status=$(get_phase_status "$phase")
    [[ "$status" == "completed" ]]
}

# Get next pending phase
get_next_phase() {
    grep "=pending" "$STATE_FILE" | head -1 | cut -d= -f1
}

# Get last checkpoint
get_last_checkpoint() {
    if [[ -f "$CHECKPOINT_FILE" ]]; then
        cat "$CHECKPOINT_FILE"
    fi
}

# Reset all state
reset_state() {
    if [[ -d "$STATE_DIR" ]]; then
        rm -rf "$STATE_DIR"
        log_info "State reset"
    fi
    init_state
}

# Show current state
show_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        print_info "No state file found"
        return
    fi

    print_header "Installation State"

    while IFS='=' read -r phase status; do
        # Skip comments and empty lines
        [[ "$phase" =~ ^#.*$ ]] && continue
        [[ -z "$phase" ]] && continue

        case "$status" in
            completed)
                print_success "$phase"
                ;;
            in_progress)
                print_warning "$phase (in progress)"
                ;;
            failed)
                print_error "$phase (failed)"
                ;;
            pending)
                print_info "$phase (pending)"
                ;;
        esac
    done < "$STATE_FILE"

    echo ""
}

# Count completed phases
count_completed() {
    grep "=completed" "$STATE_FILE" 2>/dev/null | wc -l | tr -d ' '
}

# Count total phases
count_total() {
    grep -v "^#" "$STATE_FILE" 2>/dev/null | grep -v "^$" | wc -l | tr -d ' '
}

# Calculate progress percentage
get_progress() {
    local completed=$(count_completed)
    local total=$(count_total)

    if [[ "$total" -eq 0 ]]; then
        echo "0"
    else
        echo $(( completed * 100 / total ))
    fi
}
