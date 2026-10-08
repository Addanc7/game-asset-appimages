# TRELLIS.2 GGUF (AppImage)

Single image → textured GLB, powered by TRELLIS.2 quantized to Q8_0 GGUF so it
fits in 8 GB VRAM. Built from source — see `build.sh` and `NOTES.md`.

## Quick start

```bash
chmod +x TRELLIS2-GGUF-x86_64.AppImage
./TRELLIS2-GGUF-x86_64.AppImage input.png output.glb
```

First run downloads ~10 GB of weights (resumable) to
`~/.local/share/trellis2-gguf/models`. Needs an NVIDIA GPU (CUDA sm_89 / RTX 4060
target; driver only, no toolkit).

Options: `--res 512` for the light path (~1.8 GB VRAM), `--help` for all flags.
