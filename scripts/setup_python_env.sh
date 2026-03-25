#!/bin/bash
# =============================================================================
# Python Environment Setup for Google Cloud Workstations
# Version: 1.0.1 (2026-03-25)
# =============================================================================
# Creates a persistent Python environment that survives workstation restarts.
# Installs pyenv for version management + creates a default venv.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/YOUR-REPO/scripts/setup_python_env.sh | bash
#   # or
#   bash setup_python_env.sh [python-version]
#   bash setup_python_env.sh 3.11.8
# =============================================================================

SCRIPT_VERSION="1.0.1"
REQUESTED_PYTHON="${1:-3.12}"  # Default to Python 3.12

echo "=============================================="
echo "Python Environment Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo "Requested Python: $REQUESTED_PYTHON"
echo ""

# ============================================================
# STEP 1: Install system dependencies
# ============================================================
echo "[Step 1/5] Installing build dependencies..."

sudo apt-get update -qq
sudo apt-get install -y -qq \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    curl \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git

# ============================================================
# STEP 2: Install pyenv (persistent in ~/.pyenv)
# ============================================================
echo "[Step 2/5] Installing pyenv..."

PYENV_ROOT="$ACTUAL_HOME/.pyenv"

if [ -d "$PYENV_ROOT" ]; then
    echo "pyenv already installed, updating..."
    cd "$PYENV_ROOT" && git pull -q origin master 2>/dev/null || true
else
    echo "Installing pyenv..."
    sudo -u "$ACTUAL_USER" git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
fi

# Add pyenv to .bashrc if not present
BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'PYENV_ROOT' "$BASHRC" 2>/dev/null; then
    echo "Adding pyenv to .bashrc..."
    sudo -u "$ACTUAL_USER" bash -c "cat >> '$BASHRC'" << 'EOF'

# pyenv configuration (added by setup_python_env.sh)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
fi

# Load pyenv for this session
export PYENV_ROOT="$PYENV_ROOT"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$("$PYENV_ROOT/bin/pyenv" init -)"

# ============================================================
# STEP 3: Install requested Python version
# ============================================================
echo "[Step 3/5] Installing Python $REQUESTED_PYTHON..."

# Find the latest patch version matching the request
AVAILABLE_VERSION=$("$PYENV_ROOT/bin/pyenv" install --list 2>/dev/null | grep -E "^\s*${REQUESTED_PYTHON}" | grep -v 'dev\|rc\|alpha\|beta' | tail -1 | tr -d ' ')

if [ -z "$AVAILABLE_VERSION" ]; then
    echo "Warning: Could not find Python $REQUESTED_PYTHON, trying exact match..."
    AVAILABLE_VERSION="$REQUESTED_PYTHON"
fi

echo "Installing Python $AVAILABLE_VERSION..."

if "$PYENV_ROOT/bin/pyenv" versions 2>/dev/null | grep -q "$AVAILABLE_VERSION"; then
    echo "Python $AVAILABLE_VERSION already installed."
else
    sudo -u "$ACTUAL_USER" "$PYENV_ROOT/bin/pyenv" install "$AVAILABLE_VERSION"
fi

# Set as global default
sudo -u "$ACTUAL_USER" "$PYENV_ROOT/bin/pyenv" global "$AVAILABLE_VERSION"

# ============================================================
# STEP 4: Create default virtual environment
# ============================================================
echo "[Step 4/5] Creating default virtual environment..."

DEFAULT_VENV="$ACTUAL_HOME/.venvs/default"
sudo -u "$ACTUAL_USER" mkdir -p "$ACTUAL_HOME/.venvs"

if [ -d "$DEFAULT_VENV" ]; then
    echo "Default venv already exists at $DEFAULT_VENV"
else
    PYTHON_PATH="$PYENV_ROOT/versions/$AVAILABLE_VERSION/bin/python"
    sudo -u "$ACTUAL_USER" "$PYTHON_PATH" -m venv "$DEFAULT_VENV"
    echo "Created venv at $DEFAULT_VENV"
fi

# Upgrade pip in the venv
sudo -u "$ACTUAL_USER" "$DEFAULT_VENV/bin/pip" install --upgrade pip -q

# Add venv activation helper to .bashrc
if ! grep -q 'venv-activate' "$BASHRC" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "cat >> '$BASHRC'" << 'EOF'

# Virtual environment helpers (added by setup_python_env.sh)
alias venv-default='source $HOME/.venvs/default/bin/activate'
alias venv-list='ls -la $HOME/.venvs/'

# Function to create new venvs
venv-create() {
    if [ -z "$1" ]; then
        echo "Usage: venv-create <name>"
        return 1
    fi
    python -m venv "$HOME/.venvs/$1"
    echo "Created venv: $HOME/.venvs/$1"
    echo "Activate with: source ~/.venvs/$1/bin/activate"
}
EOF
fi

# ============================================================
# STEP 5: Install common packages
# ============================================================
echo "[Step 5/5] Installing common packages..."

sudo -u "$ACTUAL_USER" "$DEFAULT_VENV/bin/pip" install -q \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    requests \
    ipython \
    black \
    ruff \
    pytest

# ============================================================
# Summary
# ============================================================
INSTALLED_VERSION=$("$PYENV_ROOT/bin/pyenv" version-name)

echo ""
echo "=============================================="
echo "✓ Python Environment Setup Complete!"
echo "=============================================="
echo ""
echo "Installed:"
echo "  pyenv:        $PYENV_ROOT"
echo "  Python:       $INSTALLED_VERSION"
echo "  Default venv: $DEFAULT_VENV"
echo ""
echo "Commands (run 'source ~/.bashrc' first):"
echo "  pyenv versions      - List installed Python versions"
echo "  pyenv install X.Y   - Install a new Python version"
echo "  venv-default        - Activate the default venv"
echo "  venv-create NAME    - Create a new venv"
echo "  venv-list           - List all venvs"
echo ""
echo "To use now:  source ~/.bashrc && venv-default"
echo ""
