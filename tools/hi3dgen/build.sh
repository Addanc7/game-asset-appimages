#!/bin/bash
# Build Hi3DGen-x86_64.AppImage from source.
# Reproducible from a clean checkout. Run on x86_64 Linux.
#
# Prerequisites (one-time):
#   - Base runtime AppDir: portable CPython 3.11.9 + torch 2.4.0+cu121,
#     produced by the TRELLIS AppImage build. Expected at $BASE_APPIMG.
#   - appimagetool (extracted squashfs-root/AppRun works too).
set -e

COMMIT=c29f668ecec44b197275e9bf77f823c0c8a21076
STN_COMMIT=HEAD  # hugoycj/StableNormal, Apache-2.0 (bundled for torch.hub local load)
WORK=~/workspace/build/appimage-campaign/hi3dgen
BASE_APPIMG=~/workspace/build/trellis-appimage/AppDir
APPIMAGETOOL=~/workspace/build/trellis-appimage/squashfs-root/AppRun

# 1. Sources (pinned commits; MIT / Apache-2.0 verified in LICENSE files)
rm -rf "$WORK/src"
git clone https://github.com/Stable-X/Hi3DGen "$WORK/src"
git -C "$WORK/src" checkout "$COMMIT"
rm -rf "$WORK/stn-src"
git clone --depth 1 https://github.com/hugoycj/StableNormal "$WORK/stn-src"

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

# 4. Hi3DGen Python deps (third-party; tool itself is pure Python)
# NOTE: numpy stays at 2.4.6 (base) despite requirements pinning 1.26.4 —
# downgrading breaks opencv/rembg; kornia 0.8.0 / timm 0.6.7 import cleanly
# against numpy 2.
"$PY" -m pip install --no-input \
  "diffusers>=0.28.0" accelerate "kornia==0.8.0" "timm==0.6.7" \
  "transformers==4.46.3" einops

# 5. Install tool source + StableNormal source + launcher into the AppDir
mkdir -p "$AD/usr/share/hi3dgen"
cp -r "$WORK/src" "$AD/usr/share/hi3dgen/src"
rm -rf "$AD/usr/share/hi3dgen/src/.git"
cp -r "$WORK/stn-src" "$AD/usr/share/hi3dgen/stn-src"
rm -rf "$AD/usr/share/hi3dgen/stn-src/.git"
cp "$WORK/hi3dgen_app.py" "$AD/usr/share/hi3dgen/"

# 6. Drop TRELLIS-only leftovers from the reused runtime
rm -rf "$SP/trellis" "$AD/usr/share/trellis" "$AD/trellis.desktop" "$AD/trellis.png"
for d in vtkmodules vtk-9.7.1.dist-info pyvista pyvista_validation \
         pyvista-0.49.0.dist-info pyvista_validation-0.2.2.dist-info \
         diff_gaussian_rasterization diff_gaussian_rasterization-0.0.0.dist-info \
         cumm cumm_cu120.libs cumm_cu120-0.4.11.dist-info pccm pccm-0.4.16.dist-info \
         gradio_litmodel3d gradio_litmodel3d-0.0.1.dist-info \
         utils3d utils3d-0.0.2.dist-info triton triton-3.0.0.dist-info \
         pymeshfix pymeshfix-0.18.1.dist-info igraph igraph-1.0.0.dist-info igraph.libs \
         kaolin moderngl moderngl-5.12.0.dist-info moderngl-stubs \
         glcontext glcontext-3.0.0.dist-info \
         _nvdiffrast_c.cpython-311-x86_64-linux-gnu.so nvdiffrast nvdiffrast-0.4.0.dist-info \
         pip wheel pip-26.2.1.dist-info wheel-0.48.0.dist-info; do
  rm -rf "$SP/$d"
done
find "$SP/nvidia" -name include -type d -exec rm -rf {} + 2>/dev/null || true
find "$SP" "$AD/usr/share/hi3dgen" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# 7. AppRun + .desktop + icon
python3 ~/workspace/build/appimage-campaign/mk_appmeta.py \
  hi3dgen Hi3DGen hi3dgen_app.py HI3DGEN_DATA \
  '~/.local/share/hi3dgen-app' \
  "Single-image to 3D geometry (Stable-X)" c026d3

# 8. Smoke test, then package
env -u no_proxy -u NO_PROXY "$AD/AppRun" --help
cd "$WORK" && rm -f Hi3DGen-x86_64.AppImage
"$APPIMAGETOOL" "$AD" Hi3DGen-x86_64.AppImage
ls -lh Hi3DGen-x86_64.AppImage
