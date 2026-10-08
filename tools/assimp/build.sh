#!/bin/bash
# assimp CLI AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/assimp"

# 1. Clone and build (BSD-3-Clause, verified in LICENSE)
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/assimp/assimp repo
cd repo && git checkout 1b19e045eb868b33f81b148f9bbbbbffbd47ae4e && cd ..
cmake -B build -S repo -DCMAKE_BUILD_TYPE=Release \
  -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_SAMPLES=OFF \
  -DASSIMP_BUILD_ASSIMP_VIEW=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=ON
cmake --build build -j"$(nproc)"
# -> build/bin/assimp

# 2. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Assimp assimp/build/bin/assimp
# -> $WORK/Assimp-x86_64.AppImage
