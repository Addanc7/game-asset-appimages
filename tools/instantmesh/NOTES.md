# InstantMesh — publish notes

- Upstream repo: https://github.com/TencentARC/InstantMesh
- Git commit built: `08822c52fdc399b93ea00e4fa9e596344ed52ccc`
- License: **Apache-2.0** (confirmed from the repo's LICENSE file)
- AppImage: `InstantMesh-x86_64.AppImage` (xz squashfs)
- CUDA toolkit version used: 12.1 — via official `torch==2.4.0+cu121` /
  `torchvision==0.19.0+cu121` / `xformers==0.0.27.post2` PyPI wheels, plus
  prebuilt `nvdiffrast` / `spconv` wheels. No nvcc in the build sandbox, so
  the only compiled-from-source bits are pure C++ pip builds (PyMCubes).
  The tool itself (InstantMesh) is pure Python — no custom CUDA ops.
- VRAM expectations: upstream targets ~10GB+; the launcher defaults to 50
  diffusion steps (upstream default 75) and is tuned for 8GB cards
  (RTX 4060). `--export_texmap` needs more VRAM.
- First-run weight download (~9 GB, resumable, one-time) → `~/.local/share/instantmesh-app/models`:
  1. `sudo-ai/zero123plus-v1.2` (~4.3 GB, HF snapshot)
  2. `https://huggingface.co/TencentARC/InstantMesh/resolve/main/diffusion_pytorch_model.bin` (~3.3 GB, curl -C - resume)
  3. `https://huggingface.co/TencentARC/InstantMesh/resolve/main/instant_mesh_large.ckpt` (~1.2 GB, curl -C - resume)
- Verified: `--help` runs; all upstream `run.py` imports resolve
  (torch/diffusers/transformers/pytorch_lightning/nvdiffrast/PyMCubes/xatlas/rembg).
  GPU inference not testable in the build sandbox (no NVIDIA GPU) — launch
  through first-run download was code-reviewed, not executed.
