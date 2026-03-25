#!/bin/bash
# =============================================================================
# QGIS + GDAL Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs QGIS and core geospatial CLI tools.
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
ACTUAL_USER="${SUDO_USER:-$USER}"
ACTUAL_HOME=$(eval echo ~$ACTUAL_USER)
LOCAL_BIN="$ACTUAL_HOME/.local/bin"

echo "=============================================="
echo "QGIS + GDAL Setup v${SCRIPT_VERSION}"
echo "=============================================="

echo "[Step 1/3] Installing QGIS/GDAL dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  qgis qgis-plugin-grass \
  gdal-bin python3-gdal python3-rasterio \
  proj-bin libgdal-dev

echo "[Step 2/3] Creating helper commands..."
sudo -u "$ACTUAL_USER" mkdir -p "$LOCAL_BIN"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/gdal-version'" << 'EOF'
#!/bin/bash
gdalinfo --version
EOF
chmod +x "$LOCAL_BIN/gdal-version"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/qgis-version'" << 'EOF'
#!/bin/bash
qgis --version 2>/dev/null | head -1 || qgis --help >/dev/null 2>&1 && echo "QGIS installed"
EOF
chmod +x "$LOCAL_BIN/qgis-version"

sudo -u "$ACTUAL_USER" bash -c "cat > '$LOCAL_BIN/geotools-check'" << 'EOF'
#!/bin/bash
echo "QGIS:"
qgis --version 2>/dev/null | head -1 || echo "  installed"
echo "GDAL:"
gdalinfo --version || true
echo "PROJ:"
proj 2>/dev/null | head -1 || true
EOF
chmod +x "$LOCAL_BIN/geotools-check"

BASHRC="$ACTUAL_HOME/.bashrc"
if ! grep -q 'export PATH=.*\.local/bin' "$BASHRC" 2>/dev/null; then
  sudo -u "$ACTUAL_USER" bash -c "echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> '$BASHRC'"
fi

echo "[Step 3/3] Done"
echo ""
echo "=============================================="
echo "✓ QGIS + GDAL setup complete"
echo "=============================================="
echo "Commands: qgis-version, gdal-version, geotools-check"
echo "Run: source ~/.bashrc"
