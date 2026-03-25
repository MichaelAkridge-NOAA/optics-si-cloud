#!/bin/bash
# =============================================================================
# Workstation Backup Script for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Backs up persistent home directory to Google Cloud Storage.
# Supports incremental backups and easy restore.
#
# Usage:
#   bash workstation_backup.sh backup gs://your-bucket/backups
#   bash workstation_backup.sh restore gs://your-bucket/backups/backup-20260325
#   bash workstation_backup.sh list gs://your-bucket/backups
# =============================================================================

SCRIPT_VERSION="1.0.0"

echo "=============================================="
echo "Workstation Backup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

COMMAND="${1:-help}"
GCS_PATH="${2:-}"
BACKUP_NAME="${3:-backup-$(date +%Y%m%d-%H%M%S)}"

# Default exclude patterns
EXCLUDE_PATTERNS=(
    ".cache"
    ".local/share/Trash"
    ".npm/_cacache"
    ".pyenv/versions/*/lib/python*/site-packages"
    "*.pyc"
    "__pycache__"
    ".git/objects"
    "node_modules"
    ".venv"
    "venv"
    ".label-studio/venv"
    ".jupyter-env"
    ".code-server"
    "*.log"
    "*.tmp"
    ".config/gcloud/logs"
)

show_help() {
    echo "Usage: workstation_backup.sh <command> <gcs-path> [options]"
    echo ""
    echo "Commands:"
    echo "  backup <gs://bucket/path>     Backup home directory to GCS"
    echo "  restore <gs://bucket/backup>  Restore from a specific backup"
    echo "  list <gs://bucket/path>       List available backups"
    echo "  schedule <gs://bucket/path>   Set up daily automatic backups"
    echo "  help                          Show this help"
    echo ""
    echo "Examples:"
    echo "  workstation_backup.sh backup gs://my-bucket/workstation-backups"
    echo "  workstation_backup.sh list gs://my-bucket/workstation-backups"
    echo "  workstation_backup.sh restore gs://my-bucket/workstation-backups/backup-20260325-120000"
    echo ""
    echo "Excluded by default:"
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        echo "  - $pattern"
    done
}

check_gcloud() {
    if ! command -v gsutil &>/dev/null; then
        echo "ERROR: gsutil not found. Install Google Cloud SDK."
        exit 1
    fi
    
    if ! gcloud auth application-default print-access-token &>/dev/null; then
        echo "ERROR: No valid GCP credentials. Run: gcloud auth application-default login"
        exit 1
    fi
}

do_backup() {
    local dest="$GCS_PATH/$BACKUP_NAME"
    
    echo "Backing up $ACTUAL_HOME to $dest"
    echo ""
    
    # Build exclude args
    local exclude_args=""
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
        exclude_args="$exclude_args -x \"$pattern\""
    done
    
    # Create manifest of what's being backed up
    echo "Creating backup manifest..."
    find "$ACTUAL_HOME" -type f \
        ! -path "*/.cache/*" \
        ! -path "*/.local/share/Trash/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/__pycache__/*" \
        ! -path "*/venv/*" \
        ! -path "*/.venv/*" \
        ! -name "*.pyc" \
        ! -name "*.log" \
        2>/dev/null | wc -l > /tmp/backup_file_count.txt
    
    FILE_COUNT=$(cat /tmp/backup_file_count.txt)
    echo "Files to backup: ~$FILE_COUNT"
    echo ""
    
    # Perform backup using gsutil rsync
    echo "Starting backup..."
    gsutil -m rsync -r -d \
        -x "\.cache|\.local/share/Trash|node_modules|__pycache__|venv|\.venv|\.pyc$|\.log$|\.label-studio/venv|\.jupyter-env|\.code-server" \
        "$ACTUAL_HOME" "$dest"
    
    if [ $? -eq 0 ]; then
        # Save metadata
        echo "Saving backup metadata..."
        cat > /tmp/backup_metadata.json << EOF
{
    "timestamp": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "user": "$ACTUAL_USER",
    "script_version": "$SCRIPT_VERSION",
    "file_count": $FILE_COUNT
}
EOF
        gsutil cp /tmp/backup_metadata.json "$dest/.backup_metadata.json"
        
        echo ""
        echo "=============================================="
        echo "✓ Backup complete!"
        echo "=============================================="
        echo "Location: $dest"
        echo "Files: ~$FILE_COUNT"
        echo ""
        echo "To restore: workstation_backup.sh restore $dest"
    else
        echo ""
        echo "✗ Backup failed. Check errors above."
        exit 1
    fi
}

do_restore() {
    local source="$GCS_PATH"
    
    if [ -z "$source" ]; then
        echo "ERROR: Specify backup path to restore from"
        echo "Usage: workstation_backup.sh restore gs://bucket/path/backup-name"
        exit 1
    fi
    
    # Check if backup exists
    if ! gsutil ls "$source/.backup_metadata.json" &>/dev/null; then
        echo "ERROR: No backup found at $source"
        echo "Run 'workstation_backup.sh list gs://bucket/path' to see available backups"
        exit 1
    fi
    
    # Show backup info
    echo "Backup to restore:"
    gsutil cat "$source/.backup_metadata.json" 2>/dev/null | head -10
    echo ""
    
    read -p "Restore to $ACTUAL_HOME? This may overwrite existing files. (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    
    echo ""
    echo "Restoring from $source..."
    gsutil -m rsync -r "$source" "$ACTUAL_HOME"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "=============================================="
        echo "✓ Restore complete!"
        echo "=============================================="
        echo ""
        echo "NOTE: You may need to:"
        echo "  1. Run 'source ~/.bashrc' to reload environment"
        echo "  2. Reinstall venvs (Label Studio, Jupyter, etc.)"
    else
        echo "✗ Restore failed. Check errors above."
        exit 1
    fi
}

do_list() {
    if [ -z "$GCS_PATH" ]; then
        echo "ERROR: Specify GCS path"
        echo "Usage: workstation_backup.sh list gs://bucket/path"
        exit 1
    fi
    
    echo "Available backups in $GCS_PATH:"
    echo ""
    
    # List directories that contain backup metadata
    gsutil ls -d "$GCS_PATH/backup-*" 2>/dev/null | while read backup; do
        backup_name=$(basename "$backup")
        if gsutil -q stat "${backup}.backup_metadata.json" 2>/dev/null; then
            timestamp=$(gsutil cat "${backup}.backup_metadata.json" 2>/dev/null | grep timestamp | cut -d'"' -f4)
            echo "  $backup_name  ($timestamp)"
        else
            echo "  $backup_name"
        fi
    done
    
    echo ""
}

do_schedule() {
    if [ -z "$GCS_PATH" ]; then
        echo "ERROR: Specify GCS path for scheduled backups"
        exit 1
    fi
    
    SCRIPT_PATH="$ACTUAL_HOME/.local/bin/workstation_backup.sh"
    
    # Copy this script to local bin
    cp "$0" "$SCRIPT_PATH" 2>/dev/null || true
    chmod +x "$SCRIPT_PATH"
    
    # Create cron job for daily backup at 2 AM
    CRON_CMD="0 2 * * * $SCRIPT_PATH backup $GCS_PATH >> $ACTUAL_HOME/.local/share/backup.log 2>&1"
    
    # Add to crontab if not already present
    if ! crontab -l 2>/dev/null | grep -q "workstation_backup.sh"; then
        (crontab -l 2>/dev/null; echo "$CRON_CMD") | crontab -
        echo "✓ Daily backup scheduled at 2:00 AM"
        echo "  Destination: $GCS_PATH"
        echo "  Log: ~/.local/share/backup.log"
    else
        echo "Backup already scheduled. Current crontab:"
        crontab -l | grep workstation_backup
    fi
}

# Main
case "$COMMAND" in
    backup)
        check_gcloud
        do_backup
        ;;
    restore)
        check_gcloud
        do_restore
        ;;
    list)
        check_gcloud
        do_list
        ;;
    schedule)
        check_gcloud
        do_schedule
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo ""
        show_help
        exit 1
        ;;
esac
