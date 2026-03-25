#!/bin/bash
# =============================================================================
# Workstation Health Check Script for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Unified health check for all installed services and system status.
# Quick overview of what's running and what needs attention.
#
# Usage:
#   bash workstation_health.sh
#   bash workstation_health.sh --json  # Output as JSON
# =============================================================================

SCRIPT_VERSION="1.0.0"

JSON_OUTPUT=false
if [ "$1" = "--json" ]; then
    JSON_OUTPUT=true
fi

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect user
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# JSON accumulator
JSON_SERVICES=()

print_header() {
    if ! $JSON_OUTPUT; then
        echo ""
        echo -e "${BLUE}=== $1 ===${NC}"
    fi
}

check_ok() {
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    if ! $JSON_OUTPUT; then
        echo -e "  ${GREEN}✓${NC} $1"
    fi
}

check_fail() {
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
    if ! $JSON_OUTPUT; then
        echo -e "  ${RED}✗${NC} $1"
    fi
}

check_warn() {
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
    if ! $JSON_OUTPUT; then
        echo -e "  ${YELLOW}⚠${NC} $1"
    fi
}

check_info() {
    if ! $JSON_OUTPUT; then
        echo -e "    $1"
    fi
}

add_service_json() {
    local name="$1"
    local status="$2"
    local version="$3"
    local port="$4"
    local details="$5"
    JSON_SERVICES+=("{\"name\":\"$name\",\"status\":\"$status\",\"version\":\"$version\",\"port\":\"$port\",\"details\":\"$details\"}")
}

if ! $JSON_OUTPUT; then
    echo "=============================================="
    echo "Workstation Health Check v${SCRIPT_VERSION}"
    echo "=============================================="
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S %Z')"
    echo "Host: $(hostname)"
fi

# ============================================================
# System Resources
# ============================================================
print_header "System Resources"

# Disk usage
DISK_USAGE=$(df -h "$ACTUAL_HOME" | tail -1)
DISK_PERCENT=$(echo "$DISK_USAGE" | awk '{print $5}' | tr -d '%')
DISK_AVAIL=$(echo "$DISK_USAGE" | awk '{print $4}')

if [ "$DISK_PERCENT" -gt 90 ]; then
    check_fail "Disk: ${DISK_PERCENT}% used ($DISK_AVAIL available) - CRITICAL"
elif [ "$DISK_PERCENT" -gt 80 ]; then
    check_warn "Disk: ${DISK_PERCENT}% used ($DISK_AVAIL available)"
else
    check_ok "Disk: ${DISK_PERCENT}% used ($DISK_AVAIL available)"
fi

# Memory
MEM_INFO=$(free -h | grep Mem)
MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
MEM_USED=$(echo "$MEM_INFO" | awk '{print $3}')
MEM_PERCENT=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')

if [ "$MEM_PERCENT" -gt 90 ]; then
    check_fail "Memory: ${MEM_PERCENT}% used ($MEM_USED / $MEM_TOTAL)"
elif [ "$MEM_PERCENT" -gt 80 ]; then
    check_warn "Memory: ${MEM_PERCENT}% used ($MEM_USED / $MEM_TOTAL)"
else
    check_ok "Memory: ${MEM_PERCENT}% used ($MEM_USED / $MEM_TOTAL)"
fi

# CPU load
LOAD=$(cat /proc/loadavg | cut -d' ' -f1)
CORES=$(nproc)
LOAD_PERCENT=$(echo "$LOAD $CORES" | awk '{printf "%.0f", ($1/$2)*100}')

if [ "$LOAD_PERCENT" -gt 100 ]; then
    check_warn "CPU Load: $LOAD (${LOAD_PERCENT}% of $CORES cores)"
else
    check_ok "CPU Load: $LOAD (${LOAD_PERCENT}% of $CORES cores)"
fi

# ============================================================
# Label Studio
# ============================================================
print_header "Label Studio"

LS_HOME="$ACTUAL_HOME/.label-studio"
if [ -d "$LS_HOME" ]; then
    if pgrep -f "label-studio start" > /dev/null; then
        LS_VERSION=$("$LS_HOME/venv/bin/pip" show label-studio 2>/dev/null | grep -i '^Version:' | sed 's/Version: *//' || echo "unknown")
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8080 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            check_ok "Running (v$LS_VERSION) - http://localhost:8080"
            add_service_json "label-studio" "running" "$LS_VERSION" "8080" "HTTP $HTTP_CODE"
        else
            check_warn "Process running but HTTP $HTTP_CODE on :8080"
            add_service_json "label-studio" "degraded" "$LS_VERSION" "8080" "HTTP $HTTP_CODE"
        fi
    else
        check_fail "Not running"
        check_info "Start with: label-studio-restart"
        add_service_json "label-studio" "stopped" "" "8080" ""
    fi
else
    check_info "Not installed"
    add_service_json "label-studio" "not_installed" "" "" ""
fi

# ============================================================
# JupyterLab
# ============================================================
print_header "JupyterLab"

JUPYTER_HOME="$ACTUAL_HOME/.jupyter-env"
if [ -d "$JUPYTER_HOME" ]; then
    if pgrep -f "jupyter-lab" > /dev/null; then
        JUPYTER_VERSION=$("$JUPYTER_HOME/bin/jupyter" --version 2>/dev/null | grep jupyterlab | awk '{print $NF}' || echo "unknown")
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8888 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            check_ok "Running (v$JUPYTER_VERSION) - http://localhost:8888"
            add_service_json "jupyter" "running" "$JUPYTER_VERSION" "8888" "HTTP $HTTP_CODE"
        else
            check_warn "Process running but HTTP $HTTP_CODE on :8888"
            add_service_json "jupyter" "degraded" "$JUPYTER_VERSION" "8888" "HTTP $HTTP_CODE"
        fi
    else
        check_fail "Not running"
        check_info "Start with: jupyter-start"
        add_service_json "jupyter" "stopped" "" "8888" ""
    fi
else
    check_info "Not installed"
    add_service_json "jupyter" "not_installed" "" "" ""
fi

# ============================================================
# code-server
# ============================================================
print_header "code-server"

CODE_SERVER_HOME="$ACTUAL_HOME/.code-server"
if [ -d "$CODE_SERVER_HOME" ]; then
    if pgrep -f "code-server" > /dev/null; then
        CS_VERSION=$("$CODE_SERVER_HOME/bin/code-server" --version 2>/dev/null | head -1 || echo "unknown")
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 5 http://localhost:8443 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ]; then
            check_ok "Running (v$CS_VERSION) - http://localhost:8443"
            add_service_json "code-server" "running" "$CS_VERSION" "8443" "HTTP $HTTP_CODE"
        else
            check_warn "Process running but HTTP $HTTP_CODE on :8443"
            add_service_json "code-server" "degraded" "$CS_VERSION" "8443" "HTTP $HTTP_CODE"
        fi
    else
        check_fail "Not running"
        check_info "Start with: code-server-start"
        add_service_json "code-server" "stopped" "" "8443" ""
    fi
else
    check_info "Not installed"
    add_service_json "code-server" "not_installed" "" "" ""
fi

# ============================================================
# Docker
# ============================================================
print_header "Docker"

if command -v docker &>/dev/null; then
    if docker info &>/dev/null 2>&1; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
        CONTAINERS_RUNNING=$(docker ps -q 2>/dev/null | wc -l)
        check_ok "Running (v$DOCKER_VERSION) - $CONTAINERS_RUNNING containers"
        add_service_json "docker" "running" "$DOCKER_VERSION" "" "$CONTAINERS_RUNNING containers"
    else
        check_fail "Installed but daemon not running"
        check_info "Start with: sudo systemctl start docker"
        add_service_json "docker" "stopped" "" "" ""
    fi
else
    check_info "Not installed"
    add_service_json "docker" "not_installed" "" "" ""
fi

# ============================================================
# Python Environment
# ============================================================
print_header "Python Environment"

if [ -d "$ACTUAL_HOME/.pyenv" ]; then
    PYENV_VERSION=$("$ACTUAL_HOME/.pyenv/bin/pyenv" version-name 2>/dev/null || echo "unknown")
    check_ok "pyenv installed (Python $PYENV_VERSION)"
else
    check_info "pyenv not installed"
fi

if [ -d "$ACTUAL_HOME/.venvs/default" ]; then
    check_ok "Default venv exists"
else
    check_info "Default venv not created"
fi

# ============================================================
# GCloud / ADC
# ============================================================
print_header "Google Cloud"

if command -v gcloud &>/dev/null; then
    GCLOUD_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
    GCLOUD_PROJECT=$(gcloud config get-value project 2>/dev/null)
    
    if [ -n "$GCLOUD_ACCOUNT" ]; then
        check_ok "Logged in as: $GCLOUD_ACCOUNT"
    else
        check_warn "Not logged in"
    fi
    
    if [ -n "$GCLOUD_PROJECT" ]; then
        check_ok "Project: $GCLOUD_PROJECT"
    else
        check_warn "No project set"
    fi
    
    # Check ADC
    if [ -f "$ACTUAL_HOME/.config/gcloud/application_default_credentials.json" ]; then
        if gcloud auth application-default print-access-token &>/dev/null 2>&1; then
            check_ok "ADC configured and valid"
        else
            check_warn "ADC exists but token expired"
        fi
    else
        check_warn "ADC not configured (run setup_gcloud_adc.sh)"
    fi
else
    check_fail "gcloud CLI not installed"
fi

# ============================================================
# Git / SSH
# ============================================================
print_header "Git & SSH"

GIT_NAME=$(git config --global user.name 2>/dev/null)
GIT_EMAIL=$(git config --global user.email 2>/dev/null)

if [ -n "$GIT_NAME" ] && [ -n "$GIT_EMAIL" ]; then
    check_ok "Git configured: $GIT_NAME <$GIT_EMAIL>"
else
    check_warn "Git identity not configured"
fi

if [ -f "$ACTUAL_HOME/.ssh/id_ed25519" ]; then
    check_ok "SSH key exists: ~/.ssh/id_ed25519"
elif [ -f "$ACTUAL_HOME/.ssh/id_rsa" ]; then
    check_ok "SSH key exists: ~/.ssh/id_rsa"
else
    check_warn "No SSH key found"
fi

# ============================================================
# Summary
# ============================================================
if ! $JSON_OUTPUT; then
    echo ""
    echo "=============================================="
    echo "Summary"
    echo "=============================================="
    
    TOTAL=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))
    
    echo -e "  ${GREEN}Passed:${NC}  $CHECKS_PASSED"
    echo -e "  ${YELLOW}Warning:${NC} $CHECKS_WARNING"
    echo -e "  ${RED}Failed:${NC}  $CHECKS_FAILED"
    echo ""
    
    if [ $CHECKS_FAILED -eq 0 ] && [ $CHECKS_WARNING -eq 0 ]; then
        echo -e "${GREEN}✓ All systems healthy!${NC}"
    elif [ $CHECKS_FAILED -eq 0 ]; then
        echo -e "${YELLOW}⚠ Some warnings to address${NC}"
    else
        echo -e "${RED}✗ Some services need attention${NC}"
    fi
    echo ""
else
    # JSON output
    SERVICES_JSON=$(IFS=,; echo "${JSON_SERVICES[*]}")
    cat << EOF
{
    "timestamp": "$(date -Iseconds)",
    "hostname": "$(hostname)",
    "summary": {
        "passed": $CHECKS_PASSED,
        "warnings": $CHECKS_WARNING,
        "failed": $CHECKS_FAILED
    },
    "resources": {
        "disk_percent": $DISK_PERCENT,
        "memory_percent": $MEM_PERCENT,
        "cpu_load": "$LOAD"
    },
    "services": [$SERVICES_JSON]
}
EOF
fi
