#!/bin/bash
# Build Direct3D-x86_64.AppImage from source.
# Reproducible from a clean checkout. Run on x86_64 Linux.
#
# Prerequisites (one-time):
#   - Base runtime AppDir: portable CPython 3.11.9 + torch 2.4.0+cu121,
#     produced by the TRELLIS AppImage build. Expected at $BASE_APPIMG.
#   - appimagetool (extracted squashfs-root/AppRun works too).
set -e

COMMIT=e786532fb4ed4564fe352c67267f1728c92c9da6
WORK=~/workspace/build/appimage-campaign/direct3d
BASE_APPIMG=~/workspace/build/trellis-appimage/AppDir
APPIMAGETOOL=~/workspace/build/trellis-appimage/squashfs-root/AppRun

# 1. Source (pinned commit, Apache-2.0 verified in LICENSE)
rm -rf "$WORK/src"
git clone https://github.com/DreamTechAI/Direct3D "$WORK/src"
git -C "$WORK/src" checkout "$COMMIT"

# 2. Fresh AppDir from the base runtime
rm -rf "$WORK/AppDir"
rsync -a --no-owner --no-group "$BASE_APPIMG/" "$WORK/AppDir/"
AD="$WORK/AppDir"
SP="$AD/usr/lib/python3.11/site-packages"
export LD_LIBRARY_PATH="$AD/usr/lib"
export TMPDIR="$WORK/tmp" && mkdir -p "$TMPDIR"
PY="$AD/usr/bin/python3.11"

# 3. Bootstrap pip (the base runtime ships without the pip module)
curl -sL -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
"$PY" /tmp/get-pip.py
"$PY" -m pip install --no-input "setuptools==80.9.0"

# 4. Direct3D Python deps (third-party; tool itself is pure Python)
"$PY" -m pip install --no-input \
  einops "transformers==4.40.2" diffusers omegaconf

# 5. Install the tool package FROM SOURCE.
# NOTE: `pip install --no-deps --no-build-isolation .` built an empty wheel
# (RECORD held only dist-info), so copy the pure-Python package tree
# directly from the source instead.
rm -rf "$SP/direct3d" "$SP/direct3d-1.0.0.dist-info"
cp -r "$WORK/src/direct3d" "$SP/"
find "$SP/direct3d" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# 6. Launcher + a copy of the source tree for reference
mkdir -p "$AD/usr/share/direct3d"
cp -r "$WORK/src" "$AD/usr/share/direct3d/src"
rm -rf "$AD/usr/share/direct3d/src/.git"
cp "$WORK/direct3d_app.py" "$AD/usr/share/direct3d/"

# 7. Drop TRELLIS-only leftovers from the reused runtime
rm -rf "$SP/trellis" "$AD/usr/share/trellis" "$AD/trellis.desktop" "$AD/trellis.png"
for d in spconv spconv_cu120.libs spconv_cu120-2.3.6.dist-info \
         vtkmodules vtk-9.7.1.dist-info pyvista pyvista_validation \
         pyvista-0.49.0.dist-info pyvista_validation-0.2.2.dist-info \
         diff_gaussian_rasterization diff_gaussian_rasterization-0.0.0.dist-info \
         cumm cumm_cu120.libs cumm_cu120-0.4.11.dist-info pccm pccm-0.4.16.dist-info \
         gradio_litmodel3d gradio_litmodel3d-0.0.1.dist-info \
         utils3d utils3d-0.0.2.dist-info triton triton-3.0.0.dist-info \
         pymeshfix pymeshfix-0.18.1.dist-info igraph igraph-1.0.0.dist-info igraph.libs \
         kaolin moderngl moderngl-5.12.0.dist-info moderngl-stubs \
         glcontext glcontext-3.0.0.dist-info \
         _nvdiffrast_c.cpython-311-x86_64-linux-gnu.so nvdiffrast nvdiffrast-0.4.0.dist-info \
         xatlas xatlas-0.0.11.dist-info \
         pip wheel pip-26.2.1.dist-info wheel-0.48.0.dist-info; do
  rm -rf "$SP/$d"
done
find "$SP/nvidia" -name include -type d -exec rm -rf {} + 2>/dev/null || true
find "$SP" "$AD/usr/share/direct3d" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# 8. AppRun + .desktop + icon
python3 ~/workspace/build/appimage-campaign/mk_appmeta.py \
  direct3d Direct3D direct3d_app.py DIRECT3D_DATA \
  '~/.local/share/direct3d-app' \
  "Single-image to 3D mesh via DiT (DreamTechAI)" 0f7b6c

# 9. Smoke test, then package
env -u no_proxy -u NO_PROXY "$AD/AppRun" --help
cd "$WORK" && rm -f Direct3D-x86_64.AppImage
"$APPIMAGETOOL" "$AD" Direct3D-x86_64.AppImage
ls -lh Direct3D-x86_64.AppImage
