#!/bin/bash
# =============================================================================
# Quarto Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs Quarto CLI from official GitHub releases.
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
LOCAL_BIN="$ACTUAL_HOME/.local/bin"

echo "=============================================="
echo "Quarto Setup v${SCRIPT_VERSION}"
echo "=============================================="

echo "[Step 1/3] Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq curl ca-certificates python3

echo "[Step 2/3] Resolving latest Quarto Linux .deb release..."
DEB_URL=$(python3 - << 'PY'
import json, urllib.request
u = "https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest"
with urllib.request.urlopen(u) as r:
    data = json.load(r)
assets = data.get("assets", [])
for a in assets:
    name = a.get("name", "")
    if name.startswith("quarto-") and name.endswith("linux-amd64.deb"):
        print(a.get("browser_download_url", ""))
        break
PY
)

if [ -z "${DEB_URL:-}" ]; then
  echo "ERROR: Could not detect Quarto .deb URL from GitHub releases"
  exit 1
fi

echo "Using: $DEB_URL"
DEB_FILE="/tmp/$(basename "$DEB_URL")"
curl -L --fail "$DEB_URL" -o "$DEB_FILE"

sudo dpkg -i "$DEB_FILE" || sudo apt-get install -f -y -qq

echo "[Step 3/3] Creating helper command..."
sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/quarto-check'" << 'EOF'
#!/bin/bash
quarto --version && echo "Quarto is ready"
EOF
chmod +x "$LOCAL_BIN/quarto-check"

BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
  sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '$BASHRC'"
fi

echo ""
echo "=============================================="
echo "✓ Quarto setup complete"
echo "=============================================="
echo "Verify with: quarto --version"
echo "Helper command: quarto-check"
