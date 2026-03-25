#!/bin/bash
# =============================================================================
# VS Code Server (code-server) Setup for Google Cloud Workstations
# Version: 1.0.1 (2026-03-25)
# =============================================================================
# Installs code-server (browser-based VS Code) as an alternative/supplement
# to the Cloud Workstation IDE. Runs on port 8443.
#
# Useful when:
# - You want VS Code in a browser tab
# - The Cloud Workstation IDE is slow/unresponsive
# - You need to share your workspace temporarily
#
# Usage:
#   bash setup_code_server.sh
# =============================================================================

SCRIPT_VERSION="1.0.1"

echo "=============================================="
echo "VS Code Server Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo ""

CODE_SERVER_HOME="$ACTUAL_HOME/.code-server"
LOCAL_BIN="$ACTUAL_HOME/.local/bin"
CONFIG_DIR="$ACTUAL_HOME/.config/code-server"

# ============================================================
# STEP 1: Install code-server
# ============================================================
echo "[Step 1/4] Installing code-server..."

# Check if already installed
if [ -f "$CODE_SERVER_HOME/bin/code-server" ]; then
    CURRENT_VERSION=$("$CODE_SERVER_HOME/bin/code-server" --version 2>/dev/null | head -1)
    echo "code-server already installed: $CURRENT_VERSION"
    read -p "Reinstall/update? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping installation."
    else
        rm -rf "$CODE_SERVER_HOME"
    fi
fi

if [ ! -f "$CODE_SERVER_HOME/bin/code-server" ]; then
    echo "Downloading code-server..."
    
    # Get latest version
    LATEST_VERSION=$(curl -sL https://api.github.com/repos/coder/code-server/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
    
    if [ -z "$LATEST_VERSION" ]; then
        echo "Could not determine latest version, using 4.23.1"
        LATEST_VERSION="4.23.1"
    fi
    
    echo "Installing version $LATEST_VERSION..."
    
    # Download and extract
    DOWNLOAD_URL="https://github.com/coder/code-server/releases/download/v${LATEST_VERSION}/code-server-${LATEST_VERSION}-linux-amd64.tar.gz"
    
    sudo -u "$ACTUAL_USER" mkdir -p "$CODE_SERVER_HOME"
    curl -sL "$DOWNLOAD_URL" | sudo -u "$ACTUAL_USER" tar -xz -C "$CODE_SERVER_HOME" --strip-components=1
    
    if [ -f "$CODE_SERVER_HOME/bin/code-server" ]; then
        echo "✓ code-server installed"
    else
        echo "ERROR: Installation failed"
        exit 1
    fi
fi

# ============================================================
# STEP 2: Configure code-server
# ============================================================
echo ""
echo "[Step 2/4] Configuring code-server..."

sudo -u "$ACTUAL_USER" mkdir -p "$CONFIG_DIR"

# Create config file
sudo -u "$ACTUAL_USER" bash -c "cat > '$CONFIG_DIR/config.yaml'" << EOF
bind-addr: 0.0.0.0:8443
auth: none
cert: false
disable-telemetry: true
disable-update-check: true
user-data-dir: $CODE_SERVER_HOME/data
extensions-dir: $CODE_SERVER_HOME/extensions
EOF

echo "✓ Configuration saved to $CONFIG_DIR/config.yaml"
echo "  Port: 8443"
echo "  Auth: disabled (Cloud Workstation uses IAM)"

# ============================================================
# STEP 3: Create management commands
# ============================================================
echo ""
echo "[Step 3/4] Creating management commands..."

sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"

# code-server-start
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/code-server-start'" << 'EOF'
#!/bin/bash
CODE_SERVER_HOME="$HOME/.code-server"
LOG_FILE="$CODE_SERVER_HOME/code-server.log"

if pgrep -f "code-server" > /dev/null; then
    echo "code-server is already running."
    echo "Access at: http://localhost:8443"
    exit 0
fi

echo "Starting code-server..."
mkdir -p "$CODE_SERVER_HOME"
nohup "$CODE_SERVER_HOME/bin/code-server" >> "$LOG_FILE" 2>&1 &
echo $! > "$CODE_SERVER_HOME/code-server.pid"

sleep 2
if pgrep -f "code-server" > /dev/null; then
    echo "✓ code-server started"
    echo "  Access at: http://localhost:8443"
    echo "  Logs: $LOG_FILE"
else
    echo "✗ Failed to start code-server"
    echo "  Check logs: $LOG_FILE"
fi
EOF
chmod +x "$LOCAL_BIN/code-server-start"

# code-server-stop
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/code-server-stop'" << 'EOF'
#!/bin/bash
if pgrep -f "code-server" > /dev/null; then
    echo "Stopping code-server..."
    pkill -f "code-server"
    echo "✓ code-server stopped."
else
    echo "code-server is not running."
fi
EOF
chmod +x "$LOCAL_BIN/code-server-stop"

# code-server-restart
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/code-server-restart'" << 'EOF'
#!/bin/bash
echo "Restarting code-server..."
pkill -f "code-server" 2>/dev/null || true
sleep 1
"$HOME/.local/bin/code-server-start"
EOF
chmod +x "$LOCAL_BIN/code-server-restart"

# code-server-status
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/code-server-status'" << 'EOF'
#!/bin/bash
CODE_SERVER_HOME="$HOME/.code-server"

if pgrep -f "code-server" > /dev/null; then
    VERSION=$("$CODE_SERVER_HOME/bin/code-server" --version 2>/dev/null | head -1)
    echo "✓ code-server is running"
    echo "  PID:     $(pgrep -f 'code-server')"
    echo "  Version: $VERSION"
    echo "  URL:     http://localhost:8443"
    echo "  Logs:    $CODE_SERVER_HOME/code-server.log"
else
    echo "✗ code-server is not running"
    echo "  Start with: code-server-start"
fi
EOF
chmod +x "$LOCAL_BIN/code-server-status"

# code-server-logs
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/code-server-logs'" << 'EOF'
#!/bin/bash
LOG_FILE="$HOME/.code-server/code-server.log"
if [ -f "$LOG_FILE" ]; then
    tail -f "$LOG_FILE"
else
    echo "No log file found at $LOG_FILE"
fi
EOF
chmod +x "$LOCAL_BIN/code-server-logs"

echo "✓ Management commands created"

# ============================================================
# STEP 4: Add to PATH
# ============================================================
echo ""
echo "[Step 4/4] Setting up PATH..."

BASHRC="$ACTUAL_HOME/.bashrc"

if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '$BASHRC'"
fi

# Also add code-server bin to path for direct invocation
if ! grep -q 'code-server/bin' "$BASHRC" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.code-server/bin:\$PATH\"' >> '$BASHRC'"
fi

# ============================================================
# Install common extensions
# ============================================================
echo ""
echo "Installing recommended extensions..."

EXTENSIONS=(
    "ms-python.python"
    "esbenp.prettier-vscode"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
)

for ext in "${EXTENSIONS[@]}"; do
    "$CODE_SERVER_HOME/bin/code-server" --install-extension "$ext" --force 2>/dev/null || true
done

echo "✓ Extensions installed"

# ============================================================
# Start code-server
# ============================================================
echo ""
echo "Starting code-server..."
"$LOCAL_BIN/code-server-start"

echo ""
echo "=============================================="
echo "✓ VS Code Server Setup Complete!"
echo "=============================================="
echo ""
echo "Access at: http://localhost:8443"
echo "(Use Cloud Workstation port forwarding for port 8443)"
echo ""
echo "Commands (run 'source ~/.bashrc' first):"
echo "  code-server-start   - Start code-server"
echo "  code-server-stop    - Stop code-server"
echo "  code-server-restart - Restart code-server"
echo "  code-server-status  - Check status"
echo "  code-server-logs    - View logs"
echo ""
echo "Install extensions:"
echo "  code-server --install-extension <extension-id>"
echo ""
