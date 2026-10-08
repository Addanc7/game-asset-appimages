#!/usr/bin/env python3
"""Dora AppImage launcher: first-run weight download + CLI passthrough to dora_infer.py."""
import os
import runpy
import sys

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "dora")

DATA = os.environ.get("DORA_DATA",
                      os.path.join(os.path.expanduser("~"), ".local", "share", "dora-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["HUGGINGFACE_HUB_CACHE"] = os.path.join(os.environ["HF_HOME"], "hub")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

REPO_ID = "Seed3D/Dora-VAE-1.1"
CKPT = os.path.join(MODELS, "dora_vae_1_1.ckpt")

USAGE = """Dora AppImage — Dora-VAE shape autoencoder (mesh round-trip demo).

Dora-VAE encodes a 3D mesh into compact shape latents and decodes it back.
This AppImage runs a single-mesh encode->decode round trip.

Usage:
  Dora-x86_64.AppImage --download-weights
      Download Dora-VAE-1.1 checkpoint (~1.5GB, resumable) to
      ~/.local/share/dora-appimage/models/

  Dora-x86_64.AppImage --input mesh.obj --output recon.obj [opts...]
      Round-trip a mesh through Dora-VAE. Options:
      --points 32768        surface samples
      --octree_depth 8      marching-cubes grid depth (7=fast, 9=fine)
      --device cuda|cpu

  Dora-x86_64.AppImage --help   show this help
"""


def ensure_weights():
    from huggingface_hub import snapshot_download
    if os.path.exists(CKPT) and os.path.getsize(CKPT) > 500_000_000:
        return
    print(f"[Dora] Downloading {REPO_ID} — resumable ...", flush=True)
    d = snapshot_download(repo_id=REPO_ID, local_dir=os.path.join(MODELS, "Dora-VAE-1.1"),
                          resume_download=True)
    # find the .ckpt inside
    for root, _, files in os.walk(d):
        for fn in files:
            if fn.endswith(".ckpt"):
                src = os.path.join(root, fn)
                if os.path.abspath(src) != os.path.abspath(CKPT):
                    os.replace(src, CKPT)
                print("[Dora] Weights ready.", flush=True)
                return
    raise RuntimeError("checkpoint .ckpt not found in downloaded snapshot")


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
        args = ["--ckpt", CKPT] + args
    sys.argv = [os.path.join(SHARE, "dora_infer.py")] + args
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, "dora_infer.py"), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
