#!/bin/bash
# =============================================================================
# Positron Setup for Google Cloud Workstations (Linux .deb)
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs Positron desktop IDE on Debian/Ubuntu systems.
# Note: Positron is evolving quickly; treat as optional/beta in shared envs.
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
LOCAL_BIN="$ACTUAL_HOME/.local/bin"

echo "=============================================="
echo "Positron Setup v${SCRIPT_VERSION}"
echo "=============================================="

echo "[Step 1/4] Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl ca-certificates jq xdg-utils \
  libnss3 libatk1.0-0 libxkbfile1 libxcomposite1 libxdamage1 libxrandr2 \
  libgbm1 libgtk-3-0 libasound2 libxshmfence1 libx11-xcb1

echo "[Step 2/4] Resolving latest Positron Linux .deb release..."
POS_API="https://api.github.com/repos/posit-dev/positron/releases/latest"
DEB_URL=$(python3 - << 'PY'
import json, urllib.request
u = "https://api.github.com/repos/posit-dev/positron/releases/latest"
with urllib.request.urlopen(u) as r:
    data = json.load(r)
assets = data.get("assets", [])
# Prefer x64.deb
for a in assets:
    name = a.get("name", "")
    if name.endswith("x64.deb") and "Positron-" in name:
        print(a.get("browser_download_url", ""))
        break
PY
)

if [ -z "${DEB_URL:-}" ]; then
  echo "ERROR: Could not detect Positron .deb URL from GitHub releases"
  exit 1
fi

echo "Using: $DEB_URL"
DEB_FILE="/tmp/$(basename "$DEB_URL")"
curl -L --fail "$DEB_URL" -o "$DEB_FILE"

echo "[Step 3/4] Installing Positron..."
sudo dpkg -i "$DEB_FILE" || sudo apt-get install -f -y -qq

echo "[Step 4/4] Creating helper command..."
sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/positron-launch'" << 'EOF'
#!/bin/bash
if ! command -v positron >/dev/null 2>&1; then
  echo "Positron command not found. Try re-running setup_positron.sh"
  exit 1
fi
if [ -z "${DISPLAY:-}" ] && [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "No graphical session detected."
  echo "Use Chrome Remote Desktop / GUI session, then run: positron"
  exit 1
fi
nohup positron >/tmp/positron.log 2>&1 &
echo "Positron launched. Logs: /tmp/positron.log"
EOF
chmod +x "$LOCAL_BIN/positron-launch"

BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
  sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '$BASHRC'"
fi

echo ""
echo "=============================================="
echo "✓ Positron setup complete"
echo "=============================================="
echo "Launch in GUI session: positron"
echo "Helper command: positron-launch"
