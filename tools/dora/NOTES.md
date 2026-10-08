# Dora AppImage — publish notes

## Upstream
- Repo: https://github.com/Seed3D/Dora
- Commit built: `a166e21` (2026-10-07, shallow clone)
- Project: "Dora: Exploring and Disentangling the Factors of Variation in 3D Shapes"
  — a shape VAE (variational autoencoder) for 3D meshes. This AppImage packages Dora-VAE
  as a single-mesh encode→decode round-trip demo (the repo has no standalone demo CLI;
  the test harness requires preprocessed datasets).

## License
- **Apache-2.0** — confirmed from the repo's `LICENSE` file (200 lines).

## Build environment
- Base runtime: shared TRELLIS AppImage base: portable CPython 3.11.9 + torch 2.4.0+cu121,
  torchvision 0.19.0+cu121, xformers, nvdiffrast (CUDA kernels from the TRELLIS build,
  CUDA 12.9, arch 8.0/8.6/8.9/9.0).
- CUDA toolkit used: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86; installed via NVIDIA apt).
- AppImage packaged with appimagetool (zstd; bundled mksquashfs supports zstd only).

## Python deps added (via the AppDir's pip, third-party only)
- `diffusers==0.31.0`, `transformers==4.40.1`, `einops`, `omegaconf`, `jaxtyping`,
  `timm`, `pytorch-lightning==2.2.4`, `PyMCubes`, `joblib`, `torch-cluster==1.6.3+pt24cu121`
  (from PyG wheel index for torch-2.4.0+cu121), `setuptools==80.9.0` (build-only, removed).
- Patches to the AppDir copy of Dora source (documented in build.sh):
  - `craftsman/models/autoencoders/utils.py`: `diso` import made optional (only needed for
    `extract_geometry_by_diffdmc`; this AppImage uses marching-cubes `extract_geometry`).
  - `craftsman/systems/shape_autoencoder.py`: fixed two Python-3.12-only f-strings
    (nested same-type quotes) that are SyntaxErrors on 3.11.
  - `craftsman/utils/saving.py`: `wandb` import made optional.
  - `lightning_fabric` / `pytorch_lightning` `__init__.py`: skip
    `pkg_resources.declare_namespace` (43s filesystem scan per import).

## VRAM expectations
- Target: RTX 4060 8GB. Dora-VAE itself is lightweight; the marching-cubes occupancy grid
  at `--octree_depth 8` is the main memory consumer. Use `--octree_depth 7` if tight.
- Baked-in knobs: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`, `CUDA_MODULE_LOADING=LAZY`.

## First-run weight downloads (to `~/.local/share/dora-appimage/models/`, resumable)
- `snapshot_download("Seed3D/Dora-VAE-1.1")` — `dora_vae_1_1.ckpt`, ~1.5 GB.

## Verification
- `Dora-x86_64.AppImage --help` prints usage (verified via AppDir AppRun).
- `craftsman.models.autoencoders.michelangelo_autoencoder.MichelangeloAutoencoder`
  imports OK ("dora imports OK").
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Dora-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Dora-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `949e3a1d30a396fc54b237c71001413666ae112501f456353a85e2b95126536b`
