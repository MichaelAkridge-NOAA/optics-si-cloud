# JupyterLab Setup for Cloud Workstations
id: jupyter-setup
title: JupyterLab Setup for Cloud Workstations
summary: Install JupyterLab with useful extensions in a persistent location.
authors: Michael Akridge
categories: Cloud, Jupyter, Python
environments: Web
status: Published
tags: cloud, jupyter, python, notebooks, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 3

This guide installs **JupyterLab** with useful extensions in a persistent location on your Cloud Workstation.

### What you'll get

- JupyterLab on **port 8888**
- Extensions: Git integration, LSP (code intelligence), widgets
- Management commands: `jupyter-start`, `jupyter-stop`, `jupyter-status`, `jupyter-logs`
- Pre-installed: pandas, numpy, matplotlib, seaborn, plotly

### Prerequisites

- A Google Cloud Workstation
- Terminal access

## Run the Setup Script

Duration: 2 minutes

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_jupyter.sh | bash
```

The script installs JupyterLab and starts it automatically.

## Access JupyterLab

JupyterLab runs on **port 8888**.

### Via Cloud Workstation Port Forwarding

1. Go to the Cloud Workstations console
2. Find your workstation
3. Click on the port forwarding URL for port 8888

Or construct the URL:

```
https://8888-YOUR-WORKSTATION-NAME.CLUSTER.cloudworkstations.dev
```

> **No password required** — Cloud Workstation IAM handles authentication.

## Management Commands

First, reload your shell:

```bash
source ~/.bashrc
```

Then use these commands:

| Command | Description |
|---------|-------------|
| `jupyter-start` | Start JupyterLab |
| `jupyter-stop` | Stop JupyterLab |
| `jupyter-status` | Check if running |
| `jupyter-logs` | View logs (tail -f) |

## Included Extensions

- **jupyterlab-git** — Git integration in the sidebar
- **jupyterlab-lsp** — Code intelligence (autocomplete, go-to-definition)
- **ipywidgets** — Interactive widgets

## Installing Packages, Libraries, and Additional Resources

🚨 **Important:** On custom NOAA Fisheries workstations, install packages in paths under your home directory (`~/`) so they persist across sessions.

For Python/Jupyter workflows:

```bash
pip install --user package_name
```

If you prefer to keep packages in the Jupyter virtual environment created by this setup, install there:

```bash
source ~/.jupyter-env/bin/activate
pip install your-package
```

Or install directly:

```bash
~/.jupyter-env/bin/pip install your-package
```

## Enable Auto-Start (Optional)

To start JupyterLab automatically when your workstation boots:

1. Edit `~/.bashrc`:
   ```bash
   nano ~/.bashrc
   ```

2. Find the JupyterLab auto-start section near the bottom

3. Uncomment the lines (remove the `#` at the start)

4. Save and exit

## Configuration

JupyterLab config is at:

```
~/.jupyter/jupyter_lab_config.py
```

Key settings:
- **Port:** 8888
- **Bind:** 0.0.0.0 (all interfaces)
- **Auth:** Disabled (IAM handles it)
- **Root directory:** /home/user

## Persistence

Everything persists across Cloud Workstation restarts:

- **JupyterLab environment:** `~/.jupyter-env`
- **Configuration:** `~/.jupyter`
- **Notebooks:** Save anywhere in `~/`

## Troubleshooting

### JupyterLab won't start

Check the logs:

```bash
jupyter-logs
```

Or:

```bash
cat ~/.jupyter/jupyter.log
```

### Port 8888 already in use

Stop any existing JupyterLab:

```bash
jupyter-stop
```

Then start again:

```bash
jupyter-start
```

### Extensions not showing

Rebuild JupyterLab:

```bash
~/.jupyter-env/bin/jupyter lab build
```

### Kernel dies immediately

Check available memory. JupyterLab needs ~500MB RAM.

## Using with Label Studio

If you have Label Studio running on port 8080, both can run simultaneously:

- **Label Studio:** port 8080
- **JupyterLab:** port 8888

Use port forwarding for both.
