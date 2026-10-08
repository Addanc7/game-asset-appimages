#!/bin/bash
# FBX2glTF AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/fbx2gltf"

# 1. Clone (BSD-3-Clause, verified in LICENSE; ufbx-based, no FBX SDK)
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/weg901127/fbx2.1glb repo
cd repo && git checkout 7ad4dc811bf4bc95a8777990a6d0d0909a3ab220 && cd ..

# 2. Draco (fetched via FetchContent) needs eigen/filesystem/tinygltf.
#    The gitlab eigen clone is unreliable, so vendor from GitHub mirrors:
mkdir -p thirdparty && cd thirdparty
[ -d draco ] || git clone --depth 1 --branch 1.5.7 https://github.com/google/draco draco
[ -d eigen ] || git clone --depth 1 https://github.com/eigenteam/eigen-git-mirror eigen
[ -d filesystem ] || git clone --depth 1 https://github.com/gulrak/filesystem filesystem
[ -d tinygltf ] || git clone --depth 1 https://github.com/syoyo/tinygltf tinygltf
cd ..

# 3. Configure + build
cmake -B build -S repo -DCMAKE_BUILD_TYPE=Release \
  -DFETCHCONTENT_SOURCE_DIR_DRACO="$T/thirdparty/draco" \
  -DDRACO_EIGEN_PATH="$T/thirdparty/eigen" \
  -DDRACO_FILESYSTEM_PATH="$T/thirdparty/filesystem" \
  -DDRACO_TINYGLTF_PATH="$T/thirdparty/tinygltf"
cmake --build build -j"$(nproc)"
# -> build/fbx2glb

# 4. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh FBX2glTF fbx2gltf/build/fbx2glb
# -> $WORK/FBX2glTF-x86_64.AppImage
