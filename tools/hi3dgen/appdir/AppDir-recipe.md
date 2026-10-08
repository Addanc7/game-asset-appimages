# Hi3DGen AppDir recipe

Base: portable CPython 3.11.9 + torch 2.4.0+cu121 runtime from the TRELLIS
AppImage build (`trellis-appimage/AppDir`), copied with
`rsync -a --no-owner --no-group`.

Layout additions:
- `AppRun` — launcher (env setup, data dirs, execs the Python entry point)
- `hi3dgen-app.desktop` / `hi3dgen-app.png` / `.DirIcon`
- `usr/share/hi3dgen/src/` — upstream Hi3DGen repo at the pinned commit
  (`.git` removed)
- `usr/share/hi3dgen/stn-src/` — StableNormal repo (Apache-2.0), loaded via
  `torch.hub` with `source='local'` so no GitHub fetch happens at runtime
- `usr/share/hi3dgen/hi3dgen_app.py` — first-run weight downloader + CLI
  (mirrors the upstream Gradio `generate_3d` flow)

Extra pip installs into `usr/lib/python3.11/site-packages` (see build.sh):
diffusers>=0.28.0, accelerate, kornia==0.8.0, timm==0.6.7,
transformers==4.46.3, einops, setuptools==80.9.0.

Removed from the reused runtime (TRELLIS-only): the `trellis` package,
`usr/share/trellis`, vtk/pyvista, diff_gaussian_rasterization, cumm, pccm,
gradio_litmodel3d, utils3d, triton, pymeshfix, igraph, kaolin, moderngl,
glcontext, nvdiffrast, pip/wheel modules, nvidia `include/` dirs,
all `__pycache__`. (spconv is KEPT — Hi3DGen's sparse backend needs it.)
