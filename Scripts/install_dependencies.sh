#!/bin/bash
# WeatherWeave Dependencies Installation Script
# Installs Python dependencies for AI image generation

set -e

echo "==================================="
echo "WeatherWeave Dependency Installer"
echo "==================================="
echo ""

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed."
    echo "Please install Python 3.10 or later from https://www.python.org/"
    exit 1
fi

# Check Python version
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo "Found Python version: $PYTHON_VERSION"

# Create virtual environment if it doesn't exist
VENV_DIR="$HOME/.weatherweave-venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment at $VENV_DIR..."
    python3 -m venv "$VENV_DIR"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "Installing dependencies..."
echo ""

# Core dependencies
echo "Installing PyTorch with MPS support for Apple Silicon..."
pip install torch torchvision torchaudio

echo "Installing Diffusers..."
pip install diffusers[torch]

echo "Installing transformers..."
pip install transformers

echo "Installing accelerate..."
pip install accelerate

echo "Installing safetensors..."
pip install safetensors

# Optional: Install MLX if on Apple Silicon
if [[ $(uname -m) == 'arm64' ]]; then
    echo "Detected Apple Silicon, installing MLX..."
    pip install mlx mlx-lm
else
    echo "Not on Apple Silicon, skipping MLX installation"
fi

# Install image processing libraries
echo "Installing Pillow..."
pip install Pillow

echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
echo ""
echo "Virtual environment created at: $VENV_DIR"
echo ""
echo "To use the image generation script:"
echo "1. Activate the virtual environment:"
echo "   source $VENV_DIR/bin/activate"
echo ""
echo "2. Run the generation script:"
echo "   python3 Scripts/generate_image.py \"your prompt\" output.png"
echo ""
echo "The WeatherWeave app will automatically use this virtual environment."
echo ""
