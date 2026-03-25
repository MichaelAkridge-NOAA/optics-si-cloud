# Positron Setup for Cloud Workstations
id: positron-setup
title: Positron Setup for Cloud Workstations
summary: Install Positron on Linux Cloud Workstations using official .deb releases.
authors: Michael Akridge
categories: Cloud, Positron, Data Science
environments: Web
status: Published
tags: cloud, positron, r, python, ide, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This guide installs **Positron** on Ubuntu-based Cloud Workstations.

<aside class="warning">
Positron is evolving quickly. Keep this as an optional/beta IDE path alongside RStudio/code-server for shared production workflows.
</aside>

### Prerequisites
- Ubuntu-based Cloud Workstation
- `sudo` access
- GUI session (for launching desktop apps)

## Install Positron
Duration: 4

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_positron.sh | bash
```

The script resolves the latest Linux `.deb` from Positron releases and installs it.

## Launch Positron
Duration: 1

In a GUI session:

```bash
positron
```

Or use helper:

```bash
positron-launch
```

## Verify
Duration: 1

```bash
which positron
```

## References
Duration: 1

- [Positron Downloads](https://positron.posit.co/download.html)
- [Positron Install Docs](https://positron.posit.co/install.html)

## Troubleshooting
Duration: 2

### No GUI session
If you are in SSH-only mode, desktop launch will fail. Open a GUI-capable session first (e.g., CRD/workstation IDE with desktop session).

### Install dependency errors
```bash
sudo apt-get install -f
```

## Next Steps
Duration: 1

- Pair with R + Quarto setup
- Compare workflow vs RStudio/code-server
- Decide if Positron should be default or optional for your team
