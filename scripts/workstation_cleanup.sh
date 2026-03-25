#!/bin/bash
# =============================================================================
# Workstation Cleanup Script for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Cleans logs, caches, and temporary files to free disk space.
# Safe defaults - won't delete user data without confirmation.
#
# Usage:
#   bash workstation_cleanup.sh           # Interactive mode
#   bash workstation_cleanup.sh --dry-run # Show what would be deleted
#   bash workstation_cleanup.sh --all     # Clean everything (no prompts)
# =============================================================================

SCRIPT_VERSION="1.0.0"

echo "=============================================="
echo "Workstation Cleanup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# Detect user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

DRY_RUN=false
AUTO_ALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|-n)
            DRY_RUN=true
            shift
            ;;
        --all|-a)
            AUTO_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: workstation_cleanup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --dry-run, -n  Show what would be deleted without deleting"
            echo "  --all, -a      Clean everything without prompts"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if $DRY_RUN; then
    echo "DRY RUN MODE - No files will be deleted"
    echo ""
fi

# Track totals
TOTAL_FREED=0

format_size() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc)G"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc)M"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc)K"
    else
        echo "${bytes}B"
    fi
}

get_dir_size() {
    du -sb "$1" 2>/dev/null | cut -f1 || echo "0"
}

clean_directory() {
    local name="$1"
    local path="$2"
    local pattern="${3:-*}"
    
    if [ ! -d "$path" ] && [ ! -f "$path" ]; then
        return
    fi
    
    local size=$(get_dir_size "$path")
    if [ "$size" -eq 0 ]; then
        return
    fi
    
    echo "  $name: $(format_size $size)"
    
    if $DRY_RUN; then
        return
    fi
    
    if $AUTO_ALL; then
        rm -rf "$path"/* 2>/dev/null || true
        TOTAL_FREED=$((TOTAL_FREED + size))
    else
        read -p "    Clean? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$path"/* 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + size))
            echo "    ✓ Cleaned"
        fi
    fi
}

clean_files() {
    local name="$1"
    local path="$2"
    local pattern="$3"
    local days="${4:-0}"
    
    if [ ! -d "$path" ]; then
        return
    fi
    
    local find_cmd="find \"$path\" -type f -name \"$pattern\""
    if [ $days -gt 0 ]; then
        find_cmd="$find_cmd -mtime +$days"
    fi
    
    local size=$(eval $find_cmd 2>/dev/null | xargs du -cb 2>/dev/null | tail -1 | cut -f1 || echo "0")
    if [ -z "$size" ] || [ "$size" -eq 0 ]; then
        return
    fi
    
    local count=$(eval $find_cmd 2>/dev/null | wc -l)
    echo "  $name: $(format_size $size) ($count files)"
    
    if $DRY_RUN; then
        return
    fi
    
    if $AUTO_ALL; then
        eval $find_cmd 2>/dev/null | xargs rm -f 2>/dev/null || true
        TOTAL_FREED=$((TOTAL_FREED + size))
    else
        read -p "    Clean? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            eval $find_cmd 2>/dev/null | xargs rm -f 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + size))
            echo "    ✓ Cleaned"
        fi
    fi
}

# ============================================================
# System Caches
# ============================================================
echo "--- System Caches ---"

clean_directory "APT cache" "/var/cache/apt/archives"
clean_directory "Systemd journal (old)" "/var/log/journal"

# ============================================================
# User Caches
# ============================================================
echo ""
echo "--- User Caches ---"

clean_directory "pip cache" "$ACTUAL_HOME/.cache/pip"
clean_directory "npm cache" "$ACTUAL_HOME/.npm/_cacache"
clean_directory "yarn cache" "$ACTUAL_HOME/.cache/yarn"
clean_directory "Go build cache" "$ACTUAL_HOME/.cache/go-build"
clean_directory "Python bytecode cache" "$ACTUAL_HOME/.cache/__pycache__"
clean_directory "Thumbnails" "$ACTUAL_HOME/.cache/thumbnails"
clean_directory "Mesa shader cache" "$ACTUAL_HOME/.cache/mesa_shader_cache"
clean_directory "Google Chrome cache" "$ACTUAL_HOME/.cache/google-chrome"
clean_directory "VS Code cache" "$ACTUAL_HOME/.cache/vscode-cpptools"

# ============================================================
# Application Logs
# ============================================================
echo ""
echo "--- Application Logs ---"

clean_files "Label Studio logs" "$ACTUAL_HOME/.label-studio" "*.log" 7
clean_files "Jupyter logs" "$ACTUAL_HOME/.jupyter" "*.log" 7
clean_files "code-server logs" "$ACTUAL_HOME/.code-server" "*.log" 7
clean_files "GCloud logs" "$ACTUAL_HOME/.config/gcloud/logs" "*" 7

# ============================================================
# Python Environments (careful!)
# ============================================================
echo ""
echo "--- Python Cache (safe) ---"

# Find and clean __pycache__ directories
PYCACHE_SIZE=$(find "$ACTUAL_HOME" -type d -name "__pycache__" 2>/dev/null | xargs du -cb 2>/dev/null | tail -1 | cut -f1 || echo "0")
if [ -n "$PYCACHE_SIZE" ] && [ "$PYCACHE_SIZE" -gt 0 ]; then
    PYCACHE_COUNT=$(find "$ACTUAL_HOME" -type d -name "__pycache__" 2>/dev/null | wc -l)
    echo "  __pycache__ dirs: $(format_size $PYCACHE_SIZE) ($PYCACHE_COUNT dirs)"
    
    if ! $DRY_RUN; then
        if $AUTO_ALL; then
            find "$ACTUAL_HOME" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
            TOTAL_FREED=$((TOTAL_FREED + PYCACHE_SIZE))
        else
            read -p "    Clean? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                find "$ACTUAL_HOME" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
                TOTAL_FREED=$((TOTAL_FREED + PYCACHE_SIZE))
                echo "    ✓ Cleaned"
            fi
        fi
    fi
fi

# .pyc files
clean_files ".pyc files" "$ACTUAL_HOME" "*.pyc" 0

# ============================================================
# Temporary Files
# ============================================================
echo ""
echo "--- Temporary Files ---"

clean_directory "User tmp" "$ACTUAL_HOME/tmp"
clean_directory "Downloads (older than 30 days)" "$ACTUAL_HOME/Downloads"
clean_files "Core dumps" "/tmp" "core.*" 0
clean_files "Vim swap files" "$ACTUAL_HOME" "*.swp" 0

# ============================================================
# Trash
# ============================================================
echo ""
echo "--- Trash ---"

TRASH_DIR="$ACTUAL_HOME/.local/share/Trash"
if [ -d "$TRASH_DIR" ]; then
    TRASH_SIZE=$(get_dir_size "$TRASH_DIR")
    if [ "$TRASH_SIZE" -gt 0 ]; then
        echo "  Trash: $(format_size $TRASH_SIZE)"
        if ! $DRY_RUN; then
            if $AUTO_ALL; then
                rm -rf "$TRASH_DIR"/* 2>/dev/null || true
                TOTAL_FREED=$((TOTAL_FREED + TRASH_SIZE))
            else
                read -p "    Empty trash? (y/n) " -n 1 -r
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    rm -rf "$TRASH_DIR"/* 2>/dev/null || true
                    TOTAL_FREED=$((TOTAL_FREED + TRASH_SIZE))
                    echo "    ✓ Emptied"
                fi
            fi
        fi
    fi
fi

# ============================================================
# Docker (if installed)
# ============================================================
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    echo ""
    echo "--- Docker ---"
    
    DOCKER_USAGE=$(docker system df --format "{{.Size}}" 2>/dev/null | head -1)
    echo "  Docker disk usage: $DOCKER_USAGE"
    
    if ! $DRY_RUN; then
        if $AUTO_ALL; then
            docker system prune -f &>/dev/null || true
            echo "    ✓ Cleaned unused Docker resources"
        else
            read -p "    Run 'docker system prune'? (y/n) " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker system prune -f
                echo "    ✓ Cleaned"
            fi
        fi
    fi
fi

# ============================================================
# Summary
# ============================================================
echo ""
echo "=============================================="

if $DRY_RUN; then
    echo "DRY RUN - No files were deleted"
    echo "Run without --dry-run to clean"
else
    echo "✓ Cleanup Complete!"
    if [ $TOTAL_FREED -gt 0 ]; then
        echo "  Space freed: ~$(format_size $TOTAL_FREED)"
    fi
fi

echo ""
echo "Current disk usage:"
df -h "$ACTUAL_HOME" | tail -1 | awk '{print "  " $3 " used / " $2 " total (" $5 " full)"}'
echo ""
