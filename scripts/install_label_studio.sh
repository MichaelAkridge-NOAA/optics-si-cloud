#!/bin/bash
set -e

echo "Installing Label Studio..."

# Detect the actual user (not root even when using sudo)
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "Detected user: $ACTUAL_USER"
echo "Home directory: $ACTUAL_HOME"

# Fix common apt repository issues before proceeding
echo "Checking apt repositories..."
if sudo apt-get update 2>&1 | grep -q "NO_PUBKEY\|not signed"; then
    echo "Warning: Some apt repositories have GPG key issues. These won't affect Label Studio installation."
    echo "Continuing with Label Studio setup..."
fi

# Install Python3 and pip if not already installed
echo "Installing Python dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv || {
    echo "Error: Failed to install Python dependencies"
    exit 1
}

# Create a persistent directory for Label Studio in the user's home
LABEL_STUDIO_HOME="$ACTUAL_HOME/.label-studio"
echo "Creating Label Studio directory at: $LABEL_STUDIO_HOME"
sudo -u "$ACTUAL_USER" mkdir -p "$LABEL_STUDIO_HOME"

# Create a virtual environment for Label Studio
if [ ! -d "$LABEL_STUDIO_HOME/venv" ]; then
    echo "Creating Python virtual environment for Label Studio..."
    sudo -u "$ACTUAL_USER" python3 -m venv "$LABEL_STUDIO_HOME/venv" || {
        echo "Error: Failed to create virtual environment"
        exit 1
    }
fi

# Activate the virtual environment and install Label Studio
echo "Installing Label Studio in virtual environment..."
sudo -u "$ACTUAL_USER" bash << EOFVENV
source "$LABEL_STUDIO_HOME/venv/bin/activate"
pip install --upgrade pip
pip install label-studio
EOFVENV

# Verify installation
if [ ! -f "$LABEL_STUDIO_HOME/venv/bin/label-studio" ]; then
    echo "Error: Label Studio installation failed"
    exit 1
fi
echo "✓ Label Studio installed successfully"

# Create a startup script that will run Label Studio on boot
echo "Creating startup script..."
STARTUP_SCRIPT="/etc/workstation-startup.d/50-start-label-studio"
sudo bash -c "cat > $STARTUP_SCRIPT" << 'EOF'
#!/bin/bash
# Start Label Studio on workstation boot

# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
if [ "$ACTUAL_USER" = "root" ]; then
    # Find the first non-root user with a home directory
    ACTUAL_USER=$(awk -F: '$3>=1000 && $3<60000 && $1!="nobody" {print $1; exit}' /etc/passwd)
fi
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

LABEL_STUDIO_HOME="$ACTUAL_HOME/.label-studio"
LOG_FILE="$LABEL_STUDIO_HOME/label-studio.log"

# Ensure the directory exists
mkdir -p "$LABEL_STUDIO_HOME"

# Check if Label Studio is already running
if pgrep -f "label-studio" > /dev/null; then
    echo "Label Studio is already running."
    exit 0
fi

# Start Label Studio as a background service
echo "Starting Label Studio..." | tee -a "$LOG_FILE"
cd "$LABEL_STUDIO_HOME"

# Run Label Studio in the background as the actual user
su - "$ACTUAL_USER" -c "cd '$LABEL_STUDIO_HOME' && nohup '$LABEL_STUDIO_HOME/venv/bin/label-studio' start \
    --host 0.0.0.0 \
    --port 8080 \
    --data-dir '$LABEL_STUDIO_HOME/data' \
    >> '$LOG_FILE' 2>&1 &"

echo "Label Studio started. PID: $!" | tee -a "$LOG_FILE"
echo "Access at: http://localhost:8080" | tee -a "$LOG_FILE"
echo "Logs: $LOG_FILE"
EOF

# Make the startup script executable
sudo chmod +x "$STARTUP_SCRIPT"

# Create a convenient command to manage Label Studio
echo "Creating management commands..."
sudo bash -c 'cat > /usr/local/bin/label-studio-status' << 'EOF'
#!/bin/bash
# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
if [ "$ACTUAL_USER" = "root" ]; then
    ACTUAL_USER=$(awk -F: '$3>=1000 && $3<60000 && $1!="nobody" {print $1; exit}' /etc/passwd)
fi
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

if pgrep -f "label-studio" > /dev/null; then
    echo "Label Studio is running"
    echo "PID: $(pgrep -f 'label-studio')"
    echo "Access at: http://localhost:8080"
    echo "Logs: $ACTUAL_HOME/.label-studio/label-studio.log"
else
    echo "Label Studio is not running"
fi
EOF
sudo chmod +x /usr/local/bin/label-studio-status

# Create a command to restart Label Studio
sudo bash -c 'cat > /usr/local/bin/label-studio-restart' << 'EOF'
#!/bin/bash
echo "Stopping Label Studio..."
pkill -f "label-studio" || true
sleep 2
echo "Starting Label Studio..."
/etc/workstation-startup.d/50-start-label-studio
EOF
sudo chmod +x /usr/local/bin/label-studio-restart

# Create a command to stop Label Studio
sudo bash -c 'cat > /usr/local/bin/label-studio-stop' << 'EOF'
#!/bin/bash
echo "Stopping Label Studio..."
pkill -f "label-studio"
echo "Label Studio stopped."
EOF
sudo chmod +x /usr/local/bin/label-studio-stop

# Create a command to view logs
sudo bash -c 'cat > /usr/local/bin/label-studio-logs' << 'EOF'
#!/bin/bash
# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
if [ "$ACTUAL_USER" = "root" ]; then
    ACTUAL_USER=$(awk -F: '$3>=1000 && $3<60000 && $1!="nobody" {print $1; exit}' /etc/passwd)
fi
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

tail -f "$ACTUAL_HOME/.label-studio/label-studio.log"
EOF
sudo chmod +x /usr/local/bin/label-studio-logs

echo ""
echo "✓ Label Studio installation complete!"
echo ""
echo "Label Studio has been installed and will auto-start on workstation boot."
echo "All data is stored in: $LABEL_STUDIO_HOME"
echo ""
echo "Available commands:"
echo "  label-studio-status   - Check if Label Studio is running"
echo "  label-studio-restart  - Restart Label Studio"
echo "  label-studio-stop     - Stop Label Studio"
echo "  label-studio-logs     - View Label Studio logs"
echo ""
echo "Starting Label Studio now..."
/etc/workstation-startup.d/50-start-label-studio
echo ""
echo "Label Studio should now be accessible at: http://localhost:8080"
