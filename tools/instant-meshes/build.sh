#!/bin/bash
# Instant Meshes AppImage build script — reproducible from a clean checkout.
# Tested on Ubuntu 24.04 (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"

# 1. Deps: X11/GL dev packages for the bundled nanogui + GLFW stack
sudo apt-get install -y libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev \
  libgl-dev libxxf86vm-dev

# 2. Clone with submodules (nanogui, glfw, tbb, eigen, …)
mkdir -p "$WORK/instant-meshes" && cd "$WORK/instant-meshes"
if [ ! -d repo ]; then
  git clone --recursive https://github.com/wjakob/instant-meshes repo
fi
cd repo && git checkout 7b3160864a2e1025af498c84cfed91cbfb613698 \
  && git submodule update --init --recursive && cd ..

# 3. Configure & build.
#    -Wno-changes-meaning: the bundled TBB trips GCC 13's -Wchanges-meaning
#    (an error by default); the flag downgrades it.
cmake -S repo -B build -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-Wno-changes-meaning -Wno-error=changes-meaning"
cmake --build build -j"$(nproc)"
# binary: build/"Instant Meshes"
cp build/"Instant Meshes" InstantMeshes

# 4. Package
cd "$WORK"
./pack.sh Instant-Meshes instant-meshes/InstantMeshes
# -> $WORK/Instant-Meshes-x86_64.AppImage
