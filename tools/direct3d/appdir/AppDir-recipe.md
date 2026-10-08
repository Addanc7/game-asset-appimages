# Direct3D AppDir recipe

Base: portable CPython 3.11.9 + torch 2.4.0+cu121 runtime from the TRELLIS
AppImage build (`trellis-appimage/AppDir`), copied with
`rsync -a --no-owner --no-group`.

Layout additions:
- `AppRun` — launcher (env setup, data dirs, execs the Python entry point)
- `direct3d-app.desktop` / `direct3d-app.png` / `.DirIcon`
- `usr/lib/python3.11/site-packages/direct3d/` — the tool package, copied
  straight from the repo source tree (pure Python; `pip install .` built an
  empty wheel, so direct copy is used — see NOTES.md)
- `usr/share/direct3d/src/` — upstream Direct3D repo at the pinned commit
  (`.git` removed), for reference
- `usr/share/direct3d/direct3d_app.py` — first-run weight downloader + CLI
  (follows the upstream README example)

Extra pip installs into `usr/lib/python3.11/site-packages` (see build.sh):
einops, transformers==4.40.2, diffusers, omegaconf, setuptools==80.9.0.

Removed from the reused runtime (TRELLIS-only): the `trellis` package,
`usr/share/trellis`, spconv, vtk/pyvista, diff_gaussian_rasterization, cumm,
pccm, gradio_litmodel3d, utils3d, triton, pymeshfix, igraph, kaolin, moderngl,
glcontext, nvdiffrast, xatlas, pip/wheel modules, nvidia `include/` dirs,
all `__pycache__`.
