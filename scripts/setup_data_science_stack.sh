#!/bin/bash
# =============================================================================
# Data Science Stack Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs a practical data science stack by orchestrating existing setup scripts.
# Default: Python + Jupyter + RStudio + Quarto
# Optional: QGIS/GDAL, Positron
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
WITH_QGIS=0
WITH_POSITRON=0
SKIP_RSTUDIO=0

for arg in "$@"; do
  case "$arg" in
    --with-qgis) WITH_QGIS=1 ;;
    --with-positron) WITH_POSITRON=1 ;;
    --skip-rstudio) SKIP_RSTUDIO=1 ;;
    -h|--help)
      echo "Usage: bash setup_data_science_stack.sh [--with-qgis] [--with-positron] [--skip-rstudio]"
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg"
      echo "Use --help for options."
      exit 1
      ;;
  esac
done

echo "=============================================="
echo "Data Science Stack Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo "Options: with-qgis=${WITH_QGIS}, with-positron=${WITH_POSITRON}, skip-rstudio=${SKIP_RSTUDIO}"

auto_run() {
  local script_name="$1"
  local local_path
  local_path="$(pwd)/scripts/${script_name}"

  echo ""
  echo "--- Running ${script_name} ---"

  if [ -f "$local_path" ]; then
    bash "$local_path"
  elif [ -f "./${script_name}" ]; then
    bash "./${script_name}"
  else
    curl -fsSL "https://raw.githubusercontent.com/MichaelAkridge-NOAA/optics-si-cloud-tools/main/scripts/${script_name}" | bash
  fi
}

# Core stack
auto_run setup_python_env.sh
auto_run setup_jupyter.sh
if [ "$SKIP_RSTUDIO" -eq 0 ]; then
  auto_run setup_r_rstudio.sh
fi
auto_run setup_quarto.sh

# Optional add-ons
if [ "$WITH_QGIS" -eq 1 ]; then
  auto_run setup_qgis_gdal.sh
fi

if [ "$WITH_POSITRON" -eq 1 ]; then
  auto_run setup_positron.sh
fi

echo ""
echo "=============================================="
echo "✓ Data Science Stack complete"
echo "=============================================="
echo "Core installed: Python env, Jupyter, Quarto$( [ "$SKIP_RSTUDIO" -eq 0 ] && echo ', RStudio' )"
[ "$WITH_QGIS" -eq 1 ] && echo "Optional installed: QGIS/GDAL"
[ "$WITH_POSITRON" -eq 1 ] && echo "Optional installed: Positron"
echo ""
echo "Recommended checks:"
echo "  jupyter-status"
[ "$SKIP_RSTUDIO" -eq 0 ] && echo "  rstudio-status"
echo "  quarto --version"
[ "$WITH_QGIS" -eq 1 ] && echo "  geotools-check"
