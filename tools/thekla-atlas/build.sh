#!/bin/bash
# thekla_atlas AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Clone and build
mkdir -p "$WORK/thekla-atlas" && cd "$WORK/thekla-atlas"
[ -d repo ] || git clone https://github.com/Thekla/thekla_atlas repo
cd repo && git checkout e6f034837ca3936c9817958746e9f46f8dd22a75 && cd ..
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"

# 2. Stage the binary (installed as `thekla-atlas` inside the AppImage)
cp build/thekla_atlas_test thekla-atlas

# 3. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Thekla-Atlas thekla-atlas/thekla-atlas
# -> $WORK/Thekla-Atlas-x86_64.AppImage
