# Mac Data Engineering Setup - Brook AI

Opinionated Mac setup for data engineering with Claude-guided installation assistance.

## Quick Start

```bash
# Clone repository
git clone https://github.com/brook-ai/mac-data-engineering-setup.git
cd mac-data-engineering-setup

# Run setup
./setup.sh

# Verify installation
./verify.sh
```

## What Gets Installed

### Data Platform & Cloud (7 packages)
- **awscli** - AWS command line interface
- **snowflake-cli** - Modern Snowflake CLI
- **snowsql** - Traditional Snowflake CLI
- **terraform** - Infrastructure as code
- **ansible** - Configuration management
- **rclone** - Cloud storage sync
- **taws** - AWS session management

### Data Tools (3 packages)
- **duckdb** - In-process analytical database
- **postgresql@16** - Local Postgres development
- **jq** - JSON processor for API/AWS work

### Kubernetes & Containers (3 packages)
- **kubectl** - Kubernetes CLI
- **helm** - Kubernetes package manager
- **Docker Desktop** ⚠️ Manual install required

### Python Ecosystem (3 packages)
- **python@3.13** - Latest Python
- **uv** - Fast Python package manager
- **ruff** - Python linter/formatter (via uv)

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

### npm Global Packages (3)
- **markdownlint-cli2** - Markdown linting
- **prettier** - Code formatter
- **sql-formatter** - SQL formatting

### VS Code Extensions (21)
Python, Go, Rust, Kubernetes, Docker, MongoDB, AWS, YAML, ESLint, and more.

## Features

**Claude Error Assistance**
When errors occur during installation, the script can ask Claude for help and apply suggested fixes.

**Resume Capability**
Interrupted installations can be resumed from the last checkpoint with `./setup.sh --resume`.

**State Tracking**
Installation progress is tracked in `.state/install.state` for reliable resume.

**Idempotent**
Safe to run multiple times - skips already installed packages.

**Verification**
Comprehensive verification script checks all installations and reports status.

**Update Support**
`./refresh.sh` pulls latest changes and updates all packages.

## Usage

### Interactive Installation (Recommended)
```bash
./setup.sh
```

### Automated Installation
```bash
./setup.sh --auto
```

### Resume Interrupted Installation
```bash
./setup.sh --resume
```

### Verify Installation
```bash
./verify.sh
```

### Update Environment
```bash
./refresh.sh
```

### Reset State
```bash
./setup.sh --reset
```

### Debug Mode
```bash
./setup.sh --debug
```

## Manual Installations Required

**Docker Desktop**
Not available via Homebrew. Download from: https://www.docker.com/products/docker-desktop

**DBT**
Install per-project or as global tool:
```bash
uv tool install dbt-snowflake
```

## Post-Installation Configuration

After running setup, configure these services (see [POST_INSTALL.md](POST_INSTALL.md)):

1. **AWS CLI** - Configure SSO or credentials
2. **GitHub** - Authenticate CLI
3. **Snowflake** - Add connection profiles
4. **Docker Desktop** - Install and sign in

## Version Strategy

**Latest Stable** - No version pinning. All packages install the latest stable release.

This simplifies maintenance and ensures you have recent security patches and features. If you need specific versions, pin them in your project-level dependency files.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues and solutions:
- Homebrew installation fails
- npm permission errors
- Package conflicts
- Network/proxy issues
- VS Code CLI not found

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Branch workflow
- Commit conventions
- Testing requirements
- Pull request process

## Repository Structure

```
mac-data-engineering-setup/
├── setup.sh              # Main installation script
├── verify.sh             # Verification script
├── refresh.sh            # Update script
├── lib/                  # Shared functions
│   ├── common.sh         # Utilities
│   ├── logger.sh         # Logging
│   ├── state.sh          # State management
│   └── claude-helper.sh  # Claude integration
├── config/               # Package manifests
│   ├── Brewfile          # Homebrew packages
│   ├── npm-global.txt    # npm packages
│   ├── uv-tools.txt      # uv tools
│   ├── vscode-extensions.txt
│   └── shell/
│       └── zshrc-snippet.sh
└── docs/
    └── notion/           # Notion-formatted guides
```

## Files Generated During Setup

- `.state/install.state` - Installation progress
- `.state/checkpoint.txt` - Last checkpoint
- `setup.log` - Installation log
- `refresh.log` - Update log

## Links

- [Brook AI Internal Docs](https://www.notion.so)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Post-Install Configuration](POST_INSTALL.md)
- [Contributing Guide](CONTRIBUTING.md)

## License

Internal use only - Brook AI Data Engineering Team
