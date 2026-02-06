# Post-Installation Configuration

Complete these configurations after running `./setup.sh` to fully set up your data engineering environment.

## AWS CLI Configuration

### Option 1: SSO (Recommended for Brook AI)

```bash
# Configure AWS SSO
aws configure sso

# Follow prompts:
# SSO session name: brook-ai
# SSO start URL: https://brook-ai.awsapps.com/start
# SSO region: us-east-1
# SSO registration scopes: sso:account:access
# CLI default client Region: us-east-1
# CLI default output format: json
# CLI profile name: default

# Login
aws sso login --profile default
```

### Option 2: Access Keys (For Service Accounts)

```bash
aws configure

# Enter when prompted:
# AWS Access Key ID: <your-access-key>
# AWS Secret Access Key: <your-secret-key>
# Default region name: us-east-1
# Default output format: json
```

### Verify AWS Configuration

```bash
# Test connection
aws sts get-caller-identity

# Should return your account ID and user/role

# Test S3 access
aws s3 ls
```

### Multiple Profiles

```bash
# Add additional profiles
aws configure sso --profile staging
aws configure sso --profile production

# Use specific profile
aws s3 ls --profile staging

# Set default profile
export AWS_PROFILE=production
```

## Snowflake CLI Configuration

### Add Connection

```bash
# Add new connection
snow connection add

# Follow prompts:
# Name for this connection: default
# Account name: brook_ai
# Username: your.name@brook.ai
# Authenticator (default|externalbrowser|username_password_mfa|oauth|snowflake_jwt): externalbrowser
# Database (optional): analytics
# Schema (optional): core
# Role (optional): data_engineer
# Warehouse (optional): compute_wh
```

### Test Connection

```bash
# Test connection
snow connection test --connection default

# Run query
snow sql -q "SELECT CURRENT_USER(), CURRENT_ROLE()"
```

### Multiple Connections

```bash
# Add production connection
snow connection add --connection-name production
# Account: brook_ai_prod
# ...

# Add staging connection
snow connection add --connection-name staging
# Account: brook_ai_staging
# ...

# Use specific connection
snow sql -c production -q "SHOW DATABASES"
```

## GitHub CLI Configuration

### Authenticate

```bash
# Login to GitHub
gh auth login

# Select:
# ? What account do you want to log into? GitHub.com
# ? What is your preferred protocol for Git operations? SSH
# ? Generate a new SSH key to add to your GitHub account? Yes
# ? Enter a passphrase for your new SSH key (Optional)
# ? Title for your SSH key: Brook AI Mac
# ? How would you like to authenticate GitHub CLI? Login with a web browser

# Follow browser prompt to authenticate
```

### Verify GitHub Configuration

```bash
# Check authentication
gh auth status

# Test GitHub access
gh repo list

# Clone a repo
gh repo clone brook-ai/data-platform
```

### Configure Git

```bash
# Set git user
git config --global user.name "Your Name"
git config --global user.email "your.name@brook.ai"

# Set default branch
git config --global init.defaultBranch main

# Set pull strategy
git config --global pull.rebase true
```

## Docker Desktop Installation

Docker Desktop is not available via Homebrew and must be installed manually.

### Installation Steps

1. Download Docker Desktop from https://www.docker.com/products/docker-desktop
2. Open the downloaded `.dmg` file
3. Drag Docker to Applications folder
4. Launch Docker Desktop
5. Accept license agreement
6. Allow privileged access when prompted
7. Wait for Docker to start (whale icon in menu bar)

### Verify Docker

```bash
# Check Docker version
docker --version

# Test Docker
docker run hello-world

# Check Docker Compose
docker compose version
```

### Docker Configuration

Open Docker Desktop preferences:
- Resources: Adjust CPU/Memory based on your needs
- File Sharing: Ensure `/Users/<your-username>` is shared
- Enable Kubernetes (optional)

## Python Development with uv

### Create New Project

```bash
# Initialize project
cd ~/Repos
uv init my-data-project
cd my-data-project

# Add dependencies
uv add pandas polars snowflake-connector-python

# Add dev dependencies
uv add --dev pytest ruff black

# Run commands in project environment
uv run python script.py
uv run pytest
```

### Install Global Tools

```bash
# Install DBT for Snowflake
uv tool install dbt-snowflake

# Install other tools
uv tool install pre-commit
uv tool install ipython
```

## VS Code Configuration

### Recommended Settings

Add to VS Code settings.json (Cmd+Shift+P → "Preferences: Open Settings (JSON)"):

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "python.terminal.activateEnvironment": true,
  "python.formatting.provider": "none",
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": true
    }
  },
  "ruff.lint.args": ["--config=pyproject.toml"],
  "files.exclude": {
    "**/.venv": true,
    "**/__pycache__": true,
    "**/.pytest_cache": true
  },
  "terminal.integrated.defaultProfile.osx": "zsh",
  "terminal.integrated.inheritEnv": false
}
```

### Configure AWS Toolkit

1. Open VS Code
2. Click AWS icon in sidebar
3. Select "Connect to AWS"
4. Choose profile configured in AWS CLI

### Configure Snowflake Extension (if available)

1. Open VS Code
2. Install Snowflake extension (if not already)
3. Configure connection using Snow CLI credentials

## Shell Customization

Your shell has been configured with these customizations. Restart your terminal or run:

```bash
source ~/.zshrc
```

### Additional Customizations (Optional)

Add to `~/.zshrc`:

```bash
# Aliases for common data tasks
alias dbt-dev='cd ~/Repos/dbt-models && source .venv/bin/activate'
alias start-local-db='docker compose up -d postgres'

# Environment-specific AWS profiles
alias aws-prod='export AWS_PROFILE=production'
alias aws-staging='export AWS_PROFILE=staging'

# Python virtual environment shortcuts
alias ve='source .venv/bin/activate'
alias vu='uv venv && source .venv/bin/activate'

# Directory shortcuts
alias repos='cd ~/Repos'
alias dp='cd ~/Repos/data-platform'
```

## SnowSQL Configuration

SnowSQL is installed as an application. Configure it:

### Create SnowSQL Config

Create `~/.snowsql/config`:

```ini
[connections.default]
accountname = brook_ai
username = your.name@brook.ai
authenticator = externalbrowser
dbname = analytics
schemaname = core
rolename = data_engineer
warehousename = compute_wh

[options]
output_format = table
timing = True
friendly = True
```

### Test SnowSQL

```bash
# Connect to Snowflake
snowsql -c default

# Run query
snowsql -c default -q "SELECT CURRENT_USER()"
```

## DBT Setup

### Install DBT for Snowflake

```bash
uv tool install dbt-snowflake
```

### Create DBT Project

```bash
cd ~/Repos
dbt init my_dbt_project

# Follow prompts:
# Which database would you like to use? snowflake
# account: brook_ai
# user: your.name@brook.ai
# authenticator: externalbrowser
# database: analytics
# warehouse: compute_wh
# schema: dbt_yourname
# threads: 4
```

### Test DBT Connection

```bash
cd ~/Repos/my_dbt_project
dbt debug
```

## Verification Checklist

After completing all configurations, verify each service:

```bash
# AWS
aws sts get-caller-identity

# Snowflake
snow connection test

# GitHub
gh auth status

# Docker
docker run hello-world

# Python/uv
uv --version
python3 --version

# DBT
dbt --version

# VS Code
code --version
```

All should return successful responses with no errors.

## Next Steps

1. Clone team repositories:
   ```bash
   cd ~/Repos
   gh repo clone brook-ai/data-platform
   gh repo clone brook-ai/dbt-models
   gh repo clone brook-ai/dagster-pipelines
   ```

2. Set up pre-commit hooks:
   ```bash
   cd ~/Repos/data-platform
   uv tool install pre-commit
   pre-commit install
   ```

3. Configure Datadog (if monitoring dashboards):
   - Request Datadog account from team lead
   - Install Datadog browser extension
   - Log in with SSO

4. Join team channels:
   - #data-engineering (Slack)
   - #data-platform (Slack)
   - Weekly sync meetings

5. Review team documentation:
   - Data platform architecture
   - DBT style guide
   - Dagster pipeline patterns
   - SQL conventions

## Troubleshooting Post-Install

If any service configuration fails:
1. Check logs for specific service
2. Verify network connectivity
3. Confirm credentials are correct
4. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
5. Ask in #data-engineering Slack channel

## Service-Specific Documentation

- **AWS CLI**: https://docs.aws.amazon.com/cli/
- **Snowflake CLI**: https://docs.snowflake.com/en/developer-guide/snowflake-cli-v2/index
- **GitHub CLI**: https://cli.github.com/manual/
- **Docker**: https://docs.docker.com/desktop/
- **DBT**: https://docs.getdbt.com/
- **uv**: https://github.com/astral-sh/uv
