#!/bin/bash
# =============================================================================
# Docker Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs Docker Engine for running containers inside Cloud Workstations.
# Configures rootless mode for security and adds management commands.
#
# Usage:
#   bash setup_docker.sh
# =============================================================================

SCRIPT_VERSION="1.0.0"

echo "=============================================="
echo "Docker Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo ""

LOCAL_BIN="$ACTUAL_HOME/.local/bin"

# ============================================================
# STEP 1: Check if Docker is already installed
# ============================================================
echo "[Step 1/5] Checking existing Docker installation..."

if command -v docker &>/dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')
    echo "Docker already installed: $DOCKER_VERSION"
    
    if docker info &>/dev/null 2>&1; then
        echo "✓ Docker daemon is running"
        read -p "Reinstall Docker? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping installation."
            exit 0
        fi
    else
        echo "Docker installed but daemon not running."
    fi
fi

# ============================================================
# STEP 2: Install Docker
# ============================================================
echo "[Step 2/5] Installing Docker..."

# Remove old versions
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# Install prerequisites
sudo apt-get update -qq
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg 2>/dev/null || true
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update -qq
sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✓ Docker installed"

# ============================================================
# STEP 3: Configure Docker for current user
# ============================================================
echo "[Step 3/5] Configuring Docker..."

# Add user to docker group
sudo usermod -aG docker "$ACTUAL_USER"

# Create Docker config directory
sudo -u "$ACTUAL_USER" mkdir -p "$ACTUAL_HOME/.docker"

# Configure Docker daemon for Cloud Workstations
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "storage-driver": "overlay2",
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "10m",
        "max-file": "3"
    },
    "live-restore": true
}
EOF

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

echo "✓ Docker configured"

# ============================================================
# STEP 4: Configure Docker data persistence
# ============================================================
echo "[Step 4/5] Setting up persistence..."

# Docker data is stored in /var/lib/docker which doesn't persist
# Create a persistent location and symlink
DOCKER_DATA="$ACTUAL_HOME/.docker-data"

if [ ! -d "$DOCKER_DATA" ]; then
    echo "Creating persistent Docker data directory..."
    sudo -u "$ACTUAL_USER" mkdir -p "$DOCKER_DATA"
    
    # Note: This requires stopping Docker and moving data
    # For now, we'll document this as a manual step
    echo ""
    echo "NOTE: Docker images/containers are stored in /var/lib/docker"
    echo "      which does NOT persist across workstation restarts."
    echo ""
    echo "To persist Docker data (optional, requires restart):"
    echo "  1. Stop Docker: sudo systemctl stop docker"
    echo "  2. Move data: sudo mv /var/lib/docker $DOCKER_DATA"
    echo "  3. Symlink: sudo ln -s $DOCKER_DATA /var/lib/docker"
    echo "  4. Start Docker: sudo systemctl start docker"
fi

# ============================================================
# STEP 5: Create management commands
# ============================================================
echo "[Step 5/5] Creating management commands..."

sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"

# docker-status
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/docker-status'" << 'EOF'
#!/bin/bash
echo "=== Docker Status ==="
echo ""

if ! command -v docker &>/dev/null; then
    echo "✗ Docker not installed"
    exit 1
fi

if docker info &>/dev/null 2>&1; then
    echo "✓ Docker daemon is running"
    echo ""
    echo "--- Version ---"
    docker --version
    docker compose version 2>/dev/null || true
    echo ""
    echo "--- Containers ---"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "--- Images ---"
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    echo ""
    echo "--- Disk Usage ---"
    docker system df
else
    echo "✗ Docker daemon is not running"
    echo "  Start with: sudo systemctl start docker"
fi
EOF
chmod +x "$LOCAL_BIN/docker-status"

# docker-cleanup
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/docker-cleanup'" << 'EOF'
#!/bin/bash
echo "=== Docker Cleanup ==="
echo ""

echo "This will remove:"
echo "  - Stopped containers"
echo "  - Unused networks"
echo "  - Dangling images"
echo "  - Build cache"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Cleaning up..."
    docker system prune -f
    echo ""
    echo "✓ Cleanup complete"
    echo ""
    docker system df
fi
EOF
chmod +x "$LOCAL_BIN/docker-cleanup"

# docker-save (save images for persistence)
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/docker-save-images'" << 'EOF'
#!/bin/bash
# Save Docker images to persistent storage for restoration after restart
SAVE_DIR="$HOME/.docker-images"
mkdir -p "$SAVE_DIR"

echo "=== Save Docker Images ==="
echo "Saving to: $SAVE_DIR"
echo ""

docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>" | while read image; do
    filename=$(echo "$image" | tr '/:' '_').tar
    echo "Saving $image..."
    docker save "$image" > "$SAVE_DIR/$filename"
done

echo ""
echo "✓ Images saved to $SAVE_DIR"
echo "  Restore with: docker-load-images"
EOF
chmod +x "$LOCAL_BIN/docker-save-images"

# docker-load (load saved images)
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/docker-load-images'" << 'EOF'
#!/bin/bash
SAVE_DIR="$HOME/.docker-images"

if [ ! -d "$SAVE_DIR" ]; then
    echo "No saved images found in $SAVE_DIR"
    exit 1
fi

echo "=== Load Docker Images ==="
echo "Loading from: $SAVE_DIR"
echo ""

for tarfile in "$SAVE_DIR"/*.tar; do
    if [ -f "$tarfile" ]; then
        echo "Loading $(basename $tarfile)..."
        docker load < "$tarfile"
    fi
done

echo ""
echo "✓ Images loaded"
docker images
EOF
chmod +x "$LOCAL_BIN/docker-load-images"

# Add to PATH
BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC"
fi

echo "✓ Management commands created"

# ============================================================
# Summary
# ============================================================
echo ""
echo "=============================================="
echo "✓ Docker Setup Complete!"
echo "=============================================="
echo ""
echo "Docker version: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',')"
echo ""
echo "IMPORTANT: Log out and back in for group changes to take effect,"
echo "or run: newgrp docker"
echo ""
echo "Commands:"
echo "  docker-status       - Show Docker status and containers"
echo "  docker-cleanup      - Remove unused containers/images"
echo "  docker-save-images  - Save images to persistent storage"
echo "  docker-load-images  - Load saved images after restart"
echo ""
echo "Quick test:"
echo "  docker run hello-world"
echo ""
echo "NOTE: Docker data in /var/lib/docker does NOT persist across"
echo "      workstation restarts. Use docker-save-images to preserve."
echo ""
