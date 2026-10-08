# TetWild — build notes

- **Upstream repo:** https://github.com/Yixin-Hu/TetWild
- **Git commit built:** `49de8cd` (master, shallow clone 2026-10-08)
- **License:** GPL-3.0 — confirmed from the repo's `LICENSE.GPL` file
  (dual-licensed GPL-3.0 / MPL-2.0; GPL-3.0 terms used)
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
TetWild robust tetrahedral meshing CLI (`TetWild` binary). Deps (geogram,
libigl, fmt, spdlog, CLI11, pymesh) built from source via the project's
DownloadProject mechanism; CGAL 4.12 built from source (see quirks); system
Boost/GMP/MPFR used. Bundled shared libs: `libCGAL.so.13`,
`libCGAL_Core.so.13`, `libgeogram.so.1`, plus gmp/mpfr/boost_thread via ldd.
AppRun is a direct passthrough.

Usage: `TetWild-x86_64.AppImage input.obj output.msh [options]`

## Build quirks (for reproducibility)
1. TetWild pins CGAL 4.12 via libigl's DownloadProject, but the full git
   clone stalls. Fix used: shallow-fetch the `releases/CGAL-4.12` tag into
   `src/extern/libigl/external/cgal`, create the ExternalProject download
   stamps, configure CGAL 4.12 (`cmake -DCMAKE_INSTALL_PREFIX=...`), build
   its `CGAL`/`CGAL_Core` targets, and redirect the source-root
   `CGALConfig.cmake` stub to the configured build tree.
2. System CGAL (5.6, `/usr/include/CGAL`) headers shadow the 4.12 ones and
   break the build (Lazy_exact_nt API mismatch) — hide `/usr/include/CGAL`
   during the TetWild compile, restore afterwards.
3. libigl's CGAL config wants `Boost::thread` — pre-seed with a
   `CMAKE_PROJECT_INCLUDE` file containing
   `find_package(Boost QUIET COMPONENTS thread system)`.
4. Needs: `apt install libboost-dev libgmp-dev libmpfr-dev libtbb-dev`.

## Verification
- `--help` prints usage; functional test meshed a tetrahedron OBJ →
  541 vertices, valid `.msh` output, via the AppImage itself
  (`APPIMAGE_EXTRACT_AND_RUN=1`).
