# MeshFix — build notes

- **Upstream repo:** https://github.com/MarcoAttene/MeshFix-V2.1
- **Git commit built:** `ac8c0c990555f26cdad31bf712286b85b20af384` (master, 2026-10-07)
- **License:** GPL-3.0 — confirmed from the repo's `gpl-3.0.txt`
  (GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007). Upstream notes the
  code is dual-licensed; the GPL-3.0 terms are the ones used here.
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `MeshFix` mesh-repair CLI: loads a triangle mesh (OFF, PLY, STL; other
formats partially), removes degeneracies and self-intersections, fills holes,
and writes the repaired mesh.

Usage: `MeshFix inmesh.off [outmesh.off] [-a] [-j] [-x]`
(`-a` join components, `-j` STL output, `-x` skip if output exists)

Quirk: with no arguments the program prints usage and then waits on stdin
("HIT ENTER TO EXIT"); flags must come before the output filename
(`MeshFix in.off -j`, not `MeshFix in.off out.off -j`) — upstream arg parsing.
