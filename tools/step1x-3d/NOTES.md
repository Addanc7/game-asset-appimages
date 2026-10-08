# Step1X-3D — publish notes

- Upstream repo: https://github.com/stepfun-ai/Step1X-3D (official StepFun repo)
- Git commit built: `cb5ac944709c6c913109070c7b90c3447f57f3d4` (origin/main HEAD, 2025-09-09)
- License: repo LICENSE file is **Apache-2.0**. ⚠️ CONFLICT: the vendored
  `step1x3d_texture/differentiable_renderer/` files (reused from Tencent
  Hunyuan3D-2.0) carry **Tencent Hunyuan non-commercial license** headers.
  Do not ship commercial work on this build until the conflict is resolved.
- AppImage: `Step1X-3D-x86_64.AppImage` (3.4 GB, zstd squashfs)
- CUDA toolkit: torch 2.4.0+cu121 / torchvision 0.19.0 (pip wheels); CUDA
  extensions (`custom_rasterizer_kernel`, `mesh_processor`, pytorch3d)
  compiled from source with nvcc 12.9 (sm_86 + sm_89)
- VRAM expectations: tuned for 8GB cards (RTX 4060)
- First-run weight download (resumable, one-time) → `~/.local/share/step1x-3d/`
- Verified: `--help` runs. GPU inference not testable in the build sandbox
  (no NVIDIA GPU).

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`Step1X-3D-x86_64.AppImage.part-00` … `.part-08` (9 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh Step1X-3D-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 9
- SHA256 of reassembled AppImage: `ffc6bd532c3982cf4b22b8c3d39672a84537ec1a2e67b65965d038a9ff54c2b5`
