#!/bin/bash
# build.sh — COLMAP AppImage from source (Ubuntu 24.04 x86-64, CPU-only, headless)
set -e
WORK=~/workspace/build/appimage-campaign
SRC=$WORK/colmap/src
BUILD=$WORK/colmap/build
AD=$WORK/github-staging/colmap/appdir

# 1. Dependencies
# sudo apt-get install -y libceres-dev libgoogle-glog-dev libgflags-dev \
#   libfreeimage-dev libsuitesparse-dev libopenimageio-dev libsqlite3-dev \
#   libmetis-dev libglew-dev libgl1-mesa-dev libopencv-dev openimageio-tools

# 2. Fetch source
# git clone --depth 1 https://github.com/colmap/colmap "$SRC"

# 3. Configure + build (Boost is auto-downloaded by COLMAP's cmake; use -j1 on small VMs)
# cmake -S "$SRC" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
#   -DGUI_ENABLED=OFF -DCUDA_ENABLED=OFF -DTESTS_ENABLED=OFF \
#   -DCGAL_ENABLED=OFF -DONNX_ENABLED=OFF
# cmake --build "$BUILD" -j1

# 4. Pack (binary: $BUILD/src/colmap/exe/colmap)
# "$WORK/pack.sh" COLMAP "$BUILD/src/colmap/exe/colmap"
echo "See NOTES.md for the full procedure."
