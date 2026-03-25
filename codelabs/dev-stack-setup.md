# Developer Stack Setup for Cloud Workstations
id: dev-stack-setup
title: Developer Stack Setup for Cloud Workstations
summary: Install a full developer stack (Git/SSH, code-server, dev CLI tools, Docker) in one run.
authors: Michael Akridge
categories: Cloud, Developer Tools, Setup
environments: Web
status: Published
tags: cloud, developer, code-server, docker, git, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This codelab installs a practical developer stack for daily coding workflows.

### Before you begin
- Expected setup time: ~10-20 minutes
- Requires `sudo` access
- Docker install may require re-login/new shell for group updates

### Default stack
- Git + SSH setup (`setup_git_ssh.sh`)
- code-server (`setup_code_server.sh`)
- CLI productivity tools (`setup_dev_cli_tools.sh`)
- Docker (`setup_docker.sh`)

### What this enables
- Browser IDE on port `8443` (code-server)
- Source control + SSH auth workflow
- Faster CLI operations (`rg`, `fd`, `jq`, `yq`, etc.)
- Containerized local development via Docker

### Optional
- gcloud ADC (`--with-gcloud-adc`)

### Do I need ADC?
Use `--with-gcloud-adc` if you will access Google Cloud APIs (especially GCS) from scripts/apps/SDKs.

- Need `gs://` access or cloud API calls from code? **Yes, enable ADC**.
- Pure local/docker-only development? **ADC can be skipped**.

## Install Default Stack
Duration: 4

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_dev_stack.sh | bash
```

## Install with ADC
Duration: 2

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_dev_stack.sh | bash -s -- --with-gcloud-adc
```

Skip Docker:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_dev_stack.sh | bash -s -- --skip-docker
```

## Verify
Duration: 2

```bash
code-server-status
dev-tools-check
docker-status
```

If ADC enabled:

```bash
gcloud auth application-default print-access-token >/dev/null && echo "ADC OK"
```

## Next Steps
Duration: 1

- Add `.pre-commit-config.yaml`
- Enable code-server extensions for your language stack
- Add backup + cleanup cron tasks for long-running workstations
