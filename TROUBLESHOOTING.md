# Troubleshooting Guide

Common errors and solutions for Mac data engineering setup.

## Homebrew Issues

### Homebrew Installation Fails

**Error**: `curl: (7) Failed to connect to raw.githubusercontent.com`

**Solutions**:
1. Check network connection
2. Try alternate DNS: `networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4`
3. Check corporate proxy settings
4. Disable VPN temporarily

**Error**: `Permission denied` errors during installation

**Solutions**:
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /usr/local/Cellar /usr/local/Homebrew
sudo chown -R $(whoami) /opt/homebrew  # For Apple Silicon
```

### Package Already Installed but Different Version

**Error**: `Error: <package> is already installed`

**Solutions**:
```bash
# Upgrade to latest
brew upgrade <package>

# Force reinstall
brew reinstall <package>

# Uninstall and reinstall
brew uninstall <package>
brew install <package>
```

### Brew Bundle Fails Partway Through

**Error**: Some packages installed, others failed

**Solutions**:
```bash
# Resume setup (will skip completed phases)
./setup.sh --resume

# Or manually complete bundle
brew bundle --file=config/Brewfile

# Check what failed
brew bundle check --file=config/Brewfile
```

## npm Issues

### npm Permission Denied

**Error**: `EACCES: permission denied, mkdir '/usr/local/lib/node_modules'`

**Solutions**:
```bash
# Fix npm permissions (recommended)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc

# Or use sudo (not recommended)
sudo npm install -g <package>
```

### npm Install Hangs

**Error**: Installation freezes during npm package install

**Solutions**:
```bash
# Clear npm cache
npm cache clean --force

# Use different registry
npm config set registry https://registry.npmjs.org/

# Install with verbose logging
npm install -g <package> --verbose
```

## uv Issues

### uv Tool Install Fails

**Error**: `error: Failed to install tool`

**Solutions**:
```bash
# Update uv first
brew upgrade uv

# Try with verbose output
uv tool install <tool> --verbose

# Check if tool is already installed
uv tool list
```

### Python Version Conflicts

**Error**: `error: No Python interpreter found`

**Solutions**:
```bash
# Verify Python installation
which python3
python3 --version

# Link Homebrew Python
brew link python@3.13

# Set Python path for uv
export UV_PYTHON=$(which python3)
```

## VS Code Issues

### Code Command Not Found

**Error**: `bash: code: command not found`

**Solutions**:
1. Open VS Code
2. Press Cmd+Shift+P
3. Type "Shell Command: Install 'code' command in PATH"
4. Select and run

Or manually add to PATH:
```bash
echo 'export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Extension Installation Fails

**Error**: `Extension '<extension>' is already installed`

**Solutions**:
```bash
# Force reinstall
code --force --install-extension <extension>

# Uninstall and reinstall
code --uninstall-extension <extension>
code --install-extension <extension>
```

### Extension Marketplace Timeout

**Error**: `connect ETIMEDOUT` when installing extensions

**Solutions**:
1. Check network connection
2. Disable VPN
3. Check firewall settings
4. Try again later (marketplace may be down)

## Git Issues

### Git Clone Fails with SSL Error

**Error**: `SSL certificate problem: unable to get local issuer certificate`

**Solutions**:
```bash
# Temporary fix (not recommended for production)
git config --global http.sslVerify false

# Better: update certificates
brew install ca-certificates

# Or set certificate path
git config --global http.sslCAinfo /usr/local/etc/ca-certificates/cert.pem
```

### Permission Denied (publickey)

**Error**: `Permission denied (publickey)` when cloning

**Solutions**:
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key and add to GitHub
pbcopy < ~/.ssh/id_ed25519.pub
# Go to GitHub Settings -> SSH Keys -> New SSH Key

# Or use HTTPS instead
git clone https://github.com/user/repo.git
```

## Shell Configuration Issues

### Changes Not Taking Effect

**Error**: Added config to ~/.zshrc but changes not visible

**Solutions**:
```bash
# Reload shell configuration
source ~/.zshrc

# Or restart terminal
# Cmd+Q to quit, then reopen
```

### Path Issues After Installation

**Error**: Command installed but not found

**Solutions**:
```bash
# Check PATH
echo $PATH

# Verify where command is installed
which <command>

# Manually add to PATH if needed
echo 'export PATH="/path/to/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## AWS CloudFormation Language Server Issues

**Error**: VS Code AWS CloudFormation extension not working

**Solutions**:
```bash
# Use the provided alias
fix-aws-cf-lsp

# Or manually clear cache
rm -rf "$HOME/Library/Application Support/aws-cloudformation-languageserver/lmdb/"

# Restart VS Code
```

## Docker Issues

### Docker Not Installed

**Error**: `docker: command not found`

**Solution**: Docker Desktop requires manual installation:
1. Download from https://www.docker.com/products/docker-desktop
2. Install the .dmg file
3. Launch Docker Desktop
4. Verify: `docker --version`

### Docker Permission Denied

**Error**: `permission denied while trying to connect to the Docker daemon socket`

**Solutions**:
1. Ensure Docker Desktop is running
2. Check Docker Desktop settings
3. Add user to docker group (not typically needed on Mac)

## Network/Proxy Issues

### Behind Corporate Proxy

**Error**: Downloads fail or timeout

**Solutions**:
```bash
# Set proxy for Homebrew
export ALL_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080

# Set proxy for npm
npm config set proxy http://proxy.company.com:8080
npm config set https-proxy http://proxy.company.com:8080

# Set proxy for git
git config --global http.proxy http://proxy.company.com:8080
```

## State/Resume Issues

### Resume Doesn't Work

**Error**: `./setup.sh --resume` starts from beginning

**Solutions**:
```bash
# Check state file
cat .state/install.state

# If corrupted, reset and restart
./setup.sh --reset
./setup.sh
```

### Want to Start Over

**Solutions**:
```bash
# Reset state and restart
./setup.sh --reset
./setup.sh

# Or manually delete state
rm -rf .state
./setup.sh
```

## Claude CLI Issues

### Claude Command Not Found

**Error**: `claude: command not found` during error assistance

**Solution**: Claude CLI is optional. If not installed, the script will continue without error assistance. To install:
```bash
# Install Claude desktop app
brew install --cask claude

# Claude CLI should be available after app installation
```

## Performance Issues

### Installation Taking Too Long

**Causes**:
- Slow internet connection
- Large packages (VS Code extensions, Xcode tools)
- Homebrew compiling from source

**Solutions**:
```bash
# Run in auto mode to skip confirmations
./setup.sh --auto

# Check what's taking time in logs
tail -f setup.log

# For Homebrew, prefer bottles (pre-compiled)
brew install --force-bottle <package>
```

## Getting Additional Help

If you continue to experience issues:

1. **Check logs**: `cat setup.log` or `cat refresh.log`
2. **Run verify**: `./verify.sh` to see what's missing
3. **Reset and retry**: `./setup.sh --reset && ./setup.sh`
4. **Debug mode**: `./setup.sh --debug` for detailed logging
5. **Ask Claude**: If Claude CLI is available, it will help automatically
6. **Team Slack**: Post in #data-engineering channel
7. **Update repo**: `git pull origin main` to get latest fixes

## Common Commands Reference

```bash
# Check what's installed
brew list                      # Homebrew packages
npm list -g --depth=0         # npm packages
uv tool list                  # uv tools
code --list-extensions        # VS Code extensions

# Update everything
./refresh.sh

# Verify installation
./verify.sh

# View logs
cat setup.log
tail -f setup.log

# Check versions
brew --version
npm --version
uv --version
python3 --version
```
