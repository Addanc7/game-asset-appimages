# InstantMesh AppDir recipe

Base: portable CPython 3.11.9 + torch 2.4.0+cu121 runtime from the TRELLIS
AppImage build (`trellis-appimage/AppDir`), copied with
`rsync -a --no-owner --no-group`.

Layout additions:
- `AppRun` — launcher (env setup + data dirs, execs the Python entry point)
- `instantmesh-app.desktop` / `instantmesh-app.png` / `.DirIcon`
- `usr/share/instantmesh/src/` — upstream InstantMesh repo at the pinned commit
  (`.git` removed)
- `usr/share/instantmesh/instantmesh_app.py` — first-run weight downloader +
  CLI wrapper (calls upstream `run.py` unchanged via subprocess)

Extra pip installs into `usr/lib/python3.11/site-packages` (see build.sh):
einops, omegaconf, accelerate, PyMCubes, diffusers==0.20.2,
transformers==4.40.2, huggingface-hub==0.24.7, numpy==2.4.6,
pytorch-lightning==2.1.2, webdataset, setuptools==80.9.0.

Removed from the reused runtime (TRELLIS-only): the `trellis` package,
`usr/share/trellis`, spconv, vtk/pyvista, diff_gaussian_rasterization, cumm,
pccm, gradio_litmodel3d, utils3d, triton, pymeshfix, igraph, kaolin stub,
pip/wheel modules, nvidia `include/` dirs, all `__pycache__`.
