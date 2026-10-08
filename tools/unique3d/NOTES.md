# Unique3D — publish notes

- Upstream repo: https://github.com/AiuniAI/Unique3D
- Git commit built: `6311af200ee197544e82e0f2557cd890edd60416`
- License: **MIT** (confirmed from the repo's LICENSE file)
- AppImage: `Unique3D-x86_64.AppImage` (zstd squashfs)
- CUDA toolkit version used: 12.1 — via official `torch==2.4.0+cu121` /
  `torchvision==0.19.0+cu121` / `xformers==0.0.27.post2` PyPI wheels,
  `onnxruntime-gpu==1.22.0` (PyPI; CUDA-12 build — 1.30.x moved to CUDA 13),
  `pytorch3d==0.7.8` (official pytorch3d conda channel,
  `py311_cu121_pyt240` build), `torch-scatter` (PyG `pt24cu121` wheel),
  prebuilt `nvdiffrast`. No nvcc in the build sandbox, so compiled deps come
  from their official binary channels, exactly as upstream's Installation.md
  recommends. The tool itself (Unique3D) is pure Python.
- VRAM expectations: upstream demo targets 12GB+; the launcher defaults to
  NO refinement on 8GB cards (RTX 4060). The base pipeline (img2mvimg +
  image2normal + RealESRGAN + rembg + pytorch3d meshing) loads models
  sequentially. `--refine` enables the SD1.5 ControlNet detail pass.
- First-run weight download (one-time, resumable) → `~/.local/share/unique3d-app/models`:
  1. `ckpt/*` from the `Wuvin/Unique3D` Hugging Face Space (~7 GB: image2normal,
     img2mvimg, controlnet-tile, realesrgan-x4.onnx) via
     `snapshot_download(repo_id="Wuvin/Unique3D", repo_type="space",
     allow_patterns=["ckpt/*"])`
  2. `runwayml/stable-diffusion-v1-5` (~4 GB, HF cache — only with `--refine`)
  3. `h94/IP-Adapter` image encoder (HF cache — only with `--refine`)
  4. rembg background model (`bria-rmbg-2.0.onnx`, ~1 GB) → `$DATA_DIR/u2net`
     on first inference (rembg default in 2.0.85)
- Source patches applied (documented in build.sh):
  1. `scripts/load_onnx.py`: removed the `TensorrtExecutionProvider` entry —
     upstream's Installation.md documents exactly this when TensorRT isn't
     installed; CUDAExecutionProvider is used.
  2. `scripts/utils.py`: fall back to `CPUExecutionProvider` for the rembg
     session when `torch.cuda.is_available()` is False — the CUDA EP
     segfaults natively (no Python exception) without a GPU, which also broke
     import-time verification. Behavior on GPU machines is unchanged.
- AppRun extends `LD_LIBRARY_PATH` with the bundled
  `site-packages/nvidia/*/lib` dirs — onnxruntime's CUDA provider `.so` has no
  RPATH (torch finds them via its own RPATH).
- Verified: `--help` runs; `pytorch3d`/`torch_scatter`/`onnxruntime-gpu`
  (CUDA EP listed) import; all upstream modules compile (`compileall`);
  `scripts.utils` + `app.utils` import (CPU fallback path).
  GPU inference not testable in the build sandbox (no NVIDIA GPU).

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Unique3D-x86_64.AppImage.part-00` … `.part-07` (8 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Unique3D-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 8
- SHA256 of reassembled AppImage: `c431e5bd5e8707bd8355a5efef27280e22d6d0a6951d572f75bb4869a2d6c63e`
