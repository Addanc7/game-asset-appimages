#!/bin/bash
# OpenCOLLADA AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/opencollada"

# 1. Clone (MIT, verified in per-module COPYING files)
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/KhronosGroup/OpenCOLLADA repo
cd repo && git checkout 6031fa956e1da4bbdd910af3a8f9e924ef0fca7a && cd ..

# 2. Dependencies + configure + build
sudo apt-get install -y libpcre3-dev
cmake -B build -S repo -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_FLAGS="-Wno-error=dangling-reference"
cmake --build build -j"$(nproc)" --target DAEValidatorExecutable OpenCOLLADAValidator
# -> build/bin/DAEValidator, build/bin/OpenCOLLADAValidator

# 3. Stage the AppDir and package (exact staging + dispatcher AppRun in
#    $T/mkappdir.sh, which also runs appimagetool; appimagetool extracted
#    root expected at $WORK/appimagetool-root)
"$T/mkappdir.sh"
# -> $WORK/OpenCOLLADA-x86_64.AppImage
