#!/usr/bin/env python3
"""InstantMesh AppImage entry point.

First run downloads the model weights (one-time, resumable) into
$INSTANTMESH_DATA/models (default ~/.local/share/instantmesh-app):

  1. sudo-ai/zero123plus-v1.2   (~4.3 GB)  - multiview diffusion pipeline
  2. TencentARC/InstantMesh/diffusion_pytorch_model.bin (~3.3 GB) - white-bg UNet
  3. TencentARC/InstantMesh/instant_mesh_large.ckpt      (~1.2 GB) - LRM weights

Then runs the upstream CLI (run.py, unmodified) with 8GB-VRAM-friendly
defaults. GPU inference needs an NVIDIA GPU + CUDA driver.
"""
import argparse
import os
import shutil
import subprocess
import sys

APP_ROOT = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(APP_ROOT, "src")          # upstream repo copy
DATA_DIR = os.environ.get("INSTANTMESH_DATA",
                          os.path.expanduser("~/.local/share/instantmesh-app"))
MODELS_DIR = os.path.join(DATA_DIR, "models")
Z123P_DIR = os.path.join(MODELS_DIR, "zero123plus-v1.2")
UNET_PATH = os.path.join(MODELS_DIR, "diffusion_pytorch_model.bin")
CKPT_PATH = os.path.join(MODELS_DIR, "instant_mesh_large.ckpt")

HF_REPO = "TencentARC/InstantMesh"
Z123P_REPO = "sudo-ai/zero123plus-v1.2"

DEFAULT_CONFIG = os.path.join(SRC_DIR, "configs", "instant-mesh-large.yaml")


def _resume_download(url, dest):
    """curl -C - resume, like the campaign spec requires."""
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    subprocess.run(["curl", "-L", "-C", "-", "--retry", "3",
                    "-o", dest, url], check=True)


def _snapshot(repo_id, local_dir):
    from huggingface_hub import snapshot_download
    if os.path.isdir(local_dir) and os.listdir(local_dir):
        print(f"  already present: {repo_id}")
        return
    print(f"  downloading {repo_id} (resumable, one-time) ...")
    snapshot_download(repo_id=repo_id, local_dir=local_dir,
                      resume_download=True)


def ensure_models():
    print("== InstantMesh first-run setup ==")
    os.makedirs(MODELS_DIR, exist_ok=True)

    # 1. zero123plus pipeline
    _snapshot(Z123P_REPO, Z123P_DIR)

    # 2+3. InstantMesh unet + LRM checkpoint (resumable direct download)
    from huggingface_hub import hf_hub_url
    for filename, dest in (("diffusion_pytorch_model.bin", UNET_PATH),
                           ("instant_mesh_large.ckpt", CKPT_PATH)):
        if os.path.exists(dest) and os.path.getsize(dest) > 0:
            print(f"  already present: {filename}")
            continue
        print(f"  downloading {filename} (resumable, one-time) ...")
        _resume_download(hf_hub_url(HF_REPO, filename, repo_type="model"), dest)
    print("== setup complete ==\n")


def make_config():
    """Render a local config with absolute weight paths."""
    cfg_path = os.path.join(DATA_DIR, "instant-mesh-large-local.yaml")
    with open(DEFAULT_CONFIG) as f:
        text = f.read()
    text = text.replace("ckpts/diffusion_pytorch_model.bin", UNET_PATH)
    text = text.replace("ckpts/instant_mesh_large.ckpt", CKPT_PATH)
    with open(cfg_path, "w") as f:
        f.write(text)
    return cfg_path


def main(argv=None):
    p = argparse.ArgumentParser(
        description="InstantMesh: single image -> 3D mesh (OBJ). "
                    "First run downloads ~9GB of weights (one-time).")
    p.add_argument("input", help="Input image (png/jpg/webp) or directory.")
    p.add_argument("-o", "--output", default="instantmesh_outputs",
                   help="Output directory (default: instantmesh_outputs).")
    p.add_argument("--steps", type=int, default=50,
                   help="Diffusion sampling steps (default 50; upstream default 75).")
    p.add_argument("--seed", type=int, default=42)
    p.add_argument("--scale", type=float, default=1.0)
    p.add_argument("--view", type=int, default=6, choices=[4, 6])
    p.add_argument("--no_rembg", action="store_true")
    p.add_argument("--export_texmap", action="store_true",
                   help="Export mesh with texture map (needs more VRAM).")
    p.add_argument("--save_video", action="store_true")
    p.add_argument("--skip_download", action="store_true",
                   help="Skip the first-run weight download (weights already present).")
    args = p.parse_args(argv)

    if not args.skip_download:
        ensure_models()
    cfg = make_config()

    cmd = [sys.executable, os.path.join(SRC_DIR, "run.py"), cfg, args.input,
           "--output_path", args.output,
           "--diffusion_steps", str(args.steps),
           "--seed", str(args.seed),
           "--scale", str(args.scale),
           "--view", str(args.view)]
    if args.no_rembg:
        cmd.append("--no_rembg")
    if args.export_texmap:
        cmd.append("--export_texmap")
    if args.save_video:
        cmd.append("--save_video")

    # run.py expects to be run from the repo root (relative asset paths)
    os.chdir(SRC_DIR)
    print("Running:", " ".join(cmd), "\n")
    os.execv(cmd[0], cmd)


if __name__ == "__main__":
    main()
