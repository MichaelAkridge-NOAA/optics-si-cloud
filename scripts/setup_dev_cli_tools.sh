#!/bin/bash
# =============================================================================
# Developer Productivity CLI Tools Setup
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs common CLI productivity tools for Cloud Workstations.
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
LOCAL_BIN="$ACTUAL_HOME/.local/bin"
BASHRC="$ACTUAL_HOME/.bashrc"

echo "=============================================="
echo "Developer CLI Tools Setup v${SCRIPT_VERSION}"
echo "=============================================="

echo "[Step 1/3] Installing packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  tmux ripgrep fd-find bat jq yq tree htop shellcheck direnv \
  pipx python3-venv

# pipx path support
sudo -u "$ACTUAL_USER" pipx ensurepath >/dev/null 2>&1 || true

# pre-commit via pipx (safe isolated install)
if ! sudo -u "$ACTUAL_USER" pipx list 2>/dev/null | grep -q pre-commit; then
  sudo -u "$ACTUAL_USER" pipx install pre-commit || true
fi

echo "[Step 2/3] Adding helper aliases..."
if ! grep -q 'dev-cli-tools marker' "$BASHRC" 2>/dev/null; then
  sudo -u "$ACTUAL_USER" bash -c "cat >> '$BASHRC'" << 'EOF'

# Developer CLI tool aliases (added by setup_dev_cli_tools.sh)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  alias fd='fdfind'
fi
if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
  alias bat='batcat'
fi
# direnv hook
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
# dev-cli-tools marker
EOF
fi

sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"
sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/dev-tools-check'" << 'EOF'
#!/bin/bash
echo "tmux:       $(tmux -V 2>/dev/null || echo not found)"
echo "rg:         $(rg --version 2>/dev/null | head -1 || echo not found)"
if command -v fd >/dev/null 2>&1; then
  echo "fd:         $(fd --version 2>/dev/null | head -1)"
elif command -v fdfind >/dev/null 2>&1; then
  echo "fd(fdfind): $(fdfind --version 2>/dev/null | head -1)"
else
  echo "fd:         not found"
fi
if command -v bat >/dev/null 2>&1; then
  echo "bat:        $(bat --version 2>/dev/null | head -1)"
elif command -v batcat >/dev/null 2>&1; then
  echo "bat(batcat):$(batcat --version 2>/dev/null | head -1)"
else
  echo "bat:        not found"
fi
echo "jq:         $(jq --version 2>/dev/null || echo not found)"
echo "yq:         $(yq --version 2>/dev/null | head -1 || echo not found)"
echo "direnv:     $(direnv version 2>/dev/null || echo not found)"
echo "pre-commit: $(pre-commit --version 2>/dev/null || echo not found)"
EOF
chmod +x "$LOCAL_BIN/dev-tools-check"

echo "[Step 3/3] Done"
echo ""
echo "=============================================="
echo "✓ Developer CLI tools setup complete"
echo "=============================================="
echo "Run: source ~/.bashrc"
echo "Check: dev-tools-check"
