#!/usr/bin/env python3
"""SyncDreamer AppImage launcher: first-run weight download + CLI passthrough to generate.py."""
import os
import re
import runpy
import sys
import urllib.request
import zipfile

APPDIR = os.environ.get("APPDIR") or os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", ".."))
SHARE = os.path.join(APPDIR, "usr", "share", "syncdreamer")

DATA = os.environ.get("SYNC_DREAMER_DATA",
                      os.path.join(os.path.expanduser("~"), ".local", "share", "syncdreamer-appimage"))
MODELS = os.path.join(DATA, "models")
os.environ["HF_HOME"] = os.path.join(DATA, "hf")
os.environ["TORCH_HOME"] = os.path.join(DATA, "torch")
os.environ.setdefault("PYTORCH_CUDA_ALLOC_CONF", "expandable_segments:True")
os.environ.setdefault("CUDA_MODULE_LOADING", "LAZY")
os.makedirs(MODELS, exist_ok=True)

# Official checkpoint bundle (ViT-L-14.ckpt + syncdreamer-pretrain.ckpt)
GDRIVE_ID = "1ypyD5WXxAnsWjnHgAfOAGolV0Zd9kpam"
CKPT = os.path.join(MODELS, "syncdreamer-pretrain.ckpt")
VIT_CKPT = os.path.join(MODELS, "ViT-L-14.ckpt")

USAGE = """SyncDreamer AppImage — single image to 16 multiview-consistent images.

Usage:
  SyncDreamer-x86_64.AppImage --download-weights
      Download checkpoints (~3.5GB zip from Google Drive, resumable-ish) to
      ~/.local/share/syncdreamer-appimage/models/

  SyncDreamer-x86_64.AppImage --input img.png --elevation 15 [--output ./out] [opts...]
      Generate 16 views. Options mirror generate.py:
      --sample_num 4 --crop_size -1 --cfg_scale 2.0 --batch_view_num 8
      --seed 6033 --sampler ddim --sample_steps 50
      (lower --batch_view_num / --sample_steps for 8GB VRAM)

  SyncDreamer-x86_64.AppImage --help   show this help
"""


def gdrive_download(file_id, dest):
    """Download a Google Drive file, handling the large-file confirm token."""
    session_opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor())
    url = f"https://drive.google.com/uc?export=download&id={file_id}"
    req = session_opener.open(url)
    # large files return a confirm page; extract confirm token
    data = req.read(2 * 1024 * 1024).decode("utf-8", "ignore")
    m = re.search(r"confirm=([0-9A-Za-z_-]+)", data)
    if m:
        url = f"https://drive.google.com/uc?export=download&confirm={m.group(1)}&id={file_id}"
        req = session_opener.open(url)
    total = 0
    with open(dest, "wb") as f:
        while True:
            chunk = req.read(8 * 1024 * 1024)
            if not chunk:
                break
            f.write(chunk)
            total += len(chunk)
            print(f"\r[SyncDreamer] downloaded {total / 1e9:.2f} GB...", end="", flush=True)
    print()


def ensure_weights():
    if os.path.exists(CKPT) and os.path.getsize(CKPT) > 1_000_000_000:
        return
    zpath = os.path.join(MODELS, "ckpt.zip")
    print("[SyncDreamer] Downloading official checkpoint bundle (~3.5GB)...", flush=True)
    gdrive_download(GDRIVE_ID, zpath)
    print("[SyncDreamer] Extracting...", flush=True)
    with zipfile.ZipFile(zpath) as z:
        for name in z.namelist():
            base = os.path.basename(name)
            if base in ("syncdreamer-pretrain.ckpt", "ViT-L-14.ckpt"):
                with z.open(name) as src, open(os.path.join(MODELS, base), "wb") as dst:
                    dst.write(src.read())
    os.remove(zpath)
    print("[SyncDreamer] Weights ready.", flush=True)


def main():
    args = list(sys.argv[1:])
    if not args or args[0] in ("--help", "-h"):
        print(USAGE)
        return 0
    if "--download-weights" in args:
        ensure_weights()
        return 0
    # allow `--input`/`--elevation` in any position; generate.py parses the rest
    if "--ckpt" not in args and not any(a.startswith("--ckpt=") for a in args):
        if not any(a in ("--help", "-h") for a in args):
            ensure_weights()
        args = ["--ckpt", CKPT] + args
    if "--cfg" not in args and not any(a.startswith("--cfg=") for a in args):
        args = ["--cfg", os.path.join(SHARE, "configs", "syncdreamer.yaml")] + args
    if "--output" not in args and not any(a.startswith("--output=") for a in args):
        args = ["--output", os.path.abspath("syncdreamer_out")] + args
    sys.argv = [os.path.join(SHARE, "generate.py")] + args
    sys.path.insert(0, SHARE)
    runpy.run_path(os.path.join(SHARE, "generate.py"), run_name="__main__")
    return 0


if __name__ == "__main__":
    sys.exit(main())
