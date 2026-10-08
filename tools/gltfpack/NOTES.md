# gltfpack — build notes

## Upstream
- Repo: https://github.com/zeux/meshoptimizer (gltfpack lives in `gltf/`, not `tools/`)
- Commit built: `4195af679a7e4a968b4a23874272f152600c9f72` (2026-10-07)
- License: **MIT** (verified in `LICENSE.md`, "Copyright (c) 2016-2026 Arseny Kapoulkine", and `gltf/gltfpack.h`)

## Toolchain
- g++ 13.3.0, cmake 3.28.3, Release build (`-DMESHOPT_BUILD_GLTFPACK=ON`)
- Linked `-static-libstdc++ -static-libgcc`; `ldd` shows only libm + libc → runs on Bazzite/Fedora 44+ with no extra deps

## What it is
glTF/GLB optimizer: quantization, EXT_meshopt_compression (`-cc`), mesh simplification (`-si`/`-sa`), Sept 2026 voxel remesher + normal generator. Pure C++ CLI — no GPU, no model weights, no network.

## VRAM / hardware
N/A — CPU-only, runs on anything x86-64.

## First-run weight download
None — no weights.

## AppImage
- `gltfpack-x86_64.AppImage` (1.3 MB). Launcher just execs gltfpack with all args.
- Google Drive mirror: https://drive.google.com/file/d/1Nh37rcwwcZdFoSKF_JogwfVSnPdlzvX_/view?usp=drivesdk

## Verification (2026-10-07)
- `gltfpack -v` → `gltfpack 1.3`; `-h` prints full help
- Real tests on repo's `demo/pirate.obj` (369 KB): OBJ→GLB (65.8 KB), GLB→GLB with `-cc` (24.7 KB); outputs byte-validated as glTF 2.0 (magic + JSON chunk parse + `gltfpack 1.3` generator stamp)
- Packaged AppImage verified via `--appimage-extract` + AppRun (no FUSE in build container; mounts normally on Bazzite)

## Caveats
- Texture compression flags (`-tc`/`-tu`) are NOT functional in this build — they need the BasisU encoder linked at compile time; left out to keep the AppImage tiny and dependency-free. All mesh-side features work.
