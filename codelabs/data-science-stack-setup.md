# Data Science Stack Setup for Cloud Workstations
id: data-science-stack-setup
title: Data Science Stack Setup for Cloud Workstations
summary: Install a full data science stack (Python, Jupyter, RStudio, Quarto) with optional QGIS and Positron.
authors: Michael Akridge
categories: Cloud, Data Science, Setup
environments: Web
status: Published
tags: cloud, data-science, python, rstudio, quarto, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This codelab installs a practical data science workstation stack with one command.

### Before you begin
- Expected setup time: ~15-30 minutes (depending on internet speed)
- Requires `sudo` access
- Some optional components are GUI apps (QGIS, Positron)

### Default stack
- Python environment (`setup_python_env.sh`)
- JupyterLab (`setup_jupyter.sh`)
- R + RStudio Server (`setup_r_rstudio.sh`)
- Quarto (`setup_quarto.sh`)

### What this enables
- Jupyter workflows on port `8888`
- RStudio workflows on port `8787`
- Reproducible report publishing with Quarto
- Optional geospatial desktop tooling and IDE add-ons

### Optional add-ons
- QGIS + GDAL (`--with-qgis`)
- Positron (`--with-positron`)

### Do I need ADC here?
If your projects read/write Google Cloud Storage (`gs://`) data, run ADC setup after install:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_gcloud_adc.sh | bash
```

If you only work with local files, ADC is optional.

## Install Default Stack
Duration: 5

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_data_science_stack.sh | bash
```

## Install with Optional Components
Duration: 3

Include QGIS + Positron:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_data_science_stack.sh | bash -s -- --with-qgis --with-positron
```

Skip RStudio if needed:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_data_science_stack.sh | bash -s -- --skip-rstudio
```

## Verify Core Services
Duration: 2

```bash
jupyter-status
rstudio-status
quarto --version
```

If installed:

```bash
geotools-check
which positron
```

## Notes for GUI Apps
Duration: 1

QGIS and Positron are desktop GUI apps. For GUI launch, use a desktop-enabled session (e.g., Chrome Remote Desktop):

- [Chrome Remote Desktop Startup](https://michaelakridge-noaa.github.io/optics-si-cloud-tools/codelabs/chrome-remote-desktop-startup/)

## Next Steps
Duration: 1

- Add project templates for R/Python/Quarto
- Configure GCS auth for cloud data access
- Run workstation health checks after setup
