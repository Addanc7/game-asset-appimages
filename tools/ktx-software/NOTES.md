# KTX-Software (toktx) — build notes

- **Upstream repo:** https://github.com/KhronosGroup/KTX-Software
- **Git commit built:** `4f2d7bc7e26d92b0f0e61a7381b92e48a4485a5d` (master, 2026-10-08)
- **License:** Apache-2.0 — confirmed from the repo's `LICENSE.md`
  ("SPDX-License-Identifier: Apache-2.0", "Files unique to this repository
  generally fall under the Apache 2.0 license") and `LICENSES/Apache-2.0.txt`
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The unified `ktx` CLI (v5.0), built from source with cmake
(`-DKTX_FEATURE_TESTS=OFF -DKTX_FEATURE_TOOLS=ON`, target `ktxtools`).
In KTX-Software v5 the standalone `toktx` was merged into `ktx create`
(`ktx create --format R8G8B8A8_SRGB in.png out.ktx2`); a `toktx` symlink is
included in the AppImage pointing at `ktx` for familiarity. Also includes
`ktx convert`, `ktx info`, `ktx validate`, etc.

Usage: `ktx create --format R8G8B8A8_SRGB in.png out.ktx2`
