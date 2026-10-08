# LGM AppImage — publish notes

## Upstream
- Repo: https://github.com/3DTopia/LGM
- Commit built: `fe8d12c` (2026-10-07, shallow clone)
- Project: "LGM: Large Multi-View Gaussian Model for High-Resolution 3D Content Creation"
  (Tang et al., 2024). Single image → 3D Gaussians (PLY) + 360° turntable video.

## License
- **MIT** — confirmed from the repo's `LICENSE` file ("MIT License, Copyright (c) 2024 3D Topia").

## Build environment
- Base runtime: shared TRELLIS AppImage base (`~/workspace/build/trellis-appimage/AppDir`):
  portable CPython 3.11.9 + torch 2.4.0+cu121, torchvision 0.19.0+cu121, xformers 0.0.27.post2,
  diff-gaussian-rasterization + nvdiffrast (CUDA kernels compiled from source during the
  TRELLIS build with CUDA 12.9, `TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0"`).
- No new CUDA compilation was needed for LGM (reuses the base runtime's kernels).
- CUDA toolkit version used for this campaign: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86).
- AppImage packaged with appimagetool (zstd compression; the bundled mksquashfs only
  supports zstd, not xz).

## Python deps added (via the AppDir's pip, third-party only)
- `tyro`, `kiui`, `roma`, `accelerate`, `lpips`, `einops`, `scikit-image`, `pygltflib`
- `diffusers==0.31.0`, `transformers==4.44.2` — pinned: newer releases require torch>=2.5,
  but the base runtime pins torch 2.4.0+cu121.
- Patch (inside AppImage only): `kiui/typing.py` — kiui 0.3.5 on PyPI ships an empty
  `typing.py` stub that breaks every `from kiui.typing import *`; replaced with proper
  re-exports (`Union`, `Tensor`, `ndarray`, `Sequence`, `Literal`, `Path`, ...).

## VRAM expectations
- Target: RTX 4060 8GB. LGM fp16 UNet + MVDream pipeline fit in 8GB at default settings
  (256px input, 64px splats). Baked-in knobs: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`,
  `CUDA_MODULE_LOADING=LAZY` (overridable via env).

## First-run weight downloads (to `~/.local/share/lgm-appimage/`, resumable via `curl -C -`)
1. `model_fp16_fixrot.safetensors` (~1.2 GB)
   https://huggingface.co/ashawkey/LGM/resolve/main/model_fp16_fixrot.safetensors
2. MVDream pipeline `ashawkey/imagedream-ipmv-diffusers` (~2–3 GB, via HF hub cache)
   downloaded automatically by diffusers on first inference.

## Verification
- `LGM-x86_64.AppImage --help` and `lrm --help` print the full tyro CLI (import chain:
  torch, diffusers, transformers, rembg, kiui, LGM model — all OK).
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`LGM-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh LGM-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `a19bae96cddc8735e27758621d562f491a63f958986ba35b0dfb6769595787af`
