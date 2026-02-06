#!/bin/bash
# claude-helper.sh - Claude CLI integration for error handling

ERROR_LOG="/tmp/setup-error.log"
CLAUDE_AVAILABLE=false

# Check if Claude CLI is available
check_claude_cli() {
    if command_exists claude; then
        CLAUDE_AVAILABLE=true
        log_debug "Claude CLI detected"
    else
        CLAUDE_AVAILABLE=false
        log_debug "Claude CLI not available"
    fi
}

# Run command with Claude error assistance
run_with_claude_help() {
    local cmd="$1"
    local description="$2"
    local allow_skip="${3:-true}"

    log_info "Running: $description"
    log_debug "Command: $cmd"

    # Run command and capture output
    if eval "$cmd" 2>"$ERROR_LOG"; then
        print_success "$description"
        return 0
    fi

    # Command failed - show error
    local error_msg=$(cat "$ERROR_LOG")
    print_error "$description failed"
    echo ""
    echo "Error output:"
    echo "$error_msg" | head -20
    echo ""

    # If Claude is available and we're in interactive mode, offer help
    if [[ "$CLAUDE_AVAILABLE" == "true" ]] && ! is_auto_mode; then
        if confirm "Ask Claude for help with this error?" "y"; then
            ask_claude_for_fix "$cmd" "$error_msg" "$allow_skip"
            return $?
        fi
    fi

    # Otherwise, offer to skip or exit
    if [[ "$allow_skip" == "true" ]]; then
        if confirm "Skip this step and continue?" "n"; then
            print_warning "Skipped: $description"
            return 0
        fi
    fi

    print_error "Installation failed at: $description"
    log_error "Installation failed at: $description"
    exit 1
}

# Ask Claude for a fix and optionally apply it
ask_claude_for_fix() {
    local cmd="$1"
    local error_msg="$2"
    local allow_skip="$3"

    print_info "Asking Claude for help..."
    echo ""

    # Prepare prompt for Claude
    local prompt="Mac setup script encountered an error.

Command that failed:
\`\`\`bash
$cmd
\`\`\`

Error output:
\`\`\`
$error_msg
\`\`\`

Please provide:
1. Brief explanation of the error
2. A specific fix command to resolve it
3. Any follow-up steps needed

Format your response as:
EXPLANATION: <brief explanation>
FIX: <exact bash command to run>
FOLLOW_UP: <any additional steps or none>"

    # Get Claude's response
    local claude_response=$(claude -p "$prompt" 2>&1)

    if [[ $? -ne 0 ]]; then
        print_error "Failed to get response from Claude"
        return 1
    fi

    # Display Claude's response
    echo "$claude_response"
    echo ""

    # Try to extract fix command
    local fix_cmd=$(echo "$claude_response" | grep "^FIX:" | sed 's/^FIX: *//')

    if [[ -z "$fix_cmd" ]]; then
        print_warning "Could not extract fix command from Claude's response"
        if [[ "$allow_skip" == "true" ]]; then
            if confirm "Skip this step?" "n"; then
                return 0
            fi
        fi
        return 1
    fi

    # Show extracted fix and ask if user wants to try it
    print_info "Extracted fix command:"
    echo "  $fix_cmd"
    echo ""

    if confirm "Try this fix?" "y"; then
        print_info "Applying fix..."
        if eval "$fix_cmd" 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Fix applied successfully"
            return 0
        else
            print_error "Fix failed"
            if [[ "$allow_skip" == "true" ]] && confirm "Skip this step?" "n"; then
                return 0
            fi
            return 1
        fi
    else
        if [[ "$allow_skip" == "true" ]] && confirm "Skip this step?" "n"; then
            return 0
        fi
        return 1
    fi
}

# Simplified wrapper for common install operations
install_with_help() {
    local installer="$1"  # brew, npm, uv, code
    local package="$2"
    local description="$3"

    case "$installer" in
        brew)
            run_with_claude_help "brew install $package" "Install $description"
            ;;
        brew-cask)
            run_with_claude_help "brew install --cask $package" "Install $description"
            ;;
        npm)
            run_with_claude_help "npm install -g $package" "Install $description"
            ;;
        uv)
            run_with_claude_help "uv tool install $package" "Install $description"
            ;;
        code)
            run_with_claude_help "code --install-extension $package" "Install $description"
            ;;
        *)
            log_error "Unknown installer: $installer"
            return 1
            ;;
    esac
}
