#!/bin/bash
# Build TRELLIS.2-GGUF from source and package as an AppImage.
# NOTE: trellis2-gguf and pixal3d-gguf share ONE source build
# (raven38/pixal3d.cpp -> trellis-cli serves both backbones). Running this
# script compiles the shared binaries, then packages only the TRELLIS.2
# AppImage. Run ../pixal3d-gguf/build.sh afterwards and the compile step is
# incremental (no rebuild).
# Target: x86-64 Linux with NVIDIA GPU (built for sm_89 / RTX 4060).
# Tested in: Ubuntu 24.04 container, CUDA toolkit 13.3.73, gcc 13.3, cmake 3.28.
set -euo pipefail

PIXAL3D_COMMIT="d1b4926452f9e09702b891db5f05acc845e153ed"
GGML_COMMIT="737e88f25d4f62254f3b7a726fd9663036cc94da"
WORKDIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# Path to a CUDA toolkit with nvcc (13.x). If your distro ships one, just
# ensure nvcc is on PATH and skip any manual toolkit assembly.
CUDA_HOME="${CUDA_HOME:-/usr/local/cuda-13.3}"
APPIMAGETOOL="${APPIMAGETOOL:-$HOME/workspace/build/trellis-appimage/appimagetool.AppImage}"

echo "==> Cloning pixal3d.cpp @ ${PIXAL3D_COMMIT}"
if [ ! -d pixal3d.cpp ]; then
  git clone https://github.com/raven38/pixal3d.cpp.git
fi
cd pixal3d.cpp
git fetch --depth 1 origin "${PIXAL3D_COMMIT}" || true
git checkout "${PIXAL3D_COMMIT}"
git submodule update --init --depth 1
git -C thirdparty/ggml fetch --depth 1 origin "${GGML_COMMIT}" || true
git -C thirdparty/ggml checkout "${GGML_COMMIT}"

echo "==> Applying build patch: skip fattn-tile/mma template instances"
# The 33 fattn-tile + fattn-mma template instances are flash-attention *speed*
# optimizations. The 4 fattn-vec kernels (f16/q4_0/q8_0/bf16) provide full
# functional fallback for every head dimension, so skipping tile/mma only
# costs some attention speed — it roughly halves CUDA compile time on small
# build machines. All 21 mmq + 16 mmf instances (quantized matmul, the core
# of GGUF inference) are kept. Revert this for a max-performance build.
if ! grep -q 'BUILD PATCH: fattn-tile instances skipped' \
    thirdparty/ggml/src/ggml-cuda/CMakeLists.txt; then
  python3 - <<'EOF'
p = "thirdparty/ggml/src/ggml-cuda/CMakeLists.txt"
s = open(p).read()
s = s.replace('    file(GLOB   SRCS "template-instances/fattn-tile*.cu")',
              '    # BUILD PATCH: fattn-tile instances skipped (see build.sh)\n    # file(GLOB   SRCS "template-instances/fattn-tile*.cu")')
s = s.replace('    file(GLOB   SRCS "template-instances/fattn-mma*.cu")',
              '    # BUILD PATCH: fattn-mma instances skipped (see build.sh)\n    # file(GLOB   SRCS "template-instances/fattn-mma*.cu")')
open(p, "w").write(s)
EOF
fi
grep -c 'BUILD PATCH: fattn-' thirdparty/ggml/src/ggml-cuda/CMakeLists.txt

echo "==> Configuring (CUDA sm_89 only — RTX 4060; add arches as needed)"
export PATH="${CUDA_HOME}/bin:${PATH}"
# nvcc spills large temp files; /tmp is often a small tmpfs — redirect it.
export TMPDIR="${TMPDIR:-$WORKDIR/tmp-nvcc}"
mkdir -p "$TMPDIR"
cmake -S . -B build-cuda \
  -DGGML_CUDA=ON \
  -DCMAKE_CUDA_ARCHITECTURES="89" \
  -DCMAKE_BUILD_TYPE=Release

echo "==> Building trellis-cli + trellis-server (takes a while: ~60 CUDA TUs)"
cmake --build build-cuda --target trellis-cli trellis-server -j2
./build-cuda/trellis-cli --help | head -5  # must run without a GPU

echo "==> Assembling AppDir-trellis2"
cd "${WORKDIR}"
AD="AppDir-trellis2"
rm -rf "$AD"
mkdir -p "$AD/usr/bin" "$AD/usr/lib" "$AD/usr/share/trellis2-gguf"
cp pixal3d.cpp/build-cuda/trellis-cli pixal3d.cpp/build-cuda/trellis-server "$AD/usr/bin/"
cp pixal3d.cpp/build-cuda/libggml*.so* "$AD/usr/lib/" 2>/dev/null || true
# CUDA runtime libs so the target needs only the NVIDIA driver (no toolkit)
for lib in libcudart.so* libcublas.so* libcublasLt.so*; do
  cp -P "${CUDA_HOME}/lib64/${lib}" "$AD/usr/lib/" 2>/dev/null || true
done
cp "$SCRIPT_DIR/ensure_weights.sh" "$AD/usr/share/trellis2-gguf/"
cp "$SCRIPT_DIR/AppRun" "$AD/AppRun"
cp "$SCRIPT_DIR/trellis2-gguf.desktop" "$AD/"
cp "$SCRIPT_DIR/trellis2-gguf.png" "$AD/" 2>/dev/null || true
chmod +x "$AD/AppRun" "$AD/usr/bin/trellis-cli" "$AD/usr/bin/trellis-server"
echo "--- ldd trellis-cli ---"
LD_LIBRARY_PATH="$AD/usr/lib" ldd "$AD/usr/bin/trellis-cli" | grep -E "not found" \
  && { echo "MISSING LIBS in $AD"; exit 1; } || echo "all libs resolved"

echo "==> Packaging TRELLIS2-GGUF-x86_64.AppImage"
rm -f TRELLIS2-GGUF-x86_64.AppImage
"${APPIMAGETOOL}" "$AD" --comp xz -o TRELLIS2-GGUF-x86_64.AppImage
ls -lh TRELLIS2-GGUF-x86_64.AppImage

echo "==> Smoke test (no GPU/weights needed for --help)"
./TRELLIS2-GGUF-x86_64.AppImage --help | head -3
echo "==> Done: ${WORKDIR}/TRELLIS2-GGUF-x86_64.AppImage"
