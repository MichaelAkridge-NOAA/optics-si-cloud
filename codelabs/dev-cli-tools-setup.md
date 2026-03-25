# Developer CLI Tools Setup for Cloud Workstations
id: dev-cli-tools-setup
title: Developer CLI Tools Setup for Cloud Workstations
summary: Install high-value CLI productivity tools for day-to-day development.
authors: Michael Akridge
categories: Cloud, Developer Tools, Productivity
environments: Web
status: Published
tags: cloud, cli, productivity, devtools, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 1

This setup installs commonly used command-line productivity tools.

### Installed tools
- `tmux`
- `ripgrep` (`rg`)
- `fd`/`fdfind`
- `bat`/`batcat`
- `jq`, `yq`
- `direnv`
- `pre-commit`
- `tree`, `htop`, `shellcheck`

## Install Tools
Duration: 3

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_dev_cli_tools.sh | bash
```

## Reload Shell
Duration: 1

```bash
source ~/.bashrc
```

## Verify
Duration: 1

```bash
dev-tools-check
```

## Quick Usage
Duration: 2

```bash
# fast search
rg "label-studio" scripts/

# find files
fd "setup_" scripts/

# JSON processing
cat package.json | jq '.'

# load project env vars safely
direnv allow
```

## Next Steps
Duration: 1

- Add `.pre-commit-config.yaml`
- Add shared shell aliases in repo docs
- Add team standard for `direnv` usage
