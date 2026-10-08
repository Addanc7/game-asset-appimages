# FBX2glTF — build notes

- **Upstream repo:** https://github.com/weg901127/fbx2.1glb (ufbx-based,
  SDK-free fork of https://github.com/facebookincubator/FBX2glTF)
- **Git commit built:** `7ad4dc811bf4bc95a8777990a6d0d0909a3ab220` (2026-10-08)
- **License:** BSD-3-Clause — confirmed from the repo's `LICENSE` file
  ("BSD License — For FBX2glTF software", Copyright (c) 2020-2022 V-Sekai
  contributors, Copyright (c) Facebook, Inc. and its affiliates)
- **CUDA toolkit version:** n/a — CPU/C++ build
- **VRAM expectations:** n/a
- **First-run weight download:** none — no weights

## What is packaged
The `fbx2glb` CLI (identifies as "FBX2glTF 0.14.0-ufbx"), built from source
with cmake. Uses the vendored ufbx single-file FBX parser — no proprietary
Autodesk FBX SDK needed (that's why the fork was chosen over upstream
facebookincubator/FBX2glTF). Draco mesh-compression support compiled in.

Usage: `fbx2glb -i model.fbx -o output` (writes `output_out/output.gltf`;
add `-b` for binary `.glb`)

## Build quirks
- Draco is fetched via FetchContent; its eigen submodule clone from
  gitlab.com failed, so eigen/filesystem/tinygltf were cloned from GitHub
  mirrors into `thirdparty/` and passed as `-DFETCHCONTENT_SOURCE_DIR_DRACO`,
  `-DDRACO_EIGEN_PATH`, `-DDRACO_FILESYSTEM_PATH`, `-DDRACO_TINYGLTF_PATH`
  (draco 1.5.7).
