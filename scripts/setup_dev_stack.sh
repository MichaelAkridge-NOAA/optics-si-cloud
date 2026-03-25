#!/bin/bash
# =============================================================================
# Developer Stack Setup for Google Cloud Workstations
# Version: 1.0.0 (2026-03-25)
# =============================================================================
# Installs common developer tooling and services.
# Default: Git/SSH + code-server + dev CLI tools + Docker
# Optional: gcloud ADC setup
# =============================================================================

set -euo pipefail

SCRIPT_VERSION="1.0.0"
WITH_GCLOUD_ADC=0
SKIP_DOCKER=0

for arg in "$@"; do
  case "$arg" in
    --with-gcloud-adc) WITH_GCLOUD_ADC=1 ;;
    --skip-docker) SKIP_DOCKER=1 ;;
    -h|--help)
      echo "Usage: bash setup_dev_stack.sh [--with-gcloud-adc] [--skip-docker]"
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
echo "Developer Stack Setup v${SCRIPT_VERSION}"
echo "=============================================="
echo "Options: with-gcloud-adc=${WITH_GCLOUD_ADC}, skip-docker=${SKIP_DOCKER}"

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

auto_run setup_git_ssh.sh
auto_run setup_code_server.sh
auto_run setup_dev_cli_tools.sh

if [ "$SKIP_DOCKER" -eq 0 ]; then
  auto_run setup_docker.sh
fi

if [ "$WITH_GCLOUD_ADC" -eq 1 ]; then
  auto_run setup_gcloud_adc.sh
fi

echo ""
echo "=============================================="
echo "✓ Developer Stack complete"
echo "=============================================="
echo "Installed: git/ssh, code-server, dev CLI tools$( [ "$SKIP_DOCKER" -eq 0 ] && echo ', docker' )"
[ "$WITH_GCLOUD_ADC" -eq 1 ] && echo "Optional installed: gcloud ADC"
echo ""
echo "Recommended checks:"
echo "  code-server-status"
echo "  dev-tools-check"
[ "$SKIP_DOCKER" -eq 0 ] && echo "  docker-status"
