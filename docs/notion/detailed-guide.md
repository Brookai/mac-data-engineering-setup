# Mac Data Engineering Setup - Detailed Guide

Complete guide for setting up a data engineering Mac environment at Brook AI.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Installation Process](#installation-process)
4. [Package Descriptions](#package-descriptions)
5. [Configuration](#configuration)
6. [Workflows](#workflows)
7. [Maintenance](#maintenance)
8. [Troubleshooting](#troubleshooting)

---

## Overview

### Purpose

This repository provides an opinionated, reproducible setup for data engineering work at Brook AI. It installs and configures:
- Data platform tools (Snowflake, AWS, Terraform)
- Python ecosystem (uv, ruff)
- Container orchestration (Kubernetes, Docker)
- Development tools (VS Code, GitHub CLI)

### Design Principles

**Reproducibility**
Every team member gets the same environment configuration.

**Automation**
One command installs everything. Errors get Claude assistance.

**Maintainability**
Version control enables sharing improvements and troubleshooting.

**Resumability**
Interrupted installations resume from checkpoint.

**Idempotency**
Safe to run multiple times. Skips completed steps.

### Version Strategy

**Latest Stable** - No version pinning in setup scripts.

Rationale:
- Simpler maintenance
- Automatic security updates
- Consistent team environment
- Pin versions in project files, not system setup

---

## Architecture

### Directory Structure

```
mac-data-engineering-setup/
├── setup.sh              # Main installation orchestrator
├── verify.sh             # Installation verification
├── refresh.sh            # Update all packages
│
├── lib/                  # Shared libraries
│   ├── common.sh         # Utility functions
│   ├── logger.sh         # Logging utilities
│   ├── state.sh          # State management
│   └── claude-helper.sh  # Claude CLI integration
│
├── config/               # Package manifests
│   ├── Brewfile          # Homebrew packages
│   ├── npm-global.txt    # npm global packages
│   ├── uv-tools.txt      # uv Python tools
│   ├── vscode-extensions.txt  # VS Code extensions
│   └── shell/
│       └── zshrc-snippet.sh   # Shell customizations
│
├── .state/               # Generated during setup
│   ├── install.state     # Phase completion status
│   └── checkpoint.txt    # Last checkpoint
│
└── docs/
    └── notion/           # Notion-formatted guides
```

### Installation Phases

1. **System Check** - Verify macOS version, permissions
2. **Homebrew** - Install/update package manager
3. **Brew Packages** - Install tools from Brewfile
4. **npm Packages** - Install global npm packages
5. **uv Tools** - Install Python tools via uv
6. **VS Code Extensions** - Install editor extensions
7. **Shell Config** - Add customizations to ~/.zshrc
8. **Directories** - Create ~/Repos

Each phase:
- Checks if already completed (skip if yes)
- Updates state to "in_progress"
- Executes installation
- Marks "completed" on success
- Enables resume on failure

### State Management

State tracked in `.state/install.state`:
```
check_system=completed
install_homebrew=completed
install_brew_packages=in_progress
install_npm_packages=pending
...
```

Benefits:
- Resume from any point
- Progress visibility
- Debugging failed installations
- Audit trail

---

## Installation Process

### Prerequisites Check

Script validates:
- macOS operating system
- Home directory writable
- Terminal has full disk access (for some operations)

### Homebrew Installation

If not present:
1. Downloads Homebrew install script
2. Executes with user confirmation
3. Adds to PATH

If present:
1. Updates Homebrew
2. Upgrades outdated formulae (optional)

### Package Installation

**Brewfile Installation:**
```bash
brew bundle --file=config/Brewfile
```

Installs:
- Formulae (CLI tools)
- Casks (GUI applications)
- Taps (third-party repositories)

**npm Global Packages:**
```bash
npm install -g package-name
```

Installs from `config/npm-global.txt`:
- markdownlint-cli2
- prettier
- sql-formatter

**uv Tools:**
```bash
uv tool install tool-name
```

Installs from `config/uv-tools.txt`:
- ruff (Python linter/formatter)

**VS Code Extensions:**
```bash
code --install-extension extension-id
```

Installs 21 extensions for Python, Docker, Kubernetes, etc.

### Shell Configuration

Adds to `~/.zshrc`:
- SnowSQL PATH
- AWS CloudFormation LSP fix alias
- Marker comment for identification

Idempotent - checks for marker before adding.

### Directory Creation

Creates `~/Repos` for repositories if not present.

---

## Package Descriptions

### Data Platform Tools

**awscli**
- AWS command line interface
- Use for S3, EC2, Lambda, CloudFormation, etc.
- Configure with `aws configure sso`

**snowflake-cli**
- Modern Snowflake CLI with better UX
- Use for connections, queries, warehouses
- Configure with `snow connection add`

**snowsql**
- Traditional Snowflake CLI (GUI application)
- SQL worksheet interface
- PATH added automatically

**terraform**
- Infrastructure as code
- Define AWS resources declaratively
- Use with `.tf` files

**ansible**
- Configuration management
- Automate server setup
- Use playbooks for repetitive tasks

**rclone**
- Cloud storage sync (S3, GCS, Azure)
- Mount cloud storage as filesystem
- Use for bulk transfers

**taws**
- AWS session management helper
- Simplifies assuming roles
- Integration with profiles

### Data Tools

**duckdb**
- In-process analytical SQL database
- Fast aggregations on local files
- Use for ad-hoc analysis

**postgresql@16**
- Local Postgres server
- Use for development/testing
- Start with `brew services start postgresql@16`

**jq**
- JSON processor
- Parse AWS CLI output
- Essential for scripting

### Kubernetes Tools

**kubectl**
- Kubernetes command line
- Manage clusters, pods, services
- Configure with kubeconfig

**helm**
- Kubernetes package manager
- Install charts (pre-configured apps)
- Manage releases

### Python Ecosystem

**python@3.13**
- Latest Python version
- Installed via Homebrew
- Default for new projects

**uv**
- Fast Python package manager
- Replaces pip + virtualenv
- Built in Rust for speed

Commands:
```bash
uv init project         # Create project
uv add package         # Add dependency
uv run script.py       # Run in venv
uv tool install tool   # Install global tool
```

**ruff**
- Python linter + formatter
- Replaces black, flake8, isort
- Extremely fast (Rust-based)

### Development Tools

**git**
- Version control
- Use with GitHub, GitLab, etc.
- Configure with user.name and user.email

**gh**
- GitHub CLI
- Create PRs, issues from terminal
- Clone repos, view workflows

**node**
- JavaScript runtime
- Required for npm packages
- Used by VS Code extensions

**tree**
- Display directory structure
- Use for documentation
- Example: `tree -L 2 -d`

**coreutils**
- GNU utilities (gdate, etc.)
- Linux compatibility
- Better than BSD versions

### Applications

**Claude**
- AI assistant
- Use for coding help
- Error troubleshooting

**VS Code**
- Code editor
- Extensions for all languages
- Integrated terminal

**iTerm2**
- Terminal emulator
- Better than default Terminal.app
- Supports split panes, search

**GitHub Desktop**
- Git GUI
- Visual diff/merge
- Easier for beginners

**SnowSQL**
- Snowflake GUI client
- SQL worksheet
- Query history

---

## Configuration

See [POST_INSTALL.md](../../POST_INSTALL.md) for complete configuration guides.

### AWS CLI

```bash
# Configure SSO
aws configure sso

# Test
aws sts get-caller-identity
```

### Snowflake

```bash
# Add connection
snow connection add

# Test
snow connection test
```

### GitHub

```bash
# Authenticate
gh auth login

# Test
gh repo list
```

### Docker Desktop

Manual installation required:
1. Download from docker.com
2. Install .dmg
3. Launch and configure

---

## Workflows

### Starting New Python Project

```bash
cd ~/Repos
uv init my-project
cd my-project

# Add dependencies
uv add pandas snowflake-connector-python

# Add dev dependencies
uv add --dev pytest ruff

# Run code
uv run python script.py

# Run tests
uv run pytest
```

### Installing DBT

```bash
# Install as global tool
uv tool install dbt-snowflake

# Or per-project
cd ~/Repos/dbt-project
uv add dbt-snowflake
uv run dbt run
```

### Working with Snowflake

```bash
# CLI
snow sql -q "SELECT * FROM table LIMIT 10"

# SnowSQL GUI
snowsql -c default

# Python
uv run python -c "
import snowflake.connector
conn = snowflake.connector.connect(
    account='brook_ai',
    user='your.name@brook.ai',
    authenticator='externalbrowser'
)
"
```

### Deploying Infrastructure

```bash
cd ~/Repos/terraform-infra

# Initialize
terraform init

# Plan changes
terraform plan

# Apply
terraform apply
```

---

## Maintenance

### Updating Packages

```bash
# Update all
./refresh.sh

# Update specific category
brew upgrade                    # Homebrew
npm update -g package          # npm
uv tool upgrade tool           # uv
```

### Adding New Package

1. Add to appropriate config file
2. Test manually
3. Update verify.sh (optional)
4. Commit and PR

Example - Add new Homebrew package:
```bash
# Edit config/Brewfile
echo 'brew "new-package"' >> config/Brewfile

# Test
brew bundle --file=config/Brewfile

# Verify
./verify.sh
```

### Removing Package

1. Remove from config file
2. Uninstall manually
3. Update docs
4. Commit and PR

### Sharing Improvements

```bash
git checkout -b add-new-tool
# Make changes
git commit -m "feat: add new-tool to Brewfile"
git push origin add-new-tool
gh pr create
```

---

## Troubleshooting

### Installation Fails

```bash
# Check logs
cat setup.log
tail -f setup.log   # Watch in real-time

# Reset and retry
./setup.sh --reset
./setup.sh

# Debug mode
./setup.sh --debug
```

### Partial Installation

```bash
# Resume from checkpoint
./setup.sh --resume

# Or start specific phase over
# Edit .state/install.state
# Change phase status to "pending"
./setup.sh
```

### Verification Failures

```bash
# See what failed
./verify.sh

# Fix specific package
brew install missing-package

# Re-verify
./verify.sh
```

### Command Not Found After Install

```bash
# Reload shell
source ~/.zshrc

# Check PATH
echo $PATH

# Find command location
which command-name

# Add to PATH if needed
echo 'export PATH="/path/to/bin:$PATH"' >> ~/.zshrc
```

### Claude Error Help Not Working

Requirements:
1. Claude desktop app installed
2. Claude CLI in PATH
3. Interactive mode (not --auto)

If not working:
- Install Claude: `brew install --cask claude`
- Verify: `which claude`
- Run setup without --auto

### Performance Issues

Slow installation causes:
- Slow internet (downloading packages)
- Compiling from source (use --force-bottle)
- Large VS Code extensions

Solutions:
```bash
# Use bottles (pre-compiled)
brew install --force-bottle package

# Skip VS Code extensions temporarily
# Remove from vscode-extensions.txt

# Run in background
nohup ./setup.sh --auto > setup.out 2>&1 &
```

---

## Advanced Topics

### Custom Configuration

Create local customizations in `~/.zshrc.local`:
```bash
# Add to ~/.zshrc
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
```

### Multiple Environments

Use separate AWS/Snowflake profiles:
```bash
# AWS
export AWS_PROFILE=staging
aws s3 ls

# Snowflake
snow sql -c production -q "SELECT 1"
```

### Team Customizations

Fork repository and add team-specific tools:
```bash
# Add to Brewfile
brew "team-specific-tool"

# Commit to team branch
git checkout -b team/data-engineering
git push origin team/data-engineering
```

---

## Resources

**Documentation:**
- [README](../../README.md)
- [Troubleshooting](../../TROUBLESHOOTING.md)
- [Post-Install](../../POST_INSTALL.md)
- [Contributing](../../CONTRIBUTING.md)

**External:**
- [Homebrew Docs](https://docs.brew.sh/)
- [uv Docs](https://github.com/astral-sh/uv)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/)
- [Snowflake CLI Docs](https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/)

**Support:**
- Slack: #data-engineering
- GitHub: https://github.com/brook-ai/mac-data-engineering-setup
