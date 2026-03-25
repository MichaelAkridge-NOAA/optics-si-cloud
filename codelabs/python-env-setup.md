# Python Environment Setup for Cloud Workstations

## Overview

Duration: 5 minutes

This guide installs **pyenv** for Python version management and creates persistent virtual environments that survive Cloud Workstation restarts.

### What you'll get

- pyenv installed in `~/.pyenv` (persists across restarts)
- Python 3.12 (or your choice) installed
- Default venv in `~/.venvs/default` with common packages
- Helper commands: `venv-default`, `venv-create`, `venv-list`

### Prerequisites

- A Google Cloud Workstation
- Terminal access

## Run the Setup Script

Duration: 3 minutes

Download and run the setup script:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_python_env.sh | bash
```

To install a specific Python version (e.g., 3.11):

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_python_env.sh | bash -s -- 3.11
```

> **Note:** The script installs build dependencies and compiles Python from source. This takes a few minutes.

## Reload Your Shell

After installation, reload your shell to use the new commands:

```bash
source ~/.bashrc
```

## Using Virtual Environments

### Activate the Default Environment

```bash
venv-default
```

You should see `(default)` in your prompt. Verify:

```bash
python --version
which python
```

### List Available Environments

```bash
venv-list
```

### Create a New Environment

```bash
venv-create myproject
```

Activate it:

```bash
source ~/.venvs/myproject/bin/activate
```

### Deactivate

```bash
deactivate
```

## Managing Python Versions

### List Installed Versions

```bash
pyenv versions
```

### Install a New Version

```bash
pyenv install 3.11.8
```

### Set Global Default

```bash
pyenv global 3.11.8
```

### See Available Versions

```bash
pyenv install --list | grep "^\s*3\."
```

## Pre-installed Packages

The default environment includes:

| Package | Purpose |
|---------|---------|
| numpy | Numerical computing |
| pandas | Data manipulation |
| matplotlib | Plotting |
| scikit-learn | Machine learning |
| requests | HTTP client |
| ipython | Enhanced Python shell |
| black | Code formatter |
| ruff | Fast linter |
| pytest | Testing framework |

## Persistence

Everything persists across Cloud Workstation restarts:

- **pyenv:** `~/.pyenv`
- **Virtual environments:** `~/.venvs/`
- **Shell config:** `~/.bashrc`

## Troubleshooting

### pyenv command not found

Run `source ~/.bashrc` or start a new terminal.

### Python build fails

The script installs build dependencies, but if it fails:

```bash
sudo apt-get install -y build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev \
    libxmlsec1-dev libffi-dev liblzma-dev
```

### Using with VS Code

VS Code should automatically detect pyenv environments. If not:

1. Open Command Palette (Ctrl+Shift+P)
2. Type "Python: Select Interpreter"
3. Choose from `~/.pyenv/versions/` or `~/.venvs/`
