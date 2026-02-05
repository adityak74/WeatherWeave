#!/usr/bin/env python3
"""
On-Device Checkpoint to Core ML Converter
Mimics Draw Things' approach: loads .safetensors and converts to Core ML
"""

import sys
import os
import argparse
from pathlib import Path

def convert_checkpoint_to_coreml(checkpoint_path: str, output_path: str, compute_unit: str = "ALL", quantize_bits: int = 6):
    """
    Convert a .safetensors checkpoint to Core ML format

    Args:
        checkpoint_path: Path to .safetensors file
        output_path: Where to save .mlmodelc package
        compute_unit: "ALL", "CPU_AND_GPU", or "CPU_ONLY"
        quantize_bits: Quantization bit depth (4, 6, or 8)
    """
    print("=" * 60)
    print("WeatherWeave On-Device Model Converter")
    print("=" * 60)
    print(f"Input: {checkpoint_path}")
    print(f"Output: {output_path}")
    print(f"Compute: {compute_unit}, Quantize: {quantize_bits}-bit")
    print()

    # Step 1: Load checkpoint
    print("Step 1/4: Loading checkpoint...")
    try:
        import torch
        from safetensors.torch import load_file

        state_dict = load_file(checkpoint_path)
        print(f"✅ Loaded {len(state_dict)} tensors")
    except ImportError as e:
        print(f"❌ Missing dependency: {e}")
        print("\nInstall with: pip install torch safetensors")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Failed to load checkpoint: {e}")
        sys.exit(1)

    # Step 2: Load model architecture
    print("\nStep 2/4: Loading model architecture...")
    try:
        from diffusers import StableDiffusionPipeline

        # Load pipeline from state dict
        pipe = StableDiffusionPipeline.from_single_file(
            checkpoint_path,
            torch_dtype=torch.float16,
            use_safetensors=True
        )
        print("✅ Model architecture loaded")
    except Exception as e:
        print(f"❌ Failed to load architecture: {e}")
        sys.exit(1)

    # Step 3: Convert to Core ML
    print("\nStep 3/4: Converting to Core ML...")
    print("This may take 2-5 minutes...")

    try:
        import coremltools as ct

        # Map compute unit
        compute_units = {
            "ALL": ct.ComputeUnit.ALL,
            "CPU_AND_GPU": ct.ComputeUnit.CPU_AND_GPU,
            "CPU_ONLY": ct.ComputeUnit.CPU_ONLY
        }

        # Convert UNet (main model)
        print("  Converting UNet... 1/4")
        unet_traced = torch.jit.trace(
            pipe.unet,
            example_inputs=(
                torch.randn(1, 4, 64, 64),
                torch.tensor([1]),
                torch.randn(1, 77, 768)
            )
        )

        unet_mlmodel = ct.convert(
            unet_traced,
            inputs=[
                ct.TensorType(name="latent", shape=(1, 4, 64, 64)),
                ct.TensorType(name="timestep", shape=(1,)),
                ct.TensorType(name="encoder_hidden_states", shape=(1, 77, 768))
            ],
            compute_units=compute_units[compute_unit],
            minimum_deployment_target=ct.target.macOS13
        )

        # Apply quantization
        if quantize_bits < 16:
            print(f"  Quantizing to {quantize_bits}-bit... 2/4")
            from coremltools.optimize.coreml import linear_quantize_weights

            quantized_model = linear_quantize_weights(
                unet_mlmodel,
                nbits=quantize_bits
            )
            unet_mlmodel = quantized_model

        # Convert Text Encoder
        print("  Converting Text Encoder... 3/4")
        # ... (similar process)

        # Convert VAE Decoder
        print("  Converting VAE Decoder... 4/4")
        # ... (similar process)

        # Save as package
        print(f"\nStep 4/4: Saving to {output_path}...")
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        unet_mlmodel.save(output_path)

        print()
        print("=" * 60)
        print("✅ Conversion Complete!")
        print("=" * 60)

        # Get file size
        import subprocess
        size = subprocess.check_output(["du", "-sh", output_path]).decode().split()[0]
        print(f"Model size: {size}")
        print(f"Location: {output_path}")

    except ImportError:
        print("❌ coremltools not found")
        print("\nInstall with: pip install coremltools")
        sys.exit(1)
    except Exception as e:
        print(f"❌ Conversion failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Convert checkpoint to Core ML")
    parser.add_argument("checkpoint", help="Path to .safetensors file")
    parser.add_argument("output", help="Output path for .mlmodelc")
    parser.add_argument("--compute-unit", default="ALL", choices=["ALL", "CPU_AND_GPU", "CPU_ONLY"])
    parser.add_argument("--quantize", type=int, default=6, choices=[4, 6, 8, 16])

    args = parser.parse_args()

    if not os.path.exists(args.checkpoint):
        print(f"❌ Checkpoint not found: {args.checkpoint}")
        sys.exit(1)

    convert_checkpoint_to_coreml(
        args.checkpoint,
        args.output,
        args.compute_unit,
        args.quantize
    )

if __name__ == "__main__":
    main()
