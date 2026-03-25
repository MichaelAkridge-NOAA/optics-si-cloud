#!/bin/bash
# =============================================================================
# R + RStudio Server Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs R and RStudio Server in a Cloud Workstation-friendly configuration.
# RStudio Server runs on port 8787.
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
RSTUDIO_VERSION="${1:-2026.01.1-403}"

ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
LOCAL_BIN="$ACTUAL_HOME/.local/bin"

echo "=============================================="
echo "R + RStudio Server Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo "User: $ACTUAL_USER"
echo "Home: $ACTUAL_HOME"
echo "RStudio Server version: $RSTUDIO_VERSION"
echo ""

echo "[Step 1/5] Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  wget curl ca-certificates gdebi-core software-properties-common \
  libssl-dev libcurl4-openssl-dev libxml2-dev build-essential

echo "[Step 2/5] Installing R..."
if ! command -v R >/dev/null 2>&1; then
  sudo apt-get install -y -qq r-base r-base-dev
else
  echo "R already installed: $(R --version | head -1)"
fi

echo "[Step 3/5] Installing useful R packages..."
sudo -u "$ACTUAL_USER" Rscript -e "install.packages(c('tidyverse','data.table','sf','arrow','jsonlite','httr','quarto'), repos='https://cloud.r-project.org')" || true

echo "[Step 4/5] Installing RStudio Server..."
CODENAME=$(lsb_release -cs 2>/dev/null || echo "jammy")
case "$CODENAME" in
  jammy|noble) ;;
  *) CODENAME="jammy" ;;
esac

DEB_URL="https://download2.rstudio.org/server/${CODENAME}/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"
DEB_FILE="/tmp/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"

if ! wget -q -O "$DEB_FILE" "$DEB_URL"; then
  echo "Primary URL failed, trying jammy fallback..."
  DEB_URL="https://download2.rstudio.org/server/jammy/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb"
  wget -q -O "$DEB_FILE" "$DEB_URL"
fi

sudo gdebi -n "$DEB_FILE"
sudo systemctl enable rstudio-server >/dev/null 2>&1 || true
sudo systemctl restart rstudio-server || sudo service rstudio-server restart || true

echo "[Step 5/5] Creating management commands..."
sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/rstudio-start'" << 'EOF'
#!/bin/bash
sudo systemctl start rstudio-server || sudo service rstudio-server start
echo "RStudio Server started on http://localhost:8787"
EOF
chmod +x "$LOCAL_BIN/rstudio-start"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/rstudio-stop'" << 'EOF'
#!/bin/bash
sudo systemctl stop rstudio-server || sudo service rstudio-server stop
echo "RStudio Server stopped"
EOF
chmod +x "$LOCAL_BIN/rstudio-stop"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/rstudio-restart'" << 'EOF'
#!/bin/bash
sudo systemctl restart rstudio-server || sudo service rstudio-server restart
echo "RStudio Server restarted"
EOF
chmod +x "$LOCAL_BIN/rstudio-restart"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/rstudio-status'" << 'EOF'
#!/bin/bash
if systemctl is-active --quiet rstudio-server 2>/dev/null; then
  echo "✓ RStudio Server is running"
  echo "  URL:  http://localhost:8787"
  echo "  R:    $(R --version | head -1 2>/dev/null || echo unknown)"
else
  echo "✗ RStudio Server is not running"
  echo "  Start with: rstudio-start"
fi
EOF
chmod +x "$LOCAL_BIN/rstudio-status"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/rstudio-logs'" << 'EOF'
#!/bin/bash
sudo journalctl -u rstudio-server -n 100 --no-pager
EOF
chmod +x "$LOCAL_BIN/rstudio-logs"

BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
  sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '$BASHRC'"
fi

echo ""
echo "=============================================="
echo "✓ R + RStudio Server setup complete"
echo "=============================================="
echo "RStudio URL: http://localhost:8787"
echo "Commands: rstudio-start, rstudio-stop, rstudio-restart, rstudio-status, rstudio-logs"
echo "Run: source ~/.bashrc"
