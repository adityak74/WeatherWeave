#!/usr/bin/env python3
"""
WeatherWeave Image Generation Script
Generates wallpapers using Z-Image/MLX or Stable Diffusion
"""

import sys
import os
from pathlib import Path

def main():
    if len(sys.argv) < 3:
        print("Usage: generate_image.py <prompt> <output_path>", file=sys.stderr)
        sys.exit(1)

    prompt = sys.argv[1]
    output_path = sys.argv[2]

    print(f"Generating image with prompt: {prompt}")
    print(f"Output path: {output_path}")

    try:
        # Check if MLX and required libraries are available
        try:
            import mlx
            import mlx.core as mx
            from diffusers import StableDiffusionPipeline
            use_mlx = True
            print("Using MLX backend for image generation")
        except ImportError:
            use_mlx = False
            print("MLX not available, falling back to standard Diffusers")

        if use_mlx:
            generate_with_mlx(prompt, output_path)
        else:
            generate_with_diffusers(prompt, output_path)

        print(f"Image successfully generated: {output_path}")
        sys.exit(0)

    except Exception as e:
        print(f"Error generating image: {str(e)}", file=sys.stderr)
        sys.exit(1)


def generate_with_mlx(prompt: str, output_path: str):
    """Generate image using MLX-optimized Stable Diffusion"""
    from diffusers import StableDiffusionPipeline
    import mlx.core as mx

    # Load the model optimized for Apple Silicon
    model_id = "stabilityai/stable-diffusion-2-1"

    # Create pipeline
    pipe = StableDiffusionPipeline.from_pretrained(
        model_id,
        use_safetensors=True,
    )

    # Generate image
    image = pipe(
        prompt,
        num_inference_steps=50,
        guidance_scale=7.5,
        width=1920,
        height=1080,
    ).images[0]

    # Save image
    image.save(output_path)


def generate_with_diffusers(prompt: str, output_path: str):
    """Generate image using standard Diffusers library"""
    from diffusers import StableDiffusionPipeline
    import torch

    # Check if MPS (Metal Performance Shaders) is available
    if torch.backends.mps.is_available():
        device = "mps"
        print("Using Metal Performance Shaders (MPS)")
    elif torch.cuda.is_available():
        device = "cuda"
        print("Using CUDA")
    else:
        device = "cpu"
        print("Using CPU (this will be slow)")

    model_id = "stabilityai/stable-diffusion-2-1"

    # Create pipeline
    pipe = StableDiffusionPipeline.from_pretrained(
        model_id,
        torch_dtype=torch.float16 if device != "cpu" else torch.float32,
        use_safetensors=True,
    )
    pipe = pipe.to(device)

    # Enable attention slicing for memory efficiency
    pipe.enable_attention_slicing()

    # Generate image
    with torch.inference_mode():
        image = pipe(
            prompt,
            num_inference_steps=50,
            guidance_scale=7.5,
            width=1920,
            height=1080,
        ).images[0]

    # Save image
    image.save(output_path)


if __name__ == "__main__":
    main()
