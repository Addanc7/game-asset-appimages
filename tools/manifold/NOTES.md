# Manifold — build notes

- **Upstream repo:** https://github.com/elalish/manifold
- **Git commit built:** `b92f06be117765cc16b47451fcfa3e8145cea984` (master, 2026-10-07)
- **License:** Apache-2.0 — confirmed from the repo's `LICENSE` file
  ("Apache License, Version 2.0, January 2004").
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `convertFile` sample CLI (built with `-DASSIMP_ENABLE=ON`), installed in
the AppImage as `manifold`. Imports any mesh format assimp reads (OBJ, STL,
PLY, GLB, …), reports whether it is manifold, attempts an automatic
boolean-merge repair when it is not, and writes the result in the format
implied by the output filename.

Usage: `manifold input.obj output.stl`
