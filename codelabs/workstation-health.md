# Workstation Health Check
id: workstation-health
title: Workstation Health Check
summary: Monitor all services and system resources on your Cloud Workstation.
authors: Michael Akridge
categories: Cloud, Monitoring, Tools
environments: Web
status: Published
tags: cloud, health, monitoring, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 1

This guide covers using the unified health check script to monitor all services on your Cloud Workstation.

### What you'll learn
- Run health checks on all installed services
- Interpret health check results
- Use JSON output for automation
- Troubleshoot common issues

### Prerequisites
- Google Cloud Workstation
- One or more services installed (Label Studio, Jupyter, etc.)

## Run Health Check
Duration: 1

Run the health check script:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/workstation_health.sh | bash
```

Or if you've cloned the repo:

```bash
bash scripts/workstation_health.sh
```

## Understanding the Output
Duration: 2

The health check examines:

### System Resources
- **Disk usage** - Warning at 80%, critical at 90%
- **Memory usage** - Warning at 80%, critical at 90%
- **CPU load** - Compared against available cores

### Services Checked
- Label Studio (port 8080)
- JupyterLab (port 8888)
- code-server (port 8443)
- Docker daemon
- Python environment (pyenv, venvs)
- Google Cloud (gcloud, ADC)
- Git & SSH configuration

### Status Icons
- ✓ Green - Healthy
- ⚠ Yellow - Warning (needs attention)
- ✗ Red - Failed (action required)

## JSON Output
Duration: 1

For automation and monitoring, use JSON output:

```bash
workstation_health.sh --json
```

Example output:
```json
{
    "timestamp": "2026-03-25T10:30:00-05:00",
    "hostname": "workstation-abc123",
    "summary": {
        "passed": 8,
        "warnings": 1,
        "failed": 0
    },
    "resources": {
        "disk_percent": 45,
        "memory_percent": 62,
        "cpu_load": "0.5"
    },
    "services": [
        {"name": "label-studio", "status": "running", "port": "8080"},
        {"name": "jupyter", "status": "running", "port": "8888"}
    ]
}
```

## Troubleshooting
Duration: 2

### Service Not Running
If a service shows as not running:

```bash
# Label Studio
label-studio-restart

# JupyterLab
jupyter-start

# code-server
code-server-start

# Docker
sudo systemctl start docker
```

### High Disk Usage
Run the cleanup script:
```bash
workstation_cleanup.sh
```

### ADC Not Configured
Set up Application Default Credentials:
```bash
bash setup_gcloud_adc.sh
```

### Git Not Configured
Set up Git and SSH:
```bash
bash setup_git_ssh.sh
```

## Automate Health Checks
Duration: 1

Add a cron job for regular health checks:

```bash
# Edit crontab
crontab -e

# Add hourly health check (JSON to file)
0 * * * * /path/to/workstation_health.sh --json >> ~/.local/share/health-log.json
```

## Congratulations
Duration: 1

You now know how to monitor your Cloud Workstation health!

### What you learned
- Running health checks
- Interpreting results
- Using JSON output
- Troubleshooting issues

### Next steps
- Set up automated health checks
- Integrate with monitoring tools
- Run cleanup when disk usage is high
