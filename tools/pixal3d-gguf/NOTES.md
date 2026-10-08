# Pixal3D-GGUF — build notes

## Upstream
- Repo: https://github.com/raven38/pixal3d.cpp (standalone C++ GGML implementation of TRELLIS.2 + Pixal3D)
- Commit built: `d1b4926452f9e09702b891db5f05acc845e153ed`
- Submodule `thirdparty/ggml` (pwilkin/ggml, `trellis-patches` branch): `737e88f25d4f62254f3b7a726fd9663036cc94da`
- Code license: **MIT** (repo root `LICENSE`)
- ⚠️ **License conflict (unresolved):** the repo README says MIT, but its
  third-party notices attribute Pixal3D to Tencent with academic/non-commercial
  terms. Do NOT present Pixal3D output as cleared for commercial work until
  this is resolved with upstream.

## Toolchain
- CUDA toolkit **13.3.73** (nvcc), assembled from NVIDIA ubuntu2404 `.debs`
- gcc 13.3, cmake 3.28, Release build
- `CMAKE_CUDA_ARCHITECTURES="89"` (sm_89 only — RTX 4060 target)
- `TMPDIR` redirected to workspace dir (nvcc temp files overflow 512 MB `/tmp` tmpfs)
- **Build patch** (in `build.sh`): the 33 `fattn-tile*` + `fattn-mma*` template
  instances in `thirdparty/ggml/src/ggml-cuda/CMakeLists.txt` are commented out.
  They are flash-attention *speed* optimizations only; the 4 `fattn-vec`
  kernels (f16/q4_0/q8_0/bf16) provide full functional fallback for every head
  dimension. All 21 `mmq` + 16 `mmf` instances (quantized matmul — the core of
  GGUF inference) are kept. Revert the patch for a max-performance rebuild.
- Shared build with `../trellis2-gguf`: one compile of `trellis-cli` serves
  both AppImages (run that `build.sh` first; this one is incremental).

## What it is
Pixal3D single-view → textured GLB, quantized to Q8_0 GGUF for 8 GB VRAM.
CLI: `trellis-cli --sv-image` (the AppRun adds `--sv-image`/`--models-sv`
automatically, so usage is just `input.png output.glb`).

## VRAM / hardware
- Target: x86-64 Linux + NVIDIA GPU, CUDA sm_89 (RTX 4060 8 GB).
- Single-view Pixal3D is lighter than the TRELLIS.2 cascade; expect it to fit
  comfortably in 8 GB at default settings. `--res 512` light path available.

## First-run weight download
Weights are NOT bundled (~9 GB). On first run `AppRun` calls
`ensure_weights.sh`, which downloads with resume (`curl -C -`) to
`~/.local/share/pixal3d-gguf/models-sv`, skipping files already present at the
expected byte size.

Pixal3D single-view set `pixal3d-sv-q8_0 v1` (~8.1 GB) from
`https://huggingface.co/raven38/pixal3d-sv-q8_0-v1/resolve/main`:

| file | bytes |
|---|---|
| dinov3.gguf | 323657920 |
| pixal3d_naf.gguf | 1334656 |
| pixal3d_ss_flow_sv.gguf | 1426559744 |
| ss_dec.gguf | 147379392 |
| pixal3d_shape_flow_512_sv.gguf | 1476761760 |
| shape_dec.gguf | 881361568 |
| pixal3d_shape_flow_1024_sv.gguf | 1476761760 |
| pixal3d_tex_flow_1024_sv.gguf | 1476813984 |
| tex_dec.gguf | 881344576 |

Plus optional BiRefNet (`birefnet.gguf`, 882749024 bytes) from
`https://huggingface.co/ilintar/trellis2-gguf/resolve/main` (better background
removal; the CLI falls back to a threshold matte without it).

Weight licenses: Pixal3D weights derive from TencentARC/Pixal3D checkpoints —
see the license-conflict warning above. DINOv3 under Meta's own license.
BiRefNet under its own license.

## AppImage
- `Pixal3D-GGUF-x86_64.AppImage`. Contains `trellis-cli` + `trellis-server`,
  `libggml*.so`, and CUDA runtime libs (`libcudart`, `libcublas`,
  `libcublasLt`) — the target needs only the NVIDIA driver, no toolkit.
- Launcher: `Pixal3D-GGUF-x86_64.AppImage input.png output.glb`
  (`--help` works without weights/GPU).
- Google Drive mirror: *(pending — AppImage packaging in progress)*

## Verification
- [x] `trellis-cli --help` runs (built from source, CUDA backend enabled)
- [ ] AppImage `--help` smoke test (pending packaging)
- [ ] First-run weight-download start (pending packaging)
- GPU inference not testable in the build container (no NVIDIA GPU) — first
  real generation must happen on the RTX 4060 target.

## Caveats
- Only sm_89 is compiled in. For other GPUs, extend
  `CMAKE_CUDA_ARCHITECTURES` in `build.sh` (compile time grows ~linearly).
- See "Build patch" above for the attention-kernel tradeoff.
- See the license-conflict warning above before any commercial use.
