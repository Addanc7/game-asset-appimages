#!/bin/bash
# KTX-Software (toktx) AppImage build script — reproducible from a clean checkout.
# Tested on the campaign build VM (x86-64), cmake 3.28, g++ 13.
set -e
WORK="${WORK:-$HOME/workspace/build/appimage-campaign}"
T="$WORK/ktx-software"

# 1. Clone and build (Apache-2.0, verified in LICENSE.md)
mkdir -p "$T" && cd "$T"
[ -d repo ] || git clone https://github.com/KhronosGroup/KTX-Software repo
cd repo && git checkout 4f2d7bc7e26d92b0f0e61a7381b92e48a4485a5d && cd ..
cmake -B build -S repo -DCMAKE_BUILD_TYPE=Release \
  -DKTX_FEATURE_TESTS=OFF -DKTX_FEATURE_TOOLS=ON
cmake --build build -j"$(nproc)" --target ktxtools
# -> build/Release/ktx  (unified CLI; `ktx create` is the toktx successor)

# 2. Package (pack.sh lives at the campaign root; appimagetool extracted root
#    is expected at $WORK/appimagetool-root — see pack.sh)
cd "$WORK"
./pack.sh Toktx ktx-software/build/Release/ktx
# add a toktx symlink for familiarity, then repack
ln -sf ktx Toktx.AppDir/usr/bin/toktx
ARCH=x86_64 "$WORK/appimagetool-root/AppRun" Toktx.AppDir Toktx-x86_64.AppImage
# -> $WORK/Toktx-x86_64.AppImage
