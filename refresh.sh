#!/bin/bash
# refresh.sh - Update local setup from latest repo changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source lib/common.sh
source lib/logger.sh

export LOG_FILE="$SCRIPT_DIR/refresh.log"
init_log

main() {
    clear
    print_header "Mac Data Engineering Setup - Refresh"

    print_info "This will update your environment from the latest repo changes"
    echo ""

    if ! confirm "Continue with refresh?" "y"; then
        print_info "Refresh cancelled"
        exit 0
    fi

    echo ""

    # Pull latest changes
    print_header "Pulling Latest Changes"
    if [[ -d ".git" ]]; then
        print_info "Fetching updates from repository..."
        if git pull origin main 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Repository updated"
        else
            print_error "Failed to pull updates"
            exit 1
        fi
    else
        print_warning "Not a git repository, skipping git pull"
    fi

    echo ""

    # Update Homebrew packages
    print_header "Updating Homebrew Packages"
    print_info "This may take several minutes..."
    if brew bundle --file=config/Brewfile 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Homebrew packages updated"
    else
        print_warning "Some Homebrew packages may have failed to update"
    fi

    echo ""

    # Update npm packages
    print_header "Updating npm Packages"
    if command_exists npm; then
        while IFS= read -r package; do
            [[ -z "$package" ]] && continue
            [[ "$package" =~ ^#.*$ ]] && continue

            print_info "Updating $package..."
            if npm update -g "$package" 2>&1 | tee -a "$LOG_FILE"; then
                print_success "$package updated"
            else
                print_warning "Failed to update $package"
            fi
        done < config/npm-global.txt
    else
        print_warning "npm not available, skipping npm updates"
    fi

    echo ""

    # Update uv tools
    print_header "Updating uv Tools"
    if command_exists uv; then
        while IFS= read -r tool; do
            [[ -z "$tool" ]] && continue
            [[ "$tool" =~ ^#.*$ ]] && continue

            print_info "Updating $tool..."
            if uv tool upgrade "$tool" 2>&1 | tee -a "$LOG_FILE"; then
                print_success "$tool updated"
            else
                print_warning "Failed to update $tool (may already be latest)"
            fi
        done < config/uv-tools.txt
    else
        print_warning "uv not available, skipping uv tool updates"
    fi

    echo ""

    # Update VS Code extensions
    print_header "Updating VS Code Extensions"
    if command_exists code; then
        local updated=0
        local total=0

        while IFS= read -r extension; do
            [[ -z "$extension" ]] && continue
            [[ "$extension" =~ ^#.*$ ]] && continue

            ((total++))

            print_info "Updating $extension..."
            if code --force --install-extension "$extension" 2>&1 | tee -a "$LOG_FILE" | grep -q "successfully installed"; then
                ((updated++))
            fi
        done < config/vscode-extensions.txt

        print_info "Updated/installed $updated/$total extensions"
    else
        print_warning "VS Code CLI not available, skipping extension updates"
    fi

    echo ""

    # Verify everything
    print_header "Running Verification"
    ./verify.sh

    echo ""
    print_header "Refresh Complete!"
    print_success "Your environment has been updated"
    echo ""
    print_info "Refresh log saved to: $LOG_FILE"
    echo ""
}

main "$@"
