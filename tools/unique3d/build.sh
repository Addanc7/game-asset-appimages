#!/bin/bash
# Build Unique3D-x86_64.AppImage from source.
# Reproducible from a clean checkout. Run on x86_64 Linux.
#
# Prerequisites (one-time):
#   - Base runtime AppDir: portable CPython 3.11.9 + torch 2.4.0+cu121,
#     produced by the TRELLIS AppImage build. Expected at $BASE_APPIMG.
#   - appimagetool (extracted squashfs-root/AppRun works too).
#   - No nvcc needed: compiled deps come from their official binary channels
#     (conda/PyG wheels), exactly as upstream's Installation.md recommends.
set -e

COMMIT=6311af200ee197544e82e0f2557cd890edd60416
WORK=~/workspace/build/appimage-campaign/unique3d
BASE_APPIMG=~/workspace/build/trellis-appimage/AppDir
APPIMAGETOOL=~/workspace/build/trellis-appimage/squashfs-root/AppRun

# 1. Source (pinned commit, MIT verified in LICENSE)
rm -rf "$WORK/src"
git clone https://github.com/AiuniAI/Unique3D "$WORK/src"
git -C "$WORK/src" checkout "$COMMIT"

# 2. Source patches (see NOTES.md for rationale)
# 2a. Drop TensorrtExecutionProvider (no TensorRT in the AppImage)
python3 - "$WORK" <<'PYEOF'
import sys
work = sys.argv[1]
p = f"{work}/src/scripts/load_onnx.py"
s = open(p).read()
old = """providers = [
    ('TensorrtExecutionProvider', {
        'device_id': 0,
        'trt_max_workspace_size': 8 * 1024 * 1024 * 1024,
        'trt_fp16_enable': True,
        'trt_engine_cache_enable': True,
    }),
    ('CUDAExecutionProvider', {"""
new = """# NOTE (AppImage port): TensorrtExecutionProvider removed (no TensorRT bundled).
providers = [
    ('CUDAExecutionProvider', {"""
assert old in s
open(p, "w").write(s.replace(old, new))
print("patched load_onnx.py")
PYEOF
# 2b. CPU fallback for the rembg session (CUDA EP segfaults without a GPU)
python3 - "$WORK" <<'PYEOF'
import sys
work = sys.argv[1]
p = f"{work}/src/scripts/utils.py"
s = open(p).read()
old = "session = new_session(providers=providers)"
new = """# NOTE (AppImage port): CPU fallback when no NVIDIA GPU is present.
if not torch.cuda.is_available():
    providers = ['CPUExecutionProvider']

session = new_session(providers=providers)"""
assert old in s
open(p, "w").write(s.replace(old, new))
print("patched scripts/utils.py")
PYEOF

# 3. Fresh AppDir from the base runtime
rm -rf "$WORK/AppDir"
rsync -a --no-owner --no-group "$BASE_APPIMG/" "$WORK/AppDir/"
AD="$WORK/AppDir"
SP="$AD/usr/lib/python3.11/site-packages"
export LD_LIBRARY_PATH="$AD/usr/lib"
export TMPDIR="$WORK/tmp" && mkdir -p "$TMPDIR"
PY="$AD/usr/bin/python3.11"

# 4. Bootstrap pip (the base runtime ships without the pip module)
curl -sL -o /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
"$PY" /tmp/get-pip.py
"$PY" -m pip install --no-input "setuptools==80.9.0"   # pkg_resources for some imports

# 5. Unique3D Python deps (third-party; tool itself is pure Python)
"$PY" -m pip install --no-input \
  diffusers transformers accelerate omegaconf fire jaxtyping peft \
  pygltflib pymeshlab typeguard datasets wandb
# onnxruntime: CPU one from the base must go; use the CUDA-12 GPU build.
# NOTE: 1.22.0 is the newest PyPI build still linked against CUDA 12
# (1.30.x wants libcublasLt.so.13); 1.17.0 (upstream's pick) is NumPy-1-only.
"$PY" -m pip uninstall --no-input -y onnxruntime
"$PY" -m pip install --no-input "onnxruntime-gpu==1.22.0" \
  --extra-index-url https://aiinfra.pkgs.visualstudio.com/PublicPackages/_packaging/onnxruntime-cuda-12/pypi/simple/
# torch-scatter: PyG wheel for torch 2.4.0 + cu121
"$PY" -m pip install --no-input torch-scatter \
  -f https://data.pyg.org/whl/torch-2.4.0+cu121.html
# pytorch3d: official conda channel, py311 + cu121 + torch 2.4.0
cd /tmp && rm -rf p3d && mkdir p3d && cd p3d
curl -sL -o p3d.tar.bz2 "https://api.anaconda.org/download/pytorch3d/pytorch3d/0.7.8/linux-64/pytorch3d-0.7.8-py311_cu121_pyt240.tar.bz2"
tar xjf p3d.tar.bz2 lib/python3.11/site-packages/pytorch3d \
  lib/python3.11/site-packages/pytorch3d-0.7.8-py3.11.egg-info
cp -r lib/python3.11/site-packages/pytorch3d \
      lib/python3.11/site-packages/pytorch3d-0.7.8-py3.11.egg-info "$SP/"

# 6. Install tool source + launcher into the AppDir
mkdir -p "$AD/usr/share/unique3d"
cp -r "$WORK/src" "$AD/usr/share/unique3d/src"
rm -rf "$AD/usr/share/unique3d/src/.git"
cp "$WORK/unique3d_app.py" "$AD/usr/share/unique3d/"

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
         glcontext glcontext-3.0.0.dist-info imageio_ffmpeg imageio_ffmpeg-0.6.0.dist-info \
         pip wheel pip-26.2.1.dist-info wheel-0.48.0.dist-info; do
  rm -rf "$SP/$d"
done
find "$SP/nvidia" -name include -type d -exec rm -rf {} + 2>/dev/null || true
find "$SP" "$AD/usr/share/unique3d" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true

# 8. AppRun + .desktop + icon (AppRun adds bundled nvidia/*/lib to
#    LD_LIBRARY_PATH for onnxruntime's CUDA provider, which has no RPATH)
python3 ~/workspace/build/appimage-campaign/mk_appmeta.py \
  unique3d Unique3D unique3d_app.py UNIQUE3D_DATA \
  '~/.local/share/unique3d-app' \
  "Single-image to textured 3D mesh (AiuniAI)" 7c3aed
# (then patch the generated AppRun's LD_LIBRARY_PATH block to add the
# nvidia lib dirs loop — see the template in mk_appmeta.py)

# 9. Smoke test, then package
env -u no_proxy -u NO_PROXY "$AD/AppRun" --help
cd "$WORK" && rm -f Unique3D-x86_64.AppImage
"$APPIMAGETOOL" "$AD" Unique3D-x86_64.AppImage
ls -lh Unique3D-x86_64.AppImage
