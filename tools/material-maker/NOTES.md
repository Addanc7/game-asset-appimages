# Material Maker — build notes

- **Upstream repo:** https://github.com/RodZill4/material-maker
- **Git commit built:** `174f15edece663bf10f78588840873fa2fd17bc7` (master, 2026-10-08)
- **License:** MIT — confirmed from the repo's `LICENSE.md`
  (Copyright (c) 2018-present Rodolphe Suescun and contributors).
- **CUDA toolkit version:** n/a — Godot GDScript project, no CUDA
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged

Material Maker is a Godot (GDScript) project; the standard "build" is an
editor export. The export was produced from the project's own source with the
official Godot 4.7.2 editor binary (the compiler in this workflow, per the
campaign's documented exception) and the 4.7.2 export templates, using the
project's own `Linux/X11` export preset (`binary_format/embed_pck=true`, so
the binary is self-contained). The AppImage carries the exported binary as
`material-maker` plus the upstream `icon.png` and a GUI `.desktop` entry.

Usage: `./Material-Maker-x86_64.AppImage`
