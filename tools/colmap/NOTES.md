# COLMAP — build notes

- **Upstream repo:** https://github.com/colmap/colmap
- **Git commit built:** `c6ab4f8` (master, shallow clone 2026-10-08)
- **License:** BSD-3-Clause ("new BSD license") — confirmed from the repo's
  `LICENSE` file ("The COLMAP library is licensed under the new BSD
  license…")
- **CUDA toolkit version:** none — CPU-only build (`-DCUDA_ENABLED=OFF`;
  banner reports "without GPU support")
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
COLMAP 4.3.0.dev0 SfM/MVS CLI (headless: `-DGUI_ENABLED=OFF`,
`-DCGAL_ENABLED=OFF`, `-DONNX_ENABLED=OFF`). The 41 MB `colmap` binary
plus ~85 MB of shared libs bundled via ldd (Ceres, SuiteSparse/CHOLMOD,
OpenImageIO, Metis, SQLite3, Boost 1.92 (built from source by COLMAP's
cmake), OpenCV, glog/gflags, BLAS/LAPACK). 126 MB AppImage. AppRun is a
direct passthrough: `COLMAP-x86_64.AppImage <command> [options]`.

## Build quirks (for reproducibility)
1. Needs many dev packages: `libceres-dev libgoogle-glog-dev
   libgflags-dev libfreeimage-dev libsuitesparse-dev libopenimageio-dev
   libsqlite3-dev libmetis-dev libglew-dev libgl1-mesa-dev libopencv-dev
   openimageio-tools`.
2. OpenImageIO's cmake config requires `/usr/bin/iconvert`
   (`openimageio-tools`) and `/usr/include/opencv4` (`libopencv-dev`).
3. COLMAP downloads and builds its own Boost 1.92 at configure time.
4. On 2-core/7GB machines use `-j1` (parallel build OOM-killed).

## Verification
- Banner: `COLMAP 4.3.0.dev0 (Commit c6ab4f8 on 2026-10-08 without GPU
  support)`; `--help` lists commands.
- Functional: `database_creator --database_path test.db` created a valid
  86 KB SQLite database via the AppImage (APPIMAGE_EXTRACT_AND_RUN=1).
