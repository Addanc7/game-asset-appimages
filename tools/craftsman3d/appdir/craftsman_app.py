#!/usr/bin/env python3
"""CraftsMan3D AppImage launcher: first-run weight download + CLI passthrough."""
import os
import runpy
import sys

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "craftsman3d")

DATA = os.environ.get("CRAFTSMAN_DATA",
                      os.path.join(os.path.expanduser("~"), ".local", "share", "craftsman3d-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["HUGGINGFACE_HUB_CACHE"] = os.path.join(os.environ["HF_HOME"], "hub")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

REPO_ID = "craftsman3d/craftsman-DoraVAE"
CKPT_DIR = os.path.join(MODELS, "craftsman-DoraVAE")

USAGE = """CraftsMan3D AppImage — single image to 3D mesh (with Dora-VAE).

Usage:
  CraftsMan3D-x86_64.AppImage --download-weights
      Download CraftsMan-DoraVAE weights (~2-3GB, resumable) to
      ~/.local/share/craftsman3d-appimage/models/

  CraftsMan3D-x86_64.AppImage --input img.png --output mesh.glb [opts...]
      Generate a 3D mesh. Options:
      --steps 50 --guidance 7.5 --seed 42 --mc_depth 8 --device cuda

  CraftsMan3D-x86_64.AppImage --help   show this help

Note: texture generation is not included; the authors recommend Hunyuan3D-2 for texturing.
"""


def ensure_weights():
    from huggingface_hub import snapshot_download
    if os.path.isdir(CKPT_DIR) and any(os.scandir(CKPT_DIR)):
        return
    print(f"[CraftsMan3D] Downloading {REPO_ID} — resumable ...", flush=True)
    snapshot_download(repo_id=REPO_ID, local_dir=CKPT_DIR, resume_download=True)
    print("[CraftsMan3D] Weights ready.", flush=True)


def main():
    args = list(sys.argv[1:])
    if not args or args[0] in ("--help", "-h"):
        print(USAGE)
        return 0
    if "--download-weights" in args:
        ensure_weights()
        return 0
    if not any(a in ("--help", "-h") for a in args):
        ensure_weights()
    if "--ckpt" not in args and not any(a.startswith("--ckpt=") for a in args):
        args = ["--ckpt", CKPT_DIR] + args
    sys.argv = [os.path.join(SHARE, "craftsman_infer.py")] + args
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, "craftsman_infer.py"), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
