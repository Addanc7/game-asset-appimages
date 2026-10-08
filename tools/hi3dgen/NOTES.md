# Hi3DGen — publish notes

- Upstream repo: https://github.com/Stable-X/Hi3DGen
- Git commit built: `c29f668ecec44b197275e9bf77f823c0c8a21076`
- License: **MIT** (confirmed from the repo's LICENSE file)
- AppImage: `Hi3DGen-x86_64.AppImage` (zstd squashfs)
- CUDA toolkit version used: 12.1 — via official `torch==2.4.0+cu121` /
  `torchvision==0.19.0+cu121` / `xformers==0.0.27.post2` PyPI wheels and the
  prebuilt `spconv-cu120` wheel. No nvcc in the build sandbox. The tool
  itself (Hi3DGen) is pure Python.
- VRAM expectations: upstream reports ~12GB. The launcher defaults to
  reduced settings for 8GB cards (RTX 4060): input resolution 768 (upstream
  1024), sparse-structure steps 25 (upstream 50), slat steps 6. An OOM is
  still possible on complex inputs — lower `--resolution`/`--ss_steps` more.
- First-run weight download (one-time, resumable) → `~/.local/share/hi3dgen-app/models`:
  1. `Stable-X/trellis-normal-v0-1` (~6 GB, HF snapshot)
  2. `Stable-X/yoso-normal-v1-8-1` (~4 GB, HF snapshot)
  3. `ZhengPeng7/BiRefNet` (~1 GB, HF cache)
- The StableNormal `hubconf.py` repo (Apache-2.0, hugoycj/StableNormal) is
  bundled at `usr/share/hi3dgen/stn-src/` and loaded via `torch.hub` with
  `source='local'` — no GitHub fetch at runtime.
- Verified: `--help` runs; `kornia` 0.8.0 / `timm` 0.6.7 / `diffusers` 0.39.0 /
  `transformers` 4.46.3 import cleanly against numpy 2.4.6 (requirements pin
  numpy==1.26.4, but downgrading would break opencv/rembg); `Hi3DGenPipeline`
  imports (`[SPARSE] Backend: spconv, Attention: xformers`).
  GPU inference not testable in the build sandbox (no NVIDIA GPU).
