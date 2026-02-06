# Mac Data Engineering Setup - Brook AI

Opinionated Mac setup for data engineering with Claude-guided installation assistance.

## Quick Start

```bash
# Clone repository
git clone https://github.com/Brookai/mac-data-engineering-setup.git
cd mac-data-engineering-setup

# Run setup
./setup.sh

# Verify installation
./verify.sh
```

## Local Testing

Before deploying to team, test the setup:

### 1. Dry Run (Recommended First Step)

```bash
cd ~/mac-data-engineering-setup

# Check what's currently installed
./verify.sh

# Test without installing anything
./setup.sh --verify-only
```

### 2. Test Individual Components

```bash
# Test Brewfile syntax
brew bundle check --file=config/Brewfile

# Test shell scripts
shellcheck setup.sh verify.sh refresh.sh lib/*.sh

# Test state management
cat .state/install.state  # if exists from previous run
```

### 3. Full Installation Test

**Option A: On your current machine (safe - skips already installed)**
```bash
./setup.sh
```
This is safe because:
- Idempotent (won't reinstall existing packages)
- State tracking prevents duplicate work
- Can resume if interrupted

**Option B: Fresh environment (recommended for validation)**

Create test user account:
```bash
# Create test user
sudo dscl . -create /Users/testuser
sudo dscl . -create /Users/testuser UserShell /bin/zsh
sudo dscl . -create /Users/testuser RealName "Test User"
sudo dscl . -create /Users/testuser UniqueID 1001
sudo dscl . -create /Users/testuser PrimaryGroupID 20
sudo dscl . -create /Users/testuser NFSHomeDirectory /Users/testuser
sudo dscl . -passwd /Users/testuser testpass

# Create home directory
sudo createhomedir -c -u testuser

# Switch to test user, clone repo, run setup
# When done, delete: sudo dscl . -delete /Users/testuser
```

Or use VM:
- UTM (free): https://mac.getutm.app/
- Parallels Desktop
- VMware Fusion

### 4. Test Resume Capability

```bash
# Start installation
./setup.sh

# Interrupt with Ctrl+C during a phase

# Resume
./setup.sh --resume

# Verify state tracking
cat .state/install.state
```

### 5. Test Error Handling

```bash
# Intentionally cause error (e.g., bad package name)
echo 'brew "nonexistent-package-xyz"' >> config/Brewfile

# Run setup - should offer Claude help or skip
./setup.sh

# Restore Brewfile
git checkout config/Brewfile
```

### 6. Test Update Workflow

```bash
# Make a change
echo '# Test comment' >> config/Brewfile

# Commit change
git add config/Brewfile
git commit -m "test: add comment"

# Test refresh
./refresh.sh

# Should pull changes and update packages
```

### 7. Verify Documentation

Check all documentation:
```bash
# Verify links work
grep -r "http" *.md docs/

# Check code blocks have language tags
grep -r '```$' *.md docs/

# Verify examples are accurate
# Manually review each .md file
```

### 8. Test on Colleague's Machine (Optional)

Ask a teammate to:
1. Clone the repo
2. Run `./setup.sh`
3. Report any errors or unclear steps
4. Verify their environment works

### Common Test Scenarios

**Scenario 1: Fresh macOS**
- Clone repo
- Run setup.sh
- Verify all 47 packages install
- Test each service (AWS, Snowflake, GitHub)

**Scenario 2: Partially configured Mac**
- Some tools already installed
- Run setup.sh
- Verify it skips installed packages
- Completes missing installations

**Scenario 3: Interrupted installation**
- Start setup.sh
- Cancel mid-way (Ctrl+C)
- Run setup.sh --resume
- Verify it continues from checkpoint

**Scenario 4: Failed package installation**
- Introduce error (bad package name)
- Run setup.sh
- Verify error handling and Claude help
- Fix and complete installation

### Validation Checklist

Before pushing to GitHub:
- [ ] `./verify.sh` passes 100%
- [ ] All shell scripts pass `shellcheck`
- [ ] Brewfile validates with `brew bundle check`
- [ ] Documentation links work
- [ ] Code examples are accurate
- [ ] Tested on fresh environment or test user
- [ ] Resume capability works
- [ ] Error handling provides helpful guidance
- [ ] No hardcoded credentials or secrets
- [ ] .gitignore excludes generated files

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

- [Repository](https://github.com/Brookai/mac-data-engineering-setup)
- [Brook AI Internal Docs](https://www.notion.so)
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Post-Install Configuration](POST_INSTALL.md)
- [Contributing Guide](CONTRIBUTING.md)

## License

Internal use only - Brook AI Data Engineering Team
