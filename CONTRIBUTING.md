# Contributing to Mac Data Engineering Setup

Guide for Brook AI team members contributing to this repository.

## Overview

This repository is a living configuration that evolves with our data engineering stack. All team members are encouraged to contribute improvements, new tools, and fixes.

## Workflow

### 1. Create Feature Branch

```bash
cd ~/Repos/mac-data-engineering-setup
git checkout main
git pull origin main
git checkout -b your-feature-branch
```

Branch naming conventions:
- `add-<tool>` - Adding new tool/package
- `fix-<issue>` - Fixing a bug or issue
- `update-<component>` - Updating configuration
- `docs-<topic>` - Documentation changes

Examples:
- `add-dbt-postgres`
- `fix-npm-permissions`
- `update-snowflake-config`
- `docs-troubleshooting`

### 2. Make Changes

#### Adding Homebrew Package

Edit `config/Brewfile`:

```ruby
# Add to appropriate section
brew "your-new-package"

# Or for cask
cask "your-new-app"
```

Test locally:
```bash
brew bundle check --file=config/Brewfile
brew bundle --file=config/Brewfile
```

#### Adding npm Package

Edit `config/npm-global.txt`:

```
your-new-package
```

#### Adding uv Tool

Edit `config/uv-tools.txt`:

```
your-new-tool
```

#### Adding VS Code Extension

Edit `config/vscode-extensions.txt`:

```
publisher.extension-name
```

Find extension ID:
```bash
code --list-extensions
```

#### Updating Documentation

- **README.md** - Overview and quick start
- **TROUBLESHOOTING.md** - Add errors and solutions
- **POST_INSTALL.md** - Configuration steps for new tools
- **docs/notion/** - Notion-formatted guides

### 3. Test Changes

```bash
# Test setup script
./setup.sh --verify-only

# Or run full setup in safe mode (dry run)
# Test on a VM or fresh user account if possible

# Verify changes
./verify.sh
```

### 4. Update Documentation

When adding new tools, update:
- README.md "What Gets Installed" section
- POST_INSTALL.md if tool needs configuration
- TROUBLESHOOTING.md for known issues

### 5. Commit Changes

Use conventional commit format:

```bash
git add .
git commit -m "<type>: <description>"
```

**Commit types:**
- `feat:` - New feature (new tool, capability)
- `fix:` - Bug fix (error resolution, correction)
- `docs:` - Documentation only
- `refactor:` - Code refactoring (no functional change)
- `test:` - Adding tests
- `chore:` - Maintenance (dependency updates)
- `perf:` - Performance improvement
- `ci:` - CI/CD changes

**Examples:**
```bash
git commit -m "feat: add dbt-postgres to uv tools"
git commit -m "fix: resolve npm permission issues in setup script"
git commit -m "docs: update AWS SSO configuration steps"
git commit -m "refactor: extract Claude helper functions"
git commit -m "chore: update Homebrew packages to latest"
```

**Commit message guidelines:**
- Use imperative mood ("add" not "added")
- Capitalize first letter
- No period at end
- Keep under 72 characters
- Reference issues: "fix: resolve #123"

### 6. Push and Create PR

```bash
# Push to GitHub
git push origin your-feature-branch

# Create PR
gh pr create \
  --title "Add dbt-postgres support" \
  --body "Adds dbt-postgres as uv tool for local Postgres development.

Changes:
- Added dbt-postgres to config/uv-tools.txt
- Updated POST_INSTALL.md with configuration steps
- Added troubleshooting section for dbt connection issues

Testing:
- Verified installation on macOS 14.2
- Tested dbt init and dbt debug commands
- Confirmed no conflicts with existing tools"
```

### 7. Request Review

Tag relevant reviewers:
```bash
# Request review from specific person
gh pr edit --add-reviewer @teammate

# Request review from team
gh pr edit --add-reviewer @brook-ai/data-engineering
```

### 8. Address Feedback

```bash
# Make changes based on review
git add .
git commit -m "refactor: address PR feedback"
git push origin your-feature-branch
```

### 9. Merge PR

After approval:
1. Squash and merge (preferred)
2. Delete branch after merge
3. Pull latest main locally

```bash
# After merge
git checkout main
git pull origin main
git branch -d your-feature-branch
```

## Testing Requirements

### Before Submitting PR

1. **Syntax validation**
   ```bash
   # Check Brewfile syntax
   brew bundle check --file=config/Brewfile

   # Verify shell scripts (if modified)
   shellcheck setup.sh verify.sh refresh.sh lib/*.sh
   ```

2. **Dry run verification**
   ```bash
   ./setup.sh --verify-only
   ```

3. **Full verification**
   ```bash
   ./verify.sh
   ```

4. **Documentation check**
   - All links work
   - Code blocks have proper syntax highlighting
   - Examples are accurate

### Recommended Testing

For significant changes, test on:
- Fresh macOS installation (VM)
- Colleague's machine (with permission)
- Different macOS versions

## Code Style

### Bash Scripts

```bash
# Use set -e for error propagation
set -e

# Validate inputs
if [[ -z "$VAR" ]]; then
    print_error "VAR is required"
    exit 1
fi

# Use functions for reusability
do_something() {
    local arg="$1"
    # function body
}

# Clear error messages
print_error "Failed to install $package: $error_msg"

# Use existing helper functions
run_with_claude_help "command" "description"
```

### Documentation

```markdown
# Use clear hierarchy
## Level 2
### Level 3

# Code blocks with language
```bash
command here
```

# Clear examples
Good:
```bash
aws configure sso
```

Bad:
```
aws configure sso
```

# Tables for comparisons
| Tool | Purpose | Install Method |
|------|---------|----------------|
| dbt  | Transforms | uv tool |
```

## Common Changes

### Adding Tool to Existing Package Manager

1. Add to appropriate config file
2. Test installation manually
3. Update README.md
4. Add to verify.sh (optional)
5. Commit and PR

### Adding New Package Manager

1. Create config file in `config/`
2. Add phase to `setup.sh`
3. Add check to `verify.sh`
4. Add update to `refresh.sh`
5. Update documentation
6. Test thoroughly

### Fixing Bug in Script

1. Identify root cause
2. Add logging if needed
3. Fix issue
4. Test fix
5. Update TROUBLESHOOTING.md
6. Commit with clear message

### Updating Documentation

1. Make changes
2. Check for broken links
3. Verify examples work
4. Update related docs
5. Commit

## Pull Request Template

Use this template for PR descriptions:

```markdown
## Summary
Brief description of changes

## Changes
- Bullet list of specific changes
- Include file paths

## Testing
- How changes were tested
- macOS version
- Any edge cases covered

## Documentation
- [ ] README.md updated
- [ ] TROUBLESHOOTING.md updated (if applicable)
- [ ] POST_INSTALL.md updated (if applicable)

## Checklist
- [ ] Tested locally
- [ ] All scripts pass shellcheck
- [ ] verify.sh passes
- [ ] Documentation updated
- [ ] Commit messages follow convention
```

## Maintenance Tasks

### Regular Updates

**Monthly:**
- Review and update package versions
- Test setup on latest macOS
- Update troubleshooting guide

**Quarterly:**
- Audit installed packages (remove unused)
- Review and update documentation
- Solicit team feedback

**As Needed:**
- Fix reported issues
- Add requested tools
- Update for new team members

### Version Management

We use **latest stable** strategy:
- No version pinning in Brewfile
- Trust Homebrew's stable channel
- Pin versions in project files, not setup

Exceptions:
- Known breaking changes
- Compatibility requirements
- Team standardization needs

## Communication

### When to Notify Team

**Always:**
- Breaking changes (tool removal, major version)
- New required configurations
- Changes to workflow

**Usually:**
- New tools added
- Significant bug fixes
- Documentation improvements

**Methods:**
- Slack #data-engineering channel
- PR description
- Update email (for major changes)

## Getting Help

**Questions about contributing:**
- Ask in #data-engineering
- Review existing PRs for examples
- Tag maintainer in PR

**Technical issues:**
- Check TROUBLESHOOTING.md
- Search closed issues/PRs
- Ask in Slack

**Unclear requirements:**
- Discuss in issue/PR comments
- Ask in team meeting
- Request clarification from requester

## Repository Maintainers

Current maintainers:
- @rob-ford (owner)
- @data-engineering-team

Maintainer responsibilities:
- Review PRs within 2 business days
- Keep main branch stable
- Update documentation
- Manage issues
- Communicate breaking changes

## Claude Code Preferences

This repo includes `.claude/CLAUDE.md` with preferences for AI-assisted contributions:
- Bash scripting conventions
- Documentation style
- Commit message format
- Testing requirements

Claude Code automatically uses these preferences when working in this repo.

## License & Usage

Internal use only - Brook AI Data Engineering Team. Not for public distribution.
