# Quarto Setup for Cloud Workstations
id: quarto-setup
title: Quarto Setup for Cloud Workstations
summary: Install Quarto CLI for reproducible data science publishing.
authors: Michael Akridge
categories: Cloud, Quarto, Publishing
environments: Web
status: Published
tags: cloud, quarto, r, python, publishing, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 1

Install Quarto CLI to build reports, dashboards, and notebooks from R/Python projects.

## Install Quarto
Duration: 3

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_quarto.sh | bash
```

## Verify
Duration: 1

```bash
quarto --version
quarto-check
```

## First Render Test
Duration: 2

```bash
mkdir -p ~/quarto-test && cd ~/quarto-test
quarto create project default
quarto render
```

## Use with R / Python
Duration: 2

- R engine: pairs well with RStudio and Positron
- Python engine: pairs with your existing `setup_python_env.sh` and Jupyter stack

## Troubleshooting
Duration: 1

```bash
quarto check
```

If dependencies were interrupted during install:

```bash
sudo apt-get install -f
```

## Next Steps
Duration: 1

- Add project templates
- Set up publish targets (GitHub Pages/Quarto Pub)
- Standardize report structure for team workflows
