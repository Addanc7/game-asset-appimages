#!/bin/bash
# QuadriFlow AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Deps (LEMON is bundled in the repo under 3rd/lemon-1.3.1)
sudo apt-get install -y libeigen3-dev libboost-dev

# 2. Clone and build
mkdir -p "$WORK/quadriflow" && cd "$WORK/quadriflow"
[ -d repo ] || git clone https://github.com/hjwdzh/QuadriFlow repo
cd repo && git checkout 810b7a0967c35b0dc85b4464e3835e26a756c967 && cd ..
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$(nproc)"
# binary: build/quadriflow

# 3. Package
cd "$WORK"
./pack.sh QuadriFlow quadriflow/build/quadriflow
# -> $WORK/QuadriFlow-x86_64.AppImage
