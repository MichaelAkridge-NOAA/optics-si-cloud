# Cloud Workstation Setup Scripts

Scripts for configuring Google Cloud Workstations with common development tools. All scripts are designed for **persistent installation** - configurations survive workstation restarts.

## Quick Start

Run any script directly:
```bash
# Download and run
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/SCRIPT_NAME.sh | bash

# Or clone and run locally
bash scripts/SCRIPT_NAME.sh
```

## Available Scripts

### Data Annotation & Processing

| Script | Description | Ports |
|--------|-------------|-------|
| `install_label_studio.sh` | Label Studio for data annotation | 8080 |
| `install_meshroom.sh` | Meshroom photogrammetry (3D reconstruction) | — |
| `install_taglab_cpu.sh` | TagLab semantic segmentation (CPU) | — |
| `install_taglab_gpu.sh` | TagLab semantic segmentation (GPU/CUDA) | — |

### Development Environment

| Script | Description | Ports |
|--------|-------------|-------|
| `setup_python_env.sh` | pyenv + persistent virtual environments | — |
| `setup_jupyter.sh` | JupyterLab with extensions | 8888 |
| `setup_code_server.sh` | VS Code in browser (code-server) | 8443 |
| `setup_r_rstudio.sh` | R + RStudio Server | 8787 |
| `setup_quarto.sh` | Quarto CLI publishing toolkit | — |
| `setup_positron.sh` | Positron IDE (Linux .deb) | GUI |
| `setup_qgis_gdal.sh` | QGIS + GDAL geospatial tools | GUI/CLI |
| `setup_dev_cli_tools.sh` | tmux, rg, fd, jq, yq, direnv, pre-commit | — |
| `setup_data_science_stack.sh` | One-command data science stack installer | 8888, 8787 (+optional GUI) |
| `setup_dev_stack.sh` | One-command developer stack installer | 8443 (+Docker) |
| `setup_docker.sh` | Docker Engine with persistence helpers | — |
| `setup_git_ssh.sh` | Git configuration + SSH keys | — |
| `setup_gcloud_adc.sh` | Application Default Credentials | — |

### Workstation Management

| Script | Description |
|--------|-------------|
| `workstation_health.sh` | Unified health check for all services |
| `workstation_cleanup.sh` | Clean logs, caches, temp files |
| `workstation_backup.sh` | Backup home directory to GCS |

## Management Commands

After installation, scripts create management commands in `~/.local/bin/`:

### Label Studio
```bash
label-studio-stop       # Stop Label Studio
label-studio-restart    # Restart Label Studio
label-studio-status     # Check status
label-studio-diagnostics # Full diagnostic info
label-studio-logs       # Tail service logs
label-studio-update     # Update to latest Label Studio
```

### JupyterLab
```bash
jupyter-start           # Start JupyterLab
jupyter-stop            # Stop JupyterLab
jupyter-restart         # Restart JupyterLab
jupyter-status          # Check status
```

### code-server
```bash
code-server-start       # Start code-server
code-server-stop        # Stop code-server
code-server-restart     # Restart code-server
code-server-status      # Check status
```

### RStudio Server
```bash
rstudio-start           # Start RStudio Server
rstudio-stop            # Stop RStudio Server
rstudio-restart         # Restart RStudio Server
rstudio-status          # Check status
rstudio-logs            # View service logs
```

### Python Environment
```bash
venv-default            # Activate default virtualenv
venv-list               # List all virtualenvs
venv-create <name>      # Create new virtualenv
```

### Docker
```bash
docker-status           # Show Docker status and containers
docker-cleanup          # Remove unused containers/images
docker-save-images      # Save images for persistence
docker-load-images      # Load saved images after restart
```

### Geospatial + Publishing + Productivity
```bash
geotools-check          # Check QGIS/GDAL/PROJ install
gdal-version            # Show GDAL version
qgis-version            # Show QGIS version
quarto-check            # Verify Quarto install
positron-launch         # Launch Positron in GUI session
dev-tools-check         # Verify dev CLI tool versions
```

### Stack Installers
```bash
setup_data_science_stack.sh                 # Python + Jupyter + RStudio + Quarto
setup_data_science_stack.sh --with-qgis     # Add QGIS/GDAL
setup_data_science_stack.sh --with-positron # Add Positron
setup_dev_stack.sh                          # Git/SSH + code-server + dev tools + Docker
setup_dev_stack.sh --with-gcloud-adc        # Also configure ADC
```

### Workstation Management
```bash
workstation_health.sh              # Check all services
workstation_health.sh --json       # JSON output for automation
workstation_cleanup.sh             # Interactive cleanup
workstation_cleanup.sh --dry-run   # Preview what would be deleted
workstation_cleanup.sh --all       # Clean everything (no prompts)
workstation_backup.sh backup gs://bucket/path    # Backup to GCS
workstation_backup.sh restore gs://bucket/backup # Restore from GCS
workstation_backup.sh list gs://bucket/path      # List backups
```

## Cloud Workstation Specifics

### Persistence
- Only `~/.` (home directory) persists across restarts
- All scripts install to persistent locations (`~/.local/`, `~/.pyenv/`, etc.)
- Auto-start is configured via `~/.bashrc` for services that need it

### Ports & Access
- Cloud Workstations use **IAM authentication** — no passwords needed
- Access services via Cloud Workstation port forwarding
- Default ports: Label Studio (8080), JupyterLab (8888), code-server (8443), RStudio Server (8787)

### Common Issues

**CSRF 403 Forbidden** (Label Studio)
- Already handled by the script via `USE_ENFORCE_CSRF_CHECKS=0`

**"Scope not authorized" errors** (GCS access)
- Run `setup_gcloud_adc.sh` to configure Application Default Credentials

**SSH/SCP breaks after install**
- Fixed in v2.1.3+ — autostart only runs for interactive shells

## Requirements

- Google Cloud Workstation (Ubuntu-based)
- `sudo` access (most scripts require it)
- Internet access (for downloads)

## Codelabs

Full step-by-step tutorials available at:
**[Optics SI Cloud Codelabs](https://michaelakridge-noaa.github.io/optics-si-cloud-tools/)**
