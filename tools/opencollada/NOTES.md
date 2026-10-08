# OpenCOLLADA — build notes

- **Upstream repo:** https://github.com/KhronosGroup/OpenCOLLADA
- **Git commit built:** `6031fa956e1da4bbdd910af3a8f9e924ef0fca7a` (master, 2026-10-08)
- **License:** MIT — confirmed from the per-module `COPYING`/`LICENSE` files
  (e.g. `COLLADAStreamWriter/COPYING`, "Copyright (c) 2008 NetAllied Systems
  GmbH … Permission is hereby granted, free of charge…")
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The two converter/validator CLIs produced by the cmake build, behind a
dispatcher AppRun:
- `DAEValidator` — validates COLLADA documents against the schema plus
  coherency tests (`--check-links`, `--check-unique-ids`, …)
- `OpenCOLLADAValidator` — validates COLLADA documents against the schema

Usage: `./OpenCOLLADA-x86_64.AppImage [dae|collada] <file.dae> [options...]`
(no selector defaults to DAEValidator). The legacy SCons-only tools
(dae23ds, dae2ma, dae2ogre) are not part of the cmake build and were not packaged.

## Build quirks
- Needs `libpcre3-dev` installed (`sudo apt-get install -y libpcre3-dev`).
- Modern GCC's `-Werror=dangling-reference` breaks `DAEValidator/library` —
  configured with `-DCMAKE_CXX_FLAGS="-Wno-error=dangling-reference"`.
