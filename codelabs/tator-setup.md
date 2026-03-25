# Tator Setup
id: tator-setup
title: Tator Setup
summary: Deploy Tator on a single node with Docker for data labeling and annotation workflows.
authors: Michael Akridge
categories: Annotation, Docker, Video
environments: Web
status: Published
tags: tator, annotation, labeling, video, docker
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

Tator is a web platform for video and imagery annotation, QA/QC, and analytics.

Project repo: https://github.com/mbari-org/tator

## Prerequisites
Duration: 1

- Docker installed
- Git installed

## Quick Start (Single Node)
Duration: 4

```bash
git clone --recurse-submodules https://github.com/mbari-org/tator.git
cd tator
cp example-env .env
make tator
make superuser
```

When prompted, set the superuser credentials.

## Access Tator
Duration: 1

Open:

```text
http://localhost:8080
```

For Cloud Workstations, use the forwarded port URL for `8080`.

## Useful Commands
Duration: 2

```bash
# Check running containers
docker ps

# Follow logs (example)
docker compose logs -f
```

## References
Duration: 1

- Repo: https://github.com/mbari-org/tator
- Intro docs: https://tator.io/docs/introduction-to-tator
- User guide: https://tator.io/docs/user-guide
