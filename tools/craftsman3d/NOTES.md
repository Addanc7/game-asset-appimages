# CraftsMan3D AppImage — publish notes

## Upstream
- Repo: https://github.com/HKUST-SAIL/CraftsMan3D
  (originally https://github.com/wyysf-98/CraftsMan3D, now redirects; built from
  the HKUST-SAIL mirror at commit `f87d6a5`)
- Project: CraftsMan3D — single image to 3D mesh via Dora-VAE + multiview diffusion.

## License
- **MIT (per README)** — the README states "CraftsMan3D is under MIT License."
  **Caveat:** no LICENSE file exists in the repo to verify against. Mirrors claiming
  AGPL-3.0 are incorrect per the project's own README. Built on the README's MIT claim.

## Build environment
- Base runtime: shared TRELLIS AppImage base: portable CPython 3.11.9 + torch 2.4.0+cu121,
  torchvision 0.19.0+cu121, xformers, nvdiffrast (CUDA kernels from the TRELLIS build,
  CUDA 12.9, arch 8.0/8.6/8.9/9.0).
- CUDA toolkit used: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86; installed via NVIDIA apt).
- AppImage packaged with appimagetool (zstd; bundled mksquashfs supports zstd only).

## Python deps added (via the AppDir's pip, third-party only)
- `diffusers==0.31.0`, `transformers==4.40.1`, `einops`, `omegaconf`, `jaxtyping`,
  `timm`, `pytorch-lightning==2.2.4`, `PyMCubes`, `joblib`, `packaging`,
  `setuptools==80.9.0` (kept), `torch-cluster==1.6.3+pt24cu121` (PyG wheel index).
- Patched `lightning_fabric` / `pytorch_lightning` to skip `pkg_resources.declare_namespace`.
- CraftsMan3D's `craftsman` package needed no source patches (diso imports are lazy;
  no py3.12-only syntax).

## VRAM expectations
- Target: RTX 4060 8GB. Defaults: 50 denoising steps, bf16, guidance 7.5.
  Lower `--steps` (30) and `--mc_depth` (7) if VRAM is tight.
- Baked-in knobs: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`, `CUDA_MODULE_LOADING=LAZY`.

## First-run weight downloads (to `~/.local/share/craftsman3d-appimage/models/`, resumable)
- `snapshot_download("craftsman3d/craftsman-DoraVAE")` — ~2-3 GB.

## Verification
- `CraftsMan3D-x86_64.AppImage --help` prints usage (verified via AppDir AppRun).
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`CraftsMan3D-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh CraftsMan3D-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `210add56e8c6b31a6191a69d3d1d17058e48b1f6b9e643bab27bf025f58af6f4`
