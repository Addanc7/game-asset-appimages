#!/usr/bin/env python3
"""Era3D AppImage launcher: first-run weight download + CLI passthrough.

Mode:
  multiview    single image -> 6-view RGB/normal images
(Note: instant-nsr-pl mesh reconstruction is not bundled — tiny-cuda-nn could not
be compiled in this build VM (OOM); the multiview diffusion is the primary CLI.)
"""
import os
import runpy
import sys

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "era3d")

DATA = os.environ.get("ERA3D_DATA",
                      os.path.join(os.path.expanduser("~"), ".local", "share", "era3d-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["HUGGINGFACE_HUB_CACHE"] = os.path.join(os.environ["HF_HOME"], "hub")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

REPO_ID = "pengHTYX/MacLab-Era3D-512-6view"
REPO_DIR = os.path.join(MODELS, "MacLab-Era3D-512-6view")

USAGE = """Era3D AppImage — high-resolution multiview diffusion (single image to 6 views).

Usage:
  Era3D-x86_64.AppImage --download-weights
      Download model weights (~4GB, resumable) to ~/.local/share/era3d-appimage/models/

  Era3D-x86_64.AppImage multiview --input <image-or-dir> [--out <dir>] [overrides...]
      Generate 6-view RGB + normal images. Extra KEY=VALUE args override the
      test config (e.g. seed=600 validation_dataset.crop_size=420 save_mode=rgb).
      ("multiview" may be omitted: --input ... works directly.)

  Era3D-x86_64.AppImage --help   show this help

Note: textured-mesh reconstruction via instant-nsr-pl is not bundled in this
build (tiny-cuda-nn needs a CUDA compile that OOMs in this VM). Use the 6-view
output with your own NeuS/meshing pipeline, or a future tcnn-enabled rebuild.
"""


def ensure_weights():
    from huggingface_hub import snapshot_download
    if os.path.isdir(REPO_DIR) and any(os.scandir(REPO_DIR)):
        return
    print(f"[Era3D] Downloading weights ({REPO_ID}) — resumable, ~4GB ...", flush=True)
    snapshot_download(repo_id=REPO_ID, local_dir=REPO_DIR, resume_download=True)
    print("[Era3D] Weights ready.", flush=True)


def run_multiview(args):
    # parse our own flags, pass the rest as OmegaConf overrides
    input_path = None
    out_dir = os.path.abspath("era3d_out")
    extras = []
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--input" and i + 1 < len(args):
            input_path = args[i + 1]; i += 2
        elif a == "--out" and i + 1 < len(args):
            out_dir = os.path.abspath(args[i + 1]); i += 2
        else:
            extras.append(a); i += 1
    if input_path is None:
        print(USAGE); print("error: multiview needs --input <image-or-dir>"); return 2
    if os.path.isdir(input_path):
        root_dir, crop = os.path.abspath(input_path), None
    else:
        # single image: stage into a temp dir (dataset expects a directory)
        root_dir = os.path.join(DATA, "staging")
        os.makedirs(root_dir, exist_ok=True)
        import shutil
        shutil.copy2(input_path, os.path.join(root_dir, os.path.basename(input_path)))
    ensure_weights()
    cfg = os.path.join(SHARE, "configs", "test_unclip-512-6view.yaml")
    argv = [os.path.join(SHARE, "test_mvdiffusion_unclip.py"),
            "--config", cfg,
            f"pretrained_model_name_or_path={REPO_DIR}",
            f"validation_dataset.root_dir={root_dir}",
            f"save_dir={out_dir}"] + extras
    sys.argv = argv
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, "test_mvdiffusion_unclip.py"), run_name="__main__")
    print(f"[Era3D] Multiview images saved to {out_dir}")
    return 0


def main():
    args = list(sys.argv[1:])
    if not args or args[0] in ("--help", "-h"):
        print(USAGE); return 0
    if "--download-weights" in args:
        ensure_weights(); return 0
    if args[0] == "multiview":
        args = args[1:]
    return run_multiview(args)


if __name__ == "__main__":
    sys.exit(main())
