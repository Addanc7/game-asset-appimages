#!/bin/bash
# Build script for LGM-x86_64.AppImage — reproducible from a clean checkout.
# Run on Ubuntu 22.04/24.04 x86_64. Expects the shared TRELLIS base runtime at
# ~/workspace/build/trellis-appimage/AppDir and appimagetool extracted at
# ~/workspace/build/trellis-appimage/squashfs-root.
set -e
BD=~/workspace/build/appimage-campaign/lgm
BASE=~/workspace/build/trellis-appimage/AppDir
SRC=~/workspace/build/appimage-campaign/src/LGM
AD=$BD/AppDir

echo "== 1. clone upstream =="
mkdir -p ~/workspace/build/appimage-campaign/src
[ -d "$SRC" ] || git clone --depth 1 https://github.com/3DTopia/LGM "$SRC"
git -C "$SRC" rev-parse HEAD

echo "== 2. copy base runtime (hard links; break links before modifying files in place) =="
mkdir -p "$BD"
rm -rf "$AD"
cp -al "$BASE" "$AD" 2>/dev/null || cp -a "$BASE" "$AD"

export LD_LIBRARY_PATH=$AD/usr/lib
PY=$AD/usr/bin/python3.11

echo "== 3. bootstrap pip =="
rm -rf $AD/usr/lib/python3.11/site-packages/pip-*.dist-info
$PY -m ensurepip --default-pip
$PY -m pip --version

echo "== 4. install LGM python deps (third-party only; torch stack comes from base) =="
export TMPDIR=$BD/tmp && mkdir -p $TMPDIR
$PY -m pip install --no-input tyro kiui roma accelerate lpips einops scikit-image pygltflib \
  "diffusers==0.31.0" "transformers==4.44.2"
# NOTE: diffusers/transformers pinned — newer releases require torch>=2.5,
# but the base runtime pins torch 2.4.0+cu121.

echo "== 5. patch broken kiui 0.3.5 typing stub =="
python3 - "$AD" <<'EOF'
import sys
ad = sys.argv[1]
p = f"{ad}/usr/lib/python3.11/site-packages/kiui/typing.py"
open(p, "w").write('''# ref: https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html
# Patched: kiui 0.3.5 ships an empty typing.py stub.
from typing import Any, Callable, Dict, List, Literal, Optional, Sequence, Tuple, Union
from pathlib import Path
from torch import Tensor
from numpy import ndarray
__all__ = ["Any","Callable","Dict","List","Literal","Optional","Path","Sequence",
           "Tuple","Union","Tensor","ndarray"]
''')
print("patched", p)
EOF

echo "== 6. copy LGM source =="
mkdir -p $AD/usr/share/lgm
cp -r "$SRC/core" "$SRC/mvdream" "$SRC/infer.py" "$SRC/convert.py" "$SRC/LICENSE" $AD/usr/share/lgm/
find $AD/usr/share/lgm -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "== 7. install launcher (lgm_app.py), AppRun, lgm.desktop, icon =="
cp ~/workspace/build/appimage-campaign/github-staging/lgm/appdir/lgm_app.py $AD/usr/share/lgm/
cp ~/workspace/build/appimage-campaign/github-staging/lgm/appdir/AppRun $AD/AppRun
cp ~/workspace/build/appimage-campaign/github-staging/lgm/appdir/lgm.desktop $AD/lgm.desktop
$PY -c "
from PIL import Image, ImageDraw
img = Image.new('RGBA', (256, 256), (18, 20, 34, 255))
d = ImageDraw.Draw(img)
for c, r in [((90,140,255),110), ((140,180,255),80), ((200,220,255),50)]:
    d.ellipse([128-r, 128-r, 128+r, 128+r], outline=c, width=10)
d.ellipse([118, 118, 138, 138], fill=(255,255,255,255))
img.save('$AD/lgm.png')"
ln -sf lgm.png $AD/.DirIcon
chmod +x $AD/AppRun
rm -f $AD/trellis.desktop $AD/trellis.png
rm -rf $AD/usr/share/trellis

echo "== 8. smoke test =="
$AD/AppRun --help | head -12
$AD/AppRun lrm --help | head -8

echo "== 9. cleanup =="
SP=$AD/usr/lib/python3.11/site-packages
rm -rf $SP/trellis $SP/trellis-*.dist-info $SP/pip $SP/pip-*.dist-info \
  $SP/setuptools* $SP/wheel* $SP/packaging* $SP/_distutils_hack $SP/distutils-precedence.pth \
  $AD/usr/bin/pip* 2>/dev/null || true
find $SP $AD/usr/share/lgm -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find $SP/nvidia -name "include" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf $BD/tmp

echo "== 10. build AppImage =="
cd "$BD" && rm -f LGM-x86_64.AppImage
export TMPDIR=$BD
~/workspace/build/trellis-appimage/squashfs-root/AppRun "$AD" LGM-x86_64.AppImage --comp zstd
chmod +x LGM-x86_64.AppImage
ls -lh LGM-x86_64.AppImage
echo "BUILD DONE"
