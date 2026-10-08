# UniRig — publish notes

- Upstream repo: https://github.com/VAST-AI-Research/UniRig (VAST-AI-Research org —
  the SIGGRAPH'25 "One Model to Rig Them All" paper implementation)
- Git commit built: `6793c6640ff01c8fb389f3993434124bb43d2933` (2026-06-04)
- License: **MIT** (LICENSE file in repo root)
- AppImage: `UniRig-x86_64.AppImage` (3.67 GB, zstd squashfs)
- CUDA toolkit: torch 2.4.0+cu121 / torchvision 0.19.0+cu121 (pip wheels);
  portable CPython 3.11.9 built from source
- VRAM expectations: auto-rigs arbitrary meshes; tuned for 8GB cards (RTX 4060)
- First-run weight download (resumable, one-time) → `~/.local/share/unirig-app/models`
- Verified: `--help` runs. GPU inference not testable in the build sandbox
  (no NVIDIA GPU).

## Delivery (chunked)

The AppImage is too large for a single upload, so it is distributed as ~400 MB
chunks in the Google Drive folder `game-asset-appimages`:
`UniRig-x86_64.AppImage.part-00` … `.part-09` (10 chunks).

To reassemble: download all `.part-*` files plus `reassemble.sh` from the same
Drive folder into one directory, then run `./reassemble.sh UniRig-x86_64.AppImage`.
See `CHUNKS_README.md` (repo root and Drive folder) for full instructions.

- Chunks: 10
- SHA256 of reassembled AppImage: `ddd95bea55c3ca1ae505a998023b616d7d6ceac3b58699098c4fe2e82a55349b`
