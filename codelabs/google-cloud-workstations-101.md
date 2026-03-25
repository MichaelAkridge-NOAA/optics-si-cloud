# Google Cloud Workstations 101
id: google-cloud-workstations-101
title: Google Cloud Workstations 101
summary: Core concepts for ports, persistence, auth, startup behavior, and common troubleshooting.
authors: Michael Akridge
categories: Cloud Workstation, Getting Started, Operations
environments: Web
status: Published
tags: cloud-workstations, ports, persistence, auth, troubleshooting
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 3

This guide explains the most important Cloud Workstations behaviors before installing tools.

## Core Concepts
Duration: 3

### 1) Authentication model
Cloud Workstations web access is protected by IAM. Most local services behind forwarded ports do not need separate external auth setup.

### 2) Persistence model
Only your home directory (`~/`) persists reliably across restarts. Install scripts in this repo store data/config in persistent paths.

### 3) Port forwarding model
Services should bind to `0.0.0.0` and then be accessed through Workstation forwarded URLs.

Common ports in this repo:
- `8080` Label Studio / annotation tools
- `8443` code-server
- `8787` RStudio Server
- `8888` JupyterLab

## Startup Behavior
Duration: 2

Some services autostart at boot; others are started on demand. If a port shows 503 immediately after restart, wait 30-120 seconds and check service status/logs.

## ADC (Application Default Credentials)
Duration: 2

If tools need Google Cloud APIs (`gs://`, storage SDKs, etc.), configure ADC:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_gcloud_adc.sh | bash
```

For advanced scope needs, run `gcloud auth application-default login` with explicit scopes.

## Common Commands: Data Movement + Storage + OS Basics
Duration: 4

Use this as a practical command reference for daily workstation usage.

### Linux 101 (Quick Essentials)

If you're new to Linux, these are the most useful day-1 commands.

### Navigation + files

```bash
# where am I?
pwd

# list files
ls
ls -la

# change directory
cd ~/          # go to home
cd ..          # go up one folder

# create/remove folders
mkdir my_folder
rm -rf old_folder
```

### View + edit files

```bash
# print file contents
cat README.md

# view first/last lines
head -20 file.txt
tail -20 file.txt

# search inside files
grep -i "label" file.txt
```

### Download files

```bash
# download file
wget https://example.com/file.sh

# or with curl
curl -L -o file.sh https://example.com/file.sh
```

### Process/session basics

```bash
# show running processes
ps aux | head

# kill process by name
pkill -f jupyter

# use tmux for persistent terminal sessions
tmux new -s work
tmux attach -t work
```

### Zip and unzip

```bash
# zip a folder
zip -r archive.zip my_folder/

# unzip
unzip archive.zip
```

### Permissions and executable scripts

```bash
# make script executable
chmod +x script.sh

# run script
./script.sh
```

### Command history tips

```bash
# show command history
history

# show last 50 commands
history 50

# search command history
history | grep docker

# rerun previous command
!!

# rerun command by history number
!123
```

Optional: append history across sessions (add to `~/.bashrc`):

```bash
shopt -s histappend
PROMPT_COMMAND='history -a'
```

<aside class="positive">
Tip: If unsure what a command does, run `command --help` (example: `ls --help`).
</aside>

### Local file operations

```bash
# copy/move files
cp source.txt dest.txt
mv old_name.txt new_name.txt

# copy folders recursively
cp -r data/ backup_data/

# check sizes and free space
du -sh ~/data
df -h
```

### Compress / archive data

```bash
# create tar.gz archive
tar -czf dataset_backup.tar.gz ~/data

# extract archive
tar -xzf dataset_backup.tar.gz
```

### Google Cloud Storage (recommended: `gcloud storage`)

```bash
# list bucket contents
gcloud storage ls gs://YOUR-BUCKET/

# copy file to bucket
gcloud storage cp local_file.csv gs://YOUR-BUCKET/path/

# copy folder recursively
gcloud storage cp --recursive ~/data gs://YOUR-BUCKET/data/

# sync local folder -> bucket folder
gcloud storage rsync ~/data gs://YOUR-BUCKET/data --recursive
```

### `gsutil` equivalents (still widely used)

```bash
# list bucket
gsutil ls gs://YOUR-BUCKET/

# parallel copy (faster for many files)
gsutil -m cp -r ~/data gs://YOUR-BUCKET/

# sync local folder -> bucket folder
gsutil -m rsync -r ~/data gs://YOUR-BUCKET/data
```

### Quick verification

```bash
# verify auth and project context
gcloud auth list
gcloud config get-value project

# test GCS access
gcloud storage ls gs://YOUR-BUCKET/ | head
```

## Quick Health Workflow
Duration: 2

```bash
workstation_health.sh
workstation_cleanup.sh --dry-run
workstation_backup.sh list gs://YOUR-BUCKET/PATH
```

## Common Troubleshooting
Duration: 3

### 503 on forwarded port
- Service may still be starting
- Verify process/status commands
- Check service logs

### GCS access fails
- Confirm ADC setup
- Confirm bucket IAM permissions
- Re-auth if tokens expired

### Service works after SSH only
- Check autostart method and restart scripts

## Next Steps
Duration: 1

- Run Data Science Stack or Dev Stack codelab
- Configure ADC if using cloud data
- Add backup + health checks for long-running environments
