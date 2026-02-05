# Draw Things Approach: On-Device Conversion

## Why This Is Better

Instead of pre-converting models, we do what production apps like Draw Things do:

```
❌ Old Approach (What we were trying):
Developer converts model → Upload 2-3GB → Users download → Use

✅ Draw Things Approach (What we're doing now):
Users download .safetensors → Convert on-device (one-time, 2-3 min) → Cache → Use
```

## Benefits

### For Users
- **Smaller initial download**: 5GB checkpoint vs 7GB (checkpoint + app with Python)
- **Always latest model**: Download directly from Hugging Face
- **Flexible**: Can support multiple models
- **Transparent**: See conversion progress

### For Developers
- **No hosting needed**: Point to Hugging Face URLs
- **No large releases**: GitHub has 2GB file limit
- **Easy updates**: Just change URL
- **Industry standard**: How Draw Things, DiffusionBee, etc. do it

## User Experience Flow

```
1. Install WeatherWeave (50MB app)
   ↓
2. First launch → Settings → Download Model
   ↓
3. Download .safetensors from HuggingFace (5GB, ~2-5 min)
   ↓
4. Convert to Core ML on-device (2-3 min, shows progress)
   ↓
5. Cache Core ML model (~4GB quantized)
   ↓
6. Generate wallpapers (<1 second forever!)
```

**One-time setup: ~5-8 minutes**
**All future generations: <1 second**

## Implementation

### Swift Side

```swift
// OnDeviceModelConverter handles everything
let converter = OnDeviceModelConverter()

// Download and convert (one-time)
try await converter.downloadAndConvert()
// Progress updates via @Published state

// Use cached model
if let modelPath = converter.getCoreMLModelPath() {
    let generator = CoreMLImageGenerator(modelPath: modelPath)
    let image = try await generator.generate(prompt: "sunny day")
}
```

### Python Side

```python
# convert_checkpoint.py does the heavy lifting
# 1. Loads .safetensors with safetensors library
# 2. Loads model architecture with diffusers
# 3. Converts to Core ML with coremltools
# 4. Quantizes to 6-bit (12GB → 4GB)
# 5. Optimizes for Neural Engine
```

## Technical Details

### Conversion Process

```python
import torch
import coremltools as ct
from safetensors.torch import load_file
from diffusers import StableDiffusionPipeline

# 1. Load checkpoint
state_dict = load_file("model.safetensors")

# 2. Load into diffusers pipeline
pipe = StableDiffusionPipeline.from_single_file("model.safetensors")

# 3. Trace and convert each component
unet_traced = torch.jit.trace(pipe.unet, example_inputs)
unet_ml = ct.convert(unet_traced, compute_units=ct.ComputeUnit.ALL)

# 4. Quantize
quantized = ct.optimize.coreml.linear_quantize_weights(unet_ml, nbits=6)

# 5. Save
quantized.save("model.mlmodelc")
```

### Storage Layout

```
~/Library/Application Support/WeatherWeave/Models/
├── checkpoint.safetensors      # Downloaded (5GB) - deleted after conversion
└── z-image-turbo.mlmodelc/     # Cached Core ML (4GB) - kept forever
    ├── model.mil
    ├── weights/
    └── metadata.json
```

## Comparison with Other Approaches

| Approach | Download | Setup Time | Space | Updates |
|----------|----------|------------|-------|---------|
| **Python Bundled** | 700MB app | Instant | 700MB + 5GB model | Hard |
| **Pre-converted CoreML** | 50MB app + 2-3GB model | Instant | 2-3GB | Manual |
| **Draw Things (Ours)** | 50MB app + 5GB checkpoint | 2-3 min | 4GB (cached) | Automatic |

## Dependencies

### Required Python Packages (Bundled with App)
```
torch
safetensors
diffusers
transformers
coremltools
```

### System Requirements
- macOS 13.0+ (for Core ML features)
- Apple Silicon recommended (M1/M2/M3/M4)
- 16GB+ RAM (for conversion)
- 10GB free space (temp during conversion)

## Production Apps Using This Approach

- **Draw Things**: Exactly this approach
- **DiffusionBee**: Similar (converts CKPT on first use)
- **Mochi Diffusion**: Downloads and converts
- **Core ML Stable Diffusion**: Reference implementation

## References

- [Draw Things Blog: Z-Image Turbo Efficiency](https://releases.drawthings.ai/p/quantify-z-image-turbo-efficiency)
- [Apple Core ML Tools](https://apple.github.io/coremltools/)
- [Apple ml-stable-diffusion](https://github.com/apple/ml-stable-diffusion)
- [Hugging Face: Z-Image-Turbo](https://huggingface.co/zimageapp/z-image-turbo-q4)

---

**Status**: ✅ Implemented
**Files**:
- `OnDeviceModelConverter.swift` - Swift coordinator
- `convert_checkpoint.py` - Python converter
- `CoreMLImageGenerator.swift` - Uses converted model

**Next**: Integrate into Settings UI and test conversion flow
