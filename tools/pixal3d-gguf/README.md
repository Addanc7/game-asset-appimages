# Pixal3D GGUF (AppImage)

Single image → textured GLB via the Pixal3D single-view backbone, quantized to
Q8_0 GGUF for 8 GB VRAM. Built from source — see `build.sh` and `NOTES.md`.

> ⚠️ License note: upstream's Pixal3D licensing is contradictory (README says
> MIT, third-party notices claim Tencent academic/non-commercial). Don't use
> for commercial work until that's resolved.

## Quick start

```bash
chmod +x Pixal3D-GGUF-x86_64.AppImage
./Pixal3D-GGUF-x86_64.AppImage input.png output.glb
```

First run downloads ~9 GB of weights (resumable) to
`~/.local/share/pixal3d-gguf/models-sv`. Needs an NVIDIA GPU (CUDA sm_89 /
RTX 4060 target; driver only, no toolkit).

`--help` works without weights/GPU.
