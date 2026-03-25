# VIAME Web (DIVE) via Docker Compose
id: viame-dive-docker-setup
title: VIAME Web (DIVE) via Docker Compose
summary: Deploy VIAME Web (DIVE) with Docker Compose for annotation and labeling workflows.
authors: Michael Akridge
categories: Annotation, Docker, DIVE
environments: Web
status: Published
tags: viame, dive, annotation, docker, labeling
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

This guide deploys **VIAME Web (DIVE)** using Docker Compose.

Reference docs: https://kitware.github.io/dive/Deployment-Docker-Compose/

### Core services
- `kitware/viame-web` (web server)
- `kitware/viame-worker` (queue worker)
- MongoDB + RabbitMQ

## Prerequisites
Duration: 2

- Linux host or VM
- Docker 19.03+
- Docker Compose 1.28+
- (Optional GPU workflows) NVIDIA drivers + nvidia-container-toolkit

## Basic Deployment
Duration: 4

```bash
# Clone DIVE repo
git clone https://github.com/Kitware/dive /opt/dive
cd /opt/dive

# Initialize env
cp .env.default .env
# Edit settings as needed
nano .env

# Pull images
docker-compose pull

# Start stack
docker-compose -f docker-compose.yml up -d
```

## Access
Duration: 1

Open:

```text
http://localhost:8010
```

Default credentials from DIVE docs:

```text
admin / letmein
```

For Cloud Workstations, use forwarded port URL for `8010`.

## Optional: Production Compose
Duration: 2

```bash
# pull extra production images
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull

# start with production compose and scale web
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d --scale girder=4
```

## Troubleshooting
Duration: 2

```bash
# check running containers
docker ps

# tail logs
docker-compose logs -f

# restart
docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up -d
```

## References
Duration: 1

- DIVE deployment docs: https://kitware.github.io/dive/Deployment-Docker-Compose/
- DIVE repo: https://github.com/Kitware/dive
- VIAME web image: https://hub.docker.com/r/kitware/viame-web
- VIAME worker image: https://hub.docker.com/r/kitware/viame-worker
