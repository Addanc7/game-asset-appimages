# QuadriFlow — build notes

- **Upstream repo:** https://github.com/hjwdzh/QuadriFlow
- **Git commit built:** `810b7a0967c35b0dc85b4464e3835e26a756c967` (master, 2026-10-07)
- **License:** BSD-3-Clause — confirmed from the repo's `LICENSE.txt`
  (Copyright (c) 2018 Jingwei Huang, Yichao Zhou, Matthias Niessner,
  Jonathan Shewchuk and Leonidas Guibas; "Redistribution and use in source
  and binary forms, with or without modification, are permitted …").
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `quadriflow` quad-meshing CLI (field-aligned quadrangulation in the
Instant Meshes family): reads a triangle mesh, outputs an all-quad mesh.

Usage: `quadriflow -i input.obj -o output.obj -f 1200`
(`-f` = target face count; with no arguments the program asserts on the
missing input — expected, input is required.)
