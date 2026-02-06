# Mac Setup Guide - Quick Start

Opinionated Mac setup for data engineering at Brook AI with Claude-guided installation.

---

## Prerequisites

✅ **Required:**
- macOS 12.0 or later
- Admin access to your Mac
- Internet connection
- Terminal access

⚠️ **Recommended:**
- Fresh macOS installation or clean user account
- Backup of important data
- 30-60 minutes for initial setup

---

## Installation

### 1. Clone Repository

```bash
cd ~/Repos  # or your preferred location
git clone https://github.com/Brookai/mac-data-engineering-setup.git
cd mac-data-engineering-setup
```

### 2. Run Setup

**Interactive Mode (Recommended)**
```bash
./setup.sh
```

The script will:
- Check system requirements
- Install Homebrew
- Install all packages from Brewfile
- Install npm, uv, and VS Code packages
- Configure shell
- Create ~/Repos directory

**Automated Mode**
```bash
./setup.sh --auto
```
Skips all confirmations (use for unattended installation)

### 3. Verify Installation

```bash
./verify.sh
```

Expected output:
```
✓ ansible (2.19.0)
✓ awscli (2.32.33)
✓ duckdb (1.2.0)
...
Summary: 45/47 packages installed (96%)
```

### 4. Restart Terminal

```bash
# Either quit and reopen terminal
# Or reload shell configuration
source ~/.zshrc
```

---

## What Gets Installed

### Data Platform & Cloud (7 packages)

- **awscli** - AWS command line interface
- **snowflake-cli** - Modern Snowflake CLI
- **snowsql** - Traditional Snowflake CLI (cask)
- **terraform** - Infrastructure as code
- **ansible** - Configuration management
- **rclone** - Cloud storage sync
- **taws** - AWS session management helper

### Data Tools (3 packages)

- **duckdb** - In-process analytical database
- **postgresql@16** - Local Postgres for development
- **jq** - JSON processor (essential for AWS/API work)

### Kubernetes & Containers (3 packages)

- **kubectl** - Kubernetes command line
- **helm** - Kubernetes package manager
- **Docker Desktop** - Container runtime (manual install required)

### Python Ecosystem (3 packages)

- **python@3.13** - Latest Python version
- **uv** - Fast Python package manager
- **ruff** - Python linter & formatter (installed via uv)

### Development Tools (5 packages)

- **git** - Version control
- **gh** - GitHub CLI
- **node** - JavaScript runtime
- **tree** - Directory visualization
- **coreutils** - GNU utilities

### Applications (5 casks)

- **Claude** - AI assistant
- **VS Code** - Code editor
- **iTerm2** - Terminal emulator
- **GitHub Desktop** - Git GUI
- **SnowSQL** - Snowflake GUI

### Additional Packages

**npm global (3):**
- markdownlint-cli2
- prettier
- sql-formatter

**uv tools (1):**
- ruff

**VS Code extensions (22):**
Python, Go, Rust, Kubernetes, Docker, MongoDB, AWS, YAML, and more

---

## Features

### 🤖 Claude Error Assistance

When errors occur, the script can ask Claude for help:
```
ERROR: Failed to install terraform
Asking Claude for help...

Claude suggests: brew tap hashicorp/tap && brew install hashicorp/tap/terraform

Try fix? (y/n/skip)
```

### ⏸️ Resume Capability

Interrupted installations resume from checkpoint:
```bash
./setup.sh --resume
```

### 📊 State Tracking

Progress tracked in `.state/install.state`:
```
check_system=completed
install_homebrew=completed
install_brew_packages=in_progress
```

### ✅ Verification

Comprehensive checks for all installations:
```bash
./verify.sh
```

### 🔄 Updates

Pull latest changes and update packages:
```bash
./refresh.sh
```

---

## Next Steps

After installation completes:

### 1. Configure Services

See [Post-Install Configuration](POST_INSTALL.md) for detailed steps:

**AWS CLI**
```bash
aws configure sso
```

**GitHub**
```bash
gh auth login
```

**Snowflake**
```bash
snow connection add
```

### 2. Manual Installations

**Docker Desktop**
Download from: https://www.docker.com/products/docker-desktop

**DBT (per project)**
```bash
uv tool install dbt-snowflake
```

### 3. Clone Repositories

```bash
cd ~/Repos
gh repo clone brook-ai/data-platform
gh repo clone brook-ai/dbt-models
gh repo clone brook-ai/dagster-pipelines
```

---

## Troubleshooting

### Homebrew Installation Fails

```bash
# Check network connection
ping github.com

# Try alternate DNS
networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4

# Disable VPN temporarily
```

### npm Permission Errors

```bash
# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

### VS Code 'code' Command Not Found

1. Open VS Code
2. Press Cmd+Shift+P
3. Type "Shell Command: Install 'code' command in PATH"
4. Select and run

### Installation Hangs

```bash
# Check logs
tail -f setup.log

# Cancel and resume
# Press Ctrl+C
./setup.sh --resume
```

For more issues, see [TROUBLESHOOTING.md](../../TROUBLESHOOTING.md)

---

## Commands Reference

```bash
# Run setup
./setup.sh                    # Interactive
./setup.sh --auto            # Automated
./setup.sh --resume          # Resume interrupted
./setup.sh --debug           # Debug mode

# Verification
./verify.sh                  # Check installations

# Updates
./refresh.sh                 # Update all packages

# State management
./setup.sh --reset           # Reset and start over
cat .state/install.state     # View progress
```

---

## Getting Help

**Documentation:**
- [Full Guide](detailed-guide.md)
- [Troubleshooting](../../TROUBLESHOOTING.md)
- [Post-Install Configuration](../../POST_INSTALL.md)
- [Contributing](../../CONTRIBUTING.md)

**Team Support:**
- Slack: #data-engineering
- Repository: https://github.com/Brookai/mac-data-engineering-setup

---

> **Note:** This is an internal tool for Brook AI data engineering team. Installation takes 15-30 minutes depending on your internet connection.
