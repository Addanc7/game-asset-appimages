#!/bin/bash
# Build script for Era3D-x86_64.AppImage — reproducible from a clean checkout.
# Run on Ubuntu 22.04/24.04 x86_64. Expects the shared TRELLIS base runtime at
# ~/workspace/build/trellis-appimage/AppDir and appimagetool extracted at
# ~/workspace/build/trellis-appimage/squashfs-root.
# NOTE: tiny-cuda-nn / instant-nsr-pl reconstruction is NOT bundled (see NOTES.md:
# nvcc OOM in the build VM). This script builds the multiview-diffusion AppImage.
set -e
BD=~/workspace/build/appimage-campaign/era3d
BASE=~/workspace/build/trellis-appimage/AppDir
SRC=~/workspace/build/appimage-campaign/src/Era3D
AD=$BD/AppDir

echo "== 1. clone upstream =="
mkdir -p ~/workspace/build/appimage-campaign/src
[ -d "$SRC" ] || git clone --depth 1 https://github.com/pengHTYX/Era3D "$SRC"
git -C "$SRC" rev-parse HEAD

echo "== 2. copy base runtime =="
mkdir -p "$BD"
rm -rf "$AD"
cp -al "$BASE" "$AD" 2>/dev/null || cp -a "$BASE" "$AD"

export LD_LIBRARY_PATH=$AD/usr/lib
PY=$AD/usr/bin/python3.11

echo "== 3. bootstrap pip =="
rm -rf $AD/usr/lib/python3.11/site-packages/pip-*.dist-info
$PY -m ensurepip --default-pip

echo "== 4. install Era3D python deps =="
export TMPDIR=$BD/tmp && mkdir -p $TMPDIR
$PY -m pip install --no-input "diffusers==0.26.0" "transformers==4.37.2" \
  "huggingface_hub==0.20.3" accelerate omegaconf einops icecream kornia \
  "nerfacc==0.3.3" PyMCubes pyransac3d
# Pins: diffusers 0.26 needs hub<=0.20 (cached_download); newer diffusers/transformers
# need torch>=2.5 but the base pins torch 2.4.0+cu121.

echo "== 5. copy Era3D source =="
mkdir -p $AD/usr/share/era3d
cp -r "$SRC/test_mvdiffusion_unclip.py" "$SRC/configs" "$SRC/mvdiffusion" "$SRC/utils" \
      "$SRC/LICENCE" "$SRC/examples" $AD/usr/share/era3d/
find $AD/usr/share/era3d -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "== 6. install launcher (era3d_app.py), AppRun, era3d.desktop, icon =="
STAGE=~/workspace/build/appimage-campaign/github-staging/era3d/appdir
cp $STAGE/era3d_app.py $AD/usr/share/era3d/
cp $STAGE/AppRun $AD/AppRun
cp $STAGE/era3d.desktop $AD/era3d.desktop
$PY -c "
from PIL import Image, ImageDraw
import math
img = Image.new('RGBA', (256, 256), (24, 18, 40, 255))
d = ImageDraw.Draw(img)
for k in range(6):
    a = math.pi/3*k - math.pi/2
    x, y = 128+78*math.cos(a), 128+78*math.sin(a)
    d.ellipse([x-26, y-26, x+26, y+26], outline=(150,110,255), width=7)
d.ellipse([108, 108, 148, 148], fill=(230,220,255,255))
img.save('$AD/era3d.png')"
ln -sf era3d.png $AD/.DirIcon
chmod +x $AD/AppRun
rm -f $AD/trellis.desktop $AD/trellis.png
rm -rf $AD/usr/share/trellis

echo "== 7. smoke test =="
$AD/AppRun --help | head -6
$PY -c "
import sys; sys.path.insert(0, '$AD/usr/share/era3d')
from mvdiffusion.pipelines.pipeline_mvdiffusion_unclip import StableUnCLIPImg2ImgPipeline
print('imports OK')"

echo "== 8. cleanup =="
SP=$AD/usr/lib/python3.11/site-packages
rm -rf $SP/trellis $SP/trellis-*.dist-info $SP/pip $SP/pip-*.dist-info \
  $SP/setuptools* $SP/wheel* $SP/packaging* $SP/_distutils_hack $SP/distutils-precedence.pth \
  $AD/usr/bin/pip* 2>/dev/null || true
find $SP $AD/usr/share/era3d -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find $SP/nvidia -name "include" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf $BD/tmp

echo "== 9. build AppImage =="
cd "$BD" && rm -f Era3D-x86_64.AppImage
export TMPDIR=$BD
~/workspace/build/trellis-appimage/squashfs-root/AppRun "$AD" Era3D-x86_64.AppImage --comp zstd
chmod +x Era3D-x86_64.AppImage
ls -lh Era3D-x86_64.AppImage
echo "BUILD DONE"
