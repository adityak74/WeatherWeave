#!/bin/bash
# WeatherWeave Python Environment Bundler
# This script bundles a Python virtual environment and necessary
# dependencies into the WeatherWeave.app bundle.

# TEMPORARILY DISABLED FOR TESTING - Skip bundling for now
echo "Python bundling temporarily disabled for testing"
exit 0

set -e

echo "==================================="
echo "Bundling Python Environment for WeatherWeave"
echo "==================================="

# --- Configuration ---
PYTHON_VERSION="3.10" # Minimum Python version required (adjust if needed)
VENV_NAME="weatherweave_bundled_venv"
BUILD_DIR="${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}"
BUNDLE_PYTHON_PATH="${BUILD_DIR}/Contents/Resources/python"
PYTHON_SCRIPT_SOURCE_PATH="${PROJECT_DIR}/Scripts/generate_image.py"
PYTHON_SCRIPT_DEST_PATH="${BUILD_DIR}/Contents/Resources/generate_image.py"

# --- 1. Find Python 3.10+ ---
# Prefer globally installed python3, but check for specific versions
PYTHON_EXECUTABLE=$(command -v python3)
if [ -z "$PYTHON_EXECUTABLE" ]; then
    echo "Error: Python 3 not found in PATH."
    echo "Please ensure Python ${PYTHON_VERSION} or later is installed and accessible."
    exit 1
fi

CURRENT_PYTHON_VERSION=$($PYTHON_EXECUTABLE -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [[ "$(printf '%s
' "$PYTHON_VERSION" "$CURRENT_PYTHON_VERSION" | sort -V | head -n1)" != "$PYTHON_VERSION" ]]; then
    echo "Error: Found Python version $CURRENT_PYTHON_VERSION, but ${PYTHON_VERSION} or newer is required."
    echo "Please install Python ${PYTHON_VERSION}+ and ensure it's in your PATH."
    exit 1
fi

echo "Using Python executable: $PYTHON_EXECUTABLE ($CURRENT_PYTHON_VERSION)"

# --- 2. Create and Activate Temporary Virtual Environment ---
echo "Creating temporary virtual environment for bundling..."
rm -rf "/tmp/$VENV_NAME" # Clean up previous temp venv
$PYTHON_EXECUTABLE -m venv "/tmp/$VENV_NAME"
source "/tmp/$VENV_NAME/bin/activate"

echo "Upgrading pip..."
pip install --upgrade pip

# --- 3. Install Dependencies ---
echo "Installing Python dependencies into temporary virtual environment..."

# Core dependencies (as per install_dependencies.sh)
pip install torch torchvision torchaudio \
            diffusers transformers accelerate safetensors Pillow

# Optional: Install MLX if on Apple Silicon
if [[ $(uname -m) == 'arm64' ]]; then
    echo "Detected Apple Silicon, installing MLX..."
    pip install mlx mlx-lm
else
    echo "Not on Apple Silicon, skipping MLX installation (for bundling purposes)"
fi

deactivate # Deactivate the temporary venv

# --- 4. Clean Virtual Environment ---
echo "Cleaning virtual environment to reduce size..."
# Remove __pycache__ directories
find "/tmp/$VENV_NAME" -type d -name "__pycache__" -exec rm -rf {} +
# Remove .pyc files
find "/tmp/$VENV_NAME" -type f -name "*.pyc" -delete
# Remove pip cache
rm -rf "/tmp/$VENV_NAME/pip-selfcheck.json"
rm -rf "/tmp/$VENV_NAME/lib/*/site-packages/*.dist-info" # Remove metadata directories to save space
rm -rf "/tmp/$VENV_NAME/lib/*/site-packages/*.egg-info"
rm -rf "/tmp/$VENV_NAME/share" # Remove share directory if it exists

# --- 5. Copy to App Bundle ---
echo "Copying bundled Python environment to: ${BUNDLE_PYTHON_PATH}"
rm -rf "${BUNDLE_PYTHON_PATH}" # Clean up previous bundled env
mkdir -p "${BUNDLE_PYTHON_PATH}"
cp -R "/tmp/$VENV_NAME" "${BUNDLE_PYTHON_PATH}"

echo "Copying generate_image.py to: ${PYTHON_SCRIPT_DEST_PATH}"
mkdir -p "$(dirname "${PYTHON_SCRIPT_DEST_PATH}")" # Ensure parent directory exists
cp "${PYTHON_SCRIPT_SOURCE_PATH}" "${PYTHON_SCRIPT_DEST_PATH}"

# --- 6. Clean up Temporary Virtual Environment ---
echo "Cleaning up temporary virtual environment..."
rm -rf "/tmp/$VENV_NAME"

echo "Python environment bundling complete!"
echo "==================================="
