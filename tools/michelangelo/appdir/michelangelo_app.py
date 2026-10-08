#!/usr/bin/env python3
"""Michelangelo AppImage launcher: first-run weight download + CLI passthrough."""
import os
import runpy
import sys

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "michelangelo")

DATA = os.environ.get("MICHELANGELO_DATA",
                      os.path.join(os.path.expanduser("~"), ".local", "share", "michelangelo-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["HUGGINGFACE_HUB_CACHE"] = os.path.join(os.environ["HF_HOME"], "hub")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

# Michelangelo checkpoints (from the repo README / HF)
CKPTS = {
    "tsal": ("NeuralCarver/michelangelo", "tsal-epoch=021.ckpt"),
}

USAGE = """Michelangelo AppImage — text/image/pointcloud to 3D mesh (GPL-3.0).

Usage:
  Michelangelo-x86_64.AppImage --download-weights
      Download checkpoints (~2GB, resumable) to ~/.local/share/michelangelo-appimage/models/

  Michelangelo-x86_64.AppImage --task image2mesh --image_path img.png --output_dir ./out [opts...]
  Michelangelo-x86_64.AppImage --task text2mesh --text "A 3D model of a chair" --output_dir ./out
  Michelangelo-x86_64.AppImage --task reconstruction --pointcloud_path pc.npz --output_dir ./out

  Full options: --config_path, --ckpt_path, --seed (see inference.py --help)

  Michelangelo-x86_64.AppImage --help   show this help
"""


def ensure_weights():
    from huggingface_hub import hf_hub_download
    for name, (repo, fn) in CKPTS.items():
        dest = os.path.join(MODELS, fn)
        if os.path.exists(dest) and os.path.getsize(dest) > 100_000_000:
            continue
        print(f"[Michelangelo] Downloading {repo}/{fn} ...", flush=True)
        p = hf_hub_download(repo_id=repo, filename=fn, local_dir=MODELS,
                            resume_download=True)
        print(f"[Michelangelo] -> {p}", flush=True)


def main():
    args = list(sys.argv[1:])
    if not args or args == ["--help"] or args == ["-h"]:
        print(USAGE)
        return 0
    if "--download-weights" in args:
        ensure_weights()
        return 0
    # passthrough to upstream inference.py (it has its own --help)
    if "--ckpt_path" not in args:
        # default to the downloaded tsal checkpoint if present
        default_ckpt = os.path.join(MODELS, CKPTS["tsal"][1])
        if os.path.exists(default_ckpt):
            args = ["--ckpt_path", default_ckpt] + args
    if "--config_path" not in args:
        default_cfg = os.path.join(SHARE, "configs", "tsal.yaml")
        if os.path.exists(default_cfg):
            args = ["--config_path", default_cfg] + args
    sys.argv = [os.path.join(SHARE, "inference.py")] + args
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, "inference.py"), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
