# TRELLIS.2-GGUF — build notes

## Upstream
- Repo: https://github.com/raven38/pixal3d.cpp (standalone C++ GGML implementation of TRELLIS.2 + Pixal3D)
- Commit built: `d1b4926452f9e09702b891db5f05acc845e153ed`
- Submodule `thirdparty/ggml` (pwilkin/ggml, `trellis-patches` branch): `737e88f25d4f62254f3b7a726fd9663036cc94da`
- Code license: **MIT** (repo root `LICENSE`)

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

## What it is
TRELLIS.2 single-image → textured GLB, quantized to Q8_0 GGUF so it fits in
8 GB VRAM (the FP16 OG TRELLIS OOMs on the RTX 4060). CLI: `trellis-cli`.

## VRAM / hardware
- Target: x86-64 Linux + NVIDIA GPU, CUDA sm_89 (RTX 4060 8 GB).
- AppRun defaults to the `--res 1024` cascade. Upstream measured the full
  res-1024 pipeline peaking ~4.7–6.2 GB on an 8 GB budget
  (`docs/PIXAL3D_DESKTOP_VRAM.md` in upstream), with automatic chunk-size
  scaling for ≤8 GB cards.
- Light path: pass `--res 512` (~1.8 GB) if a dense image still OOMs.

## First-run weight download
Weights are NOT bundled (~10 GB). On first run `AppRun` calls
`ensure_weights.sh`, which downloads with resume (`curl -C -`) to
`~/.local/share/trellis2-gguf/models`, skipping files already present at the
expected byte size.

TRELLIS.2 Q8_0 set (~10.0 GB) from
`https://huggingface.co/ilintar/trellis2-gguf/resolve/main/q8`:

| file | bytes |
|---|---|
| birefnet.gguf | 882749024 |
| dinov3.gguf | 323657920 |
| ss_flow.gguf | 1376059040 |
| ss_dec.gguf | 147379392 |
| shape_flow_512.gguf | 1376125952 |
| shape_flow_1024.gguf | 1376125952 |
| shape_dec.gguf | 881361568 |
| tex_flow_512.gguf | 1376178176 |
| tex_flow_1024.gguf | 1376178176 |
| tex_dec.gguf | 881344576 |

Weight licenses: TRELLIS.2 weights © Microsoft, **MIT**; DINOv3 under Meta's
own license (`DINOV3_LICENSE.md` in the HF repo); BiRefNet under its own
license — check before commercial use.

## AppImage
- `TRELLIS2-GGUF-x86_64.AppImage`. Contains `trellis-cli` + `trellis-server`,
  `libggml*.so`, and CUDA runtime libs (`libcudart`, `libcublas`,
  `libcublasLt`) — the target needs only the NVIDIA driver, no toolkit.
- Launcher: `TRELLIS2-GGUF-x86_64.AppImage input.png output.glb [--res 512]`
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
