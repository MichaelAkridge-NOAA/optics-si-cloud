#!/bin/bash
# =============================================================================
# GCloud ADC (Application Default Credentials) Setup for Cloud Workstations
# Version: 1.0.1 (2026-03-25)
# =============================================================================
# Configures Application Default Credentials with proper scopes for:
# - Google Cloud Storage (full access)
# - BigQuery
# - Cloud Platform APIs
#
# This fixes the common "Provided scope(s) are not authorized" error when
# accessing GCS from applications like Label Studio.
#
# Usage:
#   bash setup_gcloud_adc.sh
# =============================================================================

SCRIPT_VERSION="1.0.1"

echo "=============================================="
echo "GCloud ADC Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo ""

# ============================================================
# STEP 1: Check current configuration
# ============================================================
echo "[Step 1/4] Checking current gcloud configuration..."
echo ""

# Check if gcloud is available
if ! command -v gcloud &>/dev/null; then
    echo "ERROR: gcloud CLI not found."
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Current account
CURRENT_ACCOUNT=$(gcloud config get-value account 2>/dev/null)
CURRENT_PROJECT=$(gcloud config get-value project 2>/dev/null)

echo "Current account: ${CURRENT_ACCOUNT:-'(not set)'}"
echo "Current project: ${CURRENT_PROJECT:-'(not set)'}"
echo ""

# ============================================================
# STEP 2: Check VM scopes (if on GCE)
# ============================================================
echo "[Step 2/4] Checking VM OAuth scopes..."
echo ""

# Try to get VM scopes from metadata
VM_SCOPES=$(curl -sf -m 2 -H 'Metadata-Flavor: Google' \
    'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes' \
    2>/dev/null || echo "")

if [ -n "$VM_SCOPES" ]; then
    echo "VM has the following OAuth scopes:"
    echo "$VM_SCOPES" | tr ',' '\n' | sed 's/^/  - /'
    echo ""
    
    # Check for required scopes
    if echo "$VM_SCOPES" | grep -q 'cloud-platform\|devstorage.full_control'; then
        echo "✓ VM has sufficient scopes for GCS access"
    else
        echo "⚠ VM may have limited scopes. ADC login will provide additional access."
    fi
else
    echo "Not running on GCE or metadata unavailable."
fi
echo ""

# ============================================================
# STEP 3: Check current ADC
# ============================================================
echo "[Step 3/4] Checking current Application Default Credentials..."
echo ""

ADC_FILE="$HOME/.config/gcloud/application_default_credentials.json"

if [ -f "$ADC_FILE" ]; then
    ADC_TYPE=$(grep -o '"type"[^,]*' "$ADC_FILE" 2>/dev/null | cut -d'"' -f4)
    ADC_ACCOUNT=$(grep -o '"client_email"[^,]*' "$ADC_FILE" 2>/dev/null | cut -d'"' -f4)
    
    if [ -z "$ADC_ACCOUNT" ]; then
        ADC_ACCOUNT=$(grep -o '"account"[^,]*' "$ADC_FILE" 2>/dev/null | cut -d'"' -f4)
    fi
    
    echo "ADC file exists: $ADC_FILE"
    echo "  Type: ${ADC_TYPE:-'user credentials'}"
    echo "  Account: ${ADC_ACCOUNT:-'(user account)'}"
    echo ""
    
    # Test ADC
    echo "Testing ADC access..."
    if gcloud auth application-default print-access-token &>/dev/null; then
        echo "✓ ADC is valid and working"
        
        # Test GCS access
        if [ -n "$CURRENT_PROJECT" ]; then
            echo ""
            echo "Testing GCS access..."
            if gsutil ls "gs://" &>/dev/null 2>&1; then
                echo "✓ GCS access working"
            else
                echo "⚠ GCS access may be limited"
            fi
        fi
    else
        echo "✗ ADC token generation failed"
    fi
else
    echo "No ADC file found at $ADC_FILE"
    echo "Run this script to set up ADC."
fi
echo ""

# ============================================================
# STEP 4: Setup ADC with full scopes
# ============================================================
echo "[Step 4/4] Setting up Application Default Credentials..."
echo ""
echo "This will open a browser for authentication."
echo "Select your Google account and grant the requested permissions."
echo ""
echo "Required scopes:"
echo "  - https://www.googleapis.com/auth/cloud-platform"
echo "  - https://www.googleapis.com/auth/devstorage.full_control"
echo ""

read -p "Proceed with ADC setup? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "Running: gcloud auth application-default login --scopes=..."
echo ""

gcloud auth application-default login \
    --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/devstorage.full_control,https://www.googleapis.com/auth/bigquery"

if [ $? -eq 0 ]; then
    echo ""
    echo "=============================================="
    echo "✓ ADC Setup Complete!"
    echo "=============================================="
    echo ""
    echo "Application Default Credentials are now configured with full scopes."
    echo ""
    echo "Applications using ADC (like Label Studio, Python scripts, etc.)"
    echo "will now have access to:"
    echo "  - Google Cloud Storage (read/write)"
    echo "  - BigQuery"
    echo "  - Other Cloud Platform APIs"
    echo ""
    echo "Test GCS access with:"
    echo "  gsutil ls gs://YOUR-BUCKET"
    echo ""
    echo "Test in Python:"
    echo "  from google.cloud import storage"
    echo "  client = storage.Client()"
    echo "  list(client.list_buckets())"
    echo ""
else
    echo ""
    echo "ADC setup failed. Check the error above."
    exit 1
fi
