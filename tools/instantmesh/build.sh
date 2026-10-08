#!/bin/bash
# Build InstantMesh-x86_64.AppImage from source.
# Reproducible from a clean checkout. Run on x86_64 Linux.
#
# Prerequisites (one-time):
#   - Base runtime AppDir: portable CPython 3.11.9 + torch 2.4.0+cu121,
#     produced by the TRELLIS AppImage build (see trellis-appimage recipe).
#     Expected at $BASE_APPIMG below.
#   - appimagetool (extracted squashfs-root/AppRun works too).
set -e

COMMIT=08822c52fdc399b93ea00e4fa9e596344ed52ccc
WORK=~/workspace/build/appimage-campaign/instantmesh
BASE_APPIMG=~/workspace/build/trellis-appimage/AppDir
APPIMAGETOOL=~/workspace/build/trellis-appimage/squashfs-root/AppRun

# 1. Source (pinned commit, Apache-2.0 verified in LICENSE)
rm -rf "$WORK/src"
git clone https://github.com/TencentARC/InstantMesh "$WORK/src"
git -C "$WORK/src" checkout "$COMMIT"

# 2. Fresh AppDir from the base runtime (no preserved ownership needed)
rm -rf "$WORK/AppDir"
rsync -a --no-owner --no-group "$BASE_APPIMG/" "$WORK/AppDir/"
AD="$WORK/AppDir"
SP="$AD/usr/lib/python3.11/site-packages"
export LD_LIBRARY_PATH="$AD/usr/lib"
PY="$AD/usr/bin/python3.11"

# 3. Bootstrap pip (the base runtime ships without the pip module)
curl -sL -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
"$PY" /tmp/get-pip.py

# 4. InstantMesh Python deps (third-party; tool itself is pure Python)
"$PY" -m pip install --no-input \
  einops omegaconf accelerate PyMCubes \
  "diffusers==0.20.2" "transformers==4.40.2" "huggingface-hub==0.24.7" \
  "numpy==2.4.6" "pytorch-lightning==2.1.2" webdataset "setuptools==80.9.0"
# NOTE: huggingface-hub is pinned to 0.24.7 (not 0.26.x) because
# diffusers 0.20.2 needs the removed-in-0.26 `cached_download` API, while
# accelerate 0.32.1 needs `split_torch_state_dict_into_shards` (>=0.20).
# setuptools<81 keeps pkg_resources, which pytorch_lightning imports.

# 5. Install tool source + launcher into the AppDir
mkdir -p "$AD/usr/share/instantmesh"
cp -r "$WORK/src" "$AD/usr/share/instantmesh/src"
rm -rf "$AD/usr/share/instantmesh/src/.git"
cp "$WORK/instantmesh_app.py" "$AD/usr/share/instantmesh/"

# 6. Drop TRELLIS-only leftovers from the reused runtime
rm -rf "$SP/trellis" "$AD/usr/share/trellis" "$AD/trellis.desktop" "$AD/trellis.png"
for d in spconv spconv_cu120.libs spconv_cu120-2.3.6.dist-info \
         vtkmodules vtk-9.7.1.dist-info pyvista pyvista_validation \
         pyvista-0.49.0.dist-info pyvista_validation-0.2.2.dist-info \
         diff_gaussian_rasterization diff_gaussian_rasterization-0.0.0.dist-info \
         cumm cumm_cu120.libs cumm_cu120-0.4.11.dist-info pccm pccm-0.4.16.dist-info \
         gradio_litmodel3d gradio_litmodel3d-0.0.1.dist-info \
         utils3d utils3d-0.0.2.dist-info triton triton-3.0.0.dist-info \
         pymeshfix pymeshfix-0.18.1.dist-info igraph igraph-1.0.0.dist-info igraph.libs \
         kaolin pip wheel pip-26.2.1.dist-info wheel-0.48.0.dist-info; do
  rm -rf "$SP/$d"
done
find "$SP/nvidia" -name include -type d -exec rm -rf {} + 2>/dev/null || true
find "$SP" "$AD/usr/share/instantmesh" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# 7. AppRun + .desktop + icon
python3 ~/workspace/build/appimage-campaign/mk_appmeta.py \
  instantmesh InstantMesh instantmesh_app.py INSTANTMESH_DATA \
  '~/.local/share/instantmesh-app' \
  "Single-image to 3D mesh (TencentARC)" 2b7de9

# 8. Smoke test, then package
env -u no_proxy -u NO_PROXY "$AD/AppRun" --help
cd "$WORK" && rm -f InstantMesh-x86_64.AppImage
export TMPDIR="$WORK/tmp" && mkdir -p "$TMPDIR"
"$APPIMAGETOOL" "$AD" InstantMesh-x86_64.AppImage
# NOTE: default zstd compression (this appimagetool's mksquashfs only
# supports zstd, not xz).
ls -lh InstantMesh-x86_64.AppImage
