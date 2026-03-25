# Workstation Backup to GCS
id: workstation-backup
title: Workstation Backup to GCS
summary: Back up your Cloud Workstation home directory to Google Cloud Storage.
authors: Michael Akridge
categories: Cloud, Backup, Tools
environments: Web
status: Published
tags: cloud, backup, gcs, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 1

This guide covers backing up your Cloud Workstation home directory to Google Cloud Storage for disaster recovery.

### What you'll learn
- Back up your home directory to GCS
- Restore from a backup
- Schedule automatic backups
- Manage backup retention

### Prerequisites
- Google Cloud Workstation
- GCS bucket with write access
- ADC configured (`setup_gcloud_adc.sh`)

## Create a Backup
Duration: 2

Run the backup script:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/workstation_backup.sh | bash -s -- backup gs://YOUR-BUCKET/workstation-backups
```

Or locally:
```bash
bash scripts/workstation_backup.sh backup gs://your-bucket/workstation-backups
```

The backup will be named with a timestamp: `backup-20260325-103045`

### What Gets Backed Up
- Configuration files (`.bashrc`, `.gitconfig`, etc.)
- SSH keys (`~/.ssh`)
- Project files
- Notebooks
- Scripts

### What's Excluded (by default)
- Package caches (`.cache/pip`, `.npm/_cacache`)
- Virtual environments (can be recreated)
- Trash
- Log files
- `node_modules`
- Python bytecode

## List Available Backups
Duration: 1

View all backups in your GCS path:

```bash
bash workstation_backup.sh list gs://your-bucket/workstation-backups
```

Output:
```
Available backups:
  backup-20260325-103045  (2026-03-25T10:30:45)
  backup-20260324-140000  (2026-03-24T14:00:00)
  backup-20260320-090000  (2026-03-20T09:00:00)
```

## Restore from Backup
Duration: 2

Restore a specific backup:

```bash
bash workstation_backup.sh restore gs://your-bucket/workstation-backups/backup-20260325-103045
```

The script will:
1. Show backup metadata
2. Ask for confirmation
3. Sync files from GCS to your home directory

**After restore:**
```bash
# Reload shell configuration
source ~/.bashrc

# Reinstall virtual environments if needed
bash scripts/setup_python_env.sh
```

## Schedule Automatic Backups
Duration: 2

Set up daily automatic backups:

```bash
bash workstation_backup.sh schedule gs://your-bucket/workstation-backups
```

This creates a cron job that runs at 2:00 AM daily.

### View Scheduled Backups
```bash
crontab -l | grep backup
```

### Remove Scheduled Backups
```bash
crontab -e
# Delete the workstation_backup.sh line
```

## Customize Exclusions
Duration: 1

The default exclude patterns are defined in the script:

```bash
EXCLUDE_PATTERNS=(
    ".cache"
    ".local/share/Trash"
    ".npm/_cacache"
    "node_modules"
    ".venv"
    "venv"
    "*.log"
)
```

To customize, edit the script or use `gsutil rsync` directly with your own `-x` patterns.

## Backup Best Practices
Duration: 2

### Storage Location
Use a dedicated bucket or folder:
```
gs://my-project-backups/workstations/USER-NAME/
```

### Retention Policy
Set up lifecycle rules on your GCS bucket to auto-delete old backups:

```bash
# Delete backups older than 30 days
gsutil lifecycle set lifecycle.json gs://your-bucket
```

Example `lifecycle.json`:
```json
{
  "rule": [{
    "action": {"type": "Delete"},
    "condition": {"age": 30, "matchesPrefix": ["workstation-backups/"]}
  }]
}
```

### Before Major Changes
Always backup before:
- Major software updates
- Configuration changes
- Experimenting with new tools

## Congratulations
Duration: 1

You now have backup and restore capabilities for your workstation!

### What you learned
- Creating manual backups
- Listing and restoring backups
- Scheduling automatic backups
- Backup best practices

### Next steps
- Set up scheduled daily backups
- Configure GCS lifecycle rules
- Document your bucket location
