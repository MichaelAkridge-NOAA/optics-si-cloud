# Workstation Cleanup Guide

## Overview
Duration: 1

This guide covers cleaning up logs, caches, and temporary files on your Cloud Workstation to free disk space.

### What you'll learn
- Preview cleanup with dry-run mode
- Clean specific categories interactively
- Automate cleanup with flags
- Understand what's safe to delete

### Prerequisites
- Google Cloud Workstation
- Basic terminal knowledge

## Preview Cleanup (Dry Run)
Duration: 1

First, see what would be deleted without actually removing anything:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/workstation_cleanup.sh | bash -s -- --dry-run
```

Or locally:
```bash
bash scripts/workstation_cleanup.sh --dry-run
```

This shows each category and how much space it uses.

## Interactive Cleanup
Duration: 2

Run cleanup interactively to choose what to delete:

```bash
bash workstation_cleanup.sh
```

For each category, you'll be prompted:
```
  pip cache: 245M
    Clean? (y/n)
```

Press `y` to clean or `n` to skip.

### Categories Cleaned

**System Caches**
- APT package cache
- Systemd journal logs

**User Caches**
- pip cache (`~/.cache/pip`)
- npm cache (`~/.npm/_cacache`)
- yarn cache
- Go build cache
- Python bytecode (`__pycache__`)

**Application Logs**
- Label Studio logs (older than 7 days)
- Jupyter logs
- code-server logs
- GCloud logs

**Temporary Files**
- `~/tmp` directory
- Vim swap files
- Core dumps

**Trash**
- `~/.local/share/Trash`

## Automatic Cleanup
Duration: 1

Clean everything without prompts:

```bash
bash workstation_cleanup.sh --all
```

This is useful for:
- Scheduled cleanup tasks
- Scripts and automation
- Quick space recovery

## Docker Cleanup
Duration: 1

If Docker is installed, the script also offers:

```bash
docker system prune
```

This removes:
- Stopped containers
- Unused networks
- Dangling images
- Build cache

For more aggressive Docker cleanup:
```bash
docker system prune -a  # Also removes unused images
docker volume prune     # Removes unused volumes
```

## Schedule Regular Cleanup
Duration: 1

Add automatic cleanup to cron:

```bash
# Edit crontab
crontab -e

# Weekly cleanup (Sundays at 3 AM)
0 3 * * 0 /home/user/scripts/workstation_cleanup.sh --all >> /home/user/.local/share/cleanup.log 2>&1
```

## What's Safe to Delete
Duration: 2

### Always Safe
- Package manager caches (pip, npm, yarn)
- Python bytecode (`__pycache__`, `.pyc`)
- Old log files
- Trash
- Temporary files

### Check First
- Downloads folder (might have important files)
- Docker images (need to re-pull)

### Never Deleted by Script
- Source code
- Virtual environments (preserved)
- Configuration files
- SSH keys
- Git repositories

## Congratulations
Duration: 1

You now know how to keep your workstation clean!

### What you learned
- Preview cleanup with `--dry-run`
- Interactive vs automatic cleanup
- What's safe to delete
- Scheduling regular cleanup

### Next steps
- Set up weekly cleanup cron job
- Run cleanup when disk usage is high
- Use `workstation_health.sh` to monitor disk
