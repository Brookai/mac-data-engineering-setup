# Mac Data Engineering Setup - Repository Preferences

This file contains repo-specific preferences for working on this setup repository. Claude Code automatically loads both this file and your global `~/.claude/CLAUDE.md` preferences.

## Repo-Specific Guidelines

### Bash Scripting

**Style:**
- Use `set -e` for error propagation
- Validate all user inputs
- Provide clear error messages with context
- Use shellcheck for linting

**Structure:**
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source lib/common.sh
source lib/logger.sh

# Functions here
```

**Helper Functions:**
- Use `run_with_claude_help` for installations
- Use `print_success/error/warning/info` for output
- Use `log_info/error/debug` for logging
- Use `confirm_or_auto` for user prompts

**Error Handling:**
```bash
# Good
run_with_claude_help "brew install tool" "Install tool"

# Bad
brew install tool || echo "failed"
```

### Documentation

**README.md:**
- Keep concise (< 300 lines)
- Quick start at top
- What Gets Installed section with categories
- Links to other docs

**TROUBLESHOOTING.md:**
- Error → Solutions format
- Include exact error messages
- Provide copy-paste commands
- Group by tool/service

**POST_INSTALL.md:**
- Configuration steps only
- Include verification commands
- Link to official docs

**Code Examples:**
Always use fenced code blocks with language:
```bash
# Do this
aws configure sso
```

### Testing Requirements

Before submitting PR:
```bash
# Validate shell scripts
shellcheck setup.sh verify.sh refresh.sh lib/*.sh

# Validate Brewfile
brew bundle check --file=config/Brewfile

# Test verification
./verify.sh

# Test idempotency
./setup.sh --verify-only
```

### Commit Messages

Format: `<type>: <description>`

Types: feat, fix, docs, refactor, test, chore

Examples:
- `feat: add dbt-postgres to uv tools`
- `fix: resolve npm permission errors`
- `docs: update AWS SSO configuration`

### Configuration Files

**Brewfile:**
- Group by category with comments
- One package per line
- Casks at end

**List files (npm-global.txt, uv-tools.txt, vscode-extensions.txt):**
- One item per line
- No comments
- Alphabetically sorted

### State Management

- Track all phases in `.state/install.state`
- Support resume from any checkpoint
- Log all state transitions
- Use `start_phase`, `complete_phase`, `fail_phase`

### Claude Integration

Format errors for Claude with full context:
```bash
"Mac setup script error:
Command: $cmd
Error: $error_msg
Provide fix."
```

### Verification

Always verify after changes:
```bash
# Check what's installed
./verify.sh

# Test resume capability
# (interrupt setup.sh and run with --resume)

# Test on clean environment if possible
```

## Common Patterns

**Package installation phase:**
```bash
phase_install_packages() {
    if is_phase_completed "phase_name"; then
        print_info "Already installed, skipping"
        return 0
    fi

    start_phase "phase_name"

    while IFS= read -r package; do
        [[ -z "$package" ]] && continue
        [[ "$package" =~ ^#.*$ ]] && continue

        run_with_claude_help "install_cmd $package" "Install $package"
    done < config/packages.txt

    complete_phase "phase_name"
}
```

**Verification check:**
```bash
check_package() {
    local package="$1"
    ((TOTAL++))

    if command_exists "$package"; then
        print_success "$package"
        ((PASSED++))
        return 0
    else
        print_error "$package (NOT INSTALLED)"
        FAILED_ITEMS+=("$package")
        ((FAILED++))
        return 1
    fi
}
```

## Anti-Patterns

Avoid:
- Silent failures
- Unclear error messages
- Deep nesting (> 3 levels)
- Functions > 50 lines
- Commands without error handling
- Manual state tracking

## Quality Checklist

Before committing:
- [ ] shellcheck passes
- [ ] Brewfile validates
- [ ] verify.sh passes
- [ ] Documentation updated
- [ ] Commit message follows convention
- [ ] Idempotent (can run multiple times)
- [ ] Resume capability works
