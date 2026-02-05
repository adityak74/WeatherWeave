#!/usr/bin/env python3
"""
WeatherWeave Image Generation Script
Generates wallpapers using Z-Image/MLX or Stable Diffusion
"""

import sys
import os
import argparse
from pathlib import Path

MODEL_ID = "zimageapp/z-image-turbo-q4"

def _get_model_path(model_id: str):
    """
    Attempts to find the local path of a Hugging Face model without downloading.
    Returns the path if found, otherwise None.
    """
    try:
        from huggingface_hub import HfApi
        api = HfApi()
        # This will raise if the model is not found locally
        # The cache structure is complex, this is a heuristic
        # A more robust check might involve diffusers.utils.check_if_model_has_local_files
        
        # Check if the model's main folder exists in the default cache
        cache_dir = os.path.join(os.path.expanduser("~"), ".cache", "huggingface", "hub")
        model_repo_dir = os.path.join(cache_dir, "models--zimageapp--z-image-turbo-q4") # Specific to the model_id
        
        if os.path.exists(model_repo_dir) and os.listdir(model_repo_dir):
            return model_repo_dir
        
        return None
    except Exception:
        return None

def main():
    parser = argparse.ArgumentParser(description="WeatherWeave Image Generation Script")
    parser.add_argument("prompt", nargs="?", help="The prompt for image generation")
    parser.add_argument("output_path", nargs="?", help="The path to save the generated image")
    parser.add_argument("--check-model", action="store_true", help="Check if the AI model is downloaded")
    parser.add_argument("--download-model", action="store_true", help="Download the AI model if not present")
    parser.add_argument("--device", type=str, default="auto", help="Device to use for generation (auto, cpu, mps, cuda)")

    args = parser.parse_args()

    # Determine device for PyTorch only
    if args.device == "auto":
        if 'mlx' in sys.modules: # Check if mlx was successfully imported earlier
            device = "mlx" # This is a placeholder for logic that might use mlx directly
        else:
            try:
                import torch
                if torch.backends.mps.is_available():
                    device = "mps"
                elif torch.cuda.is_available():
                    device = "cuda"
                else:
                    device = "cpu"
            except ImportError:
                device = "cpu"
    else:
        device = args.device
    
    # Model status check logic
    if args.check_model:
        if _get_model_path(MODEL_ID):
            print("DOWNLOADED")
        else:
            print("NOT_DOWNLOADED")
        sys.exit(0)

    # Model download logic
    if args.download_model:
        print("DOWNLOAD_STARTED")
        try:
            from diffusers import StableDiffusionPipeline
            # This will trigger download if not present
            if device == "mlx" or 'mlx' in sys.modules: # Prioritize MLX usage if available
                import mlx.core as mx
                pipe = StableDiffusionPipeline.from_pretrained(
                    MODEL_ID,
                    use_safetensors=True,
                    torch_dtype=torch.float16,
                )
            else:
                import torch
                pipe = StableDiffusionPipeline.from_pretrained(
                    MODEL_ID,
                    torch_dtype=torch.float16 if device != "cpu" else torch.float32,
                    use_safetensors=True,
                )
                pipe = pipe.to(device)
                pipe.enable_attention_slicing() # Enable for diffusers
            print("DOWNLOADED_SUCCESS")
            sys.exit(0)
        except Exception as e:
            print(f"DOWNLOAD_FAILED: {str(e)}", file=sys.stderr)
            sys.exit(1)

    # --- Standard Image Generation Logic (if no flags are present) ---
    if not args.prompt or not args.output_path:
        parser.print_help()
        sys.exit(1)

    prompt = args.prompt
    output_path = args.output_path

    print(f"Generating image with prompt: {prompt}")
    print(f"Output path: {output_path}")

    try:
        # Check if MLX and required libraries are available
        use_mlx_for_gen = False
        try:
            import mlx
            import mlx.core as mx
            from diffusers import StableDiffusionPipeline # Ensure diffusers is available for both paths
            use_mlx_for_gen = True
            print("Using MLX backend for image generation")
        except ImportError:
            use_mlx_for_gen = False
            print("MLX not available for generation, falling back to standard Diffusers")

        if use_mlx_for_gen:
            _generate_with_mlx(prompt, output_path)
        else:
            _generate_with_diffusers(prompt, output_path, device)

        print(f"Image successfully generated: {output_path}")
        sys.exit(0)

    except Exception as e:
        print(f"Error generating image: {str(e)}", file=sys.stderr)
        sys.exit(1)


def _generate_with_mlx(prompt: str, output_path: str):
    """Generate image using MLX-optimized Stable Diffusion"""
    from diffusers import StableDiffusionPipeline
    import mlx.core as mx
    import torch

    # Load the model optimized for Apple Silicon
    pipe = StableDiffusionPipeline.from_pretrained(
        MODEL_ID,
        use_safetensors=True,
        torch_dtype=torch.float16,
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


def _generate_with_diffusers(prompt: str, output_path: str, device: str):
    """Generate image using standard Diffusers library"""
    from diffusers import StableDiffusionPipeline
    import torch

    # Create pipeline
    pipe = StableDiffusionPipeline.from_pretrained(
        MODEL_ID,
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
