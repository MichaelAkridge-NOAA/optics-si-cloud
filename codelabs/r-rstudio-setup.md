# R + RStudio Server Setup for Cloud Workstations
id: r-rstudio-setup
title: R + RStudio Server Setup for Cloud Workstations
summary: Install R and RStudio Server for browser-based R data science workflows.
authors: Michael Akridge
categories: Cloud, R, RStudio
environments: Web
status: Published
tags: cloud, r, rstudio, data-science, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This guide installs **R** and **RStudio Server** on a Google Cloud Workstation.

### What you'll get
- R + common data-science packages
- RStudio Server on port `8787`
- Management commands: `rstudio-start`, `rstudio-stop`, `rstudio-restart`, `rstudio-status`, `rstudio-logs`

### Prerequisites
- Ubuntu-based Google Cloud Workstation
- `sudo` access

## Install R + RStudio Server
Duration: 5

Run:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_r_rstudio.sh | bash
```

Optional: install a specific RStudio Server version:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_r_rstudio.sh | bash -s -- 2026.01.1-403
```

## Access RStudio Server
Duration: 1

Open the Cloud Workstation forwarded port URL for `8787`.

Local check:

```bash
curl -I http://localhost:8787
```

## Management Commands
Duration: 2

```bash
rstudio-status
rstudio-restart
rstudio-logs
```

## Installing Packages, Libraries, and Additional Resources
Duration: 2

🚨 **Important:** On custom NOAA Fisheries workstations, install packages in your home directory so they persist across sessions.

For R/RStudio workflows, use a user library path:

```r
install.packages("package_name", lib="~/Rlibs")
```

Optional one-time setup in R to make this default:

```r
dir.create("~/Rlibs", showWarnings = FALSE, recursive = TRUE)
.libPaths(c("~/Rlibs", .libPaths()))
```

## Shared Workstation Notes
Duration: 1

If multiple people share a workstation, ensure each user is granted access in Cloud Workstations/IAM. Otherwise the service may run but users still cannot open the forwarded URL.

## Troubleshooting
Duration: 2

### 503 on port 8787
- Wait 30-60 seconds after startup
- Check service status:

```bash
rstudio-status
sudo systemctl status rstudio-server --no-pager
```

### Service not starting
```bash
sudo journalctl -u rstudio-server -n 100 --no-pager
```

## Next Steps
Duration: 1

- Add project-level `.Rprofile`
- Install domain packages (`terra`, `stars`, `sf`, `arrow`)
- Add Quarto for publishing
