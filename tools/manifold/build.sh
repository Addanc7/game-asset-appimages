#!/bin/bash
# Manifold AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Build dependency for the convertFile CLI (assimp-based meshIO)
sudo apt-get install -y libassimp-dev

# 2. Clone and build
mkdir -p "$WORK/manifold" && cd "$WORK/manifold"
[ -d repo ] || git clone https://github.com/elalish/manifold repo
cd repo && git checkout b92f06be117765cc16b47451fcfa3e8145cea984 && cd ..
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release \
  -DMANIFOLD_TEST=ON -DASSIMP_ENABLE=ON -DMANIFOLD_CBIND=OFF
cmake --build build --target convertFile manifold -j"$(nproc)"

# 3. Stage the binary (installed as `manifold` inside the AppImage)
cp build/extras/convertFile manifold-bin

# 4. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Manifold manifold/manifold-bin
# -> $WORK/Manifold-x86_64.AppImage
