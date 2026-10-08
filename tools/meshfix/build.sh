#!/bin/bash
# MeshFix AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13. No extra deps.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

mkdir -p "$WORK/meshfix" && cd "$WORK/meshfix"
[ -d repo ] || git clone https://github.com/MarcoAttene/MeshFix-V2.1 repo
cd repo && git checkout ac8c0c990555f26cdad31bf712286b85b20af384 && cd ..
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"
# binary lands at repo/bin64/MeshFix

cd "$WORK"
./pack.sh MeshFix meshfix/repo/bin64/MeshFix
# -> $WORK/MeshFix-x86_64.AppImage
