#!/bin/bash
# =============================================================================
# Git & SSH Setup for Google Cloud Workstations
# Version: 1.0.1 (2026-03-25)
# =============================================================================
# Configures Git with your identity and sets up SSH keys for GitHub/GitLab.
# Keys are stored in ~/.ssh (persists across restarts).
#
# Usage:
#   bash setup_git_ssh.sh
#   bash setup_git_ssh.sh "Your Name" "your@email.com"
# =============================================================================

SCRIPT_VERSION="1.0.1"

echo "=============================================="
echo "Git & SSH Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect the actual user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# ============================================================
# STEP 1: Configure Git identity
# ============================================================
echo "[Step 1/4] Configuring Git identity..."
echo ""

CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$1" ] && [ -n "$2" ]; then
    GIT_NAME="$1"
    GIT_EMAIL="$2"
elif [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
    echo "Current Git config:"
    echo "  Name:  $CURRENT_NAME"
    echo "  Email: $CURRENT_EMAIL"
    echo ""
    read -p "Keep current config? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        GIT_NAME="$CURRENT_NAME"
        GIT_EMAIL="$CURRENT_EMAIL"
    else
        read -p "Enter your name: " GIT_NAME
        read -p "Enter your email: " GIT_EMAIL
    fi
else
    read -p "Enter your name (for Git commits): " GIT_NAME
    read -p "Enter your email (for Git commits): " GIT_EMAIL
fi

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo "ERROR: Name and email are required."
    exit 1
fi

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo ""
echo "✓ Git identity configured:"
echo "  Name:  $GIT_NAME"
echo "  Email: $GIT_EMAIL"

# ============================================================
# STEP 2: Configure Git defaults
# ============================================================
echo ""
echo "[Step 2/4] Configuring Git defaults..."

# Sensible defaults
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.default current
git config --global core.autocrlf input
git config --global core.editor "code --wait"
git config --global credential.helper store

# Useful aliases
git config --global alias.st "status -sb"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.ci "commit"
git config --global alias.lg "log --oneline --graph --decorate -20"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.unstage "reset HEAD --"

echo "✓ Git defaults configured"
echo "  Default branch: main"
echo "  Pull strategy:  merge (no rebase)"
echo "  Editor:         VS Code"
echo ""
echo "  Aliases added: st, co, br, ci, lg, last, unstage"

# ============================================================
# STEP 3: Setup SSH key
# ============================================================
echo ""
echo "[Step 3/4] Setting up SSH key..."

SSH_DIR="$ACTUAL_HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

sudo -u "$ACTUAL_USER" mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    echo "SSH key already exists: $SSH_KEY"
    echo ""
    read -p "Generate a new key? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing key."
    else
        BACKUP_KEY="${SSH_KEY}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$SSH_KEY" "$BACKUP_KEY"
        mv "${SSH_KEY}.pub" "${BACKUP_KEY}.pub" 2>/dev/null || true
        echo "Old key backed up to: $BACKUP_KEY"
        
        sudo -u "$ACTUAL_USER" ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
        echo "✓ New SSH key generated"
    fi
else
    echo "Generating new SSH key..."
    sudo -u "$ACTUAL_USER" ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N ""
    echo "✓ SSH key generated"
fi

chmod 600 "$SSH_KEY"
chmod 644 "${SSH_KEY}.pub" 2>/dev/null || true

# ============================================================
# STEP 4: Configure SSH for GitHub/GitLab
# ============================================================
echo ""
echo "[Step 4/4] Configuring SSH hosts..."

SSH_CONFIG="$SSH_DIR/config"

# Add GitHub config if not present
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "cat >> '$SSH_CONFIG'" << 'EOF'

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
fi

# Add GitLab config if not present
if ! grep -q "Host gitlab.com" "$SSH_CONFIG" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "cat >> '$SSH_CONFIG'" << 'EOF'

# GitLab
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
fi

# Add Cloud Source Repos config if not present
if ! grep -q "Host source.developers.google.com" "$SSH_CONFIG" 2>/dev/null; then
    sudo -u "$ACTUAL_USER" bash -c "cat >> '$SSH_CONFIG'" << 'EOF'

# Google Cloud Source Repositories
Host source.developers.google.com
    HostName source.developers.google.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes
EOF
fi

chmod 600 "$SSH_CONFIG"
echo "✓ SSH config updated for GitHub, GitLab, and Cloud Source Repos"

# ============================================================
# Summary
# ============================================================
echo ""
echo "=============================================="
echo "✓ Git & SSH Setup Complete!"
echo "=============================================="
echo ""
echo "Your public SSH key:"
echo ""
cat "${SSH_KEY}.pub"
echo ""
echo "=============================================="
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. Add this key to GitHub:"
echo "   https://github.com/settings/ssh/new"
echo ""
echo "2. Add this key to GitLab:"
echo "   https://gitlab.com/-/user_settings/ssh_keys"
echo ""
echo "3. For Google Cloud Source Repos, register the key:"
echo "   https://source.cloud.google.com/user/ssh_keys"
echo ""
echo "4. Test the connection:"
echo "   ssh -T git@github.com"
echo "   ssh -T git@gitlab.com"
echo ""
echo "Git aliases available:"
echo "  git st     - Short status"
echo "  git lg     - Pretty log graph"
echo "  git last   - Last commit details"
echo ""

# Copy public key to clipboard if xclip is available
if command -v xclip &>/dev/null; then
    cat "${SSH_KEY}.pub" | xclip -selection clipboard
    echo "✓ Public key copied to clipboard!"
elif command -v xsel &>/dev/null; then
    cat "${SSH_KEY}.pub" | xsel --clipboard
    echo "✓ Public key copied to clipboard!"
fi
