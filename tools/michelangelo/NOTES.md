# Michelangelo AppImage — publish notes

## Upstream
- Repo: https://github.com/NeuralCarver/Michelangelo
- Commit built: `6d83b0ba` (2026-10-08, shallow clone)
- Project: Michelangelo — text/image/point-cloud to 3D shape generation.

## License
- **GPL-3.0** — confirmed from the repo's `LICENSE` file (GNU General Public License v3).
  (The fork claim of GPL-3.0 is correct.)

## Build environment
- Base runtime: shared TRELLIS AppImage base: portable CPython 3.11.9 + torch 2.4.0+cu121,
  torchvision 0.19.0+cu121, xformers, nvdiffrast (CUDA kernels from the TRELLIS build,
  CUDA 12.9, arch 8.0/8.6/8.9/9.0).
- CUDA toolkit used: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86; installed via NVIDIA apt).
- AppImage packaged with appimagetool (zstd; bundled mksquashfs supports zstd only).

## Python deps added (via the AppDir's pip, third-party only)
- `einops`, `omegaconf`, `pytorch-lightning==2.2.4`, `packaging`, `setuptools==80.9.0`,
  `opencv-python-headless`. (Minimal set for inference; full requirements.txt is huge.)
- Patched `lightning_fabric` / `pytorch_lightning` to skip `pkg_resources.declare_namespace`.

## VRAM expectations
- Target: RTX 4060 8GB. The launcher passes through to upstream `inference.py`
  (`--task image2mesh|text2mesh|reconstruction`). 8GB-VRAM knobs baked in:
  `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`, `CUDA_MODULE_LOADING=LAZY`.

## First-run weight downloads (to `~/.local/share/michelangelo-appimage/models/`, resumable)
- `hf_hub_download("NeuralCarver/michelangelo", "tsal-epoch=021.ckpt")` — ~2 GB.

## Verification
- `Michelangelo-x86_64.AppImage --help` prints usage (verified via AppDir AppRun).
- `michelangelo` package imports OK.
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Michelangelo-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Michelangelo-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `74ea162e12b9f4fcb78f25589b18d0c1473d2309ab78538980447266f80c73df`
