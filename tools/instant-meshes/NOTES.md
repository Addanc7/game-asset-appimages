# Instant Meshes — build notes

- **Upstream repo:** https://github.com/wjakob/instant-meshes
- **Git commit built:** `7b3160864a2e1025af498c84cfed91cbfb613698` (master, 2026-10-07; upstream dormant since ~2017, still compiles)
- **License:** BSD-3-Clause — confirmed from the repo's `LICENSE.txt`
  (Copyright (c) 2015 Wenzel Jakob, Daniele Panozzo, Marco Tarini, and Olga
  Sorkine-Hornung; "Redistribution and use in source and binary forms, with or
  without modification, are permitted …").
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
Instant Meshes field-aligned quad/tri remesher. The AppImage is named
`Instant-Meshes-x86_64.AppImage` (hyphenated to avoid clashing with the
Tencent InstantMesh AI tool). The AppRun passes args straight through; batch
mode (`InstantMeshes input.obj -o output.obj [options]`) works headless and
is the supported path. X11/GL runtime libs are bundled in `usr/lib`.

Usage: `./Instant-Meshes-x86_64.AppImage input.obj -o output.obj -f 200`
