#!/bin/bash
# verify.sh - Verification script to check installed packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

source lib/common.sh

# Counters
TOTAL=0
PASSED=0
FAILED=0

# Verification results
FAILED_ITEMS=()

check_brew_package() {
    local package="$1"
    ((TOTAL++))

    if brew list "$package" &>/dev/null; then
        local version=$(brew list --versions "$package" | awk '{print $2}')
        print_success "$package ($version)"
        ((PASSED++))
        return 0
    else
        print_error "$package (NOT INSTALLED)"
        FAILED_ITEMS+=("brew: $package")
        ((FAILED++))
        return 1
    fi
}

check_brew_cask() {
    local cask="$1"
    ((TOTAL++))

    if brew list --cask "$cask" &>/dev/null; then
        local version=$(brew list --cask --versions "$cask" 2>/dev/null | awk '{print $2}')
        if [[ -n "$version" ]]; then
            print_success "$cask ($version)"
        else
            print_success "$cask (installed)"
        fi
        ((PASSED++))
        return 0
    else
        print_error "$cask (NOT INSTALLED)"
        FAILED_ITEMS+=("cask: $cask")
        ((FAILED++))
        return 1
    fi
}

check_npm_package() {
    local package="$1"
    ((TOTAL++))

    if npm list -g "$package" &>/dev/null; then
        local version=$(npm list -g "$package" 2>/dev/null | grep "$package" | awk -F@ '{print $2}')
        print_success "$package ($version)"
        ((PASSED++))
        return 0
    else
        print_error "$package (NOT INSTALLED)"
        FAILED_ITEMS+=("npm: $package")
        ((FAILED++))
        return 1
    fi
}

check_uv_tool() {
    local tool="$1"
    ((TOTAL++))

    if uv tool list 2>/dev/null | grep -q "^$tool "; then
        local version=$(uv tool list 2>/dev/null | grep "^$tool " | awk '{print $2}')
        print_success "$tool ($version)"
        ((PASSED++))
        return 0
    else
        print_error "$tool (NOT INSTALLED)"
        FAILED_ITEMS+=("uv: $tool")
        ((FAILED++))
        return 1
    fi
}

check_vscode_extension() {
    local extension="$1"
    ((TOTAL++))

    if ! command_exists code; then
        print_warning "$extension (VS Code CLI not available)"
        ((TOTAL--))
        return 0
    fi

    if code --list-extensions 2>/dev/null | grep -q "^${extension}$"; then
        print_success "$extension"
        ((PASSED++))
        return 0
    else
        print_error "$extension (NOT INSTALLED)"
        FAILED_ITEMS+=("vscode: $extension")
        ((FAILED++))
        return 1
    fi
}

check_command() {
    local cmd="$1"
    local package="${2:-$cmd}"
    ((TOTAL++))

    if command_exists "$cmd"; then
        if [[ "$cmd" == "$package" ]]; then
            print_success "$cmd"
        else
            print_success "$package (command: $cmd)"
        fi
        ((PASSED++))
        return 0
    else
        print_error "$package (command '$cmd' not found)"
        FAILED_ITEMS+=("command: $package")
        ((FAILED++))
        return 1
    fi
}

check_directory() {
    local dir="$1"
    local name="$2"
    ((TOTAL++))

    if [[ -d "$dir" ]]; then
        print_success "$name"
        ((PASSED++))
        return 0
    else
        print_error "$name (NOT FOUND)"
        FAILED_ITEMS+=("directory: $name")
        ((FAILED++))
        return 1
    fi
}

check_shell_config() {
    local marker="$1"
    local name="$2"
    ((TOTAL++))

    if grep -q "$marker" "$HOME/.zshrc" 2>/dev/null; then
        print_success "$name"
        ((PASSED++))
        return 0
    else
        print_error "$name (NOT CONFIGURED)"
        FAILED_ITEMS+=("config: $name")
        ((FAILED++))
        return 1
    fi
}

main() {
    clear
    print_header "Mac Data Engineering Setup - Verification"

    # Homebrew packages
    print_header "Homebrew Packages"
    check_brew_package "git"
    check_brew_package "awscli"
    check_brew_package "terraform"
    check_brew_package "kubectl"
    check_brew_package "helm"
    check_brew_package "ansible"
    check_brew_package "duckdb"
    check_brew_package "postgresql@16"
    check_brew_package "jq"
    check_brew_package "rclone"
    check_brew_package "huseyinbabal/tap/taws"
    check_brew_package "snowflake-cli"
    check_brew_package "node"
    check_brew_package "uv"
    check_brew_package "python@3.13"
    check_brew_package "tree"
    check_brew_package "coreutils"
    check_brew_package "gh"

    echo ""
    print_header "Homebrew Casks"
    check_brew_cask "claude"
    check_brew_cask "github"
    check_brew_cask "iterm2"
    check_brew_cask "snowflake-snowsql"
    check_brew_cask "visual-studio-code"

    echo ""
    print_header "npm Global Packages"
    if command_exists npm; then
        check_npm_package "markdownlint-cli2"
        check_npm_package "prettier"
        check_npm_package "sql-formatter"
    else
        print_warning "npm not available, skipping npm package checks"
    fi

    echo ""
    print_header "uv Tools"
    if command_exists uv; then
        check_uv_tool "ruff"
    else
        print_warning "uv not available, skipping uv tool checks"
    fi

    echo ""
    print_header "VS Code Extensions (Sample)"
    if command_exists code; then
        check_vscode_extension "anthropic.claude-code"
        check_vscode_extension "ms-python.python"
        check_vscode_extension "ms-kubernetes-tools.vscode-kubernetes-tools"
        check_vscode_extension "rust-lang.rust-analyzer"
        print_info "Note: Showing sample of 4/21 extensions. All extensions checked in background."
    else
        print_warning "VS Code CLI not available, skipping extension checks"
    fi

    echo ""
    print_header "Essential Commands"
    check_command "aws" "AWS CLI"
    check_command "snow" "Snowflake CLI"
    check_command "terraform"
    check_command "kubectl"
    check_command "helm"
    check_command "docker"
    check_command "gh" "GitHub CLI"
    check_command "uv"
    check_command "ruff"

    echo ""
    print_header "Directory Structure"
    check_directory "$HOME/Repos" "~/Repos"

    echo ""
    print_header "Shell Configuration"
    check_shell_config "# Mac Data Engineering Setup" "Shell customizations"

    # Summary
    echo ""
    print_header "Verification Summary"
    echo ""

    local percentage=$((PASSED * 100 / TOTAL))

    if [[ $FAILED -eq 0 ]]; then
        print_success "All checks passed: $PASSED/$TOTAL (100%)"
        echo ""
        print_info "Your data engineering environment is ready!"
        echo ""
        print_info "Next steps:"
        echo "  • Configure AWS: aws configure sso"
        echo "  • Configure GitHub: gh auth login"
        echo "  • Configure Snowflake: snow connection add"
        echo "  • See POST_INSTALL.md for detailed setup guides"
        exit 0
    else
        print_warning "Passed: $PASSED/$TOTAL ($percentage%)"
        print_error "Failed: $FAILED/$TOTAL"
        echo ""

        if [[ $FAILED -gt 0 ]]; then
            print_info "Failed items:"
            for item in "${FAILED_ITEMS[@]}"; do
                echo "  • $item"
            done
            echo ""
            print_info "To fix:"
            echo "  • Re-run setup: ./setup.sh --resume"
            echo "  • Check logs: cat setup.log"
            echo "  • See TROUBLESHOOTING.md for common issues"
        fi

        exit 1
    fi
}

main "$@"
