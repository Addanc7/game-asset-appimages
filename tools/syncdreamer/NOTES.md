# SyncDreamer AppImage — publish notes

## Upstream
- Repo: https://github.com/liuyuan-pal/SyncDreamer
- Commit built: `cc373c8` (2026-10-08, shallow clone)
- Project: "SyncDreamer: Generating Multiview-consistent Images from a Single-view Image"
  (Liu et al., ICLR 2024). Single image → 16 multiview-consistent images.

## License
- **MIT** — confirmed from the repo's `LICENSE` file.

## Build environment
- Base runtime: shared TRELLIS AppImage base: portable CPython 3.11.9 + torch 2.4.0+cu121,
  torchvision 0.19.0+cu121, xformers, nvdiffrast (CUDA kernels from the TRELLIS build,
  CUDA 12.9, arch 8.0/8.6/8.9/9.0).
- CUDA toolkit used: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86; installed via NVIDIA apt).
- AppImage packaged with appimagetool (zstd; bundled mksquashfs supports zstd only).

## Python deps added (via the AppDir's pip, third-party only)
- `pytorch_lightning==1.9.0`, `taming-transformers-rom1504`, `webdataset`, `easydict`,
  `open3d`, `carvekit-colab`, `openai/CLIP` (git), `einops`, `kornia`,
  `transformers==4.44.2`, `scikit-image`, `packaging`, `setuptools==80.9.0`
  (kept: pytorch_lightning needs pkg_resources at import).
- Patched `lightning_fabric/__init__.py` and `pytorch_lightning/__init__.py` in the AppDir
  to skip `pkg_resources.declare_namespace` (43s filesystem scan on every import).

## VRAM expectations
- Target: RTX 4060 8GB. Defaults: `--sample_steps 50`, `--batch_view_num 8`, `--cfg_scale 2.0`.
  Lower `--batch_view_num` (4) and `--sample_steps` (30) if VRAM is tight.
- Baked-in knobs: `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`, `CUDA_MODULE_LOADING=LAZY`.

## First-run weight downloads (to `~/.local/share/syncdreamer-appimage/models/`, resumable-ish)
- Google Drive file `1ypyD5WXxAnsWjnHgAfOAGolV0Zd9kpam` (~3.5 GB zip) via direct download
  with confirm-token handling; contains:
  - `ViT-L-14.ckpt` (CLIP image encoder)
  - `syncdreamer-pretrain.ckpt` (SyncDreamer UNet)
- No HuggingFace mirror exists for these weights; Drive is the only source.

## Verification
- `SyncDreamer-x86_64.AppImage --help` prints usage (verified via AppDir AppRun).
- `generate.py --help` prints full argparse CLI (all options).
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.
