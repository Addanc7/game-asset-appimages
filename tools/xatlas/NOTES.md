# xatlas — build notes

- **Upstream repo:** https://github.com/jpcy/xatlas
- **Git commit built:** `f700c7790aaa030e794b52ba7791a05c085faf0c` (master, 2026-10-08)
- **License:** MIT — confirmed from the repo's `LICENSE` file
  (Copyright (c) 2018-2020 Jonathan Young).
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged

The upstream `example` example CLI (`source/examples/example.cpp`), compiled
from source with g++ (C++11, -O2) together with `source/xatlas/xatlas.cpp`,
`source/thirdparty/tiny_obj_loader.cpp`, and
`source/thirdparty/stb_image_write.c` (the same translation units the upstream
premake5 project lists for the `example` target). Installed in the AppImage as
`xatlas`. Reads an `.obj`, computes a texture-coordinate atlas, and writes
`example_output.obj` plus `example_charts00.tga` / `example_tris00.tga`.

Usage: `./Xatlas-x86_64.AppImage input_file.obj [-verbose]`
