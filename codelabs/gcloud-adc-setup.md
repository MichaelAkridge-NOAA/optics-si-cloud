# GCloud ADC Setup for Cloud Workstations

## Overview

Duration: 3 minutes

This guide configures **Application Default Credentials (ADC)** with proper scopes to fix GCS access issues on Cloud Workstations.

### The Problem

Cloud Workstation VMs often have **limited OAuth scopes**. You might see errors like:

```
403 Forbidden: Provided scope(s) are not authorized
```

This happens when applications (Label Studio, Python scripts, etc.) try to access Google Cloud Storage.

**Common symptoms:**
- Can read from GCS but can't write
- Can list buckets but can't upload
- "Permission denied" when saving annotations

### The Solution

ADC lets you authenticate with your own user account and full scopes, bypassing VM limitations.

### Prerequisites

- A Google Cloud Workstation
- `gcloud` CLI (pre-installed on workstations)
- A Google account with access to your GCS buckets

## Run the Setup Script

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_gcloud_adc.sh | bash
```

The script will:

1. Check your current gcloud configuration
2. Show VM OAuth scopes (if on GCE)
3. Check existing ADC credentials
4. Set up ADC with full scopes

## Authenticate

When prompted, a browser window will open.

1. Sign in with your Google account
2. Grant the requested permissions:
   - Cloud Platform (full access)
   - Cloud Storage (full control)
   - BigQuery

## Test Access

### Test with gsutil

```bash
# List your buckets
gsutil ls

# List contents of a specific bucket
gsutil ls gs://your-bucket-name/

# Upload a test file
echo "test" > /tmp/test.txt
gsutil cp /tmp/test.txt gs://your-bucket-name/
```

### Test in Python

```python
from google.cloud import storage

client = storage.Client()

# List buckets
for bucket in client.list_buckets():
    print(bucket.name)

# Upload a file
bucket = client.bucket('your-bucket-name')
blob = bucket.blob('test.txt')
blob.upload_from_string('Hello, World!')
```

## Manual Setup (Alternative)

If you prefer to run the command directly:

```bash
gcloud auth application-default login \
    --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/devstorage.full_control,https://www.googleapis.com/auth/bigquery"
```

## How It Works

ADC credentials are stored in:

```
~/.config/gcloud/application_default_credentials.json
```

Applications using Google Cloud client libraries (Python, Node.js, Go, etc.) automatically find and use this file.

### Credential Hierarchy

Google Cloud libraries check credentials in this order:

1. `GOOGLE_APPLICATION_CREDENTIALS` environment variable
2. ADC file (`~/.config/gcloud/application_default_credentials.json`)
3. GCE metadata service (VM service account)

By setting up ADC, your user credentials take precedence over limited VM scopes.

## Persistence

✓ **ADC persists across restarts** — The credentials file is in your home directory.

## Troubleshooting

### Still getting 403 errors

1. **Check account access:**
   ```bash
   gcloud config get-value account
   ```
   Make sure this account has IAM permissions on the bucket.

2. **Check bucket permissions:**
   - Go to Cloud Console → Cloud Storage → Your Bucket
   - Click "Permissions" tab
   - Verify your account has the needed role (e.g., Storage Admin)

3. **Check the project:**
   ```bash
   gcloud config get-value project
   ```
   Ensure you're working in the correct project.

### Revoke and re-authenticate

```bash
gcloud auth application-default revoke
gcloud auth application-default login --scopes="https://www.googleapis.com/auth/cloud-platform,https://www.googleapis.com/auth/devstorage.full_control"
```

### View current ADC info

```bash
cat ~/.config/gcloud/application_default_credentials.json
```

### Test token generation

```bash
gcloud auth application-default print-access-token
```

If this fails, your ADC is not properly configured.

## Using with Label Studio

After setting up ADC, Label Studio can:

- **Read images from GCS:** Use `gs://bucket/path` as source storage
- **Write annotations to GCS:** Use `gs://bucket/path` as target storage

Make sure your bucket has CORS configured:

```bash
cat > /tmp/cors.json << 'EOF'
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
EOF

gsutil cors set /tmp/cors.json gs://your-bucket-name
```

## Security Notes

- ADC credentials are tied to **your user account**, not the VM
- Credentials are stored locally in `~/` (not shared)
- Revoke when no longer needed: `gcloud auth application-default revoke`
- For production, consider using a service account instead
