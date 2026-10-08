#!/bin/bash
# Build gltfpack from source and package as an AppImage.
# Tested on: Ubuntu container (g++ 13.3.0, cmake 3.28.3). Target: Bazzite/Fedora x86-64.
set -euo pipefail

UPSTREAM_COMMIT="4195af679a7e4a968b4a23874272f152600c9f72"
WORKDIR="$(pwd)"
APPIMAGETOOL="${APPIMAGETOOL:-$HOME/workspace/build/trellis-appimage/appimagetool.AppImage}"

echo "==> Cloning meshoptimizer @ ${UPSTREAM_COMMIT}"
if [ ! -d meshoptimizer ]; then
  git clone --depth 1 https://github.com/zeux/meshoptimizer.git
fi
cd meshoptimizer
git fetch --depth 1 origin "${UPSTREAM_COMMIT}" || true
git checkout "${UPSTREAM_COMMIT}"

echo "==> Building gltfpack (Release)"
cmake -S . -B build -DMESHOPT_BUILD_GLTFPACK=ON -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -static-libgcc"
cmake --build build -j"$(nproc)"
./build/gltfpack -v   # expect: gltfpack 1.3

echo "==> Assembling AppDir"
cd "${WORKDIR}"
rm -rf AppDir
mkdir -p AppDir/usr/bin
cp meshoptimizer/build/gltfpack AppDir/usr/bin/
cp "$(dirname "$0")/AppRun" AppDir/AppRun
cp "$(dirname "$0")/gltfpack.desktop" AppDir/
chmod +x AppDir/AppRun AppDir/usr/bin/gltfpack
# Optional icon: drop a gltfpack.png next to the .desktop if you have one.

echo "==> Packaging AppImage"
"${APPIMAGETOOL}" AppDir gltfpack-x86_64.AppImage

echo "==> Done: ${WORKDIR}/gltfpack-x86_64.AppImage"
./gltfpack-x86_64.AppImage --appimage-extract >/dev/null
./squashfs-root/AppRun -v
rm -rf squashfs-root
