#!/bin/bash
# build.sh — TetWild AppImage from source (Ubuntu 24.04 x86-64)
set -e
WORK=~/workspace/build/appimage-campaign
SRC=$WORK/tetwild/src
BUILD=$WORK/tetwild/build
AD=$WORK/github-staging/tetwild/appdir

# 1. Dependencies
# sudo apt-get install -y libboost-dev libgmp-dev libmpfr-dev libtbb-dev

# 2. Fetch source
# git clone --depth 1 https://github.com/Yixin-Hu/TetWild "$SRC"

# 3. CGAL 4.12 dance (see NOTES.md — the pinned DownloadProject clone stalls
#    and system CGAL 5.6 is API-incompatible):
#    a. shallow-fetch releases/CGAL-4.12 into $SRC/extern/libigl/external/cgal
#    b. touch the ExternalProject download stamps to skip re-download
#    c. cmake + make CGAL 4.12 (targets CGAL, CGAL_Core)
#    d. redirect $SRC/extern/libigl/external/cgal/CGALConfig.cmake to the build tree
#    e. hide /usr/include/CGAL during compile

# 4. Configure + build
# cmake -S "$SRC" -B "$BUILD" -DCMAKE_BUILD_TYPE=Release \
#   -DTETWILD_WITH_HUNTER=OFF -DTETWILD_WITH_ISPC=OFF \
#   -DCMAKE_PROJECT_INCLUDE=$WORK/tetwild/preload.cmake   # find_package(Boost ... thread system)
# cmake --build "$BUILD" -j$(nproc)

# 5. Pack (binary: $BUILD/TetWild; bundle libCGAL*, libgeogram from the build trees)
# "$WORK/pack.sh" TetWild "$BUILD/TetWild" /tmp/cgal412-build/lib "$BUILD/lib"
echo "See NOTES.md for the full procedure."
