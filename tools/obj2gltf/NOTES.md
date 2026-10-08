# obj2gltf — build notes

- **Upstream repo:** https://github.com/CesiumGS/obj2gltf
- **Git commit built:** `979a24a770154e8e9b964a554f86436dc4cafafa` (2026-10-08)
- **License:** Apache-2.0 — confirmed from the repo's `LICENSE` file
  ("Apache License, Version 2.0, January 2004"). Copyright 2016-2020 Cesium GS, Inc.
- **CUDA toolkit version:** n/a — CPU/Node.js build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The obj2gltf npm CLI (pure JavaScript, no native build step) bundled with the
Node.js v24.20.0 runtime binary (runtime, like a compiler — the tool itself is
built from source via `npm install` + `npm prune --omit=dev` on the cloned
repo). Converts OBJ (+MTL, textures) to glTF or GLB.

Usage: `obj2gltf -i model.obj -o model.glb`
