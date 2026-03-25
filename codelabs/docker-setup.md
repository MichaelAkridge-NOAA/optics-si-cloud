# Docker Setup for Cloud Workstations

## Overview
Duration: 1

This guide walks you through installing Docker Engine on Google Cloud Workstations, with persistence helpers for saving images across restarts.

### What you'll learn
- Install Docker Engine
- Configure Docker for Cloud Workstations
- Save and restore Docker images across restarts
- Manage containers with helper commands

### Prerequisites
- Google Cloud Workstation (Ubuntu-based)
- `sudo` access

## Install Docker
Duration: 3

Run the setup script:

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_docker.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools.git
cd optics-si-cloud-tools
bash scripts/setup_docker.sh
```

The script will:
1. Install Docker Engine and Docker Compose
2. Add your user to the `docker` group
3. Configure log rotation
4. Create management commands

## Apply Group Changes
Duration: 1

After installation, apply the docker group membership:

```bash
newgrp docker
```

Or log out and back in.

Test Docker:

```bash
docker run hello-world
```

## Understanding Persistence
Duration: 2

**Important:** Docker data in `/var/lib/docker` does **NOT** persist across Cloud Workstation restarts.

This means:
- Downloaded images are lost on restart
- Stopped containers are lost on restart
- Only running containers may survive (with live-restore)

### Solutions

**Option 1: Save images before restart**
```bash
docker-save-images
```

**Option 2: Use container registries**
```bash
# Push to Google Container Registry
docker tag myimage gcr.io/PROJECT/myimage
docker push gcr.io/PROJECT/myimage
```

## Management Commands
Duration: 2

The setup script creates these commands in `~/.local/bin/`:

### Check Status
```bash
docker-status
```
Shows Docker version, running containers, images, and disk usage.

### Cleanup
```bash
docker-cleanup
```
Removes stopped containers, unused networks, and dangling images.

### Save Images
```bash
docker-save-images
```
Saves all images to `~/.docker-images/` for restoration after restart.

### Load Images
```bash
docker-load-images
```
Restores images from `~/.docker-images/` after a workstation restart.

## Common Tasks
Duration: 2

### Run a container
```bash
docker run -d -p 8080:80 nginx
```

### Build from Dockerfile
```bash
docker build -t myapp .
```

### Use Docker Compose
```bash
docker compose up -d
docker compose down
```

### View logs
```bash
docker logs <container-name>
docker logs -f <container-name>  # Follow
```

## Congratulations
Duration: 1

You've successfully set up Docker on your Cloud Workstation!

### What you learned
- Installing Docker Engine
- Managing Docker persistence
- Using helper commands

### Next steps
- Build and run your containers
- Set up `docker-save-images` before workstation stops
- Consider using GCR for important images
