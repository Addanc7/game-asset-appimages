# assimp — build notes

- **Upstream repo:** https://github.com/assimp/assimp
- **Git commit built:** `1b19e045eb868b33f81b148f9bbbbbffbd47ae4e` (master, 2026-10-08)
- **License:** BSD-3-Clause — confirmed from the repo's `LICENSE` file
  ("Open Asset Import Library (assimp)", Copyright (c) 2006-2026, assimp team,
  "Redistribution and use of this software in source and binary forms...")
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `assimp` command-line tool (`assimp export model.fbx model.glb`,
`assimp info`, …), built from source with cmake. The CLI needs
`-DASSIMP_BUILD_ASSIMP_TOOLS=ON` (it defaults to OFF upstream).

Usage: `assimp export input.obj output.glb`
