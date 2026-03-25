# Git & SSH Setup for Cloud Workstations
id: git-ssh-setup
title: Git & SSH Setup for Cloud Workstations
summary: Configure Git and SSH keys for secure authentication with GitHub, GitLab, and Cloud Source Repos.
authors: Michael Akridge
categories: Cloud, Git, SSH
environments: Web
status: Published
tags: cloud, git, ssh, github, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This guide configures Git and SSH keys for secure authentication with GitHub, GitLab, and Google Cloud Source Repositories.

### What you'll get

- Git identity configured (name, email)
- Useful Git defaults and aliases
- SSH key (Ed25519) for authentication
- SSH config for GitHub, GitLab, Cloud Source Repos

### Prerequisites

- A Google Cloud Workstation
- Terminal access
- Accounts on GitHub/GitLab (optional)

## Run the Setup Script

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_git_ssh.sh | bash
```

Or with your name and email pre-filled:

```bash
bash <(curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_git_ssh.sh) "Your Name" "your@email.com"
```

The script will prompt you for:
- Your name (for Git commits)
- Your email (for Git commits)

## Copy Your Public Key

The script outputs your public SSH key at the end. You can also view it:

```bash
cat ~/.ssh/id_ed25519.pub
```

Copy this entire line (starts with `ssh-ed25519`).

## Add Key to GitHub

1. Go to [github.com/settings/ssh/new](https://github.com/settings/ssh/new)
2. **Title:** Give it a name (e.g., "Cloud Workstation")
3. **Key:** Paste your public key
4. Click **Add SSH key**

### Test GitHub connection

```bash
ssh -T git@github.com
```

Expected output:
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

## Add Key to GitLab

1. Go to [gitlab.com/-/user_settings/ssh_keys](https://gitlab.com/-/user_settings/ssh_keys)
2. **Key:** Paste your public key
3. **Title:** Give it a name
4. Click **Add key**

### Test GitLab connection

```bash
ssh -T git@gitlab.com
```

## Add Key to Cloud Source Repos

1. Go to [source.cloud.google.com/user/ssh_keys](https://source.cloud.google.com/user/ssh_keys)
2. Click **Register SSH Key**
3. Paste your public key

## Git Aliases

The script adds these handy aliases:

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `git st` | `git status -sb` | Short status |
| `git co` | `git checkout` | Checkout |
| `git br` | `git branch` | Branch |
| `git ci` | `git commit` | Commit |
| `git lg` | `git log --oneline --graph --decorate -20` | Pretty log |
| `git last` | `git log -1 HEAD --stat` | Last commit details |
| `git unstage` | `git reset HEAD --` | Unstage files |

### Examples

```bash
# Quick status
git st

# Pretty log
git lg

# Create and switch to new branch
git co -b feature/my-feature

# Unstage a file
git unstage myfile.txt
```

## Cloning Repositories

Now you can clone using SSH URLs:

### GitHub

```bash
git clone git@github.com:username/repo.git
```

### GitLab

```bash
git clone git@gitlab.com:username/repo.git
```

### Cloud Source Repos

```bash
git clone ssh://source.developers.google.com/p/PROJECT_ID/r/REPO_NAME
```

## Git Configuration

View your current config:

```bash
git config --list
```

The script sets these defaults:

| Setting | Value | Purpose |
|---------|-------|---------|
| `init.defaultBranch` | main | New repos use "main" |
| `pull.rebase` | false | Pull uses merge |
| `push.default` | current | Push to same-named remote branch |
| `core.autocrlf` | input | Handle line endings |
| `core.editor` | code --wait | Use VS Code for commits |
| `credential.helper` | store | Remember HTTPS passwords |

## Persistence

Everything persists across Cloud Workstation restarts:

- **SSH keys:** `~/.ssh/`
- **SSH config:** `~/.ssh/config`
- **Git config:** `~/.gitconfig`

## Troubleshooting

### Permission denied (publickey)

1. Check if ssh-agent has your key:
   ```bash
   ssh-add -l
   ```

2. If empty, add your key:
   ```bash
   ssh-add ~/.ssh/id_ed25519
   ```

3. Verify the public key was added to GitHub/GitLab

### ssh: Could not resolve hostname

Check your internet connection and DNS:

```bash
ping github.com
```

### Multiple SSH keys

If you have multiple keys, the SSH config specifies which key to use for each host. View it:

```bash
cat ~/.ssh/config
```

### Generate a new key

If you need a fresh key:

```bash
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519
```

> **Warning:** This will overwrite your existing key. Back it up first if needed.

## Security Tips

- **Never share your private key** (`~/.ssh/id_ed25519`)
- **Only share the public key** (`~/.ssh/id_ed25519.pub`)
- Add a passphrase for extra security (script creates without passphrase for convenience)
- Review connected SSH keys periodically in GitHub/GitLab settings
