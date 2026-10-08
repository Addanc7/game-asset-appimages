# Era3D AppImage — publish notes

## Upstream
- Repo: https://github.com/pengHTYX/Era3D
- Commit built: `a2ce68d` (2026-10-07, shallow clone)
- Project: "Era3D: High-Resolution Multiview Diffusion using Efficient Row-wise Attention"
  (Li et al., 2024). Single image → 6-view RGB + normal images.

## License
- **AGPL-3.0** — confirmed from the repo's `LICENCE` file (GNU Affero General Public
  License v3, 660 lines). The project README reiterates: downstream solutions/products
  including this code or the pretrained model must be open-sourced per AGPL terms.

## Build environment
- Base runtime: shared TRELLIS AppImage base: portable CPython 3.11.9 + torch 2.4.0+cu121,
  torchvision 0.19.0+cu121, xformers, nvdiffrast (CUDA kernels from the TRELLIS build,
  CUDA 12.9, arch 8.0/8.6/8.9/9.0).
- CUDA toolkit used: 12.9 (`/usr/local/cuda-12.9`, nvcc 12.9.86; installed via NVIDIA apt).
- AppImage packaged with appimagetool (zstd; bundled mksquashfs supports zstd only).

## Python deps added (via the AppDir's pip, third-party only)
- `diffusers==0.26.0`, `transformers==4.37.2`, `huggingface_hub==0.20.3`
  (pinned: diffusers 0.26 needs hub's `cached_download`; newer hub removed it;
  newer diffusers/transformers need torch>=2.5, base pins torch 2.4.0).
- `accelerate`, `omegaconf`, `einops`, `icecream`, `kornia`, `nerfacc==0.3.3`,
  `PyMCubes`, `pyransac3d`; `rembg`, `trimesh`, `opencv`, `scipy` already in base.
- `setuptools==80.9.0` temporarily (build-only, removed before packaging).

## tiny-cuda-nn / instant-nsr-pl
- **Not bundled.** tiny-cuda-nn (NVlabs, @`3daa6e5`) was cloned and its torch bindings
  build was attempted from source (`CUDA_HOME=/usr/local/cuda-12.9`,
  `TCNN_CUDA_ARCHITECTURES=89`), but nvcc was OOM-killed (exit 137) — the build VM has
  7.7GB RAM, no swap permitted, shared with sibling workers. The multiview diffusion
  CLI (the primary inference path) does not need it. `reconstruct` mode was removed
  from the launcher; README documents the limitation.

## VRAM expectations
- Target: RTX 4060 8GB. Era3D 512px 6-view UNet (fp16) fits in 8GB; baked-in knobs:
  `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`, `CUDA_MODULE_LOADING=LAZY`.
  Lower `validation_dataset.crop_size` (420→400) if VRAM is tight.

## First-run weight downloads (to `~/.local/share/era3d-appimage/models/`, resumable)
- `snapshot_download("pengHTYX/MacLab-Era3D-512-6view")` — ~4.0 GB total:
  - `unet/diffusion_pytorch_model.safetensors` — 1.9 GB
  - `image_encoder/model.safetensors` — 1.26 GB
  - `text_encoder/model.safetensors` — 0.68 GB
  - `vae/diffusion_pytorch_model.safetensors` — 0.17 GB

## Verification
- `Era3D-x86_64.AppImage --help` prints usage without importing torch.
- Import chain verified: `mvdiffusion.pipelines.pipeline_mvdiffusion_unclip`,
  `mvdiffusion.data.single_image_dataset`, `utils.misc` all import OK.
- GPU inference untestable in the build VM (no NVIDIA GPU); recorded per tool.

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Era3D-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Era3D-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `18a4309ca9cfe2853eb02de87bc9d3a5a59215f00085258339eb2d8c6c4e94c5`
