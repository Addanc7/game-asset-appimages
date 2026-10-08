# Direct3D — publish notes

- Upstream repo: https://github.com/DreamTechAI/Direct3D
- Git commit built: `e786532fb4ed4564fe352c67267f1728c92c9da6`
- License: **Apache-2.0** (confirmed from the repo's LICENSE file — the
  campaign brief said "MIT (reported)"; the actual file is Apache-2.0,
  still genuinely open-source)
- AppImage: `Direct3D-x86_64.AppImage` (zstd squashfs)
- CUDA toolkit version used: 12.1 — via official `torch==2.4.0+cu121` /
  `torchvision==0.19.0+cu121` / `xformers==0.0.27.post2` PyPI wheels.
  No nvcc in the build sandbox. The tool itself (Direct3D) is pure Python.
- VRAM expectations: upstream reports 10GB @512 / 24GB @1024. The launcher
  defaults to 25 diffusion steps (upstream example uses 50) for 8GB cards
  (RTX 4060); lower `--steps` further if it OOMs.
- First-run weight download (one-time, resumable) → `~/.local/share/direct3d-app/models`:
  1. `DreamTechAI/Direct3D`: `config.yaml` + `model.ckpt` (~7-8 GB, HF snapshot)
  2. `openai/clip-vit-large-patch14` (~1.7 GB, HF cache) — semantic encoder
  3. `facebook/dinov2-large` (~1.2 GB, HF cache) — pixel encoder
- Verified: `--help` runs; `direct3d` package (installed from source),
  `diffusers` 0.39.0, `transformers` 4.40.2, `omegaconf`, `einops` import;
  `Direct3dPipeline` class imports.
  GPU inference not testable in the build sandbox (no NVIDIA GPU).
- Install note: `pip install --no-deps --no-build-isolation .` from the repo
  produced an empty wheel (RECORD contained only dist-info), so the
  pure-Python `direct3d/` package tree is copied straight from the source
  into `site-packages` instead. Reproducible and from-source either way.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Direct3D-x86_64.AppImage.part-00` … `.part-06` (7 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Direct3D-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 7
- SHA256 of reassembled AppImage: `47eb585038aa94ae60d715664017b2987043ca4364d488cf3acfebe667b43c8b`
