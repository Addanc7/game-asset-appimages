#!/bin/bash
# build.sh — fTetWild AppImage from source (Ubuntu 24.04 x86-64)
set -e
WORK=~/workspace/build/appimage-campaign
SRC=$WORK/ftetwild/src
BUILD=$WORK/ftetwild/build
AD=$WORK/github-staging/ftetwild/appdir

# 1. Dependencies
# sudo apt-get install -y libgmp-dev libtbb-dev libeigen3-dev

# 2. Fetch source
# git clone --depth 1 https://github.com/wildmeshing/fTetWild "$SRC"

# 3. Configure + build (Eigen pre-seed avoids a stalled gitlab fetch)
# cmake -S "$SRC" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
#   -DFETCHCONTENT_SOURCE_DIR_EIGEN=/usr/include/eigen3
# cmake --build "$BUILD" -j$(nproc)

# 4. Pack (binary: $BUILD/FloatTetwild_bin; see ../pack.sh for the AppDir recipe)
# "$WORK/pack.sh" fTetWild "$BUILD/FloatTetwild_bin"
echo "See NOTES.md for the full procedure."
