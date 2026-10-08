# thekla_atlas — build notes

- **Upstream repo:** https://github.com/Thekla/thekla_atlas
- **Git commit built:** `e6f034837ca3936c9817958746e9f46f8dd22a75` (master, 2026-10-08)
- **License:** MIT — confirmed from the repo's `LICENSE` file
  (Copyright (c) 2013 Thekla, Inc).
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged

The `thekla_atlas_test` atlas CLI (the only executable target the upstream
CMakeLists builds), compiled from source with cmake Release. Installed in the
AppImage as `thekla-atlas`. Takes an OBJ, computes a texture atlas, prints
chart/stretch metrics, and writes `debug_packer_final.tga`.

Usage: `./Thekla-Atlas-x86_64.AppImage input_file.obj`
