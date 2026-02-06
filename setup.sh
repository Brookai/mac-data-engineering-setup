#!/bin/bash
# setup.sh - Main interactive setup script for Mac data engineering environment
# Brook AI - Data Engineering Team

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Source libraries
source lib/common.sh
source lib/logger.sh
source lib/state.sh
source lib/claude-helper.sh

# Configuration
export AUTO_MODE=false
export LOG_FILE="$SCRIPT_DIR/setup.log"
export LOG_LEVEL="INFO"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                AUTO_MODE=true
                shift
                ;;
            --resume)
                print_info "Resuming from last checkpoint"
                shift
                ;;
            --verify-only)
                verify_only
                exit 0
                ;;
            --reset)
                reset_state
                print_success "State reset"
                exit 0
                ;;
            --debug)
                LOG_LEVEL="DEBUG"
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

show_usage() {
    cat << EOF
Mac Data Engineering Setup - Brook AI

Usage: ./setup.sh [OPTIONS]

Options:
  --auto           Run in non-interactive mode (auto-approve all prompts)
  --resume         Resume from last checkpoint
  --verify-only    Only run verification, don't install anything
  --reset          Reset installation state and start over
  --debug          Enable debug logging
  --help, -h       Show this help message

Examples:
  ./setup.sh                 # Interactive installation
  ./setup.sh --auto          # Automated installation
  ./setup.sh --resume        # Resume interrupted installation
  ./setup.sh --verify-only   # Check what's installed
EOF
}

# Display welcome banner
show_banner() {
    clear
    cat << 'EOF'
╔═══════════════════════════════════════════════════════════════════╗
║                                                                   ║
║         Mac Data Engineering Setup - Brook AI                    ║
║                                                                   ║
║         Opinionated data engineering environment setup           ║
║         with Claude-guided error assistance                      ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
EOF
    echo ""
}

# Phase 1: System checks
phase_check_system() {
    start_phase "check_system"

    print_header "Phase 1: System Requirements"

    check_macos

    # Check for required directories
    if [[ ! -w "$HOME" ]]; then
        print_error "Home directory not writable"
        fail_phase "check_system"
        exit 1
    fi

    print_success "System checks passed"
    complete_phase "check_system"
}

# Phase 2: Install Homebrew
phase_install_homebrew() {
    if is_phase_completed "install_homebrew"; then
        print_info "Homebrew already installed, skipping"
        return 0
    fi

    start_phase "install_homebrew"

    print_header "Phase 2: Homebrew Package Manager"

    if command_exists brew; then
        print_info "Homebrew already installed"
        print_info "Updating Homebrew..."
        run_with_claude_help "brew update" "Update Homebrew" true
    else
        print_info "Installing Homebrew..."
        run_with_claude_help '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' \
            "Install Homebrew" false
    fi

    complete_phase "install_homebrew"
}

# Phase 3: Install Homebrew packages
phase_install_brew_packages() {
    if is_phase_completed "install_brew_packages"; then
        print_info "Homebrew packages already installed, skipping"
        return 0
    fi

    start_phase "install_brew_packages"

    print_header "Phase 3: Homebrew Packages"

    if [[ ! -f "config/Brewfile" ]]; then
        print_error "Brewfile not found at config/Brewfile"
        fail_phase "install_brew_packages"
        exit 1
    fi

    print_info "Installing packages from Brewfile..."
    echo "This may take 10-20 minutes depending on your connection"
    echo ""

    run_with_claude_help "brew bundle --file=config/Brewfile" \
        "Install Homebrew packages" false

    complete_phase "install_brew_packages"
}

# Phase 4: Install npm global packages
phase_install_npm_packages() {
    if is_phase_completed "install_npm_packages"; then
        print_info "npm packages already installed, skipping"
        return 0
    fi

    start_phase "install_npm_packages"

    print_header "Phase 4: npm Global Packages"

    if ! command_exists npm; then
        print_error "npm not found. Install node first via Homebrew"
        fail_phase "install_npm_packages"
        exit 1
    fi

    while IFS= read -r package; do
        [[ -z "$package" ]] && continue
        [[ "$package" =~ ^#.*$ ]] && continue

        print_info "Installing $package..."
        run_with_claude_help "npm install -g $package" "Install $package" true
    done < config/npm-global.txt

    complete_phase "install_npm_packages"
}

# Phase 5: Install uv tools
phase_install_uv_tools() {
    if is_phase_completed "install_uv_tools"; then
        print_info "uv tools already installed, skipping"
        return 0
    fi

    start_phase "install_uv_tools"

    print_header "Phase 5: uv Tools"

    if ! command_exists uv; then
        print_error "uv not found. Install via Homebrew first"
        fail_phase "install_uv_tools"
        exit 1
    fi

    while IFS= read -r tool; do
        [[ -z "$tool" ]] && continue
        [[ "$tool" =~ ^#.*$ ]] && continue

        print_info "Installing $tool..."
        run_with_claude_help "uv tool install $tool" "Install $tool" true
    done < config/uv-tools.txt

    complete_phase "install_uv_tools"
}

# Phase 6: Install VS Code extensions
phase_install_vscode_extensions() {
    if is_phase_completed "install_vscode_extensions"; then
        print_info "VS Code extensions already installed, skipping"
        return 0
    fi

    start_phase "install_vscode_extensions"

    print_header "Phase 6: VS Code Extensions"

    if ! command_exists code; then
        print_warning "VS Code CLI not found. Install VS Code first or add to PATH"
        if confirm_or_auto "Skip VS Code extensions?" "n"; then
            complete_phase "install_vscode_extensions"
            return 0
        fi
        fail_phase "install_vscode_extensions"
        exit 1
    fi

    local installed=0
    local total=0

    while IFS= read -r extension; do
        [[ -z "$extension" ]] && continue
        [[ "$extension" =~ ^#.*$ ]] && continue

        ((total++))

        # Check if already installed
        if code --list-extensions | grep -q "^${extension}$"; then
            print_success "$extension (already installed)"
            ((installed++))
            continue
        fi

        print_info "Installing $extension..."
        if run_with_claude_help "code --install-extension $extension" "Install $extension" true; then
            ((installed++))
        fi
    done < config/vscode-extensions.txt

    print_info "Installed $installed/$total extensions"

    complete_phase "install_vscode_extensions"
}

# Phase 7: Configure shell
phase_configure_shell() {
    if is_phase_completed "configure_shell"; then
        print_info "Shell already configured, skipping"
        return 0
    fi

    start_phase "configure_shell"

    print_header "Phase 7: Shell Configuration"

    local zshrc="$HOME/.zshrc"
    local snippet_marker="# Mac Data Engineering Setup - Shell Customizations"

    # Check if snippet already exists
    if grep -q "$snippet_marker" "$zshrc" 2>/dev/null; then
        print_info "Shell customizations already present in ~/.zshrc"
    else
        print_info "Adding shell customizations to ~/.zshrc"

        if [[ ! -f "$zshrc" ]]; then
            touch "$zshrc"
        fi

        # Add snippet
        echo "" >> "$zshrc"
        cat config/shell/zshrc-snippet.sh >> "$zshrc"

        print_success "Shell customizations added"
        print_warning "Restart your terminal or run: source ~/.zshrc"
    fi

    complete_phase "configure_shell"
}

# Phase 8: Create directories
phase_create_directories() {
    if is_phase_completed "create_directories"; then
        print_info "Directories already created, skipping"
        return 0
    fi

    start_phase "create_directories"

    print_header "Phase 8: Directory Setup"

    local repos_dir="$HOME/Repos"

    if [[ ! -d "$repos_dir" ]]; then
        print_info "Creating ~/Repos directory"
        mkdir -p "$repos_dir"
        print_success "Created $repos_dir"
    else
        print_info "~/Repos already exists"
    fi

    complete_phase "create_directories"
}

# Run verification
verify_only() {
    print_header "Verification"
    exec "$SCRIPT_DIR/verify.sh"
}

# Main installation flow
main() {
    parse_args "$@"

    show_banner

    # Initialize
    init_log
    init_state
    check_claude_cli

    if ! is_auto_mode; then
        show_state
        echo ""
        print_info "This will install data engineering tools for Brook AI"
        print_info "Installation log: $LOG_FILE"
        echo ""

        if ! confirm "Continue with installation?" "y"; then
            print_info "Installation cancelled"
            exit 0
        fi
        echo ""
    fi

    # Run phases
    phase_check_system
    phase_install_homebrew
    phase_install_brew_packages
    phase_install_npm_packages
    phase_install_uv_tools
    phase_install_vscode_extensions
    phase_configure_shell
    phase_create_directories

    # Show summary
    print_header "Installation Complete!"

    echo ""
    print_success "All phases completed successfully"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Run verification: ./verify.sh"
    echo "  3. Configure services (see POST_INSTALL.md):"
    echo "     - AWS CLI: aws configure sso"
    echo "     - GitHub: gh auth login"
    echo "     - Snowflake: snow connection add"
    echo ""
    print_info "Manual installations needed:"
    echo "  - Docker Desktop (not available via Homebrew)"
    echo "  - dbt: uv tool install dbt-snowflake"
    echo ""

    log_info "Installation completed successfully"
}

# Run main function
main "$@"
