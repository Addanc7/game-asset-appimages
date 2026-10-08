#!/bin/bash
# Build script for SyncDreamer-x86_64.AppImage — reproducible from a clean checkout.
# Run on Ubuntu 22.04/24.04 x86_64. Expects the shared TRELLIS base runtime at
# ~/workspace/build/trellis-appimage/AppDir and appimagetool extracted at
# ~/workspace/build/trellis-appimage/squashfs-root.
set -e
BD=~/workspace/build/appimage-campaign/syncdreamer
BASE=~/workspace/build/trellis-appimage/AppDir
SRC=~/workspace/build/appimage-campaign/src/SyncDreamer
AD=$BD/AppDir

echo "== 1. clone upstream =="
mkdir -p ~/workspace/build/appimage-campaign/src
[ -d "$SRC" ] || git clone --depth 1 https://github.com/liuyuan-pal/SyncDreamer "$SRC"
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

echo "== 4. install SyncDreamer python deps =="
export TMPDIR=$BD/tmp && mkdir -p $TMPDIR
$PY -m pip install --no-input "pytorch_lightning==1.9.0" taming-transformers-rom1504 \
  webdataset easydict open3d carvekit-colab git+https://github.com/openai/CLIP.git \
  einops kornia "transformers==4.44.2" scikit-image packaging "setuptools==80.9.0"
# setuptools kept: pytorch_lightning needs pkg_resources at import time.

echo "== 5. patch lightning namespace scan (slow on AppImage) =="
SP=$AD/usr/lib/python3.11/site-packages
for f in $SP/lightning_fabric/__init__.py $SP/pytorch_lightning/__init__.py; do
  python3 - "$f" <<'EOF'
import sys
p = sys.argv[1]
s = open(p).read()
s = s.replace('__import__("pkg_resources").declare_namespace(__name__)',
              'pass  # patched: pkg_resources.declare_namespace too slow on AppImage')
open(p, 'w').write(s)
EOF
done

echo "== 6. copy SyncDreamer source =="
mkdir -p $AD/usr/share/syncdreamer
cp -r "$SRC/generate.py" "$SRC/ldm" "$SRC/configs" "$SRC/LICENSE" "$SRC/scripts" \
      $AD/usr/share/syncdreamer/ 2>/dev/null || \
cp -r "$SRC/generate.py" "$SRC/ldm" "$SRC/configs" "$SRC/LICENSE" $AD/usr/share/syncdreamer/
find $AD/usr/share/syncdreamer -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "== 7. install launcher, AppRun, desktop, icon =="
STAGE=~/workspace/build/appimage-campaign/github-staging/syncdreamer/appdir
cp $STAGE/syncdreamer_app.py $AD/usr/share/syncdreamer/
cp $STAGE/AppRun $AD/AppRun
cp $STAGE/syncdreamer.desktop $AD/syncdreamer.desktop
$PY -c "
from PIL import Image, ImageDraw
import math
img = Image.new('RGBA', (256, 256), (28, 20, 44, 255))
d = ImageDraw.Draw(img)
cx, cy = 128, 128
for k in range(16):
    a = 2*math.pi*k/16 - math.pi/2
    x, y = cx+80*math.cos(a), cy+80*math.sin(a)
    r = 16 if k % 4 == 0 else 11
    d.ellipse([x-r, y-r, x+r, y+r], fill=(140,120,255,255))
d.ellipse([cx-22, cy-22, cx+22, cy+22], fill=(240,235,255,255))
img.save('$AD/syncdreamer.png')"
ln -sf syncdreamer.png $AD/.DirIcon
chmod +x $AD/AppRun
rm -f $AD/trellis.desktop $AD/trellis.png
rm -rf $AD/usr/share/trellis

echo "== 8. smoke test =="
$AD/AppRun --help | head -5
$PY $AD/usr/share/syncdreamer/generate.py --help | head -12

echo "== 9. cleanup =="
rm -rf $SP/trellis $SP/trellis-*.dist-info $SP/pip $SP/pip-*.dist-info \
  $AD/usr/bin/pip* 2>/dev/null || true
# NOTE: setuptools and packaging are KEPT (pytorch_lightning/skimage need them).
find $SP $AD/usr/share/syncdreamer -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find $SP/nvidia -name "include" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf $BD/tmp

echo "== 10. build AppImage =="
cd "$BD" && rm -f SyncDreamer-x86_64.AppImage
export TMPDIR=$BD
~/workspace/build/trellis-appimage/squashfs-root/AppRun "$AD" SyncDreamer-x86_64.AppImage --comp zstd
chmod +x SyncDreamer-x86_64.AppImage
ls -lh SyncDreamer-x86_64.AppImage
echo "BUILD DONE"
