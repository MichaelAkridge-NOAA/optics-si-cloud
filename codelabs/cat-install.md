# CAT (Coral Annotation Tool) Setup
id: cat-install
title: CAT (Coral Annotation Tool) Setup
summary: Install and run CAT for coral reef annotation workflows.
authors: Michael Akridge
categories: Annotation, Coral, Data Science
environments: Web
status: Published
tags: coral, annotation, cat, python, geospatial
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

CAT (Coral Annotation Tool) is a lightweight, file-based annotation system for Structure-from-Motion orthomosaic workflows.

![CAT Logo](assets/cat_logo.png)

Project repo: https://github.com/MichaelAkridge-NOAA/cat

### Prerequisites
- Python 3.9+
- Pip

## Install from PyPI (Recommended)
Duration: 2

```bash
pip install coral-annotation-tool
```

Optional (desktop shortcuts):

```bash
pip install coral-annotation-tool[shortcuts]
cat-create-shortcuts
```

## Run CAT
Duration: 1

```bash
cat
```

Open:

```text
http://localhost:8000
```

## Install from Source (Optional)
Duration: 2

```bash
git clone https://github.com/MichaelAkridge-NOAA/cat
cd cat
pip install -e .
```

Optional source shortcuts:

```bash
pip install -e .[shortcuts]
cat-create-shortcuts
```

## Quick First Workflow
Duration: 2

1. Open CAT at `http://localhost:8000`
2. Create a project
3. Drag/drop TIFF/GeoTIFF files
4. Add metadata and generate project JSON
5. Open the annotation interface and start labeling

## Notes
Duration: 1

- CAT uses file-based project storage (no DB required)
- GeoJSON export is supported
- COG conversion tools are included (`cat-convert`, `cat-batch-convert`)

## References
Duration: 1

- CAT repo: https://github.com/MichaelAkridge-NOAA/cat
- CAT PyPI: https://pypi.org/project/coral-annotation-tool
- CAT Lite demo: https://michaelakridge-noaa.github.io/cat-web-lite/
