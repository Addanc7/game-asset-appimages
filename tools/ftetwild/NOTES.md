# fTetWild — build notes

- **Upstream repo:** https://github.com/wildmeshing/fTetWild
- **Git commit built:** `8118f81` (master, shallow clone 2026-10-08)
- **License:** MPL-2.0 — confirmed from the repo's `LICENSE.MPL2` file
- **CUDA toolkit version:** n/a — CPU/C++ build (TBB enabled)
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
fTetWild fast tetrahedral meshing CLI (`FloatTetwild_bin`, shipped as
`FloatTetwild` in the AppImage). Deps (CLI11, fmt, spdlog, libigl,
geogram, nlohmann/json, Catch2) built from source via FetchContent;
system GMP + TBB used. AppRun is a direct passthrough.

Usage: `fTetWild-x86_64.AppImage -i input.obj -o output.msh [options]`

## Build quirks (for reproducibility)
1. Needs system GMP and TBB: `apt install libgmp-dev libtbb-dev`.
2. libigl's FetchContent of Eigen from gitlab.com stalls — pre-seed with
   `-DFETCHCONTENT_SOURCE_DIR_EIGEN=/usr/include/eigen3` (needs
   `libeigen3-dev`).
3. `make -j1` recommended on low-RAM machines (parallel geogram TUs can OOM).

## Verification
- `--help` prints the CLI usage.
- Functional test: 4-vertex tetrahedron OBJ → 3,408 vertices / 15,923 tets
  in 0.04 s (`--level 3`); also verified through the AppImage itself
  (`APPIMAGE_EXTRACT_AND_RUN=1`).
