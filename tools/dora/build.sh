#!/bin/bash
# Build script for Dora-x86_64.AppImage — reproducible from a clean checkout.
# Run on Ubuntu 22.04/24.04 x86_64. Expects the shared TRELLIS base runtime at
# ~/workspace/build/trellis-appimage/AppDir and appimagetool extracted at
# ~/workspace/build/trellis-appimage/squashfs-root.
set -e
BD=~/workspace/build/appimage-campaign/dora
BASE=~/workspace/build/trellis-appimage/AppDir
SRC=~/workspace/build/appimage-campaign/src/Dora
AD=$BD/AppDir

echo "== 1. clone upstream =="
mkdir -p ~/workspace/build/appimage-campaign/src
[ -d "$SRC" ] || git clone --depth 1 https://github.com/Seed3D/Dora "$SRC"
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

echo "== 4. install Dora python deps =="
export TMPDIR=$BD/tmp && mkdir -p $TMPDIR
$PY -m pip install --no-input "diffusers==0.31.0" "transformers==4.40.1" \
  einops omegaconf jaxtyping timm "pytorch-lightning==2.2.4" PyMCubes joblib packaging \
  "setuptools==80.9.0"
$PY -m pip install --no-input torch-cluster \
  -f https://data.pyg.org/whl/torch-2.4.0+cu121.html

echo "== 5. patch slow lightning namespace scan =="
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

echo "== 6. copy Dora source (pytorch_lightning tree) =="
mkdir -p $AD/usr/share/dora
cp -r "$SRC/pytorch_lightning/craftsman" "$SRC/pytorch_lightning/configs" \
      "$SRC/LICENSE" $AD/usr/share/dora/
find $AD/usr/share/dora -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "== 7. patch Dora source for py3.11 / missing optional deps =="
python3 - <<'EOF'
import re
base = "$AD/usr/share/dora".replace("$AD", __import__("os").environ.get("AD", ""))
EOF
# (patches applied inline below; kept explicit for reproducibility)
python3 <<PYEOF
import os
share = os.path.expandvars("$AD/usr/share/dora")
# 7a. diso optional (only needed for extract_geometry_by_diffdmc)
p = os.path.join(share, "craftsman/models/autoencoders/utils.py")
s = open(p).read()
s = s.replace("from diso import DiffDMC, DiffMC",
              "try:\n    from diso import DiffDMC, DiffMC\nexcept ImportError:\n    DiffDMC = DiffMC = None")
s = s.replace("        diffdmc = DiffDMC(dtype=torch.float32).to(latents.device)",
              "        if DiffDMC is None:\n            raise RuntimeError('diso not installed; extract_geometry_by_diffdmc unavailable')\n        diffdmc = DiffDMC(dtype=torch.float32).to(latents.device)")
open(p, "w").write(s)
# 7b. fix py3.12-only f-strings (nested same quotes) in shape_autoencoder.py
p = os.path.join(share, "craftsman/systems/shape_autoencoder.py")
s = open(p).read()
s = s.replace('self.get_save_path(f"it{self.true_global_step}/{os.path.basename(batch[\'uid\'][0])}.replace(".npz","")")',
              'self.get_save_path(f"it{self.true_global_step}/" + os.path.basename(batch[\'uid\'][0]).replace(".npz",""))')
open(p, "w").write(s)
# 7c. wandb optional
p = os.path.join(share, "craftsman/utils/saving.py")
s = open(p).read()
s = s.replace("import wandb", "try:\n    import wandb\nexcept ImportError:\n    wandb = None")
open(p, "w").write(s)
print("source patches applied")
PYEOF

echo "== 8. install launcher scripts, AppRun, desktop, icon =="
STAGE=~/workspace/build/appimage-campaign/github-staging/dora/appdir
cp $STAGE/dora_infer.py $STAGE/dora_app.py $AD/usr/share/dora/
cp $STAGE/AppRun $AD/AppRun
cp $STAGE/dora.desktop $AD/dora.desktop
$PY -c "
from PIL import Image, ImageDraw
img = Image.new('RGBA', (256, 256), (20, 28, 24, 255))
d = ImageDraw.Draw(img)
d.polygon([(40,128),(100,80),(100,110),(150,110),(150,80),(210,128),(150,176),(150,146),(100,146),(100,176)], fill=(120,220,160))
img.save('$AD/dora.png')"
ln -sf dora.png $AD/.DirIcon
chmod +x $AD/AppRun
rm -f $AD/trellis.desktop $AD/trellis.png
rm -rf $AD/usr/share/trellis

echo "== 9. smoke test =="
$AD/AppRun --help | head -6
cd $AD/usr/share/dora && $PY -c "
import sys; sys.path.insert(0, '.')
from craftsman.models.autoencoders.michelangelo_autoencoder import MichelangeloAutoencoder
print('dora imports OK')"

echo "== 10. cleanup =="
rm -rf $SP/pip $SP/pip-*.dist-info $AD/usr/bin/pip* 2>/dev/null || true
# NOTE: setuptools and packaging are KEPT (pytorch_lightning/lightning_utilities need them).
find $SP $AD/usr/share/dora -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
find $SP/nvidia -name "include" -type d -exec rm -rf {} + 2>/dev/null || true
rm -rf $BD/tmp

echo "== 11. build AppImage =="
cd "$BD" && rm -f Dora-x86_64.AppImage
export TMPDIR=$BD
~/workspace/build/trellis-appimage/squashfs-root/AppRun "$AD" Dora-x86_64.AppImage --comp zstd
chmod +x Dora-x86_64.AppImage
ls -lh Dora-x86_64.AppImage
echo "BUILD DONE"
