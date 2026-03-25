# QGIS + GDAL Setup for Cloud Workstations
id: qgis-gdal-setup
title: QGIS + GDAL Setup for Cloud Workstations
summary: Install QGIS, GDAL, and core geospatial tooling.
authors: Michael Akridge
categories: Cloud, GIS, Geospatial
environments: Web
status: Published
tags: cloud, qgis, gdal, geospatial, workstations
feedback link: https://github.com/MichaelAkridge-NOAA/optics-si-cloud-tools/issues

## Overview
Duration: 2

Install geospatial tools for raster/vector processing and GIS workflows.

<aside class="warning">
QGIS is a desktop GUI application (like TagLab). If you plan to open the QGIS interface, set up a desktop session first via Chrome Remote Desktop.
</aside>

### Recommended before starting (GUI users)

- Complete: [Chrome Remote Desktop Startup codelab](https://michaelakridge-noaa.github.io/optics-si-cloud-tools/codelabs/chrome-remote-desktop-startup/)
- Then run this QGIS install codelab

If you only need command-line geospatial tools (GDAL/PROJ), you can continue without CRD.

### Includes
- QGIS
- GDAL CLI (`gdalinfo`, `ogr2ogr`, etc.)
- PROJ tooling
- Helper commands: `qgis-version`, `gdal-version`, `geotools-check`

## Install QGIS + GDAL
Duration: 4

```bash
curl -sL https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/setup_qgis_gdal.sh | bash
```

## Verify Installation
Duration: 2

```bash
geotools-check
gdal-version
qgis-version
```

Example GDAL test:

```bash
gdalinfo --formats | head
```

## Usage Notes
Duration: 1

QGIS is GUI-based. For browser-only workflows, use GDAL CLI + Python geospatial libraries in notebooks.

To launch QGIS GUI, use a desktop-enabled session (e.g., CRD) and run:

```bash
qgis
```

## Troubleshooting
Duration: 2

### QGIS command not found
```bash
which qgis
source ~/.bashrc
```

### GDAL Python import issues
```bash
python3 -c "from osgeo import gdal; print(gdal.VersionInfo())"
```

## Next Steps
Duration: 1

- Add sample geotiff/shapefile dataset
- Integrate with Jupyter notebooks
- Add a raster reprojection and clip workflow
