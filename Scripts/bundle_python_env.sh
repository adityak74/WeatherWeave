#!/bin/bash
# WeatherWeave Python Environment Bundler
# This script bundles a Python virtual environment and necessary
# dependencies into the WeatherWeave.app bundle.

set -e

echo "==================================="
echo "Bundling Python Environment for WeatherWeave"
echo "==================================="

# --- Validate Xcode Environment Variables ---
if [ -z "$BUILT_PRODUCTS_DIR" ] || [ -z "$FULL_PRODUCT_NAME" ]; then
    echo "Error: Required Xcode environment variables not set."
    echo "BUILT_PRODUCTS_DIR: ${BUILT_PRODUCTS_DIR:-<not set>}"
    echo "FULL_PRODUCT_NAME: ${FULL_PRODUCT_NAME:-<not set>}"
    echo ""
    echo "This script must be run from an Xcode Build Phase."
    exit 1
fi

# --- Configuration ---
PYTHON_VERSION="3.10" # Minimum Python version required
VENV_NAME="weatherweave_bundled_venv"
BUILD_DIR="${BUILT_PRODUCTS_DIR}/${FULL_PRODUCT_NAME}"
BUNDLE_PYTHON_PATH="${BUILD_DIR}/Contents/Resources/python"
BUNDLE_RESOURCES_PATH="${BUILD_DIR}/Contents/Resources"
PYTHON_SCRIPT_SOURCE_PATH="${PROJECT_DIR}/Scripts/generate_image.py"
PYTHON_SCRIPT_DEST_PATH="${BUILD_DIR}/Contents/Resources/generate_image.py"
TEMP_VENV_PATH="/tmp/${VENV_NAME}_$$"  # Use PID for uniqueness

echo "Build directory: ${BUILD_DIR}"
echo "Bundle resources: ${BUNDLE_RESOURCES_PATH}"

# --- 1. Find Python 3.10+ ---
PYTHON_EXECUTABLE=$(command -v python3)
if [ -z "$PYTHON_EXECUTABLE" ]; then
    echo "Error: Python 3 not found in PATH."
    echo "Please ensure Python ${PYTHON_VERSION} or later is installed."
    exit 1
fi

CURRENT_PYTHON_VERSION=$($PYTHON_EXECUTABLE -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Found Python: $PYTHON_EXECUTABLE ($CURRENT_PYTHON_VERSION)"

# Version check
REQUIRED_VERSION=(${PYTHON_VERSION//./ })
CURRENT_VERSION=(${CURRENT_PYTHON_VERSION//./ })
if [ "${CURRENT_VERSION[0]}" -lt "${REQUIRED_VERSION[0]}" ] || \
   ([ "${CURRENT_VERSION[0]}" -eq "${REQUIRED_VERSION[0]}" ] && [ "${CURRENT_VERSION[1]}" -lt "${REQUIRED_VERSION[1]}" ]); then
    echo "Error: Python ${PYTHON_VERSION}+ required, found ${CURRENT_PYTHON_VERSION}"
    exit 1
fi

# --- 2. Check if bundling is needed (cache check) ---
CACHE_MARKER="${BUNDLE_PYTHON_PATH}/.bundled_successfully"
if [ -f "$CACHE_MARKER" ]; then
    CACHED_PYTHON_VERSION=$(cat "$CACHE_MARKER" 2>/dev/null || echo "unknown")
    if [ "$CACHED_PYTHON_VERSION" == "$CURRENT_PYTHON_VERSION" ]; then
        echo "Python environment already bundled for version $CURRENT_PYTHON_VERSION"
        echo "Skipping bundling (delete ${BUNDLE_PYTHON_PATH} to force rebundle)"

        # Still copy the generate_image.py script in case it changed
        echo "Updating generate_image.py..."
        cp "${PYTHON_SCRIPT_SOURCE_PATH}" "${PYTHON_SCRIPT_DEST_PATH}"

        echo "==================================="
        exit 0
    fi
fi

# --- 3. Create Temporary Virtual Environment ---
echo "Creating temporary virtual environment..."
rm -rf "$TEMP_VENV_PATH"
$PYTHON_EXECUTABLE -m venv "$TEMP_VENV_PATH"

# Activate the venv
source "$TEMP_VENV_PATH/bin/activate"

# --- 4. Install Dependencies ---
echo "Upgrading pip..."
pip install --upgrade pip --quiet

echo "Installing Python dependencies..."
echo "  - torch, torchvision, torchaudio"
pip install torch torchvision torchaudio --quiet

echo "  - diffusers, transformers, accelerate, safetensors, Pillow"
pip install diffusers transformers accelerate safetensors Pillow --quiet

# Install MLX on Apple Silicon
if [[ $(uname -m) == 'arm64' ]]; then
    echo "  - mlx, mlx-lm (Apple Silicon detected)"
    pip install mlx mlx-lm --quiet
else
    echo "  - Skipping MLX (not on Apple Silicon)"
fi

deactivate

# --- 5. Copy Site-Packages to Bundle ---
echo "Bundling Python environment to: ${BUNDLE_PYTHON_PATH}"

# Clean previous bundle
rm -rf "${BUNDLE_PYTHON_PATH}"
mkdir -p "${BUNDLE_PYTHON_PATH}"

# Copy Python executable and libraries
VENV_PYTHON_VERSION=$(ls "$TEMP_VENV_PATH/lib" | grep "python3")
SITE_PACKAGES="$TEMP_VENV_PATH/lib/$VENV_PYTHON_VERSION/site-packages"

echo "Copying site-packages..."
mkdir -p "${BUNDLE_PYTHON_PATH}/lib/$VENV_PYTHON_VERSION"
cp -R "$SITE_PACKAGES" "${BUNDLE_PYTHON_PATH}/lib/$VENV_PYTHON_VERSION/"

# Copy Python binary
echo "Copying Python binary..."
mkdir -p "${BUNDLE_PYTHON_PATH}/bin"
cp "$TEMP_VENV_PATH/bin/python3" "${BUNDLE_PYTHON_PATH}/bin/python3"

# Create symlink for python
ln -sf python3 "${BUNDLE_PYTHON_PATH}/bin/python"

# --- 6. Clean Bundle to Reduce Size ---
echo "Cleaning bundle..."
find "${BUNDLE_PYTHON_PATH}" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
find "${BUNDLE_PYTHON_PATH}" -type f -name "*.pyc" -delete 2>/dev/null || true
find "${BUNDLE_PYTHON_PATH}" -type f -name "*.pyo" -delete 2>/dev/null || true
rm -rf "${BUNDLE_PYTHON_PATH}"/lib/*/site-packages/*.dist-info 2>/dev/null || true
rm -rf "${BUNDLE_PYTHON_PATH}"/lib/*/site-packages/*.egg-info 2>/dev/null || true

# --- 7. Copy generate_image.py Script ---
echo "Copying generate_image.py..."
mkdir -p "$(dirname "${PYTHON_SCRIPT_DEST_PATH}")"
cp "${PYTHON_SCRIPT_SOURCE_PATH}" "${PYTHON_SCRIPT_DEST_PATH}"
chmod +x "${PYTHON_SCRIPT_DEST_PATH}"

# --- 8. Create Cache Marker ---
echo "$CURRENT_PYTHON_VERSION" > "$CACHE_MARKER"

# --- 9. Cleanup Temporary Environment ---
echo "Cleaning up temporary files..."
rm -rf "$TEMP_VENV_PATH"

# --- 10. Verify Bundle ---
if [ ! -f "${BUNDLE_PYTHON_PATH}/bin/python3" ]; then
    echo "Error: Python binary not found in bundle!"
    exit 1
fi

BUNDLE_SIZE=$(du -sh "${BUNDLE_PYTHON_PATH}" | cut -f1)
echo ""
echo "✅ Python environment bundling complete!"
echo "   Bundle size: ${BUNDLE_SIZE}"
echo "   Location: ${BUNDLE_PYTHON_PATH}"
echo "==================================="
