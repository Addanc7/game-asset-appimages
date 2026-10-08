# Unique3D AppDir recipe

Base: portable CPython 3.11.9 + torch 2.4.0+cu121 runtime from the TRELLIS
AppImage build (`trellis-appimage/AppDir`), copied with
`rsync -a --no-owner --no-group`.

Layout additions:
- `AppRun` — launcher (env setup incl. bundled `nvidia/*/lib` dirs on
  `LD_LIBRARY_PATH` for onnxruntime's CUDA provider, data dirs, execs Python)
- `unique3d-app.desktop` / `unique3d-app.png` / `.DirIcon`
- `usr/share/unique3d/src/` — upstream Unique3D repo at the pinned commit
  (`.git` removed), with two documented source patches
  (see NOTES.md: load_onnx.py TensorRT removal, scripts/utils.py CPU fallback)
- `usr/share/unique3d/unique3d_app.py` — first-run weight downloader + CLI
  (follows the upstream `generate3dv2` flow without Gradio)

Extra installs into `usr/lib/python3.11/site-packages` (see build.sh):
diffusers, transformers, accelerate, omegaconf, fire, jaxtyping, peft,
pygltflib, pymeshlab, typeguard, datasets, wandb, setuptools==80.9.0,
onnxruntime-gpu==1.22.0 (replacing the base's onnxruntime CPU),
torch-scatter (PyG wheel), pytorch3d 0.7.8 (official conda channel).

Removed from the reused runtime (TRELLIS-only): the `trellis` package,
`usr/share/trellis`, spconv, vtk/pyvista, diff_gaussian_rasterization, cumm,
pccm, gradio_litmodel3d, utils3d, triton, pymeshfix, igraph, kaolin, moderngl,
glcontext, imageio_ffmpeg, pip/wheel modules, nvidia `include/` dirs,
all `__pycache__`.
