# TripoSR — publish notes

- Upstream repo: https://github.com/VAST-AI-Research/TripoSR (Tripo AI + Stability AI)
- Git commit built: `107cefdc244c39106fa830359024f6a2f1c78871` (main, 2026-06-04)
- License: **MIT** (see `src/LICENSE`)
- AppImage: `TripoSR-x86_64.AppImage` (2.8 GB, zstd squashfs)
- CUDA toolkit: torch 2.4.0+cu121 / torchvision 0.19.0+cu121 (pip wheels);
  portable CPython 3.11.9 built from source
- Note: `torchmcubes` compiled CPU-only (nvcc OOM in the build sandbox) —
  mesh extraction falls back to CPU per upstream's documented path
- VRAM expectations: ~6GB; fits 8GB cards comfortably
- First-run weight download (~1.85 GB, resumable, one-time) → `~/.local/share/triposr/`
- Verified: `--help` runs; launcher writes textured GLB. GPU inference not
  testable in the build sandbox (no NVIDIA GPU).

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`TripoSR-x86_64.AppImage.part-00` … `.part-06` (7 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh TripoSR-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 7
- SHA256 of reassembled AppImage: `6dd309bdffe2611e18fabf546ca1552ea32a97bb2fa85ca0cc2c3f1aaa98553d`
