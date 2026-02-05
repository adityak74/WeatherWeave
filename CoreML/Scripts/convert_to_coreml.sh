#!/bin/bash
# Core ML Model Conversion Script for Z-Image-Turbo
# This script converts the Tongyi-MAI/Z-Image-Turbo model to Core ML format

set -e

echo "================================================="
echo "Core ML Conversion for Z-Image-Turbo"
echo "================================================="
echo ""
echo "This will take approximately 20-40 minutes on Apple Silicon."
echo "Ensure you have:"
echo "  - 16GB+ RAM"
echo "  - 20GB+ free disk space"
echo "  - Stable internet connection"
echo ""

# Configuration
MODEL_ID="zimageapp/z-image-turbo-q4"
OUTPUT_DIR="$(pwd)/CoreML/ZImageTurbo-CoreML"
TEMP_ENV="$(pwd)/CoreML/coreml-env"

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "Step 1/5: Setting up Python environment..."
if [ ! -d "$TEMP_ENV" ]; then
    python3 -m venv "$TEMP_ENV"
fi

source "$TEMP_ENV/bin/activate"

echo "Step 2/5: Installing dependencies..."
pip install --upgrade pip setuptools wheel --quiet
pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu --quiet
pip install diffusers transformers accelerate safetensors huggingface-hub --quiet
pip install coremltools --quiet

# Clone Apple's conversion tools if not exists
if [ ! -d "CoreML/ml-stable-diffusion" ]; then
    echo "Step 3/5: Cloning Apple's ml-stable-diffusion..."
    git clone https://github.com/apple/ml-stable-diffusion.git CoreML/ml-stable-diffusion
    cd CoreML/ml-stable-diffusion
    pip install -e . --quiet
    cd ../..
else
    echo "Step 3/5: Apple's ml-stable-diffusion already cloned"
    cd CoreML/ml-stable-diffusion
    pip install -e . --quiet
    cd ../..
fi

echo "Step 4/5: Verifying model loads correctly..."
python3 << 'PYTHON_EOF'
import torch
from diffusers import StableDiffusionPipeline

print("Loading model from Hugging Face...")
try:
    pipe = StableDiffusionPipeline.from_pretrained(
        "zimageapp/z-image-turbo-q4",
        torch_dtype=torch.float16,
        use_safetensors=True
    )
    print("✅ Model loads successfully!")
except Exception as e:
    print(f"❌ Error loading model: {e}")
    exit(1)
PYTHON_EOF

echo ""
echo "Step 5/5: Converting to Core ML..."
echo "This will take 20-40 minutes. Progress will be shown below."
echo "================================================="

# Run the conversion
python -m python_coreml_stable_diffusion.torch2coreml \
  --model-version zimageapp/z-image-turbo-q4 \
  --convert-unet \
  --convert-text-encoder \
  --convert-vae-decoder \
  --convert-vae-encoder \
  --convert-safety-checker \
  --bundle-resources-for-swift-cli \
  --attention-implementation SPLIT_EINSUM \
  --compute-unit ALL \
  --chunk-unet 2 \
  --quantize-nbits 6 \
  -o "$OUTPUT_DIR"

echo ""
echo "================================================="
echo "✅ Conversion Complete!"
echo "================================================="
echo ""
echo "Output directory: $OUTPUT_DIR"
echo "Size: $(du -sh "$OUTPUT_DIR" | cut -f1)"
echo ""
echo "Contents:"
ls -lh "$OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Test the converted model"
echo "2. Create a ZIP archive: cd CoreML && zip -r ZImageTurbo-CoreML.zip ZImageTurbo-CoreML"
echo "3. Upload to GitHub Releases"
echo "================================================="

deactivate
